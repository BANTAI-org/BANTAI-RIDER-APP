import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class PiIdentity {
  const PiIdentity({
    required this.version,
    required this.deviceId,
    required this.bleServiceUuid,
    required this.publicKey,
    required this.keyFingerprint,
  });

  factory PiIdentity.fromJson(Map<String, dynamic> json) {
    return PiIdentity(
      version: json['version'] as int,
      deviceId: json['device_id'] as String,
      bleServiceUuid: json['ble_service_uuid'] as String,
      publicKey: json['public_key'] as String,
      keyFingerprint: json['key_fingerprint'] as String,
    );
  }

  final int version;
  final String deviceId;
  final String bleServiceUuid;
  final String publicKey;
  final String keyFingerprint;

  Map<String, dynamic> toJson() => {
        'version': version,
        'device_id': deviceId,
        'ble_service_uuid': bleServiceUuid,
        'public_key': publicKey,
        'key_fingerprint': keyFingerprint,
      };
}

class HotspotCredentials {
  const HotspotCredentials({
    required this.ssid,
    required this.password,
  });

  final String ssid;
  final String password;

  Map<String, dynamic> toJson() => {
        'ssid': ssid,
        'password': password,
      };
}

class ProvisioningState {
  const ProvisioningState({
    this.status = ProvisioningStatus.idle,
    this.piIdentity,
    this.error,
  });

  final ProvisioningStatus status;
  final PiIdentity? piIdentity;
  final String? error;

  ProvisioningState copyWith({
    ProvisioningStatus? status,
    PiIdentity? piIdentity,
    String? error,
  }) {
    return ProvisioningState(
      status: status ?? this.status,
      piIdentity: piIdentity ?? this.piIdentity,
      error: error,
    );
  }
}

enum ProvisioningStatus {
  idle,
  scanning,
  connecting,
  authenticating,
  sendingCredentials,
  completed,
  error,
}

class ProvisioningService {
  final _x25519 = X25519();
  final _aesGcm = AesGcm.with256bits();

  SimpleKeyPair? _clientKeyPair;
  SecretKey? _sessionKey;
  Uint8List? _transcriptHash;
  PiIdentity? _piIdentity;

  PiIdentity? get piIdentity => _piIdentity;

  Future<PiIdentity?> parseQrCode(String qrData) async {
    try {
      final json = jsonDecode(qrData) as Map<String, dynamic>;
      final identity = PiIdentity.fromJson(json);

      if (identity.version != 1) {
        throw FormatException('Unsupported identity version: ${identity.version}');
      }

      if (!identity.deviceId.startsWith('BANTAI-')) {
        throw FormatException('Invalid device ID format');
      }

      _piIdentity = identity;
      return identity;
    } catch (e) {
      return null;
    }
  }

  Future<String> generateClientHello() async {
    if (_piIdentity == null) {
      throw StateError('No Pi identity available');
    }

    _clientKeyPair = await _x25519.newKeyPair();
    final clientNonce = _generateNonce(32);

    final clientPublic = await _clientKeyPair!.extractPublicKey();
    final clientPublicBytes = Uint8List.fromList(clientPublic.bytes);

    final hello = {
      'type': 'client_hello',
      'client_ephemeral': _encodeBase64(clientPublicBytes),
      'client_nonce': _encodeBase64(clientNonce),
    };

    return utf8.decode(_canonicalJson(hello));
  }

  Future<bool> processServerHello(String serverResponse, String setupToken) async {
    try {
      final response = jsonDecode(serverResponse) as Map<String, dynamic>;

      if (response['type'] != 'server_hello') {
        return false;
      }

      final serverEphemeral = _decodeBase64(response['server_ephemeral'] as String);
      final transcriptHash = _decodeBase64(response['transcript_hash'] as String);

      _transcriptHash = transcriptHash;

      final clientPublic = await _clientKeyPair!.extractPublicKey();
      final clientPublicBytes = Uint8List.fromList(clientPublic.bytes);

      final transcript = _canonicalJson({
        'version': 1,
        'device_id': _piIdentity!.deviceId,
        'identity_public': _piIdentity!.publicKey,
        'client_ephemeral': _encodeBase64(clientPublicBytes),
        'client_nonce': _encodeBase64(_lastClientNonce!),
        'server_ephemeral': response['server_ephemeral'],
        'server_nonce': response['server_nonce'],
      });

      final serverPublicKey = SimplePublicKey(
        serverEphemeral,
        type: KeyPairType.x25519,
      );
      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: _clientKeyPair!,
        remotePublicKey: serverPublicKey,
      );

      _sessionKey = await _deriveSessionKey(sharedSecret, transcript);

      return await _sendAuthorization(setupToken);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _sendAuthorization(String setupToken) async {
    if (_sessionKey == null || _transcriptHash == null) {
      return false;
    }

    final nonce = _generateNonce(12);
    final payload = jsonEncode({'setup_token': setupToken});

    await _aesGcm.encrypt(
      utf8.encode(payload),
      secretKey: _sessionKey!,
      nonce: nonce,
      aad: _transcriptHash!.toList(),
    );

    return true;
  }

  Future<bool> sendHotspotCredentials(HotspotCredentials credentials) async {
    if (_sessionKey == null || _transcriptHash == null) {
      return false;
    }

    try {
      final nonce = _generateNonce(12);
      final payload = jsonEncode({
        'type': 'hotspot_credentials',
        ...credentials.toJson(),
      });

      final aad = [..._transcriptHash!, ...utf8.encode('client-to-server')];

      await _aesGcm.encrypt(
        utf8.encode(payload),
        secretKey: _sessionKey!,
        nonce: nonce,
        aad: aad,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<SecretKey> _deriveSessionKey(
    SecretKey sharedSecret,
    Uint8List transcript,
  ) async {
    final transcriptHash = Uint8List.fromList(await _sha256(transcript));
    final hkdf = Hkdf(hmac: Hmac(Sha256()), outputLength: 32);
    return await hkdf.deriveKey(
      secretKey: sharedSecret,
      nonce: transcriptHash,
      info: Uint8List.fromList(utf8.encode('BANTAI BLE provisioning session v1')),
    );
  }

  Uint8List? _lastClientNonce;

  Uint8List _generateNonce(int length) {
    final nonce = Uint8List(length);
    for (var i = 0; i < length; i++) {
      nonce[i] = DateTime.now().microsecondsSinceEpoch % 256;
    }
    _lastClientNonce = nonce;
    return nonce;
  }

  String _encodeBase64(Uint8List data) {
    return base64Url.encode(data).replaceAll('=', '');
  }

  Uint8List _decodeBase64(String data) {
    var normalized = data;
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return base64Url.decode(normalized);
  }

  Uint8List _canonicalJson(Map<String, dynamic> data) {
    final sorted = Map.fromEntries(
      data.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return Uint8List.fromList(utf8.encode(jsonEncode(sorted)));
  }

  Future<List<int>> _sha256(Uint8List data) async {
    final sha256 = Sha256();
    final hash = await sha256.hash(data);
    return hash.bytes;
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import 'ble_provisioning_client.dart';

class PiIdentity {
  const PiIdentity({
    required this.version,
    required this.deviceId,
    required this.bleServiceUuid,
    required this.publicKey,
    required this.keyFingerprint,
    required this.setupToken,
  });

  factory PiIdentity.fromJson(Map<String, dynamic> json) {
    return PiIdentity(
      version: json['version'] as int,
      deviceId: json['device_id'] as String,
      bleServiceUuid: json['ble_service_uuid'] as String,
      publicKey: json['public_key'] as String,
      keyFingerprint: json['key_fingerprint'] as String,
      setupToken: json['setup_token'] as String,
    );
  }

  final int version;
  final String deviceId;
  final String bleServiceUuid;
  final String publicKey;
  final String keyFingerprint;
  final String setupToken;

  Map<String, dynamic> toJson() => {
    'version': version,
    'device_id': deviceId,
    'ble_service_uuid': bleServiceUuid,
    'public_key': publicKey,
    'key_fingerprint': keyFingerprint,
    'setup_token': setupToken,
  };
}

class HotspotCredentials {
  const HotspotCredentials({required this.ssid, required this.password});

  final String ssid;
  final String password;

  Map<String, dynamic> toJson() => {'ssid': ssid, 'password': password};
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
  static final Uint8List _protocolPrefix = Uint8List.fromList([
    ...utf8.encode('BANTAI-PROVISION-v1'),
    0,
  ]);
  static const String _hkdfInfo = 'BANTAI BLE provisioning session v1';

  final _x25519 = X25519();
  final _ed25519 = Ed25519();
  final _aesGcm = AesGcm.with256bits();
  final _rng = Random.secure();
  final BleProvisioningClient _bleClient = BleProvisioningClient();

  SimpleKeyPair? _clientKeyPair;
  Uint8List? _clientNonce;
  SecretKey? _sessionKey;
  Uint8List? _transcriptHash;
  PiIdentity? _piIdentity;

  PiIdentity? get piIdentity => _piIdentity;
  BleProvisioningClient get bleClient => _bleClient;

  Future<PiIdentity?> parseQrCode(String qrData) async {
    try {
      final json = jsonDecode(qrData) as Map<String, dynamic>;
      final identity = PiIdentity.fromJson(json);

      if (identity.version != 1) {
        throw FormatException(
          'Unsupported identity version: ${identity.version}',
        );
      }
      if (!identity.deviceId.startsWith('BANTAI-')) {
        throw const FormatException('Invalid device ID format');
      }

      _piIdentity = identity;
      return identity;
    } catch (e) {
      debugPrint('[BANTAI] QR parse failed: $e');
      return null;
    }
  }

  /// Throws on failure (scan timeout, connect error, missing characteristic).
  Future<void> connectToPi() async {
    final identity = _piIdentity;
    if (identity == null) throw StateError('No Pi identity available');
    await _bleClient.connect(
      expectedName: identity.deviceId,
    );
  }

  Future<bool> performHandshake(String setupToken) async {
    if (_piIdentity == null || !_bleClient.isConnected) return false;

    try {
      final hello = await generateClientHello();
      final serverResponse = await _bleClient.sendMessage(
        jsonDecode(hello) as Map<String, dynamic>,
      );

      if (serverResponse['type'] != 'server_hello') {
        debugPrint('[BANTAI] Unexpected reply: $serverResponse');
        return false;
      }
      return await processServerHello(jsonEncode(serverResponse), setupToken);
    } catch (e) {
      debugPrint('[BANTAI] Handshake error: $e');
      return false;
    }
  }

  Future<bool> sendHotspotCredentials(HotspotCredentials credentials) async {
    final hash = _transcriptHash;
    if (_sessionKey == null || hash == null || !_bleClient.isConnected) {
      return false;
    }

    try {
      final envelope = await _encrypt(
        {'type': 'hotspot_credentials', ...credentials.toJson()},
        aad: [...hash, ...utf8.encode('client-to-server')],
        type: 'encrypted',
      );

      // The Pi may spend up to ~40s in nmcli, so wait longer than usual.
      final reply = await _bleClient.sendMessage(
        envelope,
        timeout: const Duration(seconds: 60),
      );

      final payload = await _decryptServerMessage(reply);
      if (payload['type'] == 'hotspot_response') {
        return payload['success'] as bool? ?? false;
      }
      debugPrint('[BANTAI] Unexpected payload: $payload');
      return false;
    } catch (e) {
      debugPrint('[BANTAI] Send credentials error: $e');
      return false;
    }
  }

  Future<void> disconnect() => _bleClient.disconnect();

  Future<String> generateClientHello() async {
    if (_piIdentity == null) throw StateError('No Pi identity available');

    _sessionKey = null;
    _transcriptHash = null;

    _clientKeyPair = await _x25519.newKeyPair();
    _clientNonce = _randomBytes(32);

    final clientPublic = await _clientKeyPair!.extractPublicKey();

    final hello = {
      'type': 'client_hello',
      'client_ephemeral': _encodeBase64(Uint8List.fromList(clientPublic.bytes)),
      'client_nonce': _encodeBase64(_clientNonce!),
    };
    return utf8.decode(_canonicalJson(hello));
  }

  Future<bool> processServerHello(
    String serverResponse,
    String setupToken,
  ) async {
    try {
      final identity = _piIdentity;
      final keyPair = _clientKeyPair;
      final clientNonce = _clientNonce;
      if (identity == null || keyPair == null || clientNonce == null) {
        return false;
      }

      final response = jsonDecode(serverResponse) as Map<String, dynamic>;
      if (response['type'] != 'server_hello') return false;

      final serverEphemeral = _decodeBase64(
        response['server_ephemeral'] as String,
      );
      final serverNonce = _decodeBase64(response['server_nonce'] as String);
      final signature = _decodeBase64(response['signature'] as String);
      final identityPublic = _decodeBase64(identity.publicKey);

      if (serverEphemeral.length != 32 ||
          serverNonce.length != 32 ||
          identityPublic.length != 32) {
        debugPrint('[BANTAI] Bad key/nonce length in server hello');
        return false;
      }

      final clientPublic = await keyPair.extractPublicKey();

      // Rebuild the transcript locally. Never trust the server's hash.
      final transcript = _canonicalJson({
        'version': 1,
        'device_id': identity.deviceId,
        'identity_public': _encodeBase64(identityPublic),
        'client_ephemeral': _encodeBase64(
          Uint8List.fromList(clientPublic.bytes),
        ),
        'client_nonce': _encodeBase64(clientNonce),
        'server_ephemeral': _encodeBase64(serverEphemeral),
        'server_nonce': _encodeBase64(serverNonce),
      });

      // Authenticate the Pi: signature must verify against the QR's key.
      final valid = await _ed25519.verify(
        [..._protocolPrefix, ...transcript],
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(identityPublic, type: KeyPairType.ed25519),
        ),
      );
      if (!valid) {
        debugPrint('[BANTAI] Server signature INVALID, aborting');
        return false;
      }

      final transcriptHash = Uint8List.fromList(
        (await Sha256().hash(transcript)).bytes,
      );

      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: keyPair,
        remotePublicKey: SimplePublicKey(
          serverEphemeral,
          type: KeyPairType.x25519,
        ),
      );

      _sessionKey = await Hkdf(hmac: Hmac(Sha256()), outputLength: 32)
          .deriveKey(
            secretKey: sharedSecret,
            nonce: transcriptHash,
            info: utf8.encode(_hkdfInfo),
          );
      _transcriptHash = transcriptHash;

      return await _sendAuthorization(setupToken);
    } catch (e) {
      debugPrint('[BANTAI] processServerHello error: $e');
      return false;
    }
  }

  Future<bool> _sendAuthorization(String setupToken) async {
    final hash = _transcriptHash;
    if (_sessionKey == null || hash == null || !_bleClient.isConnected) {
      return false;
    }

    try {
      final envelope = await _encrypt(
        {'setup_token': setupToken},
        aad: hash,
        type: 'authorize',
      );
      final response = await _bleClient.sendMessage(envelope);
      return response['type'] == 'authorization_success';
    } catch (e) {
      debugPrint('[BANTAI] Authorization error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _encrypt(
    Map<String, dynamic> payload, {
    required List<int> aad,
    required String type,
  }) async {
    final nonce = _randomBytes(12);
    final box = await _aesGcm.encrypt(
      utf8.encode(jsonEncode(payload)),
      secretKey: _sessionKey!,
      nonce: nonce,
      aad: aad,
    );
    return {
      'type': type,
      'nonce': _encodeBase64(nonce),
      'ciphertext': _encodeBase64(
        Uint8List.fromList([...box.cipherText, ...box.mac.bytes]),
      ),
    };
  }

  Future<Map<String, dynamic>> _decryptServerMessage(
    Map<String, dynamic> envelope,
  ) async {
    if (envelope['type'] != 'encrypted') {
      throw FormatException(
        'Unexpected reply: ${envelope['type']} ${envelope['error'] ?? ''}',
      );
    }
    final nonce = _decodeBase64(envelope['nonce'] as String);
    final data = _decodeBase64(envelope['ciphertext'] as String);
    if (nonce.length != 12 || data.length < 16) {
      throw const FormatException('Malformed encrypted reply');
    }

    final box = SecretBox(
      data.sublist(0, data.length - 16),
      nonce: nonce,
      mac: Mac(data.sublist(data.length - 16)),
    );
    final clear = await _aesGcm.decrypt(
      box,
      secretKey: _sessionKey!,
      aad: [..._transcriptHash!, ...utf8.encode('server-to-client')],
    );
    return jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
  }

  Uint8List _randomBytes(int length) =>
      Uint8List.fromList(List<int>.generate(length, (_) => _rng.nextInt(256)));

  String _encodeBase64(Uint8List data) =>
      base64Url.encode(data).replaceAll('=', '');

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
}

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// BLE client for the BANTAI Pi provisioning service.
///
/// Wire framing on the provision characteristic (both directions):
///   2-byte big-endian length + JSON body, split into GATT packets of
///   (MTU - 3) bytes. Responses arrive as notifications.
class BleProvisioningClient {
  static const String serviceUuid = '8b7e1000-6d7a-4e9a-9c4e-123456789001';
  static const String identityUuid = '8b7e1003-6d7a-4e9a-9c4e-123456789001';
  static const String provisionUuid = '8b7e1004-6d7a-4e9a-9c4e-123456789001';

  /// Name advertised by older Pi builds.
  static const String _legacyName = 'BANTAI-Pi';
  static const int _maxFrame = 4096;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _provisionCharacteristic;
  BluetoothCharacteristic? _identityCharacteristic;
  StreamSubscription<BluetoothConnectionState>? _stateSub;
  StreamSubscription<List<int>>? _notifySub;

  final List<int> _rx = [];
  Completer<Uint8List>? _pending;

  bool get isConnected => _device?.isConnected ?? false;

  /// Scans by service UUID (not by name), connects, discovers the
  /// characteristics and subscribes to notifications.
  ///
  /// [expectedName] is only used to pick the right Pi when several are in
  /// range. Devices with no name or the legacy name are still accepted.
  Future<void> connect({
    String? expectedName,
    Duration scanTimeout = const Duration(seconds: 15),
    Duration connectTimeout = const Duration(seconds: 15),
  }) async {
    debugPrint('[BLE] connect() entered, expectedName=$expectedName');

    if (defaultTargetPlatform == TargetPlatform.android) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      debugPrint('[BLE] permissions: $statuses');
      if (statuses.values.any((s) => !s.isGranted)) {
        throw ProvisioningException(
          'Bluetooth permission denied. Enable it in Settings.',
        );
      }
    }

    final adapter = await FlutterBluePlus.adapterState
        .firstWhere((s) => s != BluetoothAdapterState.unknown)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => BluetoothAdapterState.unknown,
        );
    debugPrint('[BLE] adapter state: $adapter');
    if (adapter != BluetoothAdapterState.on) {
      throw BluetoothOffException('Bluetooth is not enabled ($adapter)');
    }

    await disconnect();

    try {
      final device = await _scan(expectedName, scanTimeout);
      _device = device;

      _stateSub = device.connectionState.listen((state) {
        debugPrint('[BLE] Connection state: $state');
        if (state == BluetoothConnectionState.disconnected) {
          _failPending(ProvisioningException('Device disconnected'));
        }
      });

      await device.connect(timeout: connectTimeout, mtu: 512);
      debugPrint('[BLE] Connected, MTU ${device.mtuNow}');

      final services = await device.discoverServices();
      BluetoothService? service;
      for (final s in services) {
        if (s.uuid == Guid(serviceUuid)) service = s;
      }
      if (service == null) {
        throw ProvisioningException('Provisioning service not found');
      }

      for (final c in service.characteristics) {
        if (c.uuid == Guid(identityUuid)) _identityCharacteristic = c;
        if (c.uuid == Guid(provisionUuid)) _provisionCharacteristic = c;
      }

      final provision = _provisionCharacteristic;
      if (provision == null) {
        throw ProvisioningException('Provisioning characteristic not found');
      }
      if (!provision.properties.notify) {
        throw ProvisioningException(
          'Provisioning characteristic cannot notify',
        );
      }

      // Listen first, then enable notifications, so nothing is missed.
      _notifySub = provision.onValueReceived.listen(_onNotify);
      device.cancelWhenDisconnected(_notifySub!);
      await provision.setNotifyValue(true);
      debugPrint('[BLE] Subscribed to notifications');
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  Future<BluetoothDevice> _scan(String? expectedName, Duration timeout) async {
    debugPrint('[BLE] scan starting, service=$serviceUuid, timeout=$timeout');
    final completer = Completer<BluetoothDevice>();

    final sub = FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        final name = r.advertisementData.advName.isNotEmpty
            ? r.advertisementData.advName
            : r.device.platformName;
        debugPrint('[BLE] Found ${r.device.remoteId} name="$name"');

        final nameOk =
            expectedName == null ||
            name.isEmpty ||
            name == expectedName ||
            name == _legacyName;
        if (nameOk && !completer.isCompleted) {
          completer.complete(r.device);
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)],
        timeout: timeout,
      );
      return await completer.future.timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
          'Pi not found. Is it powered on and advertising?',
        ),
      );
    } finally {
      await sub.cancel();
      await FlutterBluePlus.stopScan();
    }
  }

  void _onNotify(List<int> chunk) {
    _rx.addAll(chunk);
    if (_rx.length < 2) return;

    final length = (_rx[0] << 8) | _rx[1];
    if (length > _maxFrame) {
      _rx.clear();
      _failPending(ProvisioningException('Oversized response frame'));
      return;
    }
    if (_rx.length < 2 + length) return; // wait for more chunks

    final body = Uint8List.fromList(_rx.sublist(2, 2 + length));
    _rx.clear();

    final c = _pending;
    _pending = null;
    if (c != null && !c.isCompleted) c.complete(body);
  }

  void _failPending(Object error) {
    final c = _pending;
    _pending = null;
    if (c != null && !c.isCompleted) c.completeError(error);
  }

  Future<Map<String, dynamic>> readIdentity() async {
    final c = _identityCharacteristic;
    if (c == null) {
      throw ProvisioningException('Identity characteristic not found');
    }
    final value = await c.read();
    return jsonDecode(utf8.decode(value)) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage(
    Map<String, dynamic> message, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final characteristic = _provisionCharacteristic;
    final device = _device;
    if (characteristic == null || device == null || !device.isConnected) {
      throw ProvisioningException('Not connected');
    }
    if (_pending != null) {
      throw ProvisioningException('Another request is in flight');
    }

    final body = utf8.encode(jsonEncode(message));
    if (body.length > _maxFrame) {
      throw ProvisioningException('Message too large');
    }

    final framed = Uint8List(2 + body.length)
      ..[0] = body.length >> 8
      ..[1] = body.length & 0xFF
      ..setRange(2, 2 + body.length, body);

    final completer = Completer<Uint8List>();
    _pending = completer;
    _rx.clear();

    debugPrint('[BLE] Sending ${message['type']} (${framed.length} bytes)');

    try {
      final chunk = math.max(20, device.mtuNow - 3);
      for (var i = 0; i < framed.length; i += chunk) {
        final end = math.min(i + chunk, framed.length);
        await characteristic.write(framed.sublist(i, end));
      }

      final response = await completer.future.timeout(
        timeout,
        onTimeout: () => throw TimeoutException('No response from device'),
      );
      final json = jsonDecode(utf8.decode(response)) as Map<String, dynamic>;
      debugPrint('[BLE] Received ${json['type']}');
      return json;
    } finally {
      _pending = null;
    }
  }

  Future<void> disconnect() async {
    _pending = null;
    _rx.clear();

    await _notifySub?.cancel();
    _notifySub = null;
    await _stateSub?.cancel();
    _stateSub = null;

    try {
      await _device?.disconnect();
    } catch (e) {
      debugPrint('[BLE] disconnect error: $e');
    }
    _device = null;
    _provisionCharacteristic = null;
    _identityCharacteristic = null;
  }
}

class BluetoothOffException implements Exception {
  final String message;
  BluetoothOffException(this.message);

  @override
  String toString() => message;
}

class ProvisioningException implements Exception {
  final String message;
  ProvisioningException(this.message);

  @override
  String toString() => message;
}

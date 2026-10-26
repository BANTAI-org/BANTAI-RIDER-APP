import 'dart:async';

import 'package:camera/camera.dart' as camera;
import 'package:flutter/foundation.dart';

import '../../../data/services/provisioning_service.dart';

enum ScanMode { camera, pairDevice }

enum ProvisioningStep {
  idle,
  scanningQr,
  awaitingDetails,
  connectingBle,
  authenticating,
  sendingCredentials,
  completed,
  error,
}

class ScanController extends ChangeNotifier {
  ScanController({ProvisioningService? provisioningService})
    : _provisioningService = provisioningService ?? ProvisioningService();

  final ProvisioningService _provisioningService;

  ScanMode _mode = ScanMode.camera;
  bool _isDownloading = false;
  bool _isPaired = true;
  bool _isPairing = false;
  bool _isProvisioning = false;
  String? _pairingError;
  String? _lastScannedCode;
  bool _isCameraLoading = false;
  String? _cameraError;
  camera.CameraController? _cameraController;

  ProvisioningStep _provisioningStep = ProvisioningStep.idle;
  PiIdentity? _scannedPiIdentity;
  String? _setupToken;
  HotspotCredentials? _hotspotCredentials;

  ScanMode get mode => _mode;
  bool get isDownloading => _isDownloading;
  bool get isPaired => _isPaired;
  bool get isPairing => _isPairing;
  String? get pairingError => _pairingError;
  String? get lastScannedCode => _lastScannedCode;
  bool get isCameraLoading => _isCameraLoading;
  String? get cameraError => _cameraError;
  camera.CameraController? get cameraController => _cameraController;

  ProvisioningStep get provisioningStep => _provisioningStep;
  PiIdentity? get scannedPiIdentity => _scannedPiIdentity;
  String? get setupToken => _setupToken;
  HotspotCredentials? get hotspotCredentials => _hotspotCredentials;

  String get deviceName => _scannedPiIdentity?.deviceId ?? 'Pi 5 Connection';
  String get deviceIdentifier =>
      _scannedPiIdentity?.deviceId ?? 'BANTAI-PI-4471';
  String get firmwareVersion => 'Firmware 2.4.1';

  void selectMode(ScanMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
  }

  Future<void> initializeCamera() async {
    if (_cameraController?.value.isInitialized == true || _isCameraLoading) {
      return;
    }

    _isCameraLoading = true;
    _cameraError = null;
    notifyListeners();

    try {
      final cameras = await camera.availableCameras();
      if (cameras.isEmpty) {
        throw camera.CameraException(
          'NoCameraAvailable',
          'No camera is available on this device.',
        );
      }

      final description = cameras.firstWhere(
        (item) => item.lensDirection == camera.CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = camera.CameraController(
        description,
        camera.ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      _cameraController = controller;
    } on camera.CameraException catch (error) {
      _cameraError = _cameraErrorMessage(error);
    } catch (error) {
      _cameraError = 'Unable to access the camera: $error';
    } finally {
      _isCameraLoading = false;
      notifyListeners();
    }
  }

  Future<void> pauseCamera() async {
    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  Future<void> downloadBufferedClip() async {
    if (_isDownloading) {
      return;
    }
    _isDownloading = true;
    notifyListeners();
    try {
      // TODO(backend): Download the buffered clip from the paired device.
      await Future<void>.delayed(const Duration(milliseconds: 350));
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void enterPairingCode() {
    // TODO(backend): Open pairing-code entry and pair the selected device.
  }

  Future<void> pairFromQr(String code) async {
    if (_isPairing || code.trim().isEmpty) {
      return;
    }

    _isPairing = true;
    _pairingError = null;
    _lastScannedCode = code.trim();
    _provisioningStep = ProvisioningStep.scanningQr;
    notifyListeners();

    try {
      // Try to parse as Pi identity QR code
      final identity = await _provisioningService.parseQrCode(code.trim());

      if (identity != null) {
        debugPrint('[BANTAI] Parsed Pi identity: ${identity.deviceId}');
        _scannedPiIdentity = identity;
        _setupToken = identity.setupToken;
        // BLE does not connect yet: we are waiting for the setup token and
        // hotspot details. startProvisioning() does the connecting.
        _provisioningStep = ProvisioningStep.awaitingDetails;
        _isPairing = false;
        notifyListeners();
        // Dialog will be shown by _onProvisioningChange listener
      } else {
        debugPrint('[BANTAI] QR code is not a Pi identity, trying legacy flow');
        // Legacy pairing flow
        await Future<void>.delayed(const Duration(milliseconds: 350));
        _isPaired = true;
        _provisioningStep = ProvisioningStep.idle;
        _isPairing = false;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('[BANTAI] QR parsing error: $error');
      _pairingError = 'Unable to pair this device: $error';
      _provisioningStep = ProvisioningStep.error;
      _isPairing = false;
      notifyListeners();
    }
  }

  void setSetupToken(String token) {
    _setupToken = token;
    notifyListeners();
  }

  void setHotspotCredentials(String ssid, String password) {
    _hotspotCredentials = HotspotCredentials(ssid: ssid, password: password);
    notifyListeners();
  }

  Future<bool> startProvisioning() async {
    if (_isProvisioning) {
      debugPrint('[BANTAI] startProvisioning ignored: already running');
      return false;
    }

    if (_scannedPiIdentity == null ||
        _setupToken == null ||
        _hotspotCredentials == null) {
      _pairingError = 'Missing provisioning information';
      _provisioningStep = ProvisioningStep.error;
      notifyListeners();
      return false;
    }

    _isProvisioning = true;
    _pairingError = null;

    try {
      // Step 1: Connect to Pi via BLE
      _provisioningStep = ProvisioningStep.connectingBle;
      notifyListeners();

      debugPrint('[BANTAI] startProvisioning: calling connectToPi');
      await _provisioningService.connectToPi();
      debugPrint('[BANTAI] startProvisioning: connected');

      // Step 2: Perform cryptographic handshake with setup token
      _provisioningStep = ProvisioningStep.authenticating;
      notifyListeners();

      final handshakeSuccess = await _provisioningService.performHandshake(
        _setupToken!,
      );
      debugPrint('[BANTAI] startProvisioning: handshake=$handshakeSuccess');

      if (!handshakeSuccess) {
        _pairingError = 'Authentication failed. Check your setup token.';
        _provisioningStep = ProvisioningStep.error;
        notifyListeners();
        await _provisioningService.disconnect();
        return false;
      }

      // Step 3: Send hotspot credentials
      _provisioningStep = ProvisioningStep.sendingCredentials;
      notifyListeners();

      final success = await _provisioningService.sendHotspotCredentials(
        _hotspotCredentials!,
      );
      debugPrint('[BANTAI] startProvisioning: credentials=$success');

      if (success) {
        _provisioningStep = ProvisioningStep.completed;
        _isPaired = true;
        notifyListeners();
        await _provisioningService.disconnect();
        return true;
      } else {
        _pairingError = 'Failed to send hotspot credentials';
        _provisioningStep = ProvisioningStep.error;
        notifyListeners();
        await _provisioningService.disconnect();
        return false;
      }
    } catch (error, stack) {
      debugPrint('[BANTAI] startProvisioning FAILED: $error\n$stack');
      _pairingError = 'Provisioning failed: $error';
      _provisioningStep = ProvisioningStep.error;
      notifyListeners();
      await _provisioningService.disconnect();
      return false;
    } finally {
      _isProvisioning = false;
    }
  }

  void resetProvisioning() {
    unawaited(_provisioningService.disconnect());
    _isProvisioning = false;
    _provisioningStep = ProvisioningStep.idle;
    _scannedPiIdentity = null;
    _setupToken = null;
    _hotspotCredentials = null;
    _pairingError = null;
    notifyListeners();
  }

  /// Back to the input form after a failure, keeping the scanned identity.
  void retryProvisioning() {
    unawaited(_provisioningService.disconnect());
    _isProvisioning = false;
    _pairingError = null;
    _provisioningStep = _scannedPiIdentity == null
        ? ProvisioningStep.idle
        : ProvisioningStep.awaitingDetails;
    notifyListeners();
  }

  void unpairDevice() {
    _isPaired = false;
    notifyListeners();
    // TODO(backend): Stop recording and clear the paired device keys.
  }

  void reportLostDevice() {
    // TODO(backend): Lock the device and alert the operator.
  }

  @override
  void dispose() {
    unawaited(_provisioningService.disconnect());
    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  String _cameraErrorMessage(camera.CameraException error) {
    return switch (error.code) {
      'CameraAccessDenied' =>
        'Camera access was denied. Allow camera access in Settings.',
      'CameraAccessDeniedWithoutPrompt' =>
        'Camera access is disabled. Allow camera access in Settings.',
      'CameraAccessRestricted' => 'Camera access is restricted on this device.',
      _ => error.description ?? 'Unable to access the camera.',
    };
  }
}

import 'dart:async';

import 'package:camera/camera.dart' as camera;
import 'package:flutter/foundation.dart';

enum ScanMode { camera, pairDevice }

class ScanController extends ChangeNotifier {
  ScanMode _mode = ScanMode.camera;
  bool _isDownloading = false;
  bool _isPaired = true;
  bool _isPairing = false;
  String? _pairingError;
  String? _lastScannedCode;
  bool _isCameraLoading = false;
  String? _cameraError;
  camera.CameraController? _cameraController;

  ScanMode get mode => _mode;
  bool get isDownloading => _isDownloading;
  bool get isPaired => _isPaired;
  bool get isPairing => _isPairing;
  String? get pairingError => _pairingError;
  String? get lastScannedCode => _lastScannedCode;
  bool get isCameraLoading => _isCameraLoading;
  String? get cameraError => _cameraError;
  camera.CameraController? get cameraController => _cameraController;

  String get deviceName => 'Pi 5 Connection';
  String get deviceIdentifier => 'BANTAI-PI-4471';
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
    notifyListeners();
    try {
      // TODO(backend): Validate the QR payload and pair the Pi 5 device.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _isPaired = true;
    } catch (error) {
      _pairingError = 'Unable to pair this device: $error';
    } finally {
      _isPairing = false;
      notifyListeners();
    }
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

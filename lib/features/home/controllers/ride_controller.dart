import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../data/services/location_service.dart';
import '../../../domain/entities/incident_sos.dart';
import '../../../domain/repositories/sos_repository.dart';

class RideController extends ChangeNotifier {
  RideController(this._sosRepository, {LocationService? locationService})
    : _locationService = locationService ?? LocationService();

  final SosRepository _sosRepository;
  final LocationService _locationService;

  bool _isLoading = false;
  bool _isSosActive = false;
  bool _isSosSending = false;
  String? _sosEventId;
  String? _sosError;
  bool _isSessionLive = false;
  Duration _sessionRemaining = Duration.zero;
  Timer? _sessionTimer;
  Duration _selectedDuration = Duration.zero;

  Duration get selectedDuration => _selectedDuration;

  void setSelectedDuration(Duration duration) {
    _selectedDuration = duration;
    notifyListeners();
    // TODO(backend): Persist selected duration preference.
  }

  bool get isLoading => _isLoading;
  bool get isSosActive => _isSosActive;
  bool get isSosSending => _isSosSending;
  String? get sosError => _sosError;
  bool get isSessionLive => _isSessionLive;
  String get sessionCountdown {
    final hours = _sessionRemaining.inHours.toString().padLeft(2, '0');
    final minutes = (_sessionRemaining.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = (_sessionRemaining.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );
    return '$hours:$minutes:$seconds';
  }

  String get sessionDuration => '';
  String get distanceTravelled => '';
  String get clipsRecorded => '';
  String get nearbyHelpCount => '';
  String get nearbyHelpDistance => '';
  String get nearestRider => '';
  String get nearbyService => '';

  Future<void> loadRideDashboard() async {
    _setLoading(true);
    try {
      // TODO(backend): Load live telemetry, nearby riders, and alerts.
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshTelemetry() async {
    _setLoading(true);
    try {
      // TODO(backend): Replace the local display values with telemetry data.
    } finally {
      _setLoading(false);
    }
  }

  /// Sends a manual SOS incident report. Returns true if the server accepted it.
  Future<bool> triggerManualSos() async {
    if (_isSosSending || _isSosActive) return false;

    _isSosSending = true;
    _sosError = null;
    notifyListeners();
    try {
      final position = await _locationService.currentPosition();
      if (position == null) {
        _sosError = 'Could not get your location. Check GPS and permissions.';
        return false;
      }

      _sosEventId = await _sosRepository.createManualSos(
        latitude: position.latitude,
        longitude: position.longitude,
        threatType: ThreatType.confrontation, // TODO: correct manual default
        threatCategory: ThreatCategory.hazard, // TODO: correct manual default
      );
      _isSosActive = true;
      return true;
    } on ApiException catch (error) {
      _sosError = 'SOS failed (${error.statusCode}): ${error.message}';
      return false;
    } catch (error) {
      _sosError = 'SOS failed before reaching the server: $error';
      return false;
    } finally {
      _isSosSending = false;
      notifyListeners();
    }
  }

  Future<bool> clearManualSos() async {
    // TODO(backend): No cancel/resolve endpoint yet. This only resets the app
    // state, so the command center still sees the incident as open.
    _isSosActive = false;
    _sosEventId = null;
    notifyListeners();
    return true;
  }

  Future<void> startSession({Duration? duration}) async {
    _isSessionLive = true;
    _sessionRemaining = duration ?? _selectedDuration;
    _startSessionTimer();
    notifyListeners();
    // TODO(backend): Start the rider session through the session endpoint.
  }

  Future<void> endSession() async {
    _isSessionLive = false;
    _sessionTimer?.cancel();
    notifyListeners();
    // TODO(backend): End the rider session through the session endpoint.
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    if (!_isSessionLive) return;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sessionRemaining <= Duration.zero) {
        _sessionTimer?.cancel();
        _isSessionLive = false;
      } else {
        _sessionRemaining -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

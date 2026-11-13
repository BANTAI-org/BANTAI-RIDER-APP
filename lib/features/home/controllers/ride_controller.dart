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
      final shift = await _sosRepository.getShiftStatus();
      final isOnDuty = shift['duty_status'] == 'on_duty';
      final remainingSeconds = (shift['remaining_seconds'] as num?)?.toInt();
      _isSessionLive = isOnDuty && (remainingSeconds == null || remainingSeconds > 0);
      _sessionRemaining = remainingSeconds != null && remainingSeconds > 0
          ? Duration(seconds: remainingSeconds)
          : Duration.zero;
      if (_isSessionLive) {
        _startSessionTimer();
      }
    } on ApiException catch (error) {
      _sosError = 'Could not load ride status (${error.statusCode}): ${error.message}';
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

      await _sosRepository.createManualSos(
        latitude: position.latitude,
        longitude: position.longitude,
        threatType: ThreatType.other,
        threatCategory: ThreatCategory.assist,
        triggerSource: TriggerSource.manualSos,
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
    notifyListeners();
    return true;
  }

  Future<void> startSession({Duration? duration}) async {
    final selected = duration ?? _selectedDuration;
    if (selected <= Duration.zero) return;

    _setLoading(true);
    _sosError = null;
    try {
      await _sosRepository.changeDuty(
        dutyStatus: 'on_duty',
        shiftHours: selected.inHours + (selected.inMinutes % 60 == 0 ? 0 : 1),
      );
      _isSessionLive = true;
      _sessionRemaining = selected;
      _startSessionTimer();
    } on ApiException catch (error) {
      _sosError = 'Could not start session (${error.statusCode}): ${error.message}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> endSession() async {
    _setLoading(true);
    _sosError = null;
    try {
      await _sosRepository.changeDuty(dutyStatus: 'off_duty');
      _isSessionLive = false;
      _sessionRemaining = Duration.zero;
      _sessionTimer?.cancel();
    } on ApiException catch (error) {
      _sosError = 'Could not end session (${error.statusCode}): ${error.message}';
    } finally {
      _setLoading(false);
    }
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

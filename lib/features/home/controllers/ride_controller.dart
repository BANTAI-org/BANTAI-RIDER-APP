import 'dart:async';

import 'package:flutter/foundation.dart';

class RideController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSosActive = false;
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

  Future<void> triggerManualSos() async {
    _isSosActive = true;
    notifyListeners();
    // TODO(backend): Send the SOS event and handle the server response.
  }

  Future<void> clearManualSos() async {
    _isSosActive = false;
    notifyListeners();
    // TODO(backend): Close the active SOS event on the server.
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

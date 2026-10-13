import 'package:flutter/foundation.dart';

class RideController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSosActive = false;
  bool _isSessionLive = true;

  bool get isLoading => _isLoading;
  bool get isSosActive => _isSosActive;
  bool get isSessionLive => _isSessionLive;
  String get sessionCountdown => '06:42:20';

  String get sessionDuration => '01:17:40';
  String get distanceTravelled => '38.4 km';
  String get clipsRecorded => '12';
  String get nearbyHelpCount => '2';
  String get nearbyHelpDistance => '3 km';
  String get nearestRider => 'JOY-0871 down · C5';
  String get nearbyService => 'Service Rd · 900 m';

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

  Future<void> startSession() async {
    _isSessionLive = true;
    notifyListeners();
    // TODO(backend): Start the rider session through the session endpoint.
  }

  Future<void> endSession() async {
    _isSessionLive = false;
    notifyListeners();
    // TODO(backend): End the rider session through the session endpoint.
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
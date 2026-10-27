import 'package:flutter/foundation.dart';

class RescueController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isRescueActive = false;

  bool get isLoading => _isLoading;
  bool get isRescueActive => _isRescueActive;

  String get dispatchedMessage => '';
  String get activeUnit => '';
  String get activeUnitDetails => '';
  String get activeUnitDistance => '';

  Future<void> previewIncident() async {
    _isRescueActive = true;
    notifyListeners();
  }

  Future<void> requestRescue() async {
    _setLoading(true);
    try {
      _isRescueActive = true;
      notifyListeners();
      // TODO(backend): Create a rescue request and stream responder updates.
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearRescue() async {
    _isRescueActive = false;
    notifyListeners();
    // TODO(backend): Close the active rescue event on the server.
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

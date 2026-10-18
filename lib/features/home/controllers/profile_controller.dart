import 'package:flutter/foundation.dart';

class ProfileController extends ChangeNotifier {
  bool _announceResponderEta = true;
  bool _autoConnectHeadset = false;
  bool _isLoading = false;

  String get fullName => 'Kirby Gabayno';
  String get email => 'kirbygabayno16@angkas.ph';
  String get phoneNumber => '+63 900 000 0000';
  String get accountId => 'ANG-2214';
  String get serviceProvider => 'Angkas';
  String get faceIdStatus => 'Face ID';
  String get vehicleDetails => 'Personal, license Honda Click\n160, medical';
  String get emergencyContact => 'Majan Taganna';
  bool get announceResponderEta => _announceResponderEta;
  bool get autoConnectHeadset => _autoConnectHeadset;
  bool get isLoading => _isLoading;

  Future<void> editProfile() async {
    // TODO(backend): Load and save the rider profile.
  }

  Future<void> connectGoogle() async {
    // TODO(auth): Connect the rider's Google account.
  }

  Future<void> connectApple() async {
    // TODO(auth): Connect the rider's Apple account.
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      // TODO(auth): Clear the session and revoke the refresh token.
    } finally {
      _setLoading(false);
    }
  }

  void setAnnounceResponderEta(bool value) {
    if (_announceResponderEta == value) return;
    _announceResponderEta = value;
    notifyListeners();
  }

  void setAutoConnectHeadset(bool value) {
    if (_autoConnectHeadset == value) return;
    _autoConnectHeadset = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

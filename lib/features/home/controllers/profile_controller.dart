import 'package:flutter/foundation.dart';

import '../../../domain/entities/emergency_contact.dart';
import '../../../domain/entities/rider_profile.dart';
import '../../../domain/entities/sos_broadcast.dart';
import '../../../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._profileRepository);

  final ProfileRepository _profileRepository;

  bool _announceResponderEta = true;
  bool _autoConnectHeadset = false;
  bool _isLoading = false;

  SosBroadcast? _sosBroadcast;
  RiderProfile? _riderProfile;
  List<EmergencyContact> _emergencyContacts = [];

  String get fullName {
    if (_riderProfile == null) return 'Kirby Gabayno';
    final parts = [
      _riderProfile?.firstName,
      _riderProfile?.middleName,
      _riderProfile?.lastName
    ].where((e) => e != null && e.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : '';
  }

  String get email => _riderProfile?.emailAddress ?? 'johndoe@gmail.com';
  String get phoneNumber => _riderProfile?.phoneNumber ?? '+63 900 000 0000';
  String get accountId => 'ADBC-1234';
  String get serviceProvider =>
      _riderProfile?.serviceProvider ?? 'Provider';
  String get faceIdStatus => 'Face ID';

  String get vehicleDetails {
    if (_riderProfile == null) {
      return 'Personal, license Motor\n160, medical';
    }
    final parts = <String>[];
    if (_riderProfile?.motorcycleMake != null ||
        _riderProfile?.motorcycleModel != null) {
      parts.add(
          '${_riderProfile?.motorcycleMake ?? ''} ${_riderProfile?.motorcycleModel ?? ''}'
              .trim());
    }
    if (_riderProfile?.licenseNumber != null) parts.add('license');
    if (_riderProfile?.bloodType != null) parts.add('medical');
    return parts.join(', ');
  }

  String get emergencyContact =>
      _emergencyContacts.isNotEmpty ? _emergencyContacts.first.name : '';

  SosBroadcast? get sosBroadcast => _sosBroadcast;
  RiderProfile? get riderDetails => _riderProfile;
  List<EmergencyContact> get emergencyContacts =>
      List.unmodifiable(_emergencyContacts);

  bool get announceResponderEta => _announceResponderEta;
  bool get autoConnectHeadset => _autoConnectHeadset;
  bool get isLoading => _isLoading;

  Future<void> editProfile() async {
    // TODO(backend): Load and save the rider profile.
  }

  Future<void> loadProfileData() async {
    _setLoading(true);
    try {
      // Fetch all profile data from backend
      final results = await Future.wait([
        _profileRepository.getRiderProfile().catchError((_) => null),
        _profileRepository.getSosBroadcast().catchError((_) => null),
        _profileRepository.getEmergencyContacts().catchError((_) => <EmergencyContact>[]),
      ]);

      _riderProfile = results[0] as RiderProfile?;
      _sosBroadcast = results[1] as SosBroadcast?;
      _emergencyContacts = results[2] as List<EmergencyContact>;
      notifyListeners();
    } catch (e) {
      // Handle error - for now just set empty data
      _riderProfile = null;
      _sosBroadcast = null;
      _emergencyContacts = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    _setLoading(true);
    try {
      final added = await _profileRepository.addEmergencyContact(contact);
      _emergencyContacts.add(added);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEmergencyContact(int index, EmergencyContact contact) async {
    if (index < 0 || index >= _emergencyContacts.length) return;
    
    final existingContact = _emergencyContacts[index];
    if (existingContact.id == null) return;

    _setLoading(true);
    try {
      await _profileRepository.updateEmergencyContact(existingContact.id!, contact);
      _emergencyContacts[index] = contact;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeEmergencyContact(int index) async {
    if (index < 0 || index >= _emergencyContacts.length) return;
    
    final contact = _emergencyContacts[index];
    if (contact.id == null) return;

    _setLoading(true);
    try {
      await _profileRepository.deleteEmergencyContact(contact.id!);
      _emergencyContacts.removeAt(index);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSosBroadcast(SosBroadcast data) async {
    _setLoading(true);
    try {
      await _profileRepository.updateSosBroadcast(data);
      _sosBroadcast = data;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRiderDetails(RiderProfile data) async {
    _setLoading(true);
    try {
      await _profileRepository.updateRiderProfile(data);
      _riderProfile = data;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
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

import '../../core/constants/network_settings.dart';
import '../../core/network/api_client.dart';
import '../models/emergency_contact_model.dart';
import '../models/rider_profile_model.dart';
import '../models/sos_broadcast_model.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<RiderProfileModel> getRiderProfile() async {
    final response = await _apiClient.get(
      NetworkSettings.profilePath,
      authenticated: true,
    );
    return RiderProfileModel.fromJson(response);
  }

  Future<void> updateRiderProfile(Map<String, dynamic> patch) async {
    if (patch.isEmpty) return;
    await _apiClient.patch('/drivers/profile', patch, authenticated: true);
  }

  Future<SosBroadcastModel> getSosBroadcast() async {
    final response = await _apiClient.get(
      NetworkSettings.sosBroadcastPath,
      authenticated: true,
    );
    return SosBroadcastModel.fromJson(response);
  }

  Future<void> updateSosBroadcast(SosBroadcastModel sosBroadcast) async {
    await _apiClient.put(
      NetworkSettings.sosBroadcastPath,
      sosBroadcast.toJson(),
      authenticated: true,
    );
  }

  Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    final response = await _apiClient.get(
      NetworkSettings.profilePath,
      authenticated: true,
    );
    final contactsJson = response['emergency_contacts'] as List<dynamic>? ?? [];
    return contactsJson
        .whereType<Map<String, dynamic>>()
        .map(EmergencyContactModel.fromJson)
        .toList();
  }

  Future<EmergencyContactModel> addEmergencyContact(
    EmergencyContactModel contact,
  ) async {
    final response = await _apiClient.post(
      NetworkSettings.emergencyContactsPath,
      contact.toJson(),
      authenticated: true,
    );
    return EmergencyContactModel.fromJson(response);
  }

  Future<void> updateEmergencyContact(
    String id,
    EmergencyContactModel contact,
  ) async {
    await _apiClient.put(
      '/profile/emergency-contacts/$id',
      contact.toJson(),
      authenticated: true,
    );
  }

  Future<void> deleteEmergencyContact(String id) async {
    await _apiClient.delete(
      '/profile/emergency-contacts/$id',
      authenticated: true,
    );
  }
}

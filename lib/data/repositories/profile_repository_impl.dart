import '../../domain/entities/emergency_contact.dart';
import '../../domain/entities/rider_profile.dart';
import '../../domain/entities/sos_broadcast.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/emergency_contact_model.dart';
import '../models/rider_profile_model.dart';
import '../models/sos_broadcast_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<RiderProfile> getRiderProfile() async {
    return await _remoteDataSource.getRiderProfile();
  }

  @override
  Future<void> updateRiderProfile(RiderProfile profile) async {
    final original = await _remoteDataSource.getRiderProfile();
    final model = RiderProfileModel.fromEntity(profile);
    final patch = model.toPatchJson(original);
    await _remoteDataSource.updateRiderProfile(patch);
  }

  @override
  Future<SosBroadcast> getSosBroadcast() async {
    return await _remoteDataSource.getSosBroadcast();
  }

  @override
  Future<void> updateSosBroadcast(SosBroadcast sosBroadcast) async {
    final model = SosBroadcastModel.fromEntity(sosBroadcast);
    await _remoteDataSource.updateSosBroadcast(model);
  }

  @override
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    return await _remoteDataSource.getEmergencyContacts();
  }

  @override
  Future<EmergencyContact> addEmergencyContact(EmergencyContact contact) async {
    final model = EmergencyContactModel.fromEntity(contact);
    return await _remoteDataSource.addEmergencyContact(model);
  }

  @override
  Future<void> updateEmergencyContact(
    String id,
    EmergencyContact contact,
  ) async {
    final model = EmergencyContactModel.fromEntity(contact);
    await _remoteDataSource.updateEmergencyContact(id, model);
  }

  @override
  Future<void> deleteEmergencyContact(String id) async {
    await _remoteDataSource.deleteEmergencyContact(id);
  }
}

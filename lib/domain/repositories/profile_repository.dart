import '../entities/emergency_contact.dart';
import '../entities/rider_profile.dart';
import '../entities/sos_broadcast.dart';

abstract interface class ProfileRepository {
  Future<RiderProfile> getRiderProfile();
  
  Future<void> updateRiderProfile(RiderProfile profile);
  
  Future<SosBroadcast> getSosBroadcast();
  
  Future<void> updateSosBroadcast(SosBroadcast sosBroadcast);
  
  Future<List<EmergencyContact>> getEmergencyContacts();
  
  Future<EmergencyContact> addEmergencyContact(EmergencyContact contact);
  
  Future<void> updateEmergencyContact(String id, EmergencyContact contact);
  
  Future<void> deleteEmergencyContact(String id);
}

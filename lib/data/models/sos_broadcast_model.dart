import '../../domain/entities/sos_broadcast.dart';

class SosBroadcastModel extends SosBroadcast {
  const SosBroadcastModel({
    super.bloodType,
    super.plateNumber,
    super.conditions,
    super.firstCallContact,
    super.licenseExpiry,
  });

  factory SosBroadcastModel.fromJson(Map<String, dynamic> json) {
    return SosBroadcastModel(
      bloodType: json['blood_type'] as String?,
      plateNumber: json['plate_number'] as String?,
      conditions: json['conditions'] as String?,
      firstCallContact: json['first_call_contact'] as String?,
      licenseExpiry: json['license_expiry'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bloodType != null) 'blood_type': bloodType,
      if (plateNumber != null) 'plate_number': plateNumber,
      if (conditions != null) 'conditions': conditions,
      if (firstCallContact != null) 'first_call_contact': firstCallContact,
      if (licenseExpiry != null) 'license_expiry': licenseExpiry,
    };
  }

  factory SosBroadcastModel.fromEntity(SosBroadcast entity) {
    return SosBroadcastModel(
      bloodType: entity.bloodType,
      plateNumber: entity.plateNumber,
      conditions: entity.conditions,
      firstCallContact: entity.firstCallContact,
      licenseExpiry: entity.licenseExpiry,
    );
  }
}

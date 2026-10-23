import '../../domain/entities/rider_profile.dart';

class RiderProfileModel extends RiderProfile {
  const RiderProfileModel({
    super.id,
    super.firstName,
    super.middleName,
    super.lastName,
    super.birthday,
    super.gender,
    super.emailAddress,
    super.phoneNumber,
    super.address,
    super.licenseNumber,
    super.licenseExpiry,
    super.operatorCode,
    super.operatorStatus,
    super.serviceProvider,
    super.experienceYears,
    super.motorcycleMake,
    super.motorcycleModel,
    super.motorcyclePlateNumber,
    super.motorcycleYear,
    super.motorcycleColor,
    super.bloodType,
    super.medicalConditions,
  });

  factory RiderProfileModel.fromJson(Map<String, dynamic> json) {
    return RiderProfileModel(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      birthday: json['birthday'] as String?,
      gender: json['gender'] as String?,
      emailAddress: json['email_address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseExpiry: json['license_expiry'] as String?,
      operatorCode: json['operator_code'] as String?,
      operatorStatus: json['operator_status'] as String?,
      serviceProvider: json['service_provider'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toInt(),
      motorcycleMake: json['motorcycle_make'] as String?,
      motorcycleModel: json['motorcycle_model'] as String?,
      motorcyclePlateNumber: json['motorcycle_plate_number'] as String?,
      motorcycleYear: json['motorcycle_year'] as String?,
      motorcycleColor: json['motorcycle_color'] as String?,
      bloodType: json['blood_type'] as String?,
      medicalConditions: json['medical_conditions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      if (lastName != null) 'last_name': lastName,
      if (birthday != null) 'birthday': birthday,
      if (gender != null) 'gender': gender,
      if (emailAddress != null) 'email_address': emailAddress,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (address != null) 'address': address,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (licenseExpiry != null) 'license_expiry': licenseExpiry,
      if (operatorCode != null) 'operator_code': operatorCode,
      if (operatorStatus != null) 'operator_status': operatorStatus,
      if (serviceProvider != null) 'service_provider': serviceProvider,
      if (experienceYears != null) 'experience_years': experienceYears,
      if (motorcycleMake != null) 'motorcycle_make': motorcycleMake,
      if (motorcycleModel != null) 'motorcycle_model': motorcycleModel,
      if (motorcyclePlateNumber != null)
        'motorcycle_plate_number': motorcyclePlateNumber,
      if (motorcycleYear != null) 'motorcycle_year': motorcycleYear,
      if (motorcycleColor != null) 'motorcycle_color': motorcycleColor,
      if (bloodType != null) 'blood_type': bloodType,
      if (medicalConditions != null) 'medical_conditions': medicalConditions,
    };
  }

  factory RiderProfileModel.fromEntity(RiderProfile entity) {
    return RiderProfileModel(
      id: entity.id,
      firstName: entity.firstName,
      middleName: entity.middleName,
      lastName: entity.lastName,
      birthday: entity.birthday,
      gender: entity.gender,
      emailAddress: entity.emailAddress,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      licenseNumber: entity.licenseNumber,
      licenseExpiry: entity.licenseExpiry,
      operatorCode: entity.operatorCode,
      operatorStatus: entity.operatorStatus,
      serviceProvider: entity.serviceProvider,
      experienceYears: entity.experienceYears,
      motorcycleMake: entity.motorcycleMake,
      motorcycleModel: entity.motorcycleModel,
      motorcyclePlateNumber: entity.motorcyclePlateNumber,
      motorcycleYear: entity.motorcycleYear,
      motorcycleColor: entity.motorcycleColor,
      bloodType: entity.bloodType,
      medicalConditions: entity.medicalConditions,
    );
  }
}

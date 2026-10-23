class RiderProfile {
  const RiderProfile({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.birthday,
    this.gender,
    this.emailAddress,
    this.phoneNumber,
    this.address,
    this.licenseNumber,
    this.licenseExpiry,
    this.operatorCode,
    this.operatorStatus,
    this.serviceProvider,
    this.experienceYears,
    this.motorcycleMake,
    this.motorcycleModel,
    this.motorcyclePlateNumber,
    this.motorcycleYear,
    this.motorcycleColor,
    this.bloodType,
    this.medicalConditions,
  });

  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? birthday;
  final String? gender;
  final String? emailAddress;
  final String? phoneNumber;
  final String? address;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? operatorCode;
  final String? operatorStatus;
  final String? serviceProvider;
  final int? experienceYears;
  final String? motorcycleMake;
  final String? motorcycleModel;
  final String? motorcyclePlateNumber;
  final String? motorcycleYear;
  final String? motorcycleColor;
  final String? bloodType;
  final String? medicalConditions;
}

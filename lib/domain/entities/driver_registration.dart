class DriverRegistration {
  const DriverRegistration({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.address,
    required this.mobileNumber,
    required this.email,
    required this.password,
    required this.serviceProvider,
    required this.serviceId,
    required this.licenseNumber,
    required this.licenseExpiresAt,
    required this.yearsRiding,
    required this.plateNumber,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.bloodType,
    required this.medicalConditions,
    required this.emergencyContacts,
    required this.otpCode,
    required this.dataSharingConsent,
  });

  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String address;
  final String mobileNumber;
  final String email;
  final String password;
  final String serviceProvider;
  final String? serviceId;
  final String licenseNumber;
  final String licenseExpiresAt;
  final int yearsRiding;
  final String plateNumber;
  final String vehicleModel;
  final String vehicleColor;
  final String bloodType;
  final String medicalConditions;
  final List<Map<String, String>> emergencyContacts;
  final String otpCode;
  final bool dataSharingConsent;

  Map<String, dynamic> toJson() => {
        'f_name': firstName,
        'l_name': lastName,
        'date_of_birth': dateOfBirth,
        'address': address,
        'm_number': mobileNumber,
        'email': email,
        'auth_provider': 'local',
        'password': password,
        'service_provider': serviceProvider,
        if (serviceId != null && serviceId!.isNotEmpty) 'service_id': serviceId,
        'license_number': licenseNumber,
        'license_expires_at': licenseExpiresAt,
        'years_riding': yearsRiding,
        'plate_number': plateNumber,
        'vehicle_model': vehicleModel,
        'vehicle_color': vehicleColor,
        'blood_type': bloodType,
        'medical_conditions': medicalConditions,
        'emergency_contacts': emergencyContacts,
        'data_sharing_consent': dataSharingConsent,
        'otp_code': otpCode,
      };
}

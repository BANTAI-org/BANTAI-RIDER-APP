import '../../domain/entities/rider_profile.dart';
import 'emergency_contact_model.dart';

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
    super.fleetOperatorId,
    super.experienceYears,
    super.motorcycleMake,
    super.motorcycleModel,
    super.motorcyclePlateNumber,
    super.motorcycleYear,
    super.motorcycleColor,
    super.bloodType,
    super.medicalConditions,
    super.emergencyContacts,
  });

  factory RiderProfileModel.fromJson(Map<String, dynamic> json) {
    return RiderProfileModel(
      id: json['id'] as String?,
      firstName: json['f_name'] as String?,
      middleName: json['m_name'] as String?,
      lastName: json['l_name'] as String?,
      birthday: json['date_of_birth'] as String?,
      emailAddress: json['email'] as String?,
      phoneNumber: json['m_number'] as String?,
      address: json['address'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseExpiry: json['license_expires_at'] as String?,
      serviceProvider: json['service_provider'] as String?,
      fleetOperatorId: json['fleet_operator_id'] as String?,
      experienceYears: (json['years_riding'] as num?)?.toInt(),
      motorcycleModel: json['vehicle_model'] as String?,
      motorcyclePlateNumber: json['plate_number'] as String?,
      motorcycleColor: json['vehicle_color'] as String?,
      bloodType: json['blood_type'] as String?,
      medicalConditions: json['medical_conditions'] as String?,
      emergencyContacts: ((json['emergency_contacts'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(EmergencyContactModel.fromJson)
          .toList(),
    );
  }

  String? _normalizeDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) return trimmed;
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(trimmed)) {
      final parts = trimmed.split('/');
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        final date = DateTime(year, month, day);
        return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    }
    return null;
  }

  Map<String, dynamic> toPatchJson(RiderProfile original) {
    final patch = <String, dynamic>{};
    final currentFirst = firstName?.trim();
    final originalFirst = original.firstName?.trim();
    if (currentFirst != originalFirst &&
        currentFirst != null &&
        currentFirst.isNotEmpty) {
      patch['f_name'] = currentFirst;
    }

    final currentLast = lastName?.trim();
    final originalLast = original.lastName?.trim();
    if (currentLast != originalLast &&
        currentLast != null &&
        currentLast.isNotEmpty) {
      patch['l_name'] = currentLast;
    }

    final currentMiddle = middleName?.trim();
    final originalMiddle = original.middleName?.trim();
    if (currentMiddle != originalMiddle) {
      patch['m_name'] = (currentMiddle == null || currentMiddle.isEmpty)
          ? null
          : currentMiddle;
    }

    final currentPhone = phoneNumber?.trim();
    final originalPhone = original.phoneNumber?.trim();
    if (currentPhone != originalPhone &&
        currentPhone != null &&
        currentPhone.isNotEmpty) {
      patch['m_number'] = currentPhone;
    }

    final currentAddress = address?.trim();
    final originalAddress = original.address?.trim();
    if (currentAddress != originalAddress &&
        currentAddress != null &&
        currentAddress.isNotEmpty) {
      patch['address'] = currentAddress;
    }

    final currentBirthday = _normalizeDate(birthday);
    final originalBirthday = _normalizeDate(original.birthday);
    if (currentBirthday != originalBirthday && currentBirthday != null) {
      patch['date_of_birth'] = currentBirthday;
    }

    final currentLicense = licenseNumber?.trim();
    final originalLicense = original.licenseNumber?.trim();
    if (currentLicense != originalLicense &&
        currentLicense != null &&
        currentLicense.isNotEmpty) {
      patch['license_number'] = currentLicense;
    }

    final currentLicenseExpiry = _normalizeDate(licenseExpiry);
    final originalLicenseExpiry = _normalizeDate(original.licenseExpiry);
    if (currentLicenseExpiry != originalLicenseExpiry &&
        currentLicenseExpiry != null) {
      patch['license_expires_at'] = currentLicenseExpiry;
    }

    if (experienceYears != original.experienceYears &&
        experienceYears != null) {
      patch['years_riding'] = experienceYears;
    }

    final currentService = serviceProvider?.trim();
    final originalService = original.serviceProvider?.trim();
    if (currentService != originalService &&
        currentService != null &&
        currentService.isNotEmpty) {
      patch['service_provider'] = currentService;
    }

    final currentFleet = fleetOperatorId?.trim();
    final originalFleet = original.fleetOperatorId?.trim();
    if (currentFleet != originalFleet) {
      patch['fleet_operator_id'] =
          (currentFleet == null || currentFleet.isEmpty) ? null : currentFleet;
    }

    final currentVehicleModel = motorcycleModel?.trim();
    final originalVehicleModel = original.motorcycleModel?.trim();
    if (currentVehicleModel != originalVehicleModel &&
        currentVehicleModel != null &&
        currentVehicleModel.isNotEmpty) {
      patch['vehicle_model'] = currentVehicleModel;
    }

    final currentPlate = motorcyclePlateNumber?.trim();
    final originalPlate = original.motorcyclePlateNumber?.trim();
    if (currentPlate != originalPlate &&
        currentPlate != null &&
        currentPlate.isNotEmpty) {
      patch['plate_number'] = currentPlate;
    }

    final currentColor = motorcycleColor?.trim();
    final originalColor = original.motorcycleColor?.trim();
    if (currentColor != originalColor &&
        currentColor != null &&
        currentColor.isNotEmpty) {
      patch['vehicle_color'] = currentColor;
    }

    final currentBlood = bloodType?.trim();
    final originalBlood = original.bloodType?.trim();
    if (currentBlood != originalBlood &&
        currentBlood != null &&
        currentBlood.isNotEmpty) {
      patch['blood_type'] = currentBlood;
    }

    final currentMedical = medicalConditions?.trim();
    final originalMedical = original.medicalConditions?.trim();
    if (currentMedical != originalMedical) {
      patch['medical_conditions'] =
          (currentMedical == null || currentMedical.isEmpty)
          ? null
          : currentMedical;
    }

    if (emergencyContacts != original.emergencyContacts) {
      if (emergencyContacts.isNotEmpty) {
        patch['emergency_contacts'] = emergencyContacts
            .map(
              (contact) => {
                'name': contact.name.trim(),
                'relation': contact.relation.trim(),
                'number': contact.phoneNumber.trim(),
              },
            )
            .where(
              (e) =>
                  (e['name']?.isNotEmpty ?? false) &&
                  (e['relation']?.isNotEmpty ?? false) &&
                  (e['number']?.isNotEmpty ?? false),
            )
            .toList();
        if ((patch['emergency_contacts'] as List).isEmpty) {
          patch.remove('emergency_contacts');
        }
      }
    }
    return patch;
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
      if (fleetOperatorId != null) 'fleet_operator_id': fleetOperatorId,
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
      fleetOperatorId: entity.fleetOperatorId,
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

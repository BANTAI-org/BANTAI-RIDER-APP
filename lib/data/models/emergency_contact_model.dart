import '../../domain/entities/emergency_contact.dart';

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    super.id,
    required super.name,
    required super.relation,
    required super.phoneNumber,
    super.isFirstCall,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      relation: json['relation'] as String,
      phoneNumber: json['phone_number'] as String,
      isFirstCall: json['is_first_call'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'relation': relation,
      'phone_number': phoneNumber,
      'is_first_call': isFirstCall,
    };
  }

  factory EmergencyContactModel.fromEntity(EmergencyContact entity) {
    return EmergencyContactModel(
      id: entity.id,
      name: entity.name,
      relation: entity.relation,
      phoneNumber: entity.phoneNumber,
      isFirstCall: entity.isFirstCall,
    );
  }
}

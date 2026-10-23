class EmergencyContact {
  const EmergencyContact({
    this.id,
    required this.name,
    required this.relation,
    required this.phoneNumber,
    this.isFirstCall = false,
  });

  final String? id;
  final String name;
  final String relation;
  final String phoneNumber;
  final bool isFirstCall;
}

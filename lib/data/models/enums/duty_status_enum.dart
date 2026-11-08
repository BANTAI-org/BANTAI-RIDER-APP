enum DutyStatusEnum {
  onDuty('on_duty'),
  offDuty('off_duty');

  const DutyStatusEnum(this.wire);

  final String wire;

  static DutyStatusEnum fromWire(String value) {
    return DutyStatusEnum.values.firstWhere(
      (e) => e.wire == value,
      orElse: () => throw FormatException('Unknown DutyStatusEnum: $value'),
    );
  }

  bool get isOnDuty => this == DutyStatusEnum.onDuty;
}
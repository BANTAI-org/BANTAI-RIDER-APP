import '../models/enums/duty_status_enum.dart';

class DutyChangeModel {
  final DutyStatusEnum dutyStatus;
  final int? shiftHours;

  const DutyChangeModel({required this.dutyStatus, this.shiftHours});

  factory DutyChangeModel.fromJson(Map<String, dynamic> json) =>
      DutyChangeModel(
        dutyStatus: DutyStatusEnum.fromWire(json['duty_status'] as String),
        shiftHours: json['shift_hours'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'duty_status': dutyStatus.wire,
        if (dutyStatus.isOnDuty && shiftHours != null)
          'shift_hours': shiftHours,
      };
}
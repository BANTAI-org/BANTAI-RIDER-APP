import 'package:bantai_rider_app/core/constants/network_settings.dart';
import 'package:bantai_rider_app/data/models/enums/duty_status_enum.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/incident_sos.dart';

class RiderRemoteDataSource {
  RiderRemoteDataSource(this._api);

  final ApiClient _api;

  Future<String> createManualSos({
    required double latitude,
    required double longitude,
    required ThreatType threatType,
    required ThreatCategory threatCategory,
    required TriggerSource triggerSource,
  }) async {
    final json = await _api.post(NetworkSettings.manualSosPath, {
      'trigger_source': triggerSource.wire,
      'location': {'latitude': latitude, 'longitude': longitude},
      'threat_type': threatType.wire,
      'threat_category': threatCategory.wire,
    });
    return json['id'].toString();
  }

Future<void> changeDuty({
  required DutyStatusEnum dutyStatus,
  int? shiftHours,
}) async {
  await _api.patch(NetworkSettings.changeDutyPath, {
    'duty_status': dutyStatus.wire,
    if (dutyStatus == DutyStatusEnum.onDuty && shiftHours != null)
      'shift_hours': shiftHours,
  });
}
}

import '../../core/network/api_client.dart';
import '../../core/constants/network_settings.dart';
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
    required String dutyStatus,
    int? shiftHours,
  }) async {
    await _api.patch(NetworkSettings.changeDutyPath, {
      'duty_status': dutyStatus,
      if (dutyStatus == 'on_duty' && shiftHours != null)
        'shift_hours': shiftHours,
    });
  }

  Future<Map<String, dynamic>> getShiftStatus() {
    return _api.get('/shift');
  }
}

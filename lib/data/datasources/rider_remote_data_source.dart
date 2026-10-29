import 'package:bantai_rider_app/core/constants/network_settings.dart';

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
  }) async {
    final json = await _api.post(NetworkSettings.manualSosPath, {
      'trigger_source': TriggerSource.manualSos.wire,
      'location': {'latitude': latitude, 'longitude': longitude},
      'threat_type': threatType.wire,
      'threat_category': threatCategory.wire,
    });
    return json['id'].toString();
  }
}

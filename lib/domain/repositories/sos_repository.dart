import '../entities/incident_sos.dart';

abstract class SosRepository {
  Future<String> createManualSos({
    required double latitude,
    required double longitude,
    required ThreatType threatType,
    required ThreatCategory threatCategory,
    required TriggerSource triggerSource,
  });
}

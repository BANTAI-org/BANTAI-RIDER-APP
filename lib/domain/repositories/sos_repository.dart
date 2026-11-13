import '../entities/incident_sos.dart';

abstract class SosRepository {
  Future<String> createManualSos({
    required double latitude,
    required double longitude,
    required ThreatType threatType,
    required ThreatCategory threatCategory,
    required TriggerSource triggerSource,
  });

  Future<Map<String, dynamic>> getShiftStatus();

  Future<void> changeDuty({
    required String dutyStatus,
    int? shiftHours,
  });
}

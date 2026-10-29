import '../entities/incident_sos.dart';

abstract class SosRepository {
  /// Creates an incident report and returns its id.
  Future<String> createManualSos({
    required double latitude,
    required double longitude,
    required ThreatType threatType,
    required ThreatCategory threatCategory,
  });
}

import '../../domain/entities/incident_sos.dart';
import '../../domain/repositories/sos_repository.dart';
import '../datasources/rider_remote_data_source.dart';

class SosRepositoryImpl implements SosRepository {
  SosRepositoryImpl(this._remoteDataSource);

  final RiderRemoteDataSource _remoteDataSource;

  @override
  Future<String> createManualSos({
    required double latitude,
    required double longitude,
    required ThreatType threatType,
    required ThreatCategory threatCategory,
    required TriggerSource triggerSource,
  }) {
    return _remoteDataSource.createManualSos(
      latitude: latitude,
      longitude: longitude,
      threatType: threatType,
      threatCategory: threatCategory,
      triggerSource: triggerSource,
    );
  }

  @override
  Future<Map<String, dynamic>> getShiftStatus() {
    return _remoteDataSource.getShiftStatus();
  }

  @override
  Future<void> changeDuty({
    required String dutyStatus,
    int? shiftHours,
  }) {
    return _remoteDataSource.changeDuty(
      dutyStatus: dutyStatus,
      shiftHours: shiftHours,
    );
  }
}

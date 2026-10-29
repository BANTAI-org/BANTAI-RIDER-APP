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
  }) {
    return _remoteDataSource.createManualSos(
      latitude: latitude,
      longitude: longitude,
      threatType: threatType,
      threatCategory: threatCategory,
    );
  }
}

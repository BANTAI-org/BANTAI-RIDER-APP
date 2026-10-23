import '../../core/constants/network_settings.dart';
import '../../core/network/api_client.dart';

class HealthRemoteDataSource {
  const HealthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> checkHealth() {
    return _apiClient.get(NetworkSettings.healthPath, authenticated: false);
  }
}

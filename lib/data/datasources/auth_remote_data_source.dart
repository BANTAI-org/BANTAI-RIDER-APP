import '../../core/constants/network_settings.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/driver_registration.dart';
import '../models/auth_tokens_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(NetworkSettings.signInPath, {
      'email': email,
      'password': password,
    });
    return AuthTokensModel.fromJson(response);
  }

  Future<void> signup(DriverRegistration registration) async {
    await _apiClient.post(
      NetworkSettings.driverRegistrationPath,
      registration.toJson(),
    );
  }
}

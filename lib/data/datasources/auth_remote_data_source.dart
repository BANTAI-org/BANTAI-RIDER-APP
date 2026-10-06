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

  Future<void> otpSend({required String contactNumber}) async {
    await _apiClient.post(NetworkSettings.otpSendPath, {
      'm_number': contactNumber,
    });
  }

  Future<void> otpVerifySignup({
    required String contactNumber,
    required String otpCode
  }) async {
    await _apiClient.post(NetworkSettings.otpVerificationSignupPath, {
      'm_number': contactNumber,
      'otp_code': otpCode,
    });
  }

  Future<void> signup(DriverRegistration registration) async {
    await _apiClient.post(
      NetworkSettings.driverRegistrationPath,
      registration.toJson(),
    );
  }

  Future<int> otpForgotPasswordOtpSend({
    String? email,
    String? contactNumber,
  }) async {
    final response = await _apiClient.post(
      NetworkSettings.forgotPasswordRequestPath,
      _resetIdentity(email: email, contactNumber: contactNumber),
    );
    return (response['resend_after_seconds'] as num?)?.toInt() ?? 30;
  }

  Future<String> verifyForgotPasswordOtp({
    String? email,
    String? contactNumber,
    required String otpCode,
  }) async {
    final response = await _apiClient.post(
      NetworkSettings.forgotPasswordVerifyPath,
      {..._resetIdentity(email: email, contactNumber: contactNumber), 'otp_code': otpCode},
    );
    return response['reset_token'] as String;
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await _apiClient.post(NetworkSettings.forgotPasswordResetPath, {
      'reset_token': resetToken,
      'new_password': newPassword,
    });
  }

  Map<String, dynamic> _resetIdentity({
    String? email,
    String? contactNumber,
  }) {
    if (email != null) return {'email': email};
    if (contactNumber != null) return {'m_number': contactNumber};
    throw ArgumentError('An email or contact number is required.');
  }
}

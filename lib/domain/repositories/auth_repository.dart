import '../entities/auth_tokens.dart';
import '../entities/driver_registration.dart';

abstract interface class AuthRepository {
  Future<AuthTokens> login({required String email, required String password});
  Future<void> otpSend({required String contactNumber});
  Future<void> otpSignupVerification({
    required String contactNumber,
    required String otpCode,
  });
  Future<void> signup(DriverRegistration registration);
  Future<int> otpForgotPasswordOtpSend({
    String? email,
    String? contactNumber,
  });
  Future<String> verifyForgotPasswordOtp({
    String? email,
    String? contactNumber,
    required String otpCode,
  });
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

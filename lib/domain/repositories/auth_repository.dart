import '../entities/auth_tokens.dart';
import '../entities/driver_registration.dart';

abstract interface class AuthRepository {
  Future<AuthTokens> login({required String email, required String password});

  Future<AuthTokens> loginWithGoogle({required String idToken});

  Future<void> otpSend({required String contactNumber});

  Future<void> otpSignupVerification({
    required String contactNumber,
    required String otpCode,
  });

  Future<AuthTokens> signup(DriverRegistration registration);

  Future<int> otpForgotPasswordOtpSend({String? email, String? contactNumber});

  Future<String> verifyForgotPasswordOtp({
    String? email,
    String? contactNumber,
    required String otpCode,
  });

  Future<AuthTokens> refresh({required String refreshToken});

  Future<void> logout();

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}

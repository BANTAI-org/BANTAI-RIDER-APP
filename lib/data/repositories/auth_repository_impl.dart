import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/driver_registration.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../core/storage/auth_token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, {AuthTokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthTokens> login({required String email, required String password}) =>
      _remoteDataSource.login(email: email, password: password);

  @override
  Future<AuthTokens> loginWithGoogle({required String idToken}) =>
      _remoteDataSource.loginWithGoogle(idToken: idToken);

  @override
  Future<void> otpSend({required String contactNumber}) =>
      _remoteDataSource.otpSend(contactNumber: contactNumber);

  @override
  Future<void> otpSignupVerification({
    required String contactNumber,
    required String otpCode,
  }) => _remoteDataSource.otpVerifySignup(
    contactNumber: contactNumber,
    otpCode: otpCode,
  );

  @override
  Future<AuthTokens> signup(DriverRegistration registration) =>
      _remoteDataSource.signup(registration);

  @override
  Future<int> otpForgotPasswordOtpSend({
    String? email,
    String? contactNumber,
  }) => _remoteDataSource.otpForgotPasswordOtpSend(
    email: email,
    contactNumber: contactNumber,
  );

  @override
  Future<String> verifyForgotPasswordOtp({
    String? email,
    String? contactNumber,
    required String otpCode,
  }) => _remoteDataSource.verifyForgotPasswordOtp(
    email: email,
    contactNumber: contactNumber,
    otpCode: otpCode,
  );

  @override
  Future<AuthTokens> refresh({required String refreshToken}) async {
    final tokens = await _remoteDataSource.refresh(refreshToken: refreshToken);
    await _tokenStorage.save(tokens, keepSignedIn: true);
    return tokens;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _remoteDataSource.resetPassword(
    resetToken: resetToken,
    newPassword: newPassword,
  );
}

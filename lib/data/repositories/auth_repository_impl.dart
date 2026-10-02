import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/driver_registration.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthTokens> login({required String email, required String password}) =>
      _remoteDataSource.login(email: email, password: password);

  @override
  Future<void> signup(DriverRegistration registration) =>
      _remoteDataSource.signup(registration);
}

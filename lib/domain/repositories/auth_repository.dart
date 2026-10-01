import '../entities/auth_tokens.dart';

abstract interface class AuthRepository {
  Future<AuthTokens> login({required String email, required String password});

  Future<AuthTokens> signup({required String email, required String password});
}

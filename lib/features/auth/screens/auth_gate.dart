import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../home/screens/home_shell.dart';
import 'login.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _tokenStorage = AuthTokenStorage();
  final _localAuthentication = LocalAuthentication();
  late Future<Widget> _initialRoute;

  @override
  void initState() {
    super.initState();
    _initialRoute = _resolveInitialRoute();
  }

  Future<Widget> _resolveInitialRoute() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return _loginPage();
    }

    if (!await _tokenStorage.readKeepSignedIn()) {
      await _tokenStorage.clear();
      return _loginPage();
    }

    // Refresh the access token before biometric unlock so a long-closed app
    // does not enter the home screen with an expired token.
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      return _loginPage();
    }
    try {
      await widget.authRepository.refresh(refreshToken: refreshToken);
    } catch (_) {
      await _tokenStorage.clear();
      return _loginPage();
    }

    if (!await _localAuthentication.isDeviceSupported()) {
      return const HomeShell();
    }

    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Unlock BANTAI with your phone security.',
      );
      return authenticated ? const HomeShell() : _loginPage();
    } on LocalAuthException {
      return _loginPage();
    }
  }

  Widget _loginPage() => LoginPage(authRepository: widget.authRepository);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initialRoute,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _loginPage();
        }
        if (!snapshot.hasData) {
          return _loginPage();
        }
        return snapshot.data!;
      },
    );
  }
}

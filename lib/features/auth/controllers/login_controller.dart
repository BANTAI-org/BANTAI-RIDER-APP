import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../data/services/google_auth_service.dart';

class LoginController extends ChangeNotifier {
  LoginController(
    this._authRepository, {
    AuthTokenStorage? tokenStorage,
    GoogleAuthService? googleAuthService,
  }) : _tokenStorage = tokenStorage ?? AuthTokenStorage(),
       _googleAuthService = googleAuthService ?? GoogleAuthService();

  final AuthRepository _authRepository;
  final AuthTokenStorage _tokenStorage;
  final GoogleAuthService _googleAuthService;
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool _keepMeSignedIn = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _googleLoginSucceeded = false;

  bool get keepMeSignedIn => _keepMeSignedIn;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  bool get googleLoginSucceeded => _googleLoginSucceeded;

  void toggleKeepMeSignedIn(bool? value) {
    _keepMeSignedIn = value ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    _isLoading = true;
    notifyListeners();
    try {
      final tokens = await _authRepository.login(
        email: identifierController.text.trim(),
        password: passwordController.text,
      );
      await _tokenStorage.save(tokens, keepSignedIn: _keepMeSignedIn);
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<GoogleAuthCredential?> loginWithGoogle() async {
    if (_isLoading) return null;
    _googleLoginSucceeded = false;
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _googleAuthService.signIn();
      if (credential == null) return null;
      try {
        final tokens = await _authRepository.loginWithGoogle(
          idToken: credential.idToken,
        );
        await _tokenStorage.save(tokens, keepSignedIn: _keepMeSignedIn);
        _googleLoginSucceeded = true;
        return null;
      } on ApiException catch (error) {
        if (error.statusCode == 401 || error.statusCode == 404) {
          return credential;
        }
        rethrow;
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithDeviceSecurity() async {
    if (_isLoading) return false;

    final accessToken = await _tokenStorage.readAccessToken();
    final keepSignedIn = await _tokenStorage.readKeepSignedIn();
    if (accessToken == null || accessToken.isEmpty || !keepSignedIn) {
      return false;
    }

    if (!await _localAuthentication.isDeviceSupported()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      return await _localAuthentication.authenticate(
        localizedReason: 'Use Face ID, fingerprint, or your device password.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!value.contains('@')) return 'Please enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

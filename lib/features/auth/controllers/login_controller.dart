import 'package:flutter/material.dart';

import '../../../core/storage/auth_token_storage.dart';
import '../../../domain/repositories/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._authRepository, {AuthTokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final AuthRepository _authRepository;
  final AuthTokenStorage _tokenStorage;
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool _keepMeSignedIn = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get keepMeSignedIn => _keepMeSignedIn;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;

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
      await _tokenStorage.save(tokens);
      return true;
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

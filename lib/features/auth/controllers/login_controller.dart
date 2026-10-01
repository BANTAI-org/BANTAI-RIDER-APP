import 'package:flutter/material.dart';

import '../../../domain/repositories/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._authRepository);

  final AuthRepository _authRepository;
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
      await _authRepository.login(
        email: identifierController.text.trim(),
        password: passwordController.text,
      );
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

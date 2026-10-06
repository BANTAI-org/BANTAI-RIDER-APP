import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/repositories/auth_repository.dart';
enum ForgotPasswordStep { requestCode, verifyCode, newPassword }
enum ResetChannel { sms, email }

class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController(this._authRepository);
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final AuthRepository _authRepository;

  ForgotPasswordStep _step = ForgotPasswordStep.requestCode;
  ForgotPasswordStep get step => _step;
  ResetChannel _resetChannel = ResetChannel.email;
  ResetChannel get resetChannel => _resetChannel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? _resetToken;
  Timer? _resendTimer;
  int _resendSeconds = 0;
  int get resendSeconds => _resendSeconds;
  bool get canResend => _resendSeconds == 0 && !_isLoading;

  void setResetChannel(ResetChannel channel) {
    if (_resetChannel == channel) return;
    _resetChannel = channel;
    notifyListeners();
  }

  String get resetAccount => _resetChannel == ResetChannel.email
      ? emailController.text.trim()
      : _toApiMobile(mobileController.text);

  Future<void> sendResetCode() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cooldown = await _requestResetCode();
      _step = ForgotPasswordStep.verifyCode;
      _startResendCooldown(cooldown);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendCode() async {
    if (!canResend) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cooldown = await _requestResetCode();
      for (final controller in otpControllers) {
        controller.clear();
      }
      _startResendCooldown(cooldown);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> _requestResetCode() {
    return _authRepository.otpForgotPasswordOtpSend(
      email: _resetChannel == ResetChannel.email
          ? emailController.text.trim()
          : null,
      contactNumber: _resetChannel == ResetChannel.sms
          ? _toApiMobile(mobileController.text)
          : null,
    );
  }

  void _startResendCooldown(int seconds) {
    _resendTimer?.cancel();
    _resendSeconds = seconds.clamp(0, 3600);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        _resendSeconds = 0;
      } else {
        _resendSeconds--;
      }
      notifyListeners();
    });
  }

  Future<void> verifyCode() async {
    if (otpControllers.any((controller) => controller.text.trim().isEmpty)) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _resetToken = await _authRepository.verifyForgotPasswordOtp(
        email: _resetChannel == ResetChannel.email
            ? emailController.text.trim()
            : null,
        contactNumber: _resetChannel == ResetChannel.sms
            ? _toApiMobile(mobileController.text)
            : null,
        otpCode: otpControllers
            .map((controller) => controller.text.trim())
            .join(),
      );
      _step = ForgotPasswordStep.newPassword;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePassword() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    final resetToken = _resetToken;
    if (resetToken == null) {
      _errorMessage = 'Your reset session has expired. Request a new code.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.resetPassword(
        resetToken: resetToken,
        newPassword: passwordController.text,
      );
      _step = ForgotPasswordStep.requestCode;
      _resetToken = null;
      for (final controller in otpControllers) {
        controller.clear();
      }
      passwordController.clear();
      confirmPasswordController.clear();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void back() {
    switch (_step) {
      case ForgotPasswordStep.verifyCode:
        _step = ForgotPasswordStep.requestCode;
        _errorMessage = null;
      case ForgotPasswordStep.newPassword:
        _step = ForgotPasswordStep.verifyCode;
        _errorMessage = null;
      case ForgotPasswordStep.requestCode:
        return;
    }
    notifyListeners();
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!email.contains('@')) return 'Enter a valid email';
    return null;
  }

  String _toApiMobile(String value) {
    final digits = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (digits.startsWith('+63')) return digits;
    if (digits.startsWith('09')) return '+63${digits.substring(1)}';
    return digits;
  }

  String? validateAccount(String? value) {
    if (_resetChannel == ResetChannel.email) return validateEmail(value);
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return 'Enter your mobile number';
    final normalized = _toApiMobile(mobile);
    if (!RegExp(r'^\+639\d{9}$').hasMatch(normalized)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) return 'Use at least 6 characters';
    return null;
  }

  String? validateConfirmation(String? value) {
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? validateRequired(String? value) {
    return value?.trim().isEmpty ?? true ? 'This field is required' : null;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

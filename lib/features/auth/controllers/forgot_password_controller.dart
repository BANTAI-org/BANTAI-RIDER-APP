import 'package:flutter/material.dart';

enum ForgotPasswordStep { requestCode, verifyCode, newPassword, adminRequest, adminSent }
enum ResetChannel { sms, email }

class ForgotPasswordController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final callSignController = TextEditingController();
  final mobileController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());

  ForgotPasswordStep _step = ForgotPasswordStep.requestCode;
  ForgotPasswordStep get step => _step;
  ResetChannel _resetChannel = ResetChannel.email;
  ResetChannel get resetChannel => _resetChannel;

  void setResetChannel(ResetChannel channel) {
    if (_resetChannel == channel) return;
    _resetChannel = channel;
    emailController.clear();
    notifyListeners();
  }

  void sendResetCode() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _step = ForgotPasswordStep.verifyCode;
    notifyListeners();
  }

  void verifyCode() {
    if (otpControllers.any((controller) => controller.text.trim().isEmpty)) return;
    _step = ForgotPasswordStep.newPassword;
    notifyListeners();
  }

  void savePassword() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _step = ForgotPasswordStep.requestCode;
    notifyListeners();
  }

  void requestAdminReset() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _step = ForgotPasswordStep.adminSent;
    notifyListeners();
  }

  void openAdminReset() {
    _step = ForgotPasswordStep.adminRequest;
    formKey.currentState?.reset();
    notifyListeners();
  }

  void back() {
    switch (_step) {
      case ForgotPasswordStep.verifyCode:
        _step = ForgotPasswordStep.requestCode;
      case ForgotPasswordStep.newPassword:
        _step = ForgotPasswordStep.verifyCode;
      case ForgotPasswordStep.adminRequest:
        _step = ForgotPasswordStep.requestCode;
      case ForgotPasswordStep.requestCode:
      case ForgotPasswordStep.adminSent:
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

  String? validateAccount(String? value) {
    if (_resetChannel == ResetChannel.email) return validateEmail(value);
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return 'Enter your mobile number';
    if (mobile.length < 10) return 'Enter a valid mobile number';
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
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    callSignController.dispose();
    mobileController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

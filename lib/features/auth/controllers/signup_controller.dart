import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/repositories/auth_repository.dart';

class SignupController extends ChangeNotifier {
  SignupController(this._authRepository, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage() {
    _registerDraftListeners();
    unawaited(_restoreDraft());
  }

  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;
  static const _draftKey = 'signup_registration_draft';
  Timer? _draftSaveTimer;
  bool _isRestoring = true;
  bool _isDisposed = false;
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final licenseExpiryController = TextEditingController();
  final yearsRidingController = TextEditingController();
  final operatorIdController = TextEditingController();
  final plateNumberController = TextEditingController();
  final motorcycleController = TextEditingController();
  final bodyColorController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final medicalConditionsController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyRelationController = TextEditingController();
  final emergencyNumberController = TextEditingController();

  static const stepCount = 6;
  int _currentStep = 0;
  int get currentStep => _currentStep;
  bool get isLastStep => _currentStep == stepCount - 1;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _registerDraftListeners() {
    for (final controller in _textControllers) {
      controller.addListener(_scheduleDraftSave);
    }
  }

  List<TextEditingController> get _textControllers => [
    fullNameController,
    birthDateController,
    mobileController,
    emailController,
    passwordController,
    confirmPasswordController,
    licenseNumberController,
    licenseExpiryController,
    yearsRidingController,
    operatorIdController,
    plateNumberController,
    motorcycleController,
    bodyColorController,
    bloodTypeController,
    medicalConditionsController,
    emergencyNameController,
    emergencyRelationController,
    emergencyNumberController,
  ];

  void _scheduleDraftSave() {
    if (_isRestoring || _isDisposed) return;
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(saveDraft());
    });
  }

  Future<void> _restoreDraft() async {
    try {
      final encodedDraft = await _storage.read(key: _draftKey);
      if (encodedDraft == null) return;

      final draft = jsonDecode(encodedDraft);
      if (draft is! Map<String, dynamic>) return;

      for (final entry in _draftFields.entries) {
        final value = draft[entry.key];
        if (value is String) entry.value.text = value;
      }

      final savedStep = draft['currentStep'];
      if (savedStep is int && savedStep >= 0 && savedStep < stepCount) {
        _currentStep = savedStep;
      }
    } catch (_) {
      await _storage.delete(key: _draftKey);
    } finally {
      _isRestoring = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> saveDraft() async {
    if (_isRestoring || _isDisposed) return;
    await _storage.write(
      key: _draftKey,
      value: jsonEncode({
        'currentStep': _currentStep,
        for (final entry in _draftFields.entries) entry.key: entry.value.text,
      }),
    );
  }

  Future<void> clearDraft() async {
    _draftSaveTimer?.cancel();
    await _storage.delete(key: _draftKey);
  }

  Map<String, TextEditingController> get _draftFields => {
    'fullName': fullNameController,
    'birthDate': birthDateController,
    'mobile': mobileController,
    'email': emailController,
    'password': passwordController,
    'confirmPassword': confirmPasswordController,
    'licenseNumber': licenseNumberController,
    'licenseExpiry': licenseExpiryController,
    'yearsRiding': yearsRidingController,
    'operatorId': operatorIdController,
    'plateNumber': plateNumberController,
    'motorcycle': motorcycleController,
    'bodyColor': bodyColorController,
    'bloodType': bloodTypeController,
    'medicalConditions': medicalConditionsController,
    'emergencyName': emergencyNameController,
    'emergencyRelation': emergencyRelationController,
    'emergencyNumber': emergencyNumberController,
  };

  bool nextStep() {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (!isLastStep) {
      _currentStep++;
      notifyListeners();
    }
    return true;
  }

  void previousStep() {
    if (_currentStep == 0) {
      return;
    }
    _currentStep--;
    formKey.currentState?.reset();
    notifyListeners();
  }

  Future<bool> signup() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.signup(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await clearDraft();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!value.contains('@')) return 'Please enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 10) return 'Password must be at least 10 characters';
    if (!RegExp(r'(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9])').hasMatch(value)) {
      return 'Use an uppercase letter, number, and special character';
    }
    return null;
  }

  String? validateConfirmation(String? value) {
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your mobile number';
    }
    return null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _draftSaveTimer?.cancel();
    for (final controller in _textControllers) {
      controller.removeListener(_scheduleDraftSave);
    }
    fullNameController.dispose();
    birthDateController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    yearsRidingController.dispose();
    operatorIdController.dispose();
    plateNumberController.dispose();
    motorcycleController.dispose();
    bodyColorController.dispose();
    bloodTypeController.dispose();
    medicalConditionsController.dispose();
    emergencyNameController.dispose();
    emergencyRelationController.dispose();
    emergencyNumberController.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/driver_registration.dart';
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
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final licenseExpiryController = TextEditingController();
  final yearsRidingController = TextEditingController();
  final serviceProviderController = TextEditingController(text: 'Angkas');
  final operatorIdController = TextEditingController();
  final plateNumberController = TextEditingController();
  final motorcycleController = TextEditingController();
  final bodyColorController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final medicalConditionsController = TextEditingController();
  final emergencyNameController = TextEditingController();
  final emergencyRelationController = TextEditingController();
  final emergencyNumberController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  bool _faceVerified = false;
  bool get faceVerified => _faceVerified;
  bool dataSharingConsent = false;

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
    firstNameController,
    lastNameController,
    birthDateController,
    addressController,
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
    ...otpControllers,
  ];

  void setFaceVerified(bool value) {
    _faceVerified = value;
    notifyListeners();
  }

  void setDataSharingConsent(bool value) {
    dataSharingConsent = value;
    notifyListeners();
  }

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
    'firstName': firstNameController,
    'lastName': lastNameController,
    'birthDate': birthDateController,
    'mobile': mobileController,
    'address': addressController,
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
    if (_currentStep == 4 && !_faceVerified) return false;
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
    if (!_faceVerified || !dataSharingConsent) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final registration = DriverRegistration(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dateOfBirth: _toIsoDate(birthDateController.text),
        address: addressController.text.trim(),
        mobileNumber: _toApiMobile(mobileController.text),
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
        serviceProvider: serviceProviderController.text,
        serviceId: operatorIdController.text.trim(),
        licenseNumber: licenseNumberController.text.trim(),
        licenseExpiresAt: _toIsoDate(licenseExpiryController.text),
        yearsRiding: int.parse(yearsRidingController.text.trim()),
        plateNumber: plateNumberController.text.trim(),
        vehicleModel: motorcycleController.text.trim(),
        vehicleColor: bodyColorController.text.trim(),
        bloodType: bloodTypeController.text.trim(),
        medicalConditions: medicalConditionsController.text.trim(),
        emergencyContacts: [
          {
            'name': emergencyNameController.text.trim(),
            'relation': emergencyRelationController.text.trim(),
            'number': _toApiMobile(emergencyNumberController.text),
          },
        ],
        otpCode: otpControllers.map((controller) => controller.text).join(),
        dataSharingConsent: dataSharingConsent,
      );
      await _authRepository.signup(registration);
      await clearDraft();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _toIsoDate(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 3) throw const FormatException('Invalid date');
    return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
  }

  String _toApiMobile(String value) {
    final digits = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (digits.startsWith('+63')) return digits;
    if (digits.startsWith('09')) return '+63${digits.substring(1)}';
    return digits;
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

  String? validateDate(String? value) {
    if (validateRequired(value) != null) return 'Enter a date';
    final parts = value!.trim().split('/');
    if (parts.length != 3 ||
        parts[0].length != 2 ||
        parts[1].length != 2 ||
        parts[2].length != 4 ||
        int.tryParse(parts[0]) == null ||
        int.tryParse(parts[1]) == null ||
        int.tryParse(parts[2]) == null) {
      return 'Use DD/MM/YYYY';
    }
    return null;
  }

  String? validateYearsRiding(String? value) {
    final years = int.tryParse(value?.trim() ?? '');
    if (years == null || years < 0 || years > 80) {
      return 'Enter a number from 0 to 80';
    }
    return null;
  }

  String? validateBloodType(String? value) {
    const bloodTypes = {
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
      'unknown',
    };
    if (!bloodTypes.contains(value?.trim())) {
      return 'Use a valid blood type, or unknown';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your mobile number';
    }
    final normalized = _toApiMobile(value);
    if (!RegExp(r'^\+639\d{9}$').hasMatch(normalized)) {
      return 'Use a valid PH number (+639XXXXXXXXX)';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your home address';
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || !RegExp(r'^\d$').hasMatch(value)) {
      return 'Enter one digit';
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
    firstNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    serviceProviderController.dispose();
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
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

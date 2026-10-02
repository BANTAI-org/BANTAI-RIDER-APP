import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/signup_controller.dart';
import 'forgot_password_widgets.dart';
import 'signup_step_layout.dart';

class SignupStepView extends StatelessWidget {
  const SignupStepView({super.key, required this.controller});

  final SignupController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: switch (controller.currentStep) {
        0 => _PersonalStep(controller: controller),
        1 => _AccountStep(controller: controller),
        2 => _LicenseStep(controller: controller),
        3 => _VehicleStep(controller: controller),
        4 => _FaceStep(controller: controller),
        _ => _VerifyStep(controller: controller),
      },
    );
  }
}

class _PersonalStep extends StatelessWidget {
  const _PersonalStep({required this.controller});
  final SignupController controller;

  @override
  Widget build(BuildContext context) => SignupStepLayout(
    step: 0,
    title: 'Personal details',
    description:
        'Responders use these to identify and reach you after a crash.',
    child: SignupSection(
      title: 'Rider identity',
      child: Column(
        children: [
          SignupField(
            controller: controller.firstNameController,
            label: 'First Name',
            validator: controller.validateRequired,
          ),
          SignupField(
            controller: controller.lastNameController,
            label: 'Last Name',
            validator: controller.validateRequired,
          ),
          SignupDateField(
            controller: controller.birthDateController,
            label: 'Birth date (DD/MM/YYYY)',
            validator: controller.validateDate,
            firstDate: DateTime(1900),
            lastDate: DateUtils.dateOnly(DateTime.now()),
          ),
          SignupField(
            controller: controller.addressController,
            label: 'Home Address',
            validator: controller.validateAddress,
          ),
        ],
      ),
    ),
  );
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({required this.controller});
  final SignupController controller;

  @override
  Widget build(BuildContext context) => SignupStepLayout(
    onBack: controller.previousStep,
    step: 1,
    title: 'Account & login',
    description:
        'We text your verification code and SOS confirmations to this number.',
    child: Column(
      children: [
        SignupSection(
          title: 'Contact',
          child: Column(
            children: [
              SignupField(
                controller: controller.mobileController,
                label: 'Mobile number',
                validator: controller.validateMobile,
                keyboardType: TextInputType.phone,
              ),
              SignupField(
                controller: controller.emailController,
                label: 'Email',
                validator: controller.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SignupSection(
          title: 'Password',
          child: Column(
            children: [
              SignupField(
                controller: controller.passwordController,
                label: 'Password',
                validator: controller.validatePassword,
                obscureText: true,
              ),
              SignupField(
                controller: controller.confirmPasswordController,
                label: 'Confirm password',
                validator: controller.validateConfirmation,
                obscureText: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LicenseStep extends StatelessWidget {
  const _LicenseStep({required this.controller});
  final SignupController controller;

  @override
  Widget build(BuildContext context) => SignupStepLayout(
    onBack: controller.previousStep,
    step: 2,
    title: 'License & operator',
    description:
        'Your operator is notified alongside the LGU whenever an SOS fires.',
    child: Column(
      children: [
        SignupSection(
          title: 'Service provider',
          child: DropdownMenuFormField<String>(
            controller: controller.serviceProviderController,
            width: double.infinity,
            expandedInsets: EdgeInsets.zero,
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: AppTheme.fieldFill,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: AppTheme.fieldBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: AppTheme.fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: AppTheme.brandRed),
              ),
            ),
            menuStyle: const MenuStyle(
              maximumSize: WidgetStatePropertyAll(Size.fromHeight(240)),
            ),
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'Angkas', label: 'Angkas'),
              DropdownMenuEntry(value: 'Move It', label: 'Move It'),
              DropdownMenuEntry(value: 'JoyRide', label: 'JoyRide'),
              DropdownMenuEntry(value: 'Grab', label: 'Grab'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SignupSection(
          title: "Driver's license",
          child: Column(
            children: [
              SignupField(
                controller: controller.licenseNumberController,
                label: 'License number',
                validator: controller.validateRequired,
              ),
              SignupDateField(
                controller: controller.licenseExpiryController,
                label: 'Expiry date (DD/MM/YYYY)',
                validator: controller.validateDate,
                firstDate: DateUtils.dateOnly(DateTime.now()),
                lastDate: DateTime(2100),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SignupSection(
          title: 'Experience',
          child: Column(
            children: [
              SignupField(
                controller: controller.yearsRidingController,
                label: 'Years riding',
                validator: controller.validateYearsRiding,
                keyboardType: TextInputType.number,
              ),
              SignupField(
                controller: controller.operatorIdController,
                label: 'Operator ID',
                validator: controller.validateRequired,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _VehicleStep extends StatelessWidget {
  const _VehicleStep({required this.controller});
  final SignupController controller;

  @override
  Widget build(BuildContext context) => SignupStepLayout(
    onBack: controller.previousStep,
    step: 3,
    title: 'Vehicle & medical info',
    description: 'Plate, bike, and blood type are read aloud to responders during an SOS.',
    child: Column(
      children: [
        SignupSection(
          title: 'Vehicle',
          child: Column(
            children: [
              SignupField(
                controller: controller.plateNumberController,
                label: 'Plate number',
                validator: controller.validateRequired,
              ),
              SignupField(
                controller: controller.motorcycleController,
                label: 'Motorcycle',
                validator: controller.validateRequired,
              ),
              SignupField(
                controller: controller.bodyColorController,
                label: 'Body color',
                validator: controller.validateRequired,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SignupSection(
          title: 'Medical',
          child: Column(
            children: [
              SignupField(
                controller: controller.bloodTypeController,
                label: 'Blood type',
                validator: controller.validateBloodType,
              ),
              SignupField(
                controller: controller.medicalConditionsController,
                label: 'Conditions / allergies',
                validator: controller.validateRequired,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SignupSection(
          title: 'Emergency contact',
          child: Column(
            children: [
              SignupField(
                controller: controller.emergencyNameController,
                label: 'Contact name',
                validator: controller.validateRequired,
              ),
              SignupField(
                controller: controller.emergencyRelationController,
                label: 'Relation',
                validator: controller.validateRequired,
              ),
              SignupField(
                controller: controller.emergencyNumberController,
                label: 'Contact number',
                keyboardType: TextInputType.phone,
                validator: controller.validateMobile,
              ),
            ],
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: controller.dataSharingConsent,
          onChanged: (value) {
            controller.setDataSharingConsent(value ?? false);
          },
          title: const Text(
            'I consent to sharing these details for rider safety.',
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    ),
  );
}

class _FaceStep extends StatefulWidget {
  const _FaceStep({required this.controller});

  final SignupController controller;

  @override
  State<_FaceStep> createState() => _FaceStepState();
}

class _FaceStepState extends State<_FaceStep> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _isUnlocked = false;
  String? _errorMessage;

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final isSupported = await _localAuthentication.isDeviceSupported();
      final biometrics = await _localAuthentication.getAvailableBiometrics();
      if (!isSupported || biometrics.isEmpty) {
        setState(() {
          _errorMessage =
              'Set up Face ID or another biometric on this device first.';
        });
        return;
      }

      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Use facial unlock to confirm your rider identity.',
        biometricOnly: true,
      );
      if (!mounted) return;
      setState(() => _isUnlocked = authenticated);
      widget.controller.setFaceVerified(authenticated);
    } on LocalAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = switch (error.code) {
          LocalAuthExceptionCode.noBiometricsEnrolled ||
          LocalAuthExceptionCode.noBiometricHardware =>
            'Set up Face ID or another biometric on this device first.',
          LocalAuthExceptionCode.authInProgress =>
            'Another biometric prompt is already open.',
          LocalAuthExceptionCode.userCanceled => 'Facial unlock was canceled.',
          _ => 'Facial unlock could not be completed. Please try again.',
        };
      });
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) => SignupStepLayout(
    onBack: widget.controller.previousStep,
    step: 4,
    title: 'Face enrollment',
    description: 'Used to unlock the hands-free flow and confirm it is you standing down an SOS.',
    child: Column(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Icon(
              Icons.face_retouching_natural_outlined,
              color: Colors.white54,
              size: 72,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Position your face inside the frame',
          style: TextStyle(color: Color(0xFF7B818C)),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _isAuthenticating ? null : _authenticate,
          icon: _isAuthenticating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _isUnlocked
                      ? Icons.check_circle_outline
                      : Icons.face_retouching_natural_outlined,
                ),
          label: Text(
            _isUnlocked ? 'Facial unlock enabled' : 'Enable facial unlock',
          ),
        ),
        if (_errorMessage case final message?) ...[
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ],
      ],
    ),
  );
}

class _VerifyStep extends StatelessWidget {
  const _VerifyStep({required this.controller});
  final SignupController controller;

  @override
  Widget build(BuildContext context) => SignupStepLayout(
    onBack: controller.previousStep,
    step: 5,
    title: 'Verify your number',
    description: 'One last step before crash detection can be switched on.',
    child: Column(
      children: [
        const Icon(
          Icons.mark_chat_unread_rounded,
          color: Color(0xFFE4001B),
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the 6-digit code sent to ${controller.mobileController.text.trim()}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        OtpFields(
          controllers: controller.otpControllers,
          validator: controller.validateOtp,
        ),
      ],
    ),
  );
}

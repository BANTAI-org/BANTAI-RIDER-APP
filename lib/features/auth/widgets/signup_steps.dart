import 'package:flutter/material.dart';

import '../controllers/signup_controller.dart';
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
        4 => const _FaceStep(),
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
            controller: controller.fullNameController,
            label: 'Full name',
            validator: controller.validateRequired,
          ),
          SignupField(
            controller: controller.birthDateController,
            label: 'Birth date (DD/MM/YYYY)',
            validator: controller.validateRequired,
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
    step: 2,
    title: 'License & operator',
    description:
        'Your operator is notified alongside the LGU whenever an SOS fires.',
    child: Column(
      children: [
        SignupSection(
          title: 'Service provider',
          child: DropdownButtonFormField<String>(
            initialValue: 'Angkas',
            items: const [
              DropdownMenuItem(value: 'Angkas', child: Text('Angkas')),
            ],
            onChanged: (_) {},
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
              SignupField(
                controller: controller.licenseExpiryController,
                label: 'Expiry date (DD/MM/YYYY)',
                validator: controller.validateRequired,
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
                validator: controller.validateRequired,
                keyboardType: TextInputType.number,
              ),
              SignupField(
                controller: controller.operatorIdController,
                label: 'Operator ID',
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
              ),
              SignupField(
                controller: controller.medicalConditionsController,
                label: 'Conditions / allergies',
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
              ),
              SignupField(
                controller: controller.emergencyNumberController,
                label: 'Contact number',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FaceStep extends StatelessWidget {
  const _FaceStep();

  @override
  Widget build(BuildContext context) => SignupStepLayout(
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
      ],
    ),
  );
}

class _VerifyStep extends StatelessWidget {
  const _VerifyStep({required this.controller});
  final SignupController controller;

  @override
  Widget build(BuildContext context) => SignupStepLayout(
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
        Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

import '../controllers/forgot_password_controller.dart';
import '../widgets/forgot_password_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController()..addListener(_refresh);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _controller.formKey,
        child: _buildStep(context),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_controller.step) {
      case ForgotPasswordStep.requestCode:
        return AuthFlowLayout(
          step: 1,
          title: 'Reset your password',
          description: 'We send a 6-digit code to the number or email on your rider account.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send code by', style: TextStyle(fontSize: 12, color: Color(0xFF858894))),
              const SizedBox(height: 6),
              _channelPicker(),
              const SizedBox(height: 18),
              AuthField(
                controller: _controller.emailController,
                label: _controller.resetChannel == ResetChannel.email
                    ? 'Email'
                    : 'Mobile number',
                hint: _controller.resetChannel == ResetChannel.email
                    ? 'kilrbygabano@email.com'
                    : '+63 9XX XXX XXXX',
                validator: _controller.validateAccount,
                keyboardType: _controller.resetChannel == ResetChannel.email
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
              ),
              const SizedBox(height: 18),
              AuthActionButton(label: 'Send reset code', onPressed: _controller.sendResetCode),
              const SizedBox(height: 20),
              AuthInfoCard(
                title: "Can't receive a code?",
                body: 'If the number and email on your account are out of reach, ask your command center to reset it for you.',
                child: OutlinedButton(
                  onPressed: _controller.openAdminReset,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(34),
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFFE1E1E7)),
                  ),
                  child: const Text('Request admin reset', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        );
      case ForgotPasswordStep.verifyCode:
        return AuthFlowLayout(
          step: 2,
          title: 'Enter the code',
          description: 'Codes expire after 10 minutes for account safety.',
          onBack: _controller.back,
          child: Column(
            children: [
              const Text('🤝', style: TextStyle(fontSize: 30)),
              const SizedBox(height: 12),
              const Text('Enter the 6-digit code we texted to',
                  style: TextStyle(fontSize: 10, color: Color(0xFF858894))),
              const Text('USER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              OtpFields(controllers: _controller.otpControllers),
              const SizedBox(height: 10),
              const Text('↻ Resend code in 27s',
                  style: TextStyle(fontSize: 10, color: Color(0xFF858894))),
              const SizedBox(height: 20),
              AuthActionButton(label: 'Verify code', onPressed: _controller.verifyCode),
              const SizedBox(height: 14),
              const Text('Never share this code. B.A.N.T.A.I. dispatch will never ask you to read it out.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: Color(0xFF858894))),
            ],
          ),
        );
      case ForgotPasswordStep.newPassword:
        return AuthFlowLayout(
          step: 3,
          title: 'Set a new password',
          description: 'Choose something you can recall with gloves on and a helmet down.',
          onBack: _controller.back,
          child: Column(
            children: [
              AuthField(controller: _controller.passwordController, label: 'New', hint: 'At least 6 characters', validator: _controller.validatePassword, obscureText: true),
              AuthField(controller: _controller.confirmPasswordController, label: 'Confirm', hint: 'Re-type password', validator: _controller.validateConfirmation, obscureText: true),
              const SizedBox(height: 18),
              AuthActionButton(label: 'Save new password', onPressed: _controller.savePassword),
            ],
          ),
        );
      case ForgotPasswordStep.adminRequest:
        return AuthFlowLayout(
          step: 1,
          title: 'Request a reset from your admin',
          description: 'Use this if you can no longer receive codes on the number or email registered to your account.',
          onBack: _controller.back,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthField(controller: _controller.callSignController, label: 'Call sign', hint: 'BRGY-171-1', validator: _controller.validateRequired),
              AuthField(controller: _controller.mobileController, label: 'Contact', hint: '+63 XXX XXX XXXX', validator: _controller.validateRequired, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              const Text('Your administrator will verify your identity before issuing a temporary password.', style: TextStyle(fontSize: 9, color: Color(0xFF858894))),
              const SizedBox(height: 18),
              AuthActionButton(label: 'Send request to Barangay 171', onPressed: _controller.requestAdminReset),
            ],
          ),
        );
      case ForgotPasswordStep.adminSent:
        return AuthFlowLayout(
          step: 1,
          title: 'Reset request sent',
          description: 'Barangay 171 Command Center has been notified. An administrator will verify your identity and issue a temporary password.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthInfoCard(
                title: 'Request details',
                body: 'Your request is being reviewed. You can sign in again after the command center confirms your identity.',
                child: const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),
              AuthActionButton(label: 'Back to Sign In', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        );
    }
  }

  Widget _channelPicker() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: _channel(
                'SMS',
                ResetChannel.sms,
              ),
            ),
            Expanded(
              child: _channel(
                'Email',
                ResetChannel.email,
              ),
            ),
          ],
        ),
      );

  Widget _channel(String label, ResetChannel channel) => InkWell(
        onTap: () => _controller.setResetChannel(channel),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _controller.resetChannel == channel
                ? Colors.white
                : const Color(0xFFF0F0F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _controller.resetChannel == channel
                  ? const Color(0xFFE1E1E7)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      );
}

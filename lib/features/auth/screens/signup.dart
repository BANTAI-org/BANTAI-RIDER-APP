import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../controllers/signup_controller.dart';
import '../widgets/signup_steps.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final SignupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignupController(widget.authRepository)
      ..addListener(_refresh);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _handleSignup() async {
    try {
      if (!await _controller.otpSignupVerification()) return;

      if (await _controller.signup() && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign up failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SignupStepView(
                controller: _controller,
                onExit: () => Navigator.of(context).pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _controller.isLoading
                      ? null
                      : (_controller.isLastStep
                            ? _handleSignup
                            : _controller.nextStep),
                  child: _controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _controller.isLastStep
                              ? 'Verify & Create Account'
                              : 'Continue',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

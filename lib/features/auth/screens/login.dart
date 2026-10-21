import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';
import '../../home/screens/home_shell.dart';
import 'forgot_password.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(widget.authRepository)..addListener(_refresh);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _handleLogin() async {
    try {
      final didLogin = await _controller.login();
      if (!mounted || !didLogin) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleDeviceLogin() async {
    try {
      final didLogin = await _controller.loginWithDeviceSecurity();
      if (!mounted) return;
      if (didLogin) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No remembered session is available. Log in and enable Keep me signed in first.',
          ),
        ),
      );
    } on LocalAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_deviceAuthErrorMessage(error)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final credential = await _controller.loginWithGoogle();
      if (!mounted) return;
      if (credential != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SignupPage(
              authRepository: widget.authRepository,
              googleCredential: credential,
            ),
          ),
        );
      } else if (_controller.googleLoginSucceeded) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google authentication failed: $error'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _deviceAuthErrorMessage(LocalAuthException error) {
    return switch (error.code) {
      LocalAuthExceptionCode.userCanceled =>
        'Device authentication was canceled.',
      LocalAuthExceptionCode.noBiometricsEnrolled ||
      LocalAuthExceptionCode.noBiometricHardware =>
        'Set up Face ID, fingerprint, or a device password first.',
      _ => 'Device authentication failed. Please try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: LoginForm.themeRed,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    LoginHeader(size: size),
                    Expanded(
                      child: LoginForm(
                        controller: _controller,
                        onLogin: _handleLogin,
                        onDeviceLogin: _handleDeviceLogin,
                        onGoogleLogin: _handleGoogleLogin,
                        onSignUp: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignupPage(
                              authRepository: widget.authRepository,
                            ),
                          ),
                        ),
                        onForgotPassword: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordPage(
                              authRepository: widget.authRepository,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

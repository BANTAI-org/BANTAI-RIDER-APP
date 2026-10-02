import 'package:flutter/material.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login successful!')));
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: LoginForm.themeRed,
      body: SafeArea(
        bottom: false,
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
                        onSignUp: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignupPage(
                              authRepository: widget.authRepository,
                            ),
                          ),
                        ),
                        onForgotPassword: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
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

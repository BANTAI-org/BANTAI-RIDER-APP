import 'package:flutter/material.dart';

import '../controllers/login_controller.dart';
import 'login_text_field.dart';
import 'social_auth_button.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.controller,
    required this.onLogin,
    this.onSignUp,
    this.onForgotPassword,
  });

  static const themeRed = Color(0xFFE51D24);

  final LoginController controller;
  final VoidCallback onLogin;
  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 24),
            LoginTextField(
              controller: controller.identifierController,
              hintText: 'Email',
              prefixIcon: Icons.mail_outline_rounded,
              validator: controller.validateIdentifier,
            ),
            const SizedBox(height: 16),
            LoginTextField(
              controller: controller.passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              obscureText: controller.obscurePassword,
              onToggleVisibility: controller.togglePasswordVisibility,
              validator: controller.validatePassword,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: controller.keepMeSignedIn,
                      onChanged: controller.toggleKeepMeSignedIn,
                      activeColor: themeRed,
                    ),
                    const Text('Keep me signed in'),
                  ],
                ),
                TextButton(
                  onPressed: onForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isLoading ? null : onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: controller.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Log In'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or Continue With',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SocialAuthButton(
                    label: 'Google',
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SocialAuthButton(
                    label: 'Apple',
                    icon: const Icon(Icons.apple, size: 22),
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: onSignUp,
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    children: [
                      TextSpan(text: "Don't have any account? "),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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

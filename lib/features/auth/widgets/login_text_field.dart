import 'package:flutter/material.dart';

import 'forgot_password_widgets.dart';

class LoginTextField extends StatelessWidget {
  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return AuthField(
      controller: controller,
      label: null,
      obscureText: isPassword && obscureText,
      validator: validator,
      hint: hintText,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF858894), size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF858894),
                size: 20,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
    );
  }
}

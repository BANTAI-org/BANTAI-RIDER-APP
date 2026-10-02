import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AuthFlowHeader extends StatelessWidget {
  const AuthFlowHeader({
    super.key,
    required this.label,
    required this.step,
    required this.totalSteps,
    this.onBack,
  });

  final String label;
  final int step;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_left, size: 18),
            ),
          if (onBack != null) const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
          const Spacer(),
          Text(
            'Step $step of $totalSteps',
            style: const TextStyle(fontSize: 10, color: AppTheme.muted),
          ),
        ],
      ),
      const SizedBox(height: 10),
      LinearProgressIndicator(
        value: step / totalSteps,
        minHeight: 2,
        backgroundColor: AppTheme.fieldBorder,
        color: AppTheme.brandRed,
      ),
    ],
  );
}

class AuthFlowLayout extends StatelessWidget {
  const AuthFlowLayout({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.child,
    this.headerLabel,
    this.onBack,
  });

  final int step;
  final String title;
  final String description;
  final Widget child;
  final String? headerLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthFlowHeader(
                label: headerLabel ?? (onBack == null ? 'Sign In' : 'Back'),
                step: step,
                totalSteps: 3,
                onBack: onBack,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 42,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    ),
  );
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
  });
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    obscureText: obscureText,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 12, color: AppTheme.muted),
      hintStyle: const TextStyle(fontSize: 12, color: AppTheme.muted),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: AppTheme.brandRed),
      errorBorder: _border(color: Colors.redAccent),
      focusedErrorBorder: _border(color: Colors.redAccent),
    ),
  );

  OutlineInputBorder _border({Color? color}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color ?? AppTheme.fieldBorder),
  );
}

class OtpFields extends StatelessWidget {
  const OtpFields({super.key, required this.controllers, this.validator});
  final List<TextEditingController> controllers;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < controllers.length; index++) ...[
        Expanded(
          child: TextFormField(
            controller: controllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            validator: validator,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppTheme.fieldFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: _otpBorder(),
              enabledBorder: _otpBorder(),
              focusedBorder: _otpBorder(color: AppTheme.brandRed),
              errorBorder: _otpBorder(color: Colors.redAccent),
              focusedErrorBorder: _otpBorder(color: Colors.redAccent),
            ),
          ),
        ),
        if (index != controllers.length - 1) const SizedBox(width: 5),
      ],
    ],
  );

  OutlineInputBorder _otpBorder({Color? color}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color ?? AppTheme.fieldBorder),
  );
}

class AuthInfoCard extends StatelessWidget {
  const AuthInfoCard({
    super.key,
    required this.title,
    required this.body,
    required this.child,
  });
  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE1E1E7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.muted,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.surface,
    body: SafeArea(child: child),
  );
}

import 'package:flutter/material.dart';

class SignupStepLayout extends StatelessWidget {
  const SignupStepLayout({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.child,
  });

  final int step;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step ${step + 1} of 6', style: _eyebrowStyle),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (step + 1) / 6,
            minHeight: 3,
            backgroundColor: const Color(0xFFE5E7EB),
            color: const Color(0xFFE4001B),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF7B818C), height: 1.35),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  static const _eyebrowStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF7B818C),
  );
}

class SignupField extends StatelessWidget {
  const SignupField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class SignupSection extends StatelessWidget {
  const SignupSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7B818C),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

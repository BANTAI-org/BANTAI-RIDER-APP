import 'package:flutter/material.dart';

import 'auth_flow_widgets.dart';

class SignupStepLayout extends StatelessWidget {
  const SignupStepLayout({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.child,
    this.onBack,
  });

  final int step;
  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthFlowHeader(
            label: 'Create account',
            step: step + 1,
            totalSteps: 6,
            onBack: onBack,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuthField(
        controller: controller,
        label: label,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}

class SignupDateField extends StatelessWidget {
  const SignupDateField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.firstDate,
    required this.lastDate,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AuthField(
        controller: controller,
        label: label,
        readOnly: true,
        validator: validator,
        onTap: () => _pickDate(context),
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final currentValue = _parseDate(controller.text);
    final today = DateUtils.dateOnly(DateTime.now());
    final boundedInitialDate =
        currentValue != null &&
            !currentValue.isBefore(firstDate) &&
            !currentValue.isAfter(lastDate)
        ? currentValue
        : (today.isBefore(firstDate)
              ? firstDate
              : today.isAfter(lastDate)
              ? lastDate
              : today);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: boundedInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: label,
      fieldLabelText: label,
      errorFormatText: 'Use the calendar to select a date',
      errorInvalidText: 'Select a valid date',
    );
    if (pickedDate == null) return;

    final date = DateUtils.dateOnly(pickedDate);
    controller.text =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';
  }

  DateTime? _parseDate(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? DateUtils.dateOnly(date)
        : null;
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

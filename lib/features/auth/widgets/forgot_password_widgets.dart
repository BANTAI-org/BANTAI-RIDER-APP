import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/forgot_password_controller.dart';

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

class OtpFields extends StatefulWidget {
  const OtpFields({super.key, required this.controllers, this.validator});
  final List<TextEditingController> controllers;
  final String? Function(String?)? validator;

  @override
  State<OtpFields> createState() => _OtpFieldsState();
}

class _OtpFieldsState extends State<OtpFields> {
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.controllers.length, (_) => FocusNode());
  }

  void _handleChanged(int index, String value) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        widget.controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      widget.controllers[index - 1].selection = TextSelection.collapsed(
        offset: widget.controllers[index - 1].text.length,
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < widget.controllers.length; index++) ...[
        Expanded(
          child: Focus(
            onKeyEvent: (_, event) => _handleKey(index, event),
            child: TextFormField(
              controller: widget.controllers[index],
              focusNode: _focusNodes[index],
              autofocus: index == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: index == widget.controllers.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 1,
              validator: widget.validator,
              onChanged: (value) => _handleChanged(index, value),
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
        ),
        if (index != widget.controllers.length - 1) const SizedBox(width: 5),
      ],
    ],
  );

  OutlineInputBorder _otpBorder({Color? color}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color ?? AppTheme.fieldBorder),
  );

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
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

class AuthFlowLayout extends StatelessWidget {
  const AuthFlowLayout({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.child,
    this.headerLabel,
    this.onBack,
    this.scrollable = true,
  });

  final int step;
  final String title;
  final String description;
  final Widget child;
  final String? headerLabel;
  final VoidCallback? onBack;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
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
    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}

class ForgotPasswordStepView extends StatelessWidget {
  const ForgotPasswordStepView({
    super.key,
    required this.controller,
    required this.onExit,
    required this.onPasswordReset,
  });

  final ForgotPasswordController controller;
  final VoidCallback onExit;
  final Future<void> Function() onPasswordReset;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                switch (controller.step) {
                  ForgotPasswordStep.requestCode => _RequestCodeStep(
                    controller: controller,
                    onExit: onExit,
                  ),
                  ForgotPasswordStep.verifyCode => _VerifyCodeStep(
                    controller: controller,
                  ),
                  ForgotPasswordStep.newPassword => _NewPasswordStep(
                    controller: controller,
                    onPasswordReset: onPasswordReset,
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestCodeStep extends StatelessWidget {
  const _RequestCodeStep({required this.controller, required this.onExit});

  final ForgotPasswordController controller;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => AuthFlowLayout(
    step: 1,
    onBack: onExit,
    headerLabel: 'Back to sign in',
    title: 'Reset your password',
    description:
        'We send a 6-digit code to the number or email on your rider account.',
    scrollable: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send code by',
          style: TextStyle(fontSize: 12, color: Color(0xFF858894)),
        ),
        const SizedBox(height: 6),
        _ChannelPicker(controller: controller),
        const SizedBox(height: 18),
        AuthField(
          controller: controller.resetChannel == ResetChannel.email
              ? controller.emailController
              : controller.mobileController,
          label: controller.resetChannel == ResetChannel.email
              ? 'Email'
              : 'Mobile number',
          hint: controller.resetChannel == ResetChannel.email
              ? 'kilrbygabano@email.com'
              : '+63 9XX XXX XXXX',
          validator: controller.validateAccount,
          keyboardType: controller.resetChannel == ResetChannel.email
              ? TextInputType.emailAddress
              : TextInputType.phone,
        ),
        const SizedBox(height: 18),
        AuthActionButton(
          label: 'Send reset code',
          isLoading: controller.isLoading,
          onPressed: () => controller.sendResetCode(),
        ),
      ],
    ),
  );
}

class _VerifyCodeStep extends StatelessWidget {
  const _VerifyCodeStep({required this.controller});

  final ForgotPasswordController controller;

  @override
  Widget build(BuildContext context) => AuthFlowLayout(
    step: 2,
    title: 'Enter the code',
    description: 'Codes expire after 10 minutes for account safety.',
    onBack: controller.back,
    scrollable: false,
    child: Column(
      children: [
        const Text('🤝', style: TextStyle(fontSize: 30)),
        const SizedBox(height: 12),
        const Text(
          'Enter the 6-digit code we texted to',
          style: TextStyle(fontSize: 10, color: Color(0xFF858894)),
        ),
        const Text(
          'USER',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        OtpFields(controllers: controller.otpControllers),
        const SizedBox(height: 10),
        TextButton(
          onPressed: controller.canResend ? controller.resendCode : null,
          child: Text(
            controller.resendSeconds > 0
                ? 'Resend code in ${controller.resendSeconds}s'
                : 'Resend code',
            style: const TextStyle(fontSize: 10),
          ),
        ),
        const SizedBox(height: 20),
        AuthActionButton(
          label: 'Verify code',
          isLoading: controller.isLoading,
          onPressed: () => controller.verifyCode(),
        ),
        const SizedBox(height: 14),
        const Text(
          'Never share this code. B.A.N.T.A.I. dispatch will never ask you to read it out.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, color: Color(0xFF858894)),
        ),
      ],
    ),
  );
}

class _NewPasswordStep extends StatelessWidget {
  const _NewPasswordStep({
    required this.controller,
    required this.onPasswordReset,
  });

  final ForgotPasswordController controller;
  final Future<void> Function() onPasswordReset;

  @override
  Widget build(BuildContext context) => AuthFlowLayout(
    step: 3,
    title: 'Set a new password',
    description:
        'Choose something you can recall with gloves on and a helmet down.',
    onBack: controller.back,
    scrollable: false,
    child: Column(
      children: [
        AuthField(
          controller: controller.passwordController,
          label: 'New',
          hint: 'At least 6 characters',
          validator: controller.validatePassword,
          obscureText: true,
        ),
        AuthField(
          controller: controller.confirmPasswordController,
          label: 'Confirm',
          hint: 'Re-type password',
          validator: controller.validateConfirmation,
          obscureText: true,
        ),
        const SizedBox(height: 18),
        AuthActionButton(
          label: 'Save new password',
          isLoading: controller.isLoading,
          onPressed: () async {
            if (await controller.savePassword()) {
              await onPasswordReset();
            }
          },
        ),
      ],
    ),
  );
}

class _ChannelPicker extends StatelessWidget {
  const _ChannelPicker({required this.controller});

  final ForgotPasswordController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: _Channel(
            label: 'SMS',
            channel: ResetChannel.sms,
            controller: controller,
          ),
        ),
        Expanded(
          child: _Channel(
            label: 'Email',
            channel: ResetChannel.email,
            controller: controller,
          ),
        ),
      ],
    ),
  );
}

class _Channel extends StatelessWidget {
  const _Channel({
    required this.label,
    required this.channel,
    required this.controller,
  });

  final String label;
  final ResetChannel channel;
  final ForgotPasswordController controller;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => controller.setResetChannel(channel),
    borderRadius: BorderRadius.circular(8),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: controller.resetChannel == channel
            ? Colors.white
            : const Color(0xFFF0F0F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: controller.resetChannel == channel
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

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 42,
    child: FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.brandRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    ),
  );
}

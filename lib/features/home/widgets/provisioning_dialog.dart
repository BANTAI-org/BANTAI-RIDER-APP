import 'package:flutter/material.dart';

import '../../../data/services/provisioning_service.dart';
import '../controllers/scan_controller.dart';

class ProvisioningDialog extends StatefulWidget {
  const ProvisioningDialog({
    super.key,
    required this.controller,
    this.onProvision,
  });

  final ScanController controller;
  final Future<bool> Function()? onProvision;

  @override
  State<ProvisioningDialog> createState() => _ProvisioningDialogState();
}

class _ProvisioningDialogState extends State<ProvisioningDialog> {
  final _setupTokenController = TextEditingController();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isProvisioning = false;

  @override
  void dispose() {
    _setupTokenController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        final step = widget.controller.provisioningStep;
        final identity = widget.controller.scannedPiIdentity;

        return AlertDialog(
          title: Text(_dialogTitle(step)),
          content: _buildContent(step, identity),
          actions: _buildActions(step),
        );
      },
    );
  }

  String _dialogTitle(ProvisioningStep step) {
    return switch (step) {
      ProvisioningStep.scanningQr => 'Device Detected',
      ProvisioningStep.connectingBle => 'Connecting...',
      ProvisioningStep.authenticating => 'Authenticating...',
      ProvisioningStep.sendingCredentials => 'Sending Credentials...',
      ProvisioningStep.completed => 'Setup Complete',
      ProvisioningStep.error => 'Setup Failed',
      ProvisioningStep.idle => 'Provision Device',
    };
  }

  Widget _buildContent(ProvisioningStep step, PiIdentity? identity) {
    if (step == ProvisioningStep.completed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(
            'Successfully connected to ${identity?.deviceId ?? "device"}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'The Pi will now connect to your phone\'s hotspot.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    if (step == ProvisioningStep.error) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            widget.controller.pairingError ?? 'An error occurred',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (step == ProvisioningStep.connectingBle ||
        step == ProvisioningStep.authenticating ||
        step == ProvisioningStep.sendingCredentials) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _statusMessage(step),
            textAlign: TextAlign.center,
          ),
          if (identity != null) ...[
            const SizedBox(height: 8),
            Text(
              'Device: ${identity.deviceId}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      );
    }

    // Show the form for setup token and hotspot credentials
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (identity != null) ...[
              Text(
                'Device: ${identity.deviceId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Setup Token',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _setupTokenController,
              decoration: const InputDecoration(
                hintText: 'Enter the setup token from the Pi',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Setup token is required';
                }
                return null;
              },
              onChanged: (value) => widget.controller.setSetupToken(value.trim()),
            ),
            const SizedBox(height: 20),
            const Text(
              'Phone Hotspot Credentials',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'The Pi will connect to your phone\'s hotspot for internet access.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Hotspot SSID',
                hintText: 'Your hotspot name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'SSID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Hotspot Password',
                hintText: 'Your hotspot password',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
              onChanged: (value) {
                widget.controller.setHotspotCredentials(
                  _ssidController.text.trim(),
                  value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _statusMessage(ProvisioningStep step) {
    return switch (step) {
      ProvisioningStep.connectingBle => 'Establishing secure connection...',
      ProvisioningStep.authenticating => 'Verifying setup token...',
      ProvisioningStep.sendingCredentials => 'Sending hotspot credentials...',
      _ => 'Processing...',
    };
  }

  List<Widget> _buildActions(ProvisioningStep step) {
    if (step == ProvisioningStep.completed) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Done'),
        ),
      ];
    }

    if (step == ProvisioningStep.error) {
      return [
        TextButton(
          onPressed: () {
            widget.controller.resetProvisioning();
            Navigator.of(context).pop(false);
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () => widget.controller.resetProvisioning(),
          child: const Text('Retry'),
        ),
      ];
    }

    if (step == ProvisioningStep.connectingBle ||
        step == ProvisioningStep.authenticating ||
        step == ProvisioningStep.sendingCredentials) {
      return [
        TextButton(
          onPressed: _isProvisioning ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () {
          widget.controller.resetProvisioning();
          Navigator.of(context).pop(false);
        },
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _startProvisioning,
        child: _isProvisioning
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Start Setup'),
      ),
    ];
  }

  Future<void> _startProvisioning() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.controller.setSetupToken(_setupTokenController.text.trim());
    widget.controller.setHotspotCredentials(
      _ssidController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isProvisioning = true);

    try {
      final success = widget.onProvision != null
          ? await widget.onProvision!()
          : await widget.controller.startProvisioning();

      if (success && mounted) {
        // Dialog will remain open showing success state
      }
    } finally {
      if (mounted) {
        setState(() => _isProvisioning = false);
      }
    }
  }
}

Future<bool?> showProvisioningDialog(
  BuildContext context, {
  required ScanController controller,
  Future<bool> Function()? onProvision,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProvisioningDialog(
      controller: controller,
      onProvision: onProvision,
    ),
  );
}

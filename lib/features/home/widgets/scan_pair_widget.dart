import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/scan_controller.dart';
import 'provisioning_dialog.dart';

class ScanPairWidget extends StatelessWidget {
  const ScanPairWidget({
    super.key,
    required this.controller,
    required this.isPairing,
    required this.pairingError,
    required this.onQrDetected,
    required this.onEnterPairingCode,
    required this.onUnpairDevice,
    required this.onReportLostDevice,
  });

  final ScanController controller;
  final bool isPairing;
  final String? pairingError;
  final ValueChanged<String> onQrDetected;
  final VoidCallback onEnterPairingCode;
  final VoidCallback onUnpairDevice;
  final VoidCallback onReportLostDevice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: _cardDecoration,
          child: Column(
            children: [
              _QrScannerFrame(
                controller: controller,
                isPairing: isPairing,
                pairingError: pairingError,
                onQrDetected: onQrDetected,
              ),
              const SizedBox(height: 12),
              const Text(
                'Point at the QR sticker on the Pi 5 enclosure to pair',
                style: TextStyle(color: Color(0xFF8D8E94), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PairAction(
          icon: Icons.link_rounded,
          title: 'Enter pairing code manually',
          subtitle: 'Use the 8-digit code printed under the QR',
          color: const Color(0xFF1CCB68),
          onTap: onEnterPairingCode,
        ),
        _PairAction(
          icon: Icons.link_off_rounded,
          title: 'Unpair BANTAI-PI-4471',
          subtitle: 'Stops recording and clears local keys',
          color: const Color(0xFFE51D24),
          onTap: onUnpairDevice,
        ),
      ],
    );
  }
}

class _QrScannerFrame extends StatefulWidget {
  const _QrScannerFrame({
    required this.controller,
    required this.isPairing,
    required this.pairingError,
    required this.onQrDetected,
  });

  final ScanController controller;
  final bool isPairing;
  final String? pairingError;
  final ValueChanged<String> onQrDetected;

  @override
  State<_QrScannerFrame> createState() => _QrScannerFrameState();
}

class _QrScannerFrameState extends State<_QrScannerFrame> {
  late final MobileScannerController _scannerController;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    widget.controller.addListener(_onProvisioningChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onProvisioningChange);
    _scannerController.dispose();
    super.dispose();
  }

  void _onProvisioningChange() {
    final step = widget.controller.provisioningStep;
    final identity = widget.controller.scannedPiIdentity;

    debugPrint(
      '[BANTAI] _onProvisioningChange: step=$step, identity=${identity?.deviceId}, _dialogShown=$_dialogShown, mounted=$mounted',
    );

    if (identity != null &&
        (step == ProvisioningStep.awaitingDetails ||
            step == ProvisioningStep.connectingBle) &&
        !_dialogShown &&
        mounted) {
      debugPrint('[BANTAI] Showing provisioning dialog');
      _dialogShown = true;
      _scannerController.stop();
      showProvisioningDialog(
        context,
        controller: widget.controller,
        onProvision: () {
          debugPrint('[BANTAI] onProvision called');
          return widget.controller.startProvisioning();
        },
      ).then((_) {
        _dialogShown = false;
        _scannerController.start();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final code = capture.barcodes
                  .map((barcode) => barcode.rawValue)
                  .whereType<String>()
                  .firstOrNull;
              if (code != null) {
                widget.onQrDetected(code);
              }
            },
          ),
          IgnorePointer(child: CustomPaint(painter: _ScannerCornersPainter())),
          if (widget.isPairing)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF18D665)),
            ),
          if (widget.pairingError != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xD9000000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.pairingError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF18D665)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 21.0;
    const inset = 20.0;
    final paths = [
      Path()
        ..moveTo(inset + length, inset)
        ..lineTo(inset, inset)
        ..lineTo(inset, inset + length),
      Path()
        ..moveTo(size.width - inset - length, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, inset + length),
      Path()
        ..moveTo(inset, size.height - inset - length)
        ..lineTo(inset, size.height - inset)
        ..lineTo(inset + length, size.height - inset),
      Path()
        ..moveTo(size.width - inset, size.height - inset - length)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset - length, size.height - inset),
    ];
    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
    canvas.drawLine(
      Offset(inset + 7, size.height / 2),
      Offset(size.width - inset - 7, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PairAction extends StatelessWidget {
  const _PairAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: color, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF92939A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _cardDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFE1E1E5))),
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

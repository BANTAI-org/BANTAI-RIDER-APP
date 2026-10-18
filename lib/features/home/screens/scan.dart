import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/scan_controller.dart';
import '../widgets/scan_camera_widget.dart';
import '../widgets/scan_pair_widget.dart';
import '../widgets/scan_status_widget.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, this.controller});

  final ScanController? controller;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  late final ScanController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = widget.controller ?? ScanController();
    _ownsController = widget.controller == null;
    _controller.addListener(_refresh);
    unawaited(_controller.initializeCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_refresh);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.initializeCamera());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_controller.pauseCamera());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Device',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  _ModeSelector(
                    mode: _controller.mode,
                    onSelected: _controller.selectMode,
                  ),
                  const SizedBox(height: 20),
                  if (_controller.mode == ScanMode.camera) ...[
                    ScanCameraWidget(
                      cameraController: _controller.cameraController,
                      isCameraLoading: _controller.isCameraLoading,
                      cameraError: _controller.cameraError,
                      onRetryCamera: _controller.initializeCamera,
                      isDownloading: _controller.isDownloading,
                      onDownloadClip: _controller.downloadBufferedClip,
                    ),
                    const SizedBox(height: 22),
                    const ScanStatusWidget(),
                  ] else
                    ScanPairWidget(
                      isPairing: _controller.isPairing,
                      pairingError: _controller.pairingError,
                      onQrDetected: _controller.pairFromQr,
                      onEnterPairingCode: _controller.enterPairingCode,
                      onUnpairDevice: _controller.unpairDevice,
                      onReportLostDevice: _controller.reportLostDevice,
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onSelected});

  final ScanMode mode;
  final ValueChanged<ScanMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Camera',
            selected: mode == ScanMode.camera,
            onTap: () => onSelected(ScanMode.camera),
          ),
          _ModeButton(
            label: 'Pair Device',
            selected: mode == ScanMode.pairDevice,
            onTap: () => onSelected(ScanMode.pairDevice),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x18000000), blurRadius: 2)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : const Color(0xFF7E7F86),
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ScanCameraWidget extends StatelessWidget {
  const ScanCameraWidget({
    super.key,
    required this.cameraController,
    required this.isCameraLoading,
    required this.cameraError,
    required this.onRetryCamera,
    required this.isDownloading,
    required this.onDownloadClip,
  });

  final CameraController? cameraController;
  final bool isCameraLoading;
  final String? cameraError;
  final VoidCallback onRetryCamera;
  final bool isDownloading;
  final VoidCallback onDownloadClip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Camera View',
          style: TextStyle(
            color: Color(0xFF92939B),
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        _CameraPreview(
          controller: cameraController,
          isLoading: isCameraLoading,
          error: cameraError,
          onRetry: onRetryCamera,
        ),
        const SizedBox(height: 7),
        const Padding(
          padding: EdgeInsets.only(left: 3),
          child: Text(
            'Front Camera (180°)',
            style: TextStyle(color: Color(0xFF85868E), fontSize: 12),
          ),
        ),
        const SizedBox(height: 22),
        _OfflineFootageCard(
          isDownloading: isDownloading,
          onDownloadClip: onDownloadClip,
        ),
      ],
    );
  }
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({
    required this.controller,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final CameraController? controller;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: const Color(0xFF101010),
          child: Stack(
            children: [
              if (activeController?.value.isInitialized == true)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: activeController!.value.previewSize!.height,
                      height: activeController.value.previewSize!.width,
                      child: CameraPreview(activeController),
                    ),
                  ),
                )
              else
                _CameraPlaceholder(
                  isLoading: isLoading,
                  error: error,
                  onRetry: onRetry,
                ),
              const Positioned(
                left: 14,
                bottom: 14,
                child: _PreviewPill(
                  label: 'LIVE',
                  color: Color(0xFF20D46D),
                  background: Color(0xB3186B3E),
                ),
              ),
              const Positioned(
                right: 14,
                bottom: 14,
                child: _PreviewPill(
                  label: 'LIVE CAMERA',
                  color: Colors.white,
                  background: Color(0xB3000000),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(color: Color(0xFF20D46D))
            else ...[
              const Icon(
                Icons.videocam_off_outlined,
                color: Color(0xFF98999D),
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                error ?? 'Camera is not ready.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD5D5D8), fontSize: 13),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF20D46D),
                  side: const BorderSide(color: Color(0xFF20D46D)),
                ),
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OfflineFootageCard extends StatelessWidget {
  const _OfflineFootageCard({
    required this.isDownloading,
    required this.onDownloadClip,
  });

  final bool isDownloading;
  final VoidCallback onDownloadClip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E1E5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.download_outlined,
                  size: 20,
                  color: Color(0xFF8A8B91),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save Offline Footage',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Available when a connection drop is detected',
                      style: TextStyle(color: Color(0xFF96979D), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: isDownloading ? null : onDownloadClip,
              icon: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : const Icon(Icons.download_outlined, size: 18),
              label: Text(
                isDownloading ? 'Downloading...' : 'Download Buffered Clip',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE7E7E9),
                foregroundColor: const Color(0xFF85868B),
                disabledBackgroundColor: const Color(0xFFE7E7E9),
                disabledForegroundColor: const Color(0xFF85868B),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ScanStatusWidget extends StatelessWidget {
  const ScanStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hardware Status',
          style: TextStyle(
            color: Color(0xFF92939B),
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            children: [
              _StatusRow(
                title: 'Pi 5 Connection',
                detail: 'Stream stable · low latency',
                status: 'Online',
              ),
              _StatusRow(
                title: 'Raspberry Pi 5 Unit',
                detail: 'BANTAI-PI-4471 · Firmware 2.4.1',
                status: 'Online',
              ),
              _StatusRow(
                title: 'Front Camera (180°)',
                detail: '1080p · 30fps stream stable',
                status: 'Connected',
              ),
              _StatusRow(
                title: 'Rear Camera (180°)',
                detail: 'Lens obstruction detected — wipe lens',
                status: 'Degraded',
                warning: true,
              ),
              _StatusRow(
                title: 'SD Card Storage',
                detail: '46.2 GB of 64 GB used · loop recording',
                status: '72%',
                progress: 0.72,
              ),
              _StatusRow(
                title: 'Device Battery',
                detail: 'Running on bike power · charging',
                status: '84%',
                progress: 0.84,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.title,
    required this.detail,
    required this.status,
    this.warning = false,
    this.progress,
  });

  final String title;
  final String detail;
  final String status;
  final bool warning;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final color = warning ? const Color(0xFFE8A32A) : const Color(0xFF18BC61);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: Color(0xFF96979D),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: warning
                      ? const Color(0xFFFFF0D4)
                      : const Color(0xFFE2F9EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    '• $status',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: const Color(0xFFE3E3E5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  warning ? Colors.orange : color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

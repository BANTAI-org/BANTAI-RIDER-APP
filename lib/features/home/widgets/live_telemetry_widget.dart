import 'package:flutter/material.dart';

class LiveTelemetryWidget extends StatelessWidget {
  const LiveTelemetryWidget({
    super.key,
    required this.duration,
    required this.distance,
    required this.clips,
  });

  final String duration;
  final String distance;
  final String clips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Live Telemetry'),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _TelemetryCard(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: duration,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _TelemetryCard(
                icon: Icons.route_outlined,
                label: 'Distance',
                value: distance,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _TelemetryCard(
                icon: Icons.video_library_outlined,
                label: 'Clips',
                value: clips,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF95969C),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _TelemetryCard extends StatelessWidget {
  const _TelemetryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: const Color(0x18000000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 11, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF85868C), size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF85868C),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

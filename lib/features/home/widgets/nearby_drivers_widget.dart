import 'package:flutter/material.dart';

class NearbyHelpCard extends StatelessWidget {
  const NearbyHelpCard({
    super.key,
    required this.count,
    required this.distance,
    required this.nearestRider,
    required this.service,
    this.onTap,
  });

  final String count;
  final String distance;
  final String nearestRider;
  final String service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Nearby'),
        const SizedBox(height: 9),
        _DashboardSurface(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(20, 17, 16, 17),
          child: Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count riders need help within $distance',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nearest: $nearestRider\n$service',
                      style: const TextStyle(
                        color: Color(0xFF8C8D93),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFB3B4B9),
                size: 28,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardSurface extends StatelessWidget {
  const _DashboardSurface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: const Color(0x18000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(padding: padding, child: child),
      ),
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

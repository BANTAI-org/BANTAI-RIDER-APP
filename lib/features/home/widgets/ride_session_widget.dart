import 'package:flutter/material.dart';

import '../controllers/ride_controller.dart';

class RideSessionWidget extends StatelessWidget {
  const RideSessionWidget({super.key, required this.controller, this.onTap});

  final RideController controller;
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          child: Row(
            children: [
              const _PowerBadge(),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isSessionLive
                          ? 'Session is live'
                          : 'Session is off',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isSessionLive
                          ? 'Auto-stops in\n${controller.sessionCountdown}'
                          : 'Tap to start a session',
                      style: const TextStyle(
                        color: Color(0xFF85858B),
                        fontSize: 11,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const _StatusPill(icon: Icons.wifi, label: 'WS'),
              const SizedBox(width: 6),
              const _StatusPill(icon: Icons.location_on, label: 'GPS'),
            ],
          ),
        ),
      ),
    );
  }
}

class _PowerBadge extends StatelessWidget {
  const _PowerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF7BE38E),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5576C76C),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.power_settings_new,
        color: Colors.white,
        size: 23,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFB4F2C0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Color(0xFF25C66A), size: 7),
          const SizedBox(width: 4),
          Icon(icon, color: const Color(0xFF32B953), size: 15),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF398F4E),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

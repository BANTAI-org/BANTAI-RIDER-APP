import 'package:flutter/material.dart';

class RescueSafeWidget extends StatelessWidget {
  const RescueSafeWidget({super.key, required this.onPreviewIncident});

  final VoidCallback onPreviewIncident;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF48A923),
            size: 56,
          ),
          const SizedBox(height: 24),
          const Text(
            "You're riding safe",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'If a crash is detected, this screen\ntakes over and your headset narrates\nevery step - no touch needed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF96979C),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onPreviewIncident,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE6001A),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Preview an incident'),
          ),
        ],
      ),
    );
  }
}

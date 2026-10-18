import 'package:flutter/material.dart';

class RescueDispatchBanner extends StatelessWidget {
  const RescueDispatchBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3B38),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x35FF3B38),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.headset_mic_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'Auto voice beacon',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              Spacer(),
              Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Playing on Bluetooth headset - Cardo Freecom 4',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

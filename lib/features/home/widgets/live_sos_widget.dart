import 'package:flutter/material.dart';

class LiveSosWidget extends StatelessWidget {
  const LiveSosWidget({
    super.key,
    required this.isSosActive,
    this.onManualSos,
  });

  final bool isSosActive;
  final VoidCallback? onManualSos;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: const Color(0x18000000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF46474D),
                  size: 22,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Auto-AI Crash Detection',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6),
                          _OnlineDot(),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ACTIVE - Pi 5 watching impact, tilt &\nsudden stop.',
                        style: TextStyle(
                          color: Color(0xFF8C8D93),
                          fontSize: 11,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 66,
              child: ElevatedButton.icon(
                onPressed: onManualSos,
                icon: Icon(
                  isSosActive ? Icons.close : Icons.warning_rounded,
                  size: 22,
                ),
                label: Text(
                  isSosActive ? 'Cancel Manual SOS' : 'Hold for Manual SOS',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B38),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0x55FF3B38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF25C66A),
        shape: BoxShape.circle,
      ),
    );
  }
}

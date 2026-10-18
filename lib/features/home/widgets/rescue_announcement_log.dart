import 'package:flutter/material.dart';

class RescueAnnouncementLog extends StatelessWidget {
  const RescueAnnouncementLog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _RescueAnnouncement(
            text: 'MDRRMO Ambulance dispatched. ETA 3 minutes. Stay where you are.',
            time: '14:32:09 - Bluetooth Headset',
          ),
          Divider(height: 1, indent: 39, endIndent: 12),
          _RescueAnnouncement(
            text: 'Crash detected on C5 Service Road. Emergency contacts notified.',
            time: '14:34:21 - Bluetooth Headset',
          ),
          Divider(height: 1, indent: 39, endIndent: 12),
          _RescueAnnouncement(
            text: 'Front and rear clips locked. 90 seconds saved to evidence vault.',
            time: '14:34:41 - Headset Speaker',
          ),
        ],
      ),
    );
  }
}

class _RescueAnnouncement extends StatelessWidget {
  const _RescueAnnouncement({required this.text, required this.time});

  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.volume_up_outlined,
              color: Color(0xFF96979C),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF96979C),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

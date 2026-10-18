import 'package:flutter/material.dart';

import '../controllers/rescue_controller.dart';
import 'rescue_announcement_log.dart';
import 'rescue_dispatch_banner.dart';
import 'rescue_responder_card.dart';

class ActiveRescueWidget extends StatelessWidget {
  const ActiveRescueWidget({super.key, required this.controller});

  final RescueController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RescueDispatchBanner(message: controller.dispatchedMessage),
        const SizedBox(height: 20),
        RescueResponderCard(
          name: controller.activeUnit,
          details: controller.activeUnitDetails,
          distance: controller.activeUnitDistance,
          status: 'arriving',
          progress: 0.82,
          color: const Color(0xFFFF3B38),
          icon: Icons.local_hospital_rounded,
        ),
        const SizedBox(height: 14),
        const RescueResponderCard(
          name: 'PNP Mobile Patrol',
          details: 'Car 12 - Station 6',
          distance: '1.6 km',
          status: 'en route',
          progress: 0.58,
          color: Color(0xFF25C66A),
          icon: Icons.verified_user_rounded,
        ),
        const SizedBox(height: 14),
        const RescueResponderCard(
          name: 'Barangay Tanod',
          details: 'Brgy. Kapitolyo Outpost',
          distance: '2.4 km',
          status: 'dispatched',
          progress: 0.33,
          color: Color(0xFF25C66A),
          icon: Icons.groups_rounded,
        ),
        const SizedBox(height: 22),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Announced Hands-Free',
            style: TextStyle(
              color: Color(0xFF96979C),
              fontSize: 14,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const RescueAnnouncementLog(),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: controller.clearRescue,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF3B38),
              backgroundColor: Colors.white,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "I'm safe - stand down responders",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

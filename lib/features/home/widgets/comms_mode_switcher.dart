import 'package:flutter/material.dart';

import '../controllers/comms_controller.dart';

class CommsModeSwitcher extends StatelessWidget {
  const CommsModeSwitcher({
    super.key,
    required this.mode,
    required this.onModeSelected,
  });

  final CommsMode mode;
  final ValueChanged<CommsMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E4EA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Nearby Map',
            selected: mode == CommsMode.nearbyMap,
            onTap: () => onModeSelected(CommsMode.nearbyMap),
          ),
          _ModeButton(
            label: 'Radio & Chat',
            selected: mode == CommsMode.radioChat,
            onTap: () => onModeSelected(CommsMode.radioChat),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? Colors.black : const Color(0xFF858894),
            ),
          ),
        ),
      ),
    );
  }
}

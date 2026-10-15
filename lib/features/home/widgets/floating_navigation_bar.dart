import 'package:flutter/material.dart';

class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    _NavigationDestination(Icons.two_wheeler_outlined, 'Ride'),
    _NavigationDestination(Icons.emergency_outlined, 'Rescue'),
    _NavigationDestination(Icons.qr_code_scanner_rounded, 'Scan'),
    _NavigationDestination(Icons.bar_chart_rounded, 'Comms'),
    _NavigationDestination(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(42),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var index = 0; index < _destinations.length; index++)
            Expanded(
              child: _NavigationItem(
                destination: _destinations[index],
                isSelected: selectedIndex == index,
                onTap: () => onDestinationSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _NavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFFE6001A)
        : const Color(0xFF96979C);

    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(destination.icon, color: color, size: 27),
              const SizedBox(height: 1),
              Text(
                destination.label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination(this.icon, this.label);

  final IconData icon;
  final String label;
}

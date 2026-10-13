import 'package:flutter/material.dart';

import '../widgets/floating_navigation_bar.dart';
import 'ride.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          RidePage(),
          _PlaceholderPage(
            title: 'Rescue',
            icon: Icons.emergency_outlined,
          ),
          _PlaceholderPage(
            title: 'Scan',
            icon: Icons.qr_code_scanner_rounded,
          ),
          _PlaceholderPage(
            title: 'Comms',
            icon: Icons.bar_chart_rounded,
          ),
          _PlaceholderPage(
            title: 'Profile',
            icon: Icons.person_outline_rounded,
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF96979C), size: 64),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coming soon',
              style: TextStyle(color: Color(0xFF858894)),
            ),
          ],
        ),
      ),
    );
  }
}

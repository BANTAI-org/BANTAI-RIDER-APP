import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profile.dart';
import '../widgets/floating_navigation_bar.dart';
import 'comms.dart';
import 'ride.dart';
import 'rescue.dart';
import 'scan.dart';

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFFF5F5FA),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5FA),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            RidePage(),
            RescuePage(),
            ScanPage(),
            CommsPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: FloatingNavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectDestination,
          ),
        ),
      ),
    );
  }
}

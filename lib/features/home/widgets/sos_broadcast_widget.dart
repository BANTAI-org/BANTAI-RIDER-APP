import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class SosBroadcastPage extends StatelessWidget {
  const SosBroadcastPage({super.key, this.controller});

  final ProfileController? controller;

  @override
  Widget build(BuildContext context) {
    final data = controller?.sosBroadcast;
    final items = <_SosBroadcastItem>[];

    if (data?.bloodType != null) {
      items.add(_SosBroadcastItem(
        icon: Icons.bloodtype_outlined,
        title: 'Blood type',
        value: data!.bloodType!,
      ));
    }

    if (data?.plateNumber != null) {
      items.add(_SosBroadcastItem(
        icon: Icons.confirmation_number_outlined,
        title: 'Plate no.',
        value: data!.plateNumber!,
      ));
    }

    if (data?.conditions != null) {
      items.add(_SosBroadcastItem(
        icon: Icons.medical_information_outlined,
        title: 'Conditions',
        value: data!.conditions!,
      ));
    }

    if (data?.firstCallContact != null) {
      items.add(_SosBroadcastItem(
        icon: Icons.phone_outlined,
        title: 'First call',
        value: data!.firstCallContact!,
      ));
    }

    if (data?.licenseExpiry != null) {
      items.add(_SosBroadcastItem(
        icon: Icons.credit_card_outlined,
        title: 'License expiry',
        value: data!.licenseExpiry!,
      ));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SOS Broadcast',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Read aloud to responders and nearby riders the moment a crash is detected.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8C8D93),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              if (items.isNotEmpty)
                _SosBroadcastCard(items: items)
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'No SOS broadcast data available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8C8D93),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosBroadcastCard extends StatelessWidget {
  const _SosBroadcastCard({required this.items});

  final List<_SosBroadcastItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) => Column(
            children: [
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: const Color(0xFFF0F0F2),
                  indent: 56,
                ),
              items[index],
            ],
          ),
        ),
      ),
    );
  }
}

class _SosBroadcastItem extends StatelessWidget {
  const _SosBroadcastItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF6B6C72),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C8D93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFD1D1D6),
            size: 20,
          ),
        ],
      ),
    );
  }
}

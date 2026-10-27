import 'package:flutter/material.dart';

import '../controllers/profile_controller.dart';

class RiderDetailsPage extends StatelessWidget {
  const RiderDetailsPage({super.key, this.controller});

  final ProfileController? controller;

  @override
  Widget build(BuildContext context) {
    final data = controller?.riderDetails;

    final personalItems = <_RiderDetailItem>[];
    final licenseItems = <_RiderDetailItem>[];
    final motorcycleItems = <_RiderDetailItem>[];
    final medicalItems = <_RiderDetailItem>[];

    // Personal & contact
    if (data?.firstName != null ||
        data?.middleName != null ||
        data?.lastName != null) {
      final fullName = [
        data?.firstName,
        data?.middleName,
        data?.lastName,
      ].where((e) => e != null && e.isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        personalItems.add(
          _RiderDetailItem(
            icon: Icons.person_outline,
            title: 'Full name',
            value: fullName,
          ),
        );
      }
    }

    if (data?.phoneNumber != null) {
      personalItems.add(
        _RiderDetailItem(
          icon: Icons.phone_outlined,
          title: 'Mobile',
          value: data!.phoneNumber!,
        ),
      );
    }

    if (data?.emailAddress != null) {
      personalItems.add(
        _RiderDetailItem(
          icon: Icons.email_outlined,
          title: 'Email',
          value: data!.emailAddress!,
        ),
      );
    }

    if (data?.birthday != null) {
      personalItems.add(
        _RiderDetailItem(
          icon: Icons.cake_outlined,
          title: 'Birth date',
          value: data!.birthday!,
        ),
      );
    }

    if (data?.gender != null) {
      personalItems.add(
        _RiderDetailItem(
          icon: Icons.wc_outlined,
          title: 'Gender',
          value: data!.gender!,
        ),
      );
    }

    // License & operator
    if (data?.licenseNumber != null) {
      licenseItems.add(
        _RiderDetailItem(
          icon: Icons.credit_card_outlined,
          title: 'License no.',
          value: data!.licenseNumber!,
        ),
      );
    }

    if (data?.licenseExpiry != null) {
      licenseItems.add(
        _RiderDetailItem(
          icon: Icons.event_outlined,
          title: 'Expires',
          value: data!.licenseExpiry!,
        ),
      );
    }

    if (data?.operatorStatus != null) {
      licenseItems.add(
        _RiderDetailItem(
          icon: Icons.check_circle_outline,
          title: 'Status',
          value: data!.operatorStatus!,
          valueColor: data.operatorStatus == 'Valid'
              ? const Color(0xFFE51D24)
              : null,
        ),
      );
    }

    if (data?.operatorCode != null) {
      licenseItems.add(
        _RiderDetailItem(
          icon: Icons.badge_outlined,
          title: 'Operator ID',
          value: data!.operatorCode!,
        ),
      );
    }

    // Registered motorcycle
    if (data?.motorcyclePlateNumber != null) {
      motorcycleItems.add(
        _RiderDetailItem(
          icon: Icons.confirmation_number_outlined,
          title: 'Plate no.',
          value: data!.motorcyclePlateNumber!,
        ),
      );
    }

    if (data?.motorcycleMake != null || data?.motorcycleModel != null) {
      final vehicle = [
        data?.motorcycleMake,
        data?.motorcycleModel,
      ].where((e) => e != null && e.isNotEmpty).join(' ');
      if (vehicle.isNotEmpty) {
        motorcycleItems.add(
          _RiderDetailItem(
            icon: Icons.two_wheeler_outlined,
            title: 'Model',
            value: vehicle,
          ),
        );
      }
    }

    if (data?.motorcycleYear != null) {
      motorcycleItems.add(
        _RiderDetailItem(
          icon: Icons.calendar_today_outlined,
          title: 'Year',
          value: data!.motorcycleYear!,
        ),
      );
    }

    // Medical
    if (data?.bloodType != null) {
      medicalItems.add(
        _RiderDetailItem(
          icon: Icons.bloodtype_outlined,
          title: 'Blood type',
          value: data!.bloodType!,
        ),
      );
    }

    if (data?.medicalConditions != null) {
      medicalItems.add(
        _RiderDetailItem(
          icon: Icons.medical_information_outlined,
          title: 'Conditions',
          value: data!.medicalConditions!,
        ),
      );
    }

    final hasAnyData =
        personalItems.isNotEmpty ||
        licenseItems.isNotEmpty ||
        motorcycleItems.isNotEmpty ||
        medicalItems.isNotEmpty;

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
                'Rider Details',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Everything on file for you, your license, your bike, and your medical record.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8C8D93),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              if (!hasAnyData)
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
                      'No rider details available',
                      style: TextStyle(fontSize: 14, color: Color(0xFF8C8D93)),
                    ),
                  ),
                ),
              if (personalItems.isNotEmpty) ...[
                const _SectionLabel('Personal & contact'),
                const SizedBox(height: 12),
                _RiderDetailsCard(items: personalItems),
                const SizedBox(height: 24),
              ],
              if (licenseItems.isNotEmpty) ...[
                const _SectionLabel('License & operator'),
                const SizedBox(height: 12),
                _RiderDetailsCard(items: licenseItems),
                const SizedBox(height: 24),
              ],
              if (motorcycleItems.isNotEmpty) ...[
                const _SectionLabel('Registered motorcycle'),
                const SizedBox(height: 12),
                _RiderDetailsCard(items: motorcycleItems),
                const SizedBox(height: 24),
              ],
              if (medicalItems.isNotEmpty) ...[
                const _SectionLabel('Medical'),
                const SizedBox(height: 12),
                _RiderDetailsCard(items: medicalItems),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF8C8D93),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _RiderDetailsCard extends StatelessWidget {
  const _RiderDetailsCard({required this.items});

  final List<_RiderDetailItem> items;

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

class _RiderDetailItem extends StatelessWidget {
  const _RiderDetailItem({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

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
            child: Icon(icon, size: 20, color: const Color(0xFF6B6C72)),
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
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? Colors.black,
                    fontWeight: FontWeight.w600,
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

import 'package:flutter/material.dart';

import '../controllers/ride_controller.dart';

class RideSessionWidget extends StatelessWidget {
  const RideSessionWidget({super.key, required this.controller, this.onTap});

  final RideController controller;
  final VoidCallback? onTap;

  Future<void> _showDurationPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DurationPickerSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: const Color(0x18000000),
      child: InkWell(
        onTap: controller.isSessionLive
            ? onTap
            : () => _showDurationPicker(context),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Row(
            children: [
              const _PowerBadge(),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isSessionLive
                          ? 'Session is live'
                          : 'Session is off',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isSessionLive
                          ? 'Auto-stops in\n${controller.sessionCountdown}'
                          : 'Tap to start a session',
                      style: const TextStyle(
                        color: Color(0xFF85858B),
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const _StatusPill(icon: Icons.wifi, label: 'WS'),
              const SizedBox(width: 6),
              const _StatusPill(icon: Icons.location_on, label: 'GPS'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationPickerSheet extends StatefulWidget {
  const _DurationPickerSheet({required this.controller});

  final RideController controller;

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late int _selectedHours;
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.controller.selectedDuration.inHours;
    _selectedMinutes = widget.controller.selectedDuration.inMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Set Session Duration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimePickerColumn(
                label: 'Hours',
                value: _selectedHours,
                minValue: 0,
                maxValue: 23,
                onChanged: (value) => setState(() => _selectedHours = value),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
                ),
              ),
              _TimePickerColumn(
                label: 'Minutes',
                value: _selectedMinutes,
                minValue: 0,
                maxValue: 59,
                onChanged: (value) => setState(() => _selectedMinutes = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final duration = Duration(
                  hours: _selectedHours,
                  minutes: _selectedMinutes,
                );
                widget.controller.setSelectedDuration(duration);
                Navigator.of(context).pop();
                widget.controller.startSession();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE60012),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePickerColumn extends StatelessWidget {
  const _TimePickerColumn({
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF85858B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              perspective: 0.005,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) => onChanged(minValue + index),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: maxValue - minValue + 1,
                builder: (context, index) {
                  final itemValue = minValue + index;
                  return Center(
                    child: Text(
                      itemValue.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: itemValue == value
                            ? FontWeight.w600
                            : FontWeight.w300,
                        color: itemValue == value
                            ? Colors.black
                            : const Color(0xFFBDBDBD),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerBadge extends StatelessWidget {
  const _PowerBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF7BE38E),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5576C76C),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.power_settings_new,
        color: Colors.white,
        size: 27,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB4F2C0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Color(0xFF25C66A), size: 7),
          const SizedBox(width: 4),
          Icon(icon, color: const Color(0xFF32B953), size: 17),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF398F4E),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

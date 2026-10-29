import 'package:flutter/material.dart';

import '../controllers/ride_controller.dart';

const _kRed = Color(0xFFE60012);
const _kGreen = Color(0xFF7BE38E);
const _kGreenDark = Color(0xFF2E9E4F);
const _kSheetBg = Color(0xFFF7F7F9);
const _kGrey = Color(0xFF85858B);

class RideSessionWidget extends StatelessWidget {
  const RideSessionWidget({super.key, required this.controller, this.onTap});

  final RideController controller;
  final VoidCallback? onTap;

  Future<void> _showSessionSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionSheet(controller: controller),
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
        onTap: () => _showSessionSheet(context),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Row(
            children: [
              _PowerBadge(active: controller.isSessionLive),
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
                        color: _kGrey,
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

// ───────────────────────── Session sheet ─────────────────────────

enum _Preset { h8, h12, custom }

class _SessionSheet extends StatefulWidget {
  const _SessionSheet({required this.controller});

  final RideController controller;

  @override
  State<_SessionSheet> createState() => _SessionSheetState();
}

class _SessionSheetState extends State<_SessionSheet> {
  _Preset _preset = _Preset.h8;
  int _customHours = 2;
  int _customMinutes = 0;

  Duration get _duration {
    switch (_preset) {
      case _Preset.h8:
        return const Duration(hours: 8);
      case _Preset.h12:
        return const Duration(hours: 12);
      case _Preset.custom:
        return Duration(hours: _customHours, minutes: _customMinutes);
    }
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  void _start() {
    Navigator.of(context).pop();
    widget.controller.startSession(duration: _duration);
  }

  void _end() {
    // Adjust to your controller's method name if different.
    widget.controller.endSession();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Requires RideController to be a Listenable (e.g. ChangeNotifier).
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final live = widget.controller.isSessionLive;
        final duration = _duration;

        return Container(
          decoration: const BoxDecoration(
            color: _kSheetBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grabber
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9C9CE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_left,
                                size: 22,
                                color: Colors.black,
                              ),
                              Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Session',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status card
                _StatusCard(
                  live: live,
                  subtitle: live
                      ? 'Auto-stops in ${widget.controller.sessionCountdown}'
                      : 'Tap the power icon to start recording',
                  onPowerTap: live ? _end : _start,
                ),
                const SizedBox(height: 16),

                // Duration (only before a session starts)
                if (!live) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duration',
                          style: TextStyle(fontSize: 12, color: _kGrey),
                        ),
                        Text(
                          '${_format(duration)} total',
                          style: const TextStyle(fontSize: 12, color: _kGrey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DurationChip(
                          title: '8 h',
                          subtitle: 'Standard',
                          selected: _preset == _Preset.h8,
                          onTap: () => setState(() => _preset = _Preset.h8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DurationChip(
                          title: '12 h',
                          subtitle: 'Long ride',
                          selected: _preset == _Preset.h12,
                          onTap: () => setState(() => _preset = _Preset.h12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _CustomCard(
                    selected: _preset == _Preset.custom,
                    hours: _customHours,
                    minutes: _customMinutes,
                    onTap: () => setState(() => _preset = _Preset.custom),
                    onHoursChanged: (v) => setState(() => _customHours = v),
                    onMinutesChanged: (v) => setState(() => _customMinutes = v),
                  ),
                  const SizedBox(height: 14),
                ],

                // Battery info
                const _InfoCard(),
                const SizedBox(height: 20),

                // Primary action
                if (live)
                  _ActionButton(
                    icon: Icons.close,
                    label: 'End session now',
                    onPressed: _end,
                  )
                else
                  _ActionButton(
                    icon: Icons.power_settings_new,
                    label: 'Start session — ${_format(duration)}',
                    onPressed: duration == Duration.zero ? null : _start,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.live,
    required this.subtitle,
    required this.onPowerTap,
  });

  final bool live;
  final String subtitle;
  final VoidCallback onPowerTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: live
              ? const [Color(0xFF8DE8A0), Color(0xFF6FD98A)]
              : const [Color(0xFFE9E9EE), Color(0xFFE4E4EA)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPowerTap,
            child: _PowerBadge(active: live),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live ? 'Session is live' : 'Session is off',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: live ? const Color(0xFF3F7F52) : _kGrey,
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

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _kGreen : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: selected ? 0 : 1,
      shadowColor: const Color(0x14000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: selected ? _kGreenDark : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? _kGreenDark : _kGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  const _CustomCard({
    required this.selected,
    required this.hours,
    required this.minutes,
    required this.onTap,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  final bool selected;
  final int hours;
  final int minutes;
  final VoidCallback onTap;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: selected ? _kGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: selected ? 0 : 1,
          shadowColor: const Color(0x14000000),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: selected ? _kGreenDark : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pick any duration',
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? _kGreenDark : _kGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    size: 22,
                    color: selected ? _kGreenDark : _kGrey,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: selected
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Stepper(
                            label: 'Hours',
                            value: hours,
                            min: 0,
                            max: 23,
                            step: 1,
                            onChanged: onHoursChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Stepper(
                            label: 'Minutes',
                            value: minutes,
                            min: 0,
                            max: 55,
                            step: 5,
                            onChanged: onMinutesChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _kGrey)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: value - step >= min
                    ? () => onChanged(value - step)
                    : null,
              ),
              Expanded(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add,
                onTap: value + step <= max
                    ? () => onChanged(value + step)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? const Color(0xFFC9C9CE) : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.battery_charging_full,
              size: 18,
              color: Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pi 5 uses about 6% battery per hour. Session auto-stops at '
              'zero so your helmet never drains while parked.',
              style: TextStyle(fontSize: 12.5, color: _kGrey, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFEAEAEE),
          disabledForegroundColor: const Color(0xFFB8B8BE),
          elevation: 4,
          shadowColor: const Color(0x66E60012),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Shared bits ─────────────────────────

class _PowerBadge extends StatelessWidget {
  const _PowerBadge({this.active = true});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? _kGreen : const Color(0xFF9A9AA3),
        boxShadow: [
          BoxShadow(
            color: active ? const Color(0x5576C76C) : const Color(0x33000000),
            blurRadius: 5,
            offset: const Offset(0, 2),
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

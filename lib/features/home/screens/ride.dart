import 'package:flutter/material.dart';
import '../controllers/ride_controller.dart';
import '../widgets/live_sos_widget.dart';
import '../widgets/live_telemetry_widget.dart';
import '../widgets/nearby_drivers_widget.dart';
import '../widgets/ride_session_widget.dart';

class RidePage extends StatefulWidget {
  const RidePage({super.key, this._controller});

  final RideController? _controller;

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  late final RideController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _controller = widget._controller ?? RideController();
    _ownsController = widget._controller == null;
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refreshTelemetry,
          color: const Color(0xFFE60012),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _RideTitle(),
                    const SizedBox(height: 15),
                    LiveSosWidget(
                      isSosActive: _controller.isSosActive,
                      onManualSos: _controller.isSosActive
                          ? _controller.clearManualSos
                          : _controller.triggerManualSos,
                    ),
                    const SizedBox(height: 14),
                    RideSessionWidget(
                      controller: _controller,
                      onTap: _controller.isSessionLive
                          ? _controller.endSession
                          : _controller.startSession,
                    ),
                    const SizedBox(height: 21),
                    LiveTelemetryWidget(
                      duration: _controller.sessionDuration,
                      distance: _controller.distanceTravelled,
                      clips: _controller.clipsRecorded,
                    ),
                    const SizedBox(height: 21),
                    NearbyHelpCard(
                      count: _controller.nearbyHelpCount,
                      distance: _controller.nearbyHelpDistance,
                      nearestRider: _controller.nearestRider,
                      service: _controller.nearbyService,
                    ),
                    const SizedBox(height: 23),
                    const _TodayLabel(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RideTitle extends StatelessWidget {
  const _RideTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Ride',
      style: TextStyle(
        color: Colors.black,
        fontSize: 27,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TodayLabel extends StatelessWidget {
  const _TodayLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 12),
      child: Text(
        'Today',
        style: TextStyle(
          color: Color(0xFF95969C),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

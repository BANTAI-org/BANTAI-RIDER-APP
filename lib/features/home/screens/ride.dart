import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/datasources/rider_remote_data_source.dart';
import '../../../data/repositories/sos_repository_impl.dart';
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
    _controller =
        widget._controller ??
        RideController(SosRepositoryImpl(RiderRemoteDataSource(ApiClient())));
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

  Widget _buildTelemetry() {
    final hasData =
        _controller.sessionDuration.isNotEmpty ||
        _controller.distanceTravelled.isNotEmpty ||
        _controller.clipsRecorded.isNotEmpty;
    if (!hasData) {
      return const _EmptyStateCard(message: 'No telemetry data available');
    }
    return LiveTelemetryWidget(
      duration: _controller.sessionDuration,
      distance: _controller.distanceTravelled,
      clips: _controller.clipsRecorded,
    );
  }

  Widget _buildNearbyHelp() {
    final hasData =
        _controller.nearbyHelpCount.isNotEmpty ||
        _controller.nearbyHelpDistance.isNotEmpty ||
        _controller.nearestRider.isNotEmpty ||
        _controller.nearbyService.isNotEmpty;
    if (!hasData) {
      return const _EmptyStateCard(message: 'No nearby help requests');
    }
    return NearbyHelpCard(
      count: _controller.nearbyHelpCount,
      distance: _controller.nearbyHelpDistance,
      nearestRider: _controller.nearestRider,
      service: _controller.nearbyService,
    );
  }

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
                    const SizedBox(height: 20),
                    LiveSosWidget(
                      isSosActive: _controller.isSosActive,
                      isSosSending: _controller.isSosSending,
                      sosError: _controller.sosError,
                      onManualSos: _controller.isSosActive
                          ? _controller.clearManualSos
                          : _controller.triggerManualSos,
                    ),
                    const SizedBox(height: 14),
                    RideSessionWidget(
                      controller: _controller,
                      onTap: _controller.endSession,
                    ),
                    const SizedBox(height: 21),
                    _buildTelemetry(),
                    const SizedBox(height: 20),
                    _buildNearbyHelp(),
                    const SizedBox(height: 20),
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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: const Color(0x14000000),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF95969C), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF85858B),
                  fontSize: 13,
                  height: 1.25,
                ),
              ),
            ),
          ],
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
        fontSize: 37,
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

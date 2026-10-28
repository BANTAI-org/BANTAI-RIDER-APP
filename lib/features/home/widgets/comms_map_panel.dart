import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/comms_controller.dart';

const _kUrgentRed = Color(0xFFFF3B30);
const _kNeutralGrey = Color(0xFFB9C3D0);
const _kGreen = Color(0xFF22C55E);
const _kAmber = Color(0xFFF59E0B);
const _kMuted = Color(0xFF858894);

/// Shown until the first GPS fix arrives (Manila area, matches the design).
const _kDefaultCenter = LatLng(14.5764, 121.0851);

/// Zoom that fits the whole 3 km ring inside the 240 px tall map card.
const double _kCoverageZoom = 12.3;

/// Only for design testing: places pins for riders that have no coordinates.
/// Keep this false in real builds so a pin is never in a made-up position.
const bool _kPlaceholderPins = false;
const _kPlaceholderBearings = <double>[315, 135, 10, 225, 60];

bool _isUrgent(NearbyRider r) => r.isCritical || r.isNeedHelp;

class CommsMapPanel extends StatefulWidget {
  const CommsMapPanel({super.key, required this.controller});

  final CommsController controller;

  @override
  State<CommsMapPanel> createState() => _CommsMapPanelState();
}

class _CommsMapPanelState extends State<CommsMapPanel> {
  GoogleMapController? _mapController;
  bool _hasCentered = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  /// Only recenter ONCE when the first GPS fix arrives, so user panning isn't
  /// undone by later controller updates.
  void _handleControllerChanged() {
    final position = widget.controller.position;
    if (_hasCentered || position == null || _mapController == null) return;
    _hasCentered = true;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        _kCoverageZoom,
      ),
    );
  }

  void _showRiderLocationModal(NearbyRider rider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _RiderLocationModal(rider: rider, controller: widget.controller),
    );
  }

  /// The card shown under the map when there is something to explain.
  /// Returns null when the normal rider list should be shown on its own.
  ///
  /// Important: "no incidents" is only claimed when we actually know it
  /// (location known AND live connection up). Otherwise we say what is wrong.
  Widget? _buildNotice(CommsController c, bool hasRiders) {
    if (c.position == null) {
      return _NoticeCard(
        icon: Icons.location_off_outlined,
        color: _kMuted,
        title: 'Location needed',
        message: c.locationError ?? 'Waiting for your location…',
        actionLabel: c.isLoadingLocation ? null : 'Try again',
        onAction: c.refreshLocation,
      );
    }
    if (!c.isConnected) {
      final connecting =
          c.connectionState == CommsConnectionState.connecting ||
          c.connectionState == CommsConnectionState.reconnecting;
      final fallback = hasRiders
          ? 'Showing the last known incidents. They may be out of date.'
          : "We'll keep trying to reconnect.";
      return _NoticeCard(
        icon: connecting ? Icons.sync : Icons.cloud_off_outlined,
        color: _kAmber,
        title: connecting
            ? 'Connecting to live updates…'
            : 'Live updates unavailable',
        message: kDebugMode && c.connectionError != null && !hasRiders
            ? c.connectionError!
            : fallback,
      );
    }
    if (!hasRiders) {
      return const _NoticeCard(
        icon: Icons.check_circle_outline,
        color: _kGreen,
        title: 'No incidents within 3 km',
        message: 'Nothing has been reported near you. This updates live.',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final position = c.position;
    final center = position == null
        ? _kDefaultCenter
        : LatLng(position.latitude, position.longitude);
    final riders = c.nearbyRiders;
    final notice = _buildNotice(c, riders.isNotEmpty);

    return Column(
      children: [
        _MapCard(
          controller: c,
          center: center,
          onMapCreated: (controller) {
            _mapController = controller;
            _hasCentered = c.position != null;
          },
          onRiderTap: _showRiderLocationModal,
        ),
        const SizedBox(height: 10),
        if (notice != null) ...[notice, const SizedBox(height: 7)],
        for (final rider in riders) ...[
          _NearbyRiderCard(
            rider: rider,
            onTap: () => _showRiderLocationModal(rider),
          ),
          const SizedBox(height: 7),
        ],
      ],
    );
  }
}

/// Neutral info card used for empty / offline / location states.
class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(color: _kMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE6001A),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 32),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapCard extends StatefulWidget {
  const _MapCard({
    required this.controller,
    required this.center,
    required this.onMapCreated,
    required this.onRiderTap,
  });

  final CommsController controller;
  final LatLng center;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<NearbyRider> onRiderTap;

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard> {
  GoogleMapController? _mapController;
  String? _mapStyle;
  BitmapDescriptor? _redPin, _greyPin, _youDot;
  bool _assetsReady = false;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
    final red = await _makePin(_kUrgentRed, glow: true);
    final grey = await _makePin(_kNeutralGrey, glow: true);
    final you = await _makePin(_kGreen, glow: false, size: 14);
    if (!mounted) return;
    setState(() {
      _redPin = red;
      _greyPin = grey;
      _youDot = you;
      _assetsReady = true;
    });
  }

  /// Draws a filled circle with a white ring and optional soft glow.
  Future<BitmapDescriptor> _makePin(
    Color color, {
    required bool glow,
    double size = 28,
  }) async {
    const ratio = 3.0;
    final canvasSize = (glow ? size * 2.4 : size + 6) * ratio;
    final c = canvasSize / 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (glow) {
      canvas.drawCircle(
        Offset(c, c),
        size * 0.95 * ratio,
        Paint()
          ..color = color.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
      canvas.drawCircle(
        Offset(c, c),
        size * 0.62 * ratio,
        Paint()
          ..color = color.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    } else {
      canvas.drawCircle(
        Offset(c, c),
        (size / 2 + 3) * ratio,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    canvas.drawCircle(
      Offset(c, c),
      size / 2 * ratio,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(c, c),
      (size / 2 - 2) * ratio,
      Paint()..color = color,
    );

    final image = await recorder.endRecording().toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: ratio,
    );
  }

  /// Real coordinates when present. Only when [_kPlaceholderPins] is true
  /// (design testing) a position is derived from the distance text.
  LatLng? _riderLatLng(NearbyRider rider, int index) {
    if (rider.latitude != null && rider.longitude != null) {
      return LatLng(rider.latitude!, rider.longitude!);
    }
    if (!_kPlaceholderPins) return null;

    final m = RegExp(r'([\d.]+)\s*(km|m)\b')
        .firstMatch(rider.distance.toLowerCase());
    if (m == null) return null;
    var meters = double.tryParse(m.group(1)!) ?? 0;
    if (m.group(2) == 'km') meters *= 1000;

    final bearing =
        _kPlaceholderBearings[index % _kPlaceholderBearings.length] *
        math.pi /
        180;
    final c = widget.center;
    final dLat = meters * math.cos(bearing) / 111320;
    final dLng =
        meters *
        math.sin(bearing) /
        (111320 * math.cos(c.latitude * math.pi / 180));
    return LatLng(c.latitude + dLat, c.longitude + dLng);
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final riders = widget.controller.nearbyRiders;
    for (var i = 0; i < riders.length; i++) {
      final rider = riders[i];
      final pos = _riderLatLng(rider, i);
      if (pos == null) continue;
      final urgent = _isUrgent(rider);
      final icon = urgent ? _redPin : _greyPin;
      markers.add(
        Marker(
          markerId: MarkerId(rider.id),
          position: pos,
          icon: icon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: urgent ? 2 : 1,
          onTap: () => widget.onRiderTap(rider),
        ),
      );
    }
    if (widget.controller.position != null && _youDot != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('me'),
          position: widget.center,
          icon: _youDot!,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 3,
        ),
      );
    }
    return markers;
  }

  Set<Circle> _buildCircles() => widget.controller.position == null
      ? const {}
      : {
          Circle(
            circleId: const CircleId('coverage'),
            center: widget.center,
            radius: kNearbyRadiusMeters,
            strokeColor: _kGreen,
            strokeWidth: 2,
            fillColor: _kGreen.withValues(alpha: 0.05),
          ),
        };

  Future<void> _onLocateTap() async {
    await widget.controller.refreshLocation();
    if (!mounted) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(widget.center, _kCoverageZoom),
    );
  }

  /// Small status chip (top left): Live / Connecting… / Offline.
  Widget _buildLiveChip() {
    final (color, label) = switch (widget.controller.connectionState) {
      CommsConnectionState.connected => (_kGreen, 'Live'),
      CommsConnectionState.connecting ||
      CommsConnectionState.reconnecting => (_kAmber, 'Connecting…'),
      CommsConnectionState.disconnected => (const Color(0xFF9AA0AA), 'Offline'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _whiteBox(BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 240,
        child: !_assetsReady
            // Don't show the default Google style for a split second: wait
            // until our style and pins are ready.
            ? Container(
                color: const Color(0xFFECEEF1),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFB0B1B7),
                    ),
                  ),
                ),
              )
            : Stack(
                children: [
                  // ---- Map layer (bottom) ----
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.center,
                      zoom: _kCoverageZoom,
                    ),
                    style: _mapStyle,
                    minMaxZoomPreference: const MinMaxZoomPreference(10, 17),
                    // Claim every touch that starts on the map so the parent
                    // scroll view doesn't steal pan/pinch gestures.
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    myLocationEnabled: false, // we draw our own green dot
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    trafficEnabled: false,
                    buildingsEnabled: false,
                    indoorViewEnabled: false,
                    circles: _buildCircles(),
                    markers: _buildMarkers(),
                    onMapCreated: (mc) {
                      _mapController = mc;
                      widget.onMapCreated(mc);
                    },
                  ),

                  // ---- Info boxes layered ABOVE the map ----

                  // Connection status (top left)
                  Positioned(left: 12, top: 12, child: _buildLiveChip()),

                  // Zoom control: single joined pill (top right)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 34,
                      decoration: _whiteBox(BorderRadius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ZoomButton(
                            icon: Icons.add,
                            onTap: () => _changeZoom(1),
                          ),
                          const Divider(height: 1, color: Color(0xFFE6E6E9)),
                          _ZoomButton(
                            icon: Icons.remove,
                            onTap: () => _changeZoom(-1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // "Within 3 km of you" pill. It sits ABOVE the Google logo
                  // (bottom left), which stays visible as the terms require.
                  Positioned(
                    left: 12,
                    bottom: 38,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: _whiteBox(BorderRadius.circular(20)),
                      child: const Text(
                        'Within 3 km of you',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),

                  // Locate button: red circle, white crosshair (bottom right)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6001A),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE6001A)
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _onLocateTap,
                          child: Center(
                            child: widget.controller.isLoadingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.gps_fixed,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  BoxDecoration _whiteBox(BorderRadius radius) => BoxDecoration(
    color: Colors.white,
    borderRadius: radius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  void _changeZoom(double amount) {
    _mapController?.animateCamera(CameraUpdate.zoomBy(amount));
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

/// Avatar matching the design: solid red + glow + white icon when urgent,
/// soft grey otherwise.
class _RiderAvatar extends StatelessWidget {
  const _RiderAvatar({required this.urgent, this.size = 40});

  final bool urgent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: urgent ? _kUrgentRed : const Color(0xFFEDEFF2),
        boxShadow: urgent
            ? [
                BoxShadow(
                  color: _kUrgentRed.withValues(alpha: 0.45),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: urgent ? Colors.white : _kNeutralGrey,
      ),
    );
  }
}

class _NearbyRiderCard extends StatelessWidget {
  const _NearbyRiderCard({required this.rider, required this.onTap});

  final NearbyRider rider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final urgent = _isUrgent(rider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _RiderAvatar(urgent: urgent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rider.id,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (rider.status.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _StatusBadge(rider: rider),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rider.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _kMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${rider.updatedAt} ${rider.respondersSummary != null ? '• ${rider.respondersSummary}' : ''}',
                    style: const TextStyle(
                      color: Color(0xFFB0B1B7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rider.distance,
                  style: TextStyle(
                    color: urgent ? const Color(0xFFE6001A) : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFB0B1B7),
                  size: 17,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.rider});

  final NearbyRider rider;

  @override
  Widget build(BuildContext context) {
    final critical = rider.isCritical;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: critical ? const Color(0xFFFFE6E5) : const Color(0xFFFFF0E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rider.status,
        style: TextStyle(
          color: critical ? const Color(0xFFE6001A) : const Color(0xFFE35A27),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RiderLocationModal extends StatelessWidget {
  const _RiderLocationModal({required this.rider, required this.controller});

  final NearbyRider rider;
  final CommsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    _RiderAvatar(urgent: _isUrgent(rider), size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rider.id,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${rider.riderName ?? "Emman"} • ${rider.platform ?? "JoyRide"} • ${rider.updatedAt}',
                            style: const TextStyle(
                              color: _kMuted,
                              fontSize: 11,
                            ),
                          ),
                          if (rider.status.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _StatusBadge(rider: rider),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFFB0B1B7)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Crash Detection Alert Banner (if critical/crash)
              if (rider.isCritical)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Auto-AI crash detection',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Side impact · rider down, no movement for 40 s',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Details Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: rider.location,
                      trailingValue: rider.distance.isNotEmpty
                          ? '${rider.distance} away'
                          : null,
                      isCritical: false,
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Responders',
                      value:
                          rider.respondersInfo ??
                          'MDRRMO Ambulance • ETA 3 min',
                      isCritical: false,
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.water_drop_outlined,
                      label: 'Rider info',
                      value:
                          rider.riderInfo ?? 'Plate NBH 8821 • Blood type B+',
                      isCritical: false,
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.group_outlined,
                      label: 'Riders responding',
                      value:
                          rider.respondersSummary ??
                          '4 nearby riders on the way',
                      isCritical: false,
                    ),
                  ],
                ),
              ),

              // Help needed box
              if (rider.helpNeededText != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What help is needed',
                        style: TextStyle(
                          color: _kMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rider.helpNeededText!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6001A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: const Text(
                        "I'm responding - notify the channel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            icon: const Icon(Icons.navigation, size: 18),
                            label: const Text(
                              'Navigate',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text(
                              'Call dispatch',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailingValue,
    required this.isCritical,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trailingValue;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF777982)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFB0B1B7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (trailingValue != null)
                    Text(
                      trailingValue!,
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isCritical ? const Color(0xFFE6001A) : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

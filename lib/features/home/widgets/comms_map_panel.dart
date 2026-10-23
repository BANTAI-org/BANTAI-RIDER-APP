import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/comms_controller.dart';

class CommsMapPanel extends StatefulWidget {
  const CommsMapPanel({super.key, required this.controller});

  final CommsController controller;

  @override
  State<CommsMapPanel> createState() => _CommsMapPanelState();
}

class _CommsMapPanelState extends State<CommsMapPanel> {
  GoogleMapController? _mapController;

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

  void _handleControllerChanged() {
    final position = widget.controller.position;
    if (position != null && _mapController != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final position = widget.controller.position;
    final center = position == null
        ? const LatLng(14.5764, 121.0851)
        : LatLng(position.latitude, position.longitude);

    return Column(
      children: [
        _MapCard(
          controller: widget.controller,
          center: center,
          onMapCreated: (controller) => _mapController = controller,
        ),
        if (widget.controller.locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              widget.controller.locationError!,
              style: const TextStyle(color: Color(0xFFE6001A), fontSize: 11),
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${widget.controller.nearbyRiders.length} rider${widget.controller.nearbyRiders.length == 1 ? '' : 's'} within 3 km',
            style: const TextStyle(
              color: Color(0xFF777982),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 7),
        for (final rider in widget.controller.nearbyRiders) ...[
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

class _MapCard extends StatefulWidget {
  const _MapCard({
    required this.controller,
    required this.center,
    required this.onMapCreated,
  });

  final CommsController controller;
  final LatLng center;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard> {
  GoogleMapController? _mapController;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.json').then((style) {
      _mapStyle = style;
    }).catchError((error) {
      debugPrint('Error loading map style: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: SizedBox(
        height: 240,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.center,
                zoom: 14.5,
              ),
              myLocationEnabled: widget.controller.position != null,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              circles: widget.controller.coverageCircles,
              markers: widget.controller.riderMarkers,
              padding: const EdgeInsets.only(bottom: 40),
              onMapCreated: (mapController) {
                _mapController = mapController;
                if (_mapStyle != null) {
                  mapController.setMapStyle(_mapStyle);
                }
                widget.onMapCreated(mapController);
              },
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Column(
                children: [
                  _MapControl(icon: Icons.add, onPressed: () => _changeZoom(1)),
                  const SizedBox(height: 8),
                  _MapControl(
                    icon: Icons.remove,
                    onPressed: () => _changeZoom(-1),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: widget.controller.refreshLocation,
                    child: Center(
                      child: widget.controller.isLoadingLocation
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFE6001A),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              size: 18,
                              color: Color(0xFF1A1A1A),
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

  void _changeZoom(double amount) {
    _mapController?.animateCamera(CameraUpdate.zoomBy(amount));
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
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
    final accent = rider.isCritical
        ? const Color(0xFFFF3B30)
        : const Color(0xFFB9C3D0);
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
            CircleAvatar(
              radius: 20,
              backgroundColor: accent.withOpacity(0.18),
              child: Icon(Icons.person, size: 20, color: accent),
            ),
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
                    style: const TextStyle(
                      color: Color(0xFF858894),
                      fontSize: 11,
                    ),
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
                    color: rider.isCritical || rider.isNeedHelp
                        ? const Color(0xFFE6001A)
                        : Colors.black,
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
    final accent = rider.isCritical
        ? const Color(0xFFFF3B30)
        : const Color(0xFFB9C3D0);
    final hasCoordinates = rider.latitude != null && rider.longitude != null;

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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: accent.withOpacity(0.18),
                      child: Icon(Icons.person, size: 24, color: accent),
                    ),
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
                          Row(
                            children: [
                              Text(
                                '${rider.riderName ?? "Emman"} • ${rider.platform ?? "JoyRide"} • ${rider.updatedAt}',
                                style: const TextStyle(
                                  color: Color(0xFF858894),
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
                          color: Color(0xFF858894),
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

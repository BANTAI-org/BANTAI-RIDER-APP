import 'package:flutter/material.dart';
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
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Within 3 km of you',
            style: TextStyle(
              color: Color(0xFF777982),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 7),
        for (final rider in widget.controller.nearbyRiders) ...[
          _NearbyRiderCard(rider: rider),
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: SizedBox(
        height: 184,
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
              circles: widget.controller.coverageCircles,
              markers: widget.controller.riderMarkers,
              onMapCreated: (mapController) {
                _mapController = mapController;
                widget.onMapCreated(mapController);
              },
            ),
            Positioned(
              right: 7,
              top: 8,
              child: Column(
                children: [
                  _MapControl(icon: Icons.add, onPressed: () => _changeZoom(1)),
                  _MapControl(
                    icon: Icons.remove,
                    onPressed: () => _changeZoom(-1),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8,
              bottom: 9,
              child: FloatingActionButton.small(
                heroTag: 'comms-location',
                elevation: 2,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE6001A),
                onPressed: widget.controller.refreshLocation,
                child: widget.controller.isLoadingLocation
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 17),
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
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(width: 30, height: 29, child: Icon(icon, size: 18)),
      ),
    );
  }
}

class _NearbyRiderCard extends StatelessWidget {
  const _NearbyRiderCard({required this.rider});

  final NearbyRider rider;

  @override
  Widget build(BuildContext context) {
    final accent = rider.isCritical
        ? const Color(0xFFFF3B30)
        : const Color(0xFFB9C3D0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
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
            radius: 16,
            backgroundColor: accent.withValues(alpha: 0.18),
            child: Icon(Icons.person, size: 18, color: accent),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rider.id,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (rider.status.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      _StatusBadge(rider: rider),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  rider.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF858894), fontSize: 9),
                ),
                const SizedBox(height: 2),
                Text(
                  rider.updatedAt,
                  style: const TextStyle(color: Color(0xFFB0B1B7), fontSize: 8),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFB0B1B7),
                size: 17,
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: critical ? const Color(0xFFFFE6E5) : const Color(0xFFFFF0E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rider.status,
        style: TextStyle(
          color: critical ? const Color(0xFFE6001A) : const Color(0xFFE35A27),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

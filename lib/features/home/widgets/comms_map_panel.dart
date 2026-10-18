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
  void didUpdateWidget(covariant CommsMapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final position = widget.controller.position;
    if (position != null && oldWidget.controller.position != position) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 300,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: 14.5,
                  ),
                  myLocationEnabled: position != null,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: widget.controller.riderMarkers,
                  onMapCreated: (controller) => _mapController = controller,
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'comms-location',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    onPressed: widget.controller.refreshLocation,
                    child: widget.controller.isLoadingLocation
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 19),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.controller.locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.controller.locationError!,
              style: const TextStyle(color: Color(0xFFE6001A), fontSize: 12),
            ),
          ),
        const SizedBox(height: 12),
        const _MapStatusCard(),
      ],
    );
  }
}

class _MapStatusCard extends StatelessWidget {
  const _MapStatusCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.people_alt_outlined, color: Color(0xFFE6001A)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nearby riders will appear here as Comms services are connected.',
                style: TextStyle(fontSize: 13, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

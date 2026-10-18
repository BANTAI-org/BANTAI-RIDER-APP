import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CommsMode { nearbyMap, radioChat }

class CommsController extends ChangeNotifier {
  CommsMode _mode = CommsMode.nearbyMap;
  Position? _position;
  bool _isLoadingLocation = false;
  String? _locationError;

  CommsMode get mode => _mode;
  Position? get position => _position;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;

  Set<Marker> get riderMarkers => {
        if (_position != null)
          Marker(
            markerId: const MarkerId('current-rider'),
            position: LatLng(_position!.latitude, _position!.longitude),
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
      };

  Future<void> initialize() async {
    await refreshLocation();
  }

  void selectMode(CommsMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationServiceDisabledException();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const PermissionDeniedException('Location permission was denied.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException(
          'Location permission is permanently denied. Enable it in Settings.',
        );
      }

      _position = await Geolocator.getCurrentPosition();
    } on LocationServiceDisabledException {
      _locationError = 'Turn on location services to center the map.';
    } on PermissionDeniedException catch (error) {
      _locationError = error.message;
    } catch (_) {
      _locationError = 'We could not determine your location. Try again.';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }
}

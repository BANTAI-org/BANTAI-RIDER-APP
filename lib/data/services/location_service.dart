import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Fresh GPS fix with a timeout, falling back to the last known position.
  /// Returns null if location is off or permission is denied.
  Future<Position?> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }
}

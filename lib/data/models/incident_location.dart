import 'dart:math' as math;

class IncidentLocation {
  const IncidentLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  bool get isUnset => latitude == 0.0 && longitude == 0.0;

  factory IncidentLocation.fromJson(dynamic json) {
    if (json is Map) {
      final lat = json['latitude'] ?? json['lat'];
      final lng = json['longitude'] ?? json['lng'];
      if (lat is num && lng is num) {
        return IncidentLocation(
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
        );
      }
    }
    if (json is List && json.length >= 2) {
      final lng = json[0];
      final lat = json[1];
      if (lat is num && lng is num) {
        return IncidentLocation(
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
        );
      }
    }
    return const IncidentLocation(latitude: 0, longitude: 0);
  }

  double distanceTo(IncidentLocation other) {
    const earthRadius = 6371000.0;
    final lat1 = latitude * math.pi / 180.0;
    final lat2 = other.latitude * math.pi / 180.0;
    final dLat = (other.latitude - latitude) * math.pi / 180.0;
    final dLng = (other.longitude - longitude) * math.pi / 180.0;
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
    return 2 * earthRadius * math.asin(math.sqrt(a.toDouble()));
  }

  @override
  String toString() =>
      'IncidentLocation(${latitude.toStringAsFixed(5)}, '
      '${longitude.toStringAsFixed(5)})';
}
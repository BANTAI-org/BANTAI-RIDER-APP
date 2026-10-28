import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/constants/network_settings.dart';
import '../../../core/storage/auth_token_storage.dart';

enum CommsMode { nearbyMap, radioChat }

enum CommsConnectionState { disconnected, connecting, connected, reconnecting }

/// Radius of the "nearby" ring in metres. Keep in sync with the map panel
/// (the 3 km circle) and with the radius the backend uses.
const double kNearbyRadiusMeters = 3000;

/// Prints every raw socket event in debug builds so you can compare the real
/// payloads with what [NearbyRider.fromJson] expects. Turn off when done.
const bool kLogCommsEvents = true;

/// Non-urgent riders that haven't been heard from for this long are dropped.
/// Critical / needs-help entries are never dropped automatically.
const Duration _kStaleAfter = Duration(minutes: 10);

class NearbyRider {
  const NearbyRider({
    required this.id,
    required this.status,
    required this.distance,
    required this.location,
    required this.updatedAt,
    required this.isCritical,
    required this.isNeedHelp,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    this.updatedAtTime,
    this.riderName,
    this.platform,
    this.respondersInfo,
    this.riderInfo,
    this.respondersSummary,
    this.helpNeededText,
    this.crashDetectionText,
  });

  final String id;

  /// Display label: 'Critical', 'Needs help' or '' (no badge).
  final String status;

  /// Display text such as "900 m". Recomputed by the controller from real
  /// coordinates whenever possible.
  final String distance;
  final String location;

  /// Display text such as "2 min ago". Refreshed by the controller.
  final String updatedAt;
  final bool isCritical;
  final bool isNeedHelp;
  final double? latitude;
  final double? longitude;

  /// Raw distance in metres (used for filtering and sorting).
  final double? distanceMeters;

  /// Parsed timestamp of the last update, when the backend sends one.
  final DateTime? updatedAtTime;

  final String? riderName;
  final String? platform;
  final String? respondersInfo;
  final String? riderInfo;
  final String? respondersSummary;
  final String? helpNeededText;
  final String? crashDetectionText;

  NearbyRider copyWith({
    String? status,
    String? distance,
    String? location,
    String? updatedAt,
    bool? isCritical,
    bool? isNeedHelp,
    double? latitude,
    double? longitude,
    double? distanceMeters,
    DateTime? updatedAtTime,
    String? riderName,
    String? platform,
    String? respondersInfo,
    String? riderInfo,
    String? respondersSummary,
    String? helpNeededText,
    String? crashDetectionText,
  }) {
    return NearbyRider(
      id: id,
      status: status ?? this.status,
      distance: distance ?? this.distance,
      location: location ?? this.location,
      updatedAt: updatedAt ?? this.updatedAt,
      isCritical: isCritical ?? this.isCritical,
      isNeedHelp: isNeedHelp ?? this.isNeedHelp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      updatedAtTime: updatedAtTime ?? this.updatedAtTime,
      riderName: riderName ?? this.riderName,
      platform: platform ?? this.platform,
      respondersInfo: respondersInfo ?? this.respondersInfo,
      riderInfo: riderInfo ?? this.riderInfo,
      respondersSummary: respondersSummary ?? this.respondersSummary,
      helpNeededText: helpNeededText ?? this.helpNeededText,
      crashDetectionText: crashDetectionText ?? this.crashDetectionText,
    );
  }

  factory NearbyRider.fromJson(Map<String, dynamic> json) {
    final (latitude, longitude) = _coords(json);
    final distanceMeters = _number(json['distance_meters'] ?? json['distance']);
    final (critical, needHelp) = _flags(json);
    final rawTime =
        json['updated_at'] ??
        json['updatedAt'] ??
        json['time'] ??
        json['timestamp'] ??
        json['created_at'];

    final textDistance =
        json['distance'] is String && _number(json['distance']) == null
        ? _string(json['distance'])
        : _string(json['distance_label']);

    return NearbyRider(
      id: _string(json['id'] ?? json['rider_id'] ?? json['riderId']),
      status: critical
          ? 'Critical'
          : needHelp
          ? 'Needs help'
          : '',
      distance: distanceMeters == null
          ? textDistance
          : distanceLabel(distanceMeters),
      distanceMeters: distanceMeters,
      location: _locationText(json),
      updatedAt: _string(rawTime),
      updatedAtTime: _time(rawTime),
      isCritical: critical,
      isNeedHelp: needHelp,
      latitude: latitude,
      longitude: longitude,
      riderName: json['rider_name']?.toString() ?? json['name']?.toString(),
      platform: json['platform']?.toString(),
      respondersInfo: json['responders_info']?.toString(),
      riderInfo: json['rider_info']?.toString(),
      respondersSummary: json['responders_summary']?.toString(),
      helpNeededText: json['help_needed_text']?.toString(),
      crashDetectionText: json['crash_detection_text']?.toString(),
    );
  }

  /// Keys that carry status information. When none of them is present in an
  /// update, the rider's existing status must be kept.
  static const statusKeys = [
    'status',
    'alert_type',
    'is_critical',
    'needs_help',
    'need_help',
    'severity',
    'threat_level',
  ];

  static String rawStatus(Map<String, dynamic> json) =>
      _string(json['status'] ?? json['alert_type']);

  static String normalizeStatus(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[_\-]+'), ' ').trim();

  static (bool, bool) _flags(Map<String, dynamic> json) {
    final status = normalizeStatus(rawStatus(json));
    final severity = normalizeStatus(
      _string(json['severity'] ?? json['threat_level']),
    );
    final critical =
        json['is_critical'] == true ||
        status == 'critical' ||
        severity == 'critical';
    final needHelp =
        json['needs_help'] == true ||
        json['need_help'] == true ||
        status == 'needs help' ||
        status == 'need help' ||
        status == 'help needed';
    return (critical, needHelp);
  }

  /// Reads coordinates from flat keys or from a nested location object.
  static (double?, double?) _coords(Map<String, dynamic> json) {
    double? lat = _number(json['latitude'] ?? json['lat']);
    double? lng = _number(json['longitude'] ?? json['lng'] ?? json['lon']);
    if (!_validCoord(lat, lng)) {
      lat = null;
      lng = null;
      for (final key in const [
        'location',
        'position',
        'coords',
        'coordinates',
      ]) {
        final v = json[key];
        if (v is Map) {
          final la = _number(v['latitude'] ?? v['lat']);
          final ln = _number(v['longitude'] ?? v['lng'] ?? v['lon']);
          if (_validCoord(la, ln)) {
            lat = la;
            lng = ln;
            break;
          }
        }
      }
    }
    return (lat, lng);
  }

  static bool _validCoord(double? lat, double? lng) =>
      lat != null &&
      lng != null &&
      lat >= -90 &&
      lat <= 90 &&
      lng >= -180 &&
      lng <= 180 &&
      !(lat == 0 && lng == 0);

  static String _locationText(Map<String, dynamic> json) {
    final address = json['address'] ?? json['location_label'];
    if (address != null) return _string(address);
    final loc = json['location'];
    if (loc is String) return loc;
    if (loc is Map) {
      return _string(loc['address'] ?? loc['label'] ?? loc['name']);
    }
    return '';
  }

  static DateTime? _time(Object? value) {
    if (value is num) {
      final n = value.toInt();
      // Treat small numbers as seconds, large ones as milliseconds.
      return DateTime.fromMillisecondsSinceEpoch(
        n < 100000000000 ? n * 1000 : n,
      );
    }
    if (value is String) {
      final asNumber = num.tryParse(value);
      if (asNumber != null) return _time(asNumber);
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String _string(Object? value) => value?.toString() ?? '';

  static double? _number(Object? value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  static String distanceLabel(double meters) => meters < 1000
      ? '${meters.round()} m'
      : '${(meters / 1000).toStringAsFixed(1)} km';
}

class CommsController extends ChangeNotifier {
  CommsController({AuthTokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final AuthTokenStorage _tokenStorage;
  final Map<String, NearbyRider> _riders = {};
  final Map<String, DateTime> _lastSeen = {};
  List<NearbyRider> _visible = const [];

  io.Socket? _gpsSocket;
  io.Socket? _incidentsSocket;
  bool _gpsUp = false;
  bool _incidentsUp = false;

  Timer? _reconnectTimer;
  Timer? _ticker;
  StreamSubscription<Position>? _positionSub;
  bool _disposed = false;
  bool _initialized = false;
  int _reconnectAttempt = 0;

  CommsMode _mode = CommsMode.nearbyMap;
  Position? _position;
  bool _isLoadingLocation = false;
  String? _locationError;
  String? _connectionError;
  CommsConnectionState _connectionState = CommsConnectionState.disconnected;

  CommsMode get mode => _mode;
  Position? get position => _position;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  String? get connectionError => _connectionError;
  CommsConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == CommsConnectionState.connected;

  /// Riders and incidents inside [kNearbyRadiusMeters], most urgent first
  /// (critical, then needs help, then the rest), nearest first within a group.
  /// Distance and "x min ago" labels are computed here from real data.
  List<NearbyRider> get nearbyRiders => _visible;

  // Kept for compatibility; the map panel builds its own markers and circle.
  Set<Marker> get riderMarkers => {
    if (_position != null)
      Marker(
        markerId: const MarkerId('current-rider'),
        position: LatLng(_position!.latitude, _position!.longitude),
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    for (final rider in _riders.values)
      if (rider.latitude != null && rider.longitude != null)
        Marker(
          markerId: MarkerId(rider.id),
          position: LatLng(rider.latitude!, rider.longitude!),
          infoWindow: InfoWindow(title: rider.id),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            rider.isCritical
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueOrange,
          ),
        ),
  };

  Set<Circle> get coverageCircles => {
    if (_position != null)
      Circle(
        circleId: const CircleId('nearby-coverage'),
        center: LatLng(_position!.latitude, _position!.longitude),
        radius: kNearbyRadiusMeters,
        fillColor: const Color(0x1434C759),
        strokeColor: const Color(0x9934C759),
        strokeWidth: 2,
      ),
  };

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    // Refreshes "x min ago" labels and drops stale non-urgent riders.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      _pruneStale();
      _notify();
    });
    await Future.wait([refreshLocation(), connect()]);
  }

  void selectMode(CommsMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _notify();
  }

  // ---------------------------------------------------------------------
  // Sockets
  // ---------------------------------------------------------------------

  static const _incidentEvents = [
    'incident.created',
    'incident.status_changed',
    'incident.escalated',
    'incident.verified',
    'incident.threat_level_changed',
    'incident.peer_responded',
    'incident.severity_changed',
    'incident.peer_stand_down',
    'report.status_changed',
  ];

  Future<void> connect() async {
    if (_disposed ||
        _connectionState == CommsConnectionState.connecting ||
        _connectionState == CommsConnectionState.reconnecting ||
        _connectionState == CommsConnectionState.connected) {
      return;
    }

    _reconnectTimer?.cancel();
    _setConnectionState(
      _reconnectAttempt == 0
          ? CommsConnectionState.connecting
          : CommsConnectionState.reconnecting,
    );

    try {
      final token = await _tokenStorage.readAccessToken();
      if (_disposed) return;
      if (token == null || token.isEmpty) {
        throw const CommsConnectionException(
          'You must be signed in to receive nearby rider updates.',
        );
      }

      // Never leave an old pair of sockets (and their listeners) alive.
      _teardownSockets();

      final options = io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew() // one separate connection per namespace
          .disableAutoConnect()
          .setAuth({'token': token})
          .build();

      final gps = io.io('${NetworkSettings.commsSocketBaseUrl}/gps', options);
      final incidents = io.io(
        '${NetworkSettings.commsSocketBaseUrl}/incidents',
        options,
      );
      _gpsSocket = gps;
      _incidentsSocket = incidents;

      gps.on('connect', (_) => _handleSocketConnected(gps));
      incidents.on('connect', (_) => _handleSocketConnected(incidents));

      // Pass the Socket.IO event name along: the payload itself usually does
      // not say which event it belongs to.
      gps.on('gps-update', (data) => _handleSocketMessage('gps-update', data));
      for (final event in _incidentEvents) {
        incidents.on(event, (data) => _handleSocketMessage(event, data));
      }

      gps.on('connect_error', (e) => _handleSocketClosed(gps, e));
      incidents.on('connect_error', (e) => _handleSocketClosed(incidents, e));
      gps.on('disconnect', (e) => _handleSocketClosed(gps, e));
      incidents.on('disconnect', (e) => _handleSocketClosed(incidents, e));

      gps.connect();
      incidents.connect();
    } on CommsConnectionException catch (error) {
      _handleConnectionFailure(error.message);
    } on FormatException catch (error) {
      _handleConnectionFailure(error.message);
    } catch (error) {
      _handleConnectionFailure(error.toString());
    }
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectAttempt = 0;
    _teardownSockets();
    if (!_disposed) _setConnectionState(CommsConnectionState.disconnected);
  }

  void _teardownSockets() {
    final gps = _gpsSocket;
    final incidents = _incidentsSocket;
    // Clear the references first so late events from these sockets are ignored.
    _gpsSocket = null;
    _incidentsSocket = null;
    _gpsUp = false;
    _incidentsUp = false;
    gps?.dispose();
    incidents?.dispose();
  }

  bool _isCurrent(io.Socket socket) =>
      identical(socket, _gpsSocket) || identical(socket, _incidentsSocket);

  void _handleSocketConnected(io.Socket socket) {
    if (_disposed || !_isCurrent(socket)) return;
    if (identical(socket, _gpsSocket)) {
      _gpsUp = true;
    } else {
      _incidentsUp = true;
    }
    if (_gpsUp && _incidentsUp) {
      _reconnectAttempt = 0;
      _connectionError = null;
      _setConnectionState(CommsConnectionState.connected);
      // The server needs our position to know who is "nearby".
      _sendLocation();
    }
  }

  void _handleSocketClosed(io.Socket socket, dynamic reason) {
    if (_disposed || !_isCurrent(socket)) return;
    _handleConnectionFailure(
      reason?.toString() ?? 'The Comms connection was closed.',
    );
  }

  void _handleConnectionFailure(String message) {
    if (_disposed) return;
    _teardownSockets();
    _connectionError = message;
    _connectionState = CommsConnectionState.disconnected;
    _notify();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer?.isActive == true) return;
    final seconds = 1 << _reconnectAttempt.clamp(0, 5);
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }

  void _setConnectionState(CommsConnectionState state) {
    _connectionState = state;
    _notify();
  }

  // ---------------------------------------------------------------------
  // Incoming events
  // ---------------------------------------------------------------------

  void _handleSocketMessage(String eventName, dynamic message) {
    if (kLogCommsEvents && kDebugMode) {
      debugPrint('[comms] $eventName: $message');
    }
    try {
      final map = _asMap(message);
      if (map == null) {
        throw const FormatException('The Comms event must be a JSON object.');
      }
      _applyEvent(eventName, map);
    } on FormatException catch (error) {
      _connectionError = error.message;
      _notify();
    }
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    if (value is List && value.isNotEmpty) return _asMap(value.first);
    if (value is String) {
      try {
        return _asMap(jsonDecode(value));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static const _upsertTypes = {'rider_upsert', 'rider_update', 'nearby_rider'};

  /// Incident statuses that mean "this is over" and should leave the map.
  static const _terminalStatuses = {
    'resolved',
    'closed',
    'cancelled',
    'canceled',
    'completed',
    'expired',
    'false alarm',
    'stood down',
    'stand down',
  };

  bool _isUpsertType(String type) =>
      _upsertTypes.contains(type) ||
      type == 'gps-update' ||
      type.startsWith('incident.') ||
      type.startsWith('report.');

  void _applyEvent(String eventName, Map<String, dynamic> event) {
    final type = (event['type'] ?? event['event'] ?? eventName).toString();
    final payload = _asMap(event['data']) ?? event;

    switch (type) {
      case 'nearby_snapshot':
      case 'riders_snapshot':
        final riders = payload['riders'];
        if (riders is! List) {
          throw const FormatException('The rider snapshot has no riders list.');
        }
        _riders.clear();
        _lastSeen.clear();
        for (final item in riders) {
          final json = _asMap(item);
          if (json != null) _upsert(json);
        }
      case 'rider_removed':
      case 'nearby_rider_removed':
        final id = (payload['rider_id'] ?? payload['id'])?.toString();
        if (id != null) {
          _riders.remove(id);
          _lastSeen.remove(id);
        }
      case 'error':
        _connectionError =
            payload['message']?.toString() ?? 'Comms server error.';
      default:
        if (!_isUpsertType(type)) return;
        final rider = _asMap(payload['rider']);
        final incident = _asMap(payload['incident']);
        _upsert({...payload, ...?incident, ...?rider});
    }
    _notify();
  }

  /// Adds or updates one rider. Fields missing from a partial update keep
  /// their previous values instead of being wiped.
  void _upsert(Map<String, dynamic> json) {
    final incoming = NearbyRider.fromJson(json);
    if (incoming.id.isEmpty) {
      throw const FormatException('A rider update has no rider ID.');
    }

    final statusSent = NearbyRider.statusKeys.any(json.containsKey);
    if (statusSent &&
        _terminalStatuses.contains(
          NearbyRider.normalizeStatus(NearbyRider.rawStatus(json)),
        )) {
      _riders.remove(incoming.id);
      _lastSeen.remove(incoming.id);
      return;
    }

    _lastSeen[incoming.id] = DateTime.now();
    final existing = _riders[incoming.id];
    if (existing == null) {
      _riders[incoming.id] = incoming;
      return;
    }

    String? text(String value) => value.isEmpty ? null : value;
    _riders[incoming.id] = existing.copyWith(
      status: statusSent ? incoming.status : null,
      isCritical: statusSent ? incoming.isCritical : null,
      isNeedHelp: statusSent ? incoming.isNeedHelp : null,
      distance: text(incoming.distance),
      distanceMeters: incoming.distanceMeters,
      location: text(incoming.location),
      updatedAt: text(incoming.updatedAt),
      updatedAtTime: incoming.updatedAtTime,
      latitude: incoming.latitude,
      longitude: incoming.longitude,
      riderName: incoming.riderName,
      platform: incoming.platform,
      respondersInfo: incoming.respondersInfo,
      riderInfo: incoming.riderInfo,
      respondersSummary: incoming.respondersSummary,
      helpNeededText: incoming.helpNeededText,
      crashDetectionText: incoming.crashDetectionText,
    );
  }

  void _pruneStale() {
    final cutoff = DateTime.now().subtract(_kStaleAfter);
    _riders.removeWhere((id, rider) {
      if (rider.isCritical || rider.isNeedHelp) return false;
      final seen = _lastSeen[id];
      return seen != null && seen.isBefore(cutoff);
    });
    _lastSeen.removeWhere((id, _) => !_riders.containsKey(id));
  }

  // ---------------------------------------------------------------------
  // Visible list (filter, distance, sort)
  // ---------------------------------------------------------------------

  void _notify() {
    if (_disposed) return;
    _visible = _computeVisible();
    notifyListeners();
  }

  List<NearbyRider> _computeVisible() {
    final me = _position;
    final entries = <({NearbyRider rider, double? meters})>[];

    for (final rider in _riders.values) {
      double? meters = rider.distanceMeters;
      if (me != null && rider.latitude != null && rider.longitude != null) {
        meters = Geolocator.distanceBetween(
          me.latitude,
          me.longitude,
          rider.latitude!,
          rider.longitude!,
        );
      }
      // Outside the ring: hide. Unknown distance: keep (better to show an
      // incident than to hide one).
      if (meters != null && meters > kNearbyRadiusMeters) continue;

      entries.add((
        rider: rider.copyWith(
          distance: meters == null ? null : NearbyRider.distanceLabel(meters),
          distanceMeters: meters,
          updatedAt: _updatedLabel(rider),
        ),
        meters: meters,
      ));
    }

    int rank(NearbyRider r) => r.isCritical
        ? 0
        : r.isNeedHelp
        ? 1
        : 2;
    entries.sort((a, b) {
      final byRank = rank(a.rider).compareTo(rank(b.rider));
      if (byRank != 0) return byRank;
      return (a.meters ?? double.infinity).compareTo(
        b.meters ?? double.infinity,
      );
    });

    return List.unmodifiable(entries.map((e) => e.rider));
  }

  String _updatedLabel(NearbyRider rider) {
    final time =
        rider.updatedAtTime ??
        (rider.updatedAt.isEmpty ? _lastSeen[rider.id] : null);
    if (time == null) return rider.updatedAt;
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }

  // ---------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------

  Future<void> refreshLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    _notify();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationServiceDisabledException();
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const PermissionDeniedException(
          'Location permission was denied.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException(
          'Location permission is permanently denied. Enable it in Settings.',
        );
      }
      _position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _startPositionStream();
      _sendLocation();
    } on LocationServiceDisabledException {
      _locationError = 'Turn on location services to center the map.';
    } on PermissionDeniedException catch (error) {
      _locationError = error.message;
    } on TimeoutException {
      _locationError = 'Location lookup timed out. Try again.';
    } catch (_) {
      _locationError = 'Could not get your location. Try again.';
    } finally {
      _isLoadingLocation = false;
      _notify();
    }
  }

  /// Keeps our position (and the server's idea of "nearby") up to date as the
  /// rider moves.
  void _startPositionStream() {
    if (_positionSub != null) return;
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 25, // metres
          ),
        ).listen((position) {
          _position = position;
          _sendLocation();
          _notify();
        }, onError: (_) {});
  }

  void _sendLocation() {
    final position = _position;
    final socket = _gpsSocket;
    if (position == null || socket == null || !_gpsUp) return;
    socket.emit('location_update', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _ticker?.cancel();
    _positionSub?.cancel();
    _positionSub = null;
    _teardownSockets();
    super.dispose();
  }
}

class CommsConnectionException implements Exception {
  const CommsConnectionException(this.message);

  final String message;
}

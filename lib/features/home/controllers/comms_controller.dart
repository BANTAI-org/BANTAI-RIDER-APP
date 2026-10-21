import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../core/constants/network_settings.dart';
import '../../../core/storage/auth_token_storage.dart';

enum CommsMode { nearbyMap, radioChat }

enum CommsConnectionState { disconnected, connecting, connected, reconnecting }

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
  });

  final String id;
  final String status;
  final String distance;
  final String location;
  final String updatedAt;
  final bool isCritical;
  final bool isNeedHelp;
  final double? latitude;
  final double? longitude;

  NearbyRider copyWith({
    String? status,
    String? distance,
    String? location,
    String? updatedAt,
    bool? isCritical,
    bool? isNeedHelp,
    double? latitude,
    double? longitude,
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
    );
  }

  factory NearbyRider.fromJson(Map<String, dynamic> json) {
    final latitude = _number(json['latitude'] ?? json['lat']);
    final longitude = _number(json['longitude'] ?? json['lng']);
    final distance = _number(json['distance_meters'] ?? json['distance']);
    final status = _string(json['status'] ?? json['alert_type']);

    return NearbyRider(
      id: _string(json['id'] ?? json['rider_id'] ?? json['riderId']),
      status: status,
      distance: distance == null
          ? _string(json['distance_label'])
          : _distanceLabel(distance),
      location: _string(json['location'] ?? json['address']),
      updatedAt: _string(
        json['updated_at'] ?? json['updatedAt'] ?? json['time'],
      ),
      isCritical:
          json['is_critical'] == true || status.toLowerCase() == 'critical',
      isNeedHelp:
          json['needs_help'] == true || status.toLowerCase() == 'needs help',
      latitude: latitude,
      longitude: longitude,
    );
  }

  static String _string(Object? value) => value?.toString() ?? '';

  static double? _number(Object? value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  static String _distanceLabel(double meters) => meters < 1000
      ? '${meters.round()} m'
      : '${(meters / 1000).toStringAsFixed(1)} km';
}

class CommsController extends ChangeNotifier {
  CommsController({AuthTokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final AuthTokenStorage _tokenStorage;
  final Map<String, NearbyRider> _riders = {};
  io.Socket? _gpsSocket;
  io.Socket? _incidentsSocket;
  Timer? _reconnectTimer;
  bool _disposed = false;
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
  List<NearbyRider> get nearbyRiders => _riders.values.toList(growable: false);

  Set<Marker> get riderMarkers => {
    if (_position != null)
      Marker(
        markerId: const MarkerId('current-rider'),
        position: LatLng(_position!.latitude, _position!.longitude),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
    for (final rider in _riders.values)
      if (rider.latitude != null && rider.longitude != null)
        Marker(
          markerId: MarkerId(rider.id),
          position: LatLng(rider.latitude!, rider.longitude!),
          infoWindow: InfoWindow(title: rider.id),
        ),
  };

  Set<Circle> get coverageCircles => {
    if (_position != null)
      Circle(
        circleId: const CircleId('nearby-coverage'),
        center: LatLng(_position!.latitude, _position!.longitude),
        radius: 3000,
        fillColor: const Color(0x1434C759),
        strokeColor: const Color(0x9934C759),
        strokeWidth: 1,
      ),
  };

  Future<void> initialize() async {
    await Future.wait([refreshLocation(), connect()]);
  }

  void selectMode(CommsMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  Future<void> connect() async {
    if (_disposed ||
        _connectionState == CommsConnectionState.connecting ||
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
      if (token == null || token.isEmpty) {
        throw const CommsConnectionException(
          'You must be signed in to receive nearby rider updates.',
        );
      }

      final options = io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build();
      final gpsSocket = io.io(
        '${NetworkSettings.commsSocketBaseUrl}/gps',
        options,
      );
      final incidentsSocket = io.io(
        '${NetworkSettings.commsSocketBaseUrl}/incidents',
        options,
      );
      if (_disposed) {
        gpsSocket.dispose();
        incidentsSocket.dispose();
        return;
      }

      _gpsSocket = gpsSocket;
      _incidentsSocket = incidentsSocket;
      gpsSocket.on('connect', (_) => _handleSocketConnected());
      incidentsSocket.on('connect', (_) => _handleSocketConnected());
      gpsSocket.on('gps-update', _handleSocketMessage);
      for (final event in _incidentEvents) {
        incidentsSocket.on(event, _handleSocketMessage);
      }
      gpsSocket.on('connect_error', _handleSocketError);
      incidentsSocket.on('connect_error', _handleSocketError);
      gpsSocket.on('disconnect', _handleSocketClosed);
      incidentsSocket.on('disconnect', _handleSocketClosed);
      gpsSocket.connect();
      incidentsSocket.connect();
    } on CommsConnectionException catch (error) {
      _handleConnectionFailure(error.message);
    } on FormatException catch (error) {
      _handleConnectionFailure(error.message);
    }
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectAttempt = 0;
    _gpsSocket?.dispose();
    _incidentsSocket?.dispose();
    _gpsSocket = null;
    _incidentsSocket = null;
    if (!_disposed) _setConnectionState(CommsConnectionState.disconnected);
  }

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

  void _handleSocketConnected() {
    _reconnectAttempt = 0;
    _connectionError = null;
    _setConnectionState(CommsConnectionState.connected);
  }

  void _handleSocketMessage(dynamic message) {
    try {
      if (message is! Map) {
        throw const FormatException('The Comms event must be a JSON object.');
      }
      _applyEvent(Map<String, dynamic>.from(message));
    } on FormatException catch (error) {
      _connectionError = error.message;
      notifyListeners();
    }
  }

  void _applyEvent(Map<String, dynamic> event) {
    final type = event['type']?.toString() ?? event['event']?.toString();
    final payload = event['data'] is Map<String, dynamic>
        ? event['data'] as Map<String, dynamic>
        : event;

    switch (type) {
      case 'nearby_snapshot':
      case 'riders_snapshot':
        final riders = payload['riders'];
        if (riders is! List) {
          throw const FormatException('The rider snapshot has no riders list.');
        }
        _riders
          ..clear()
          ..addEntries(
            riders.whereType<Map<String, dynamic>>().map((json) {
              final rider = NearbyRider.fromJson(json);
              return MapEntry(rider.id, rider);
            }),
          );
      case 'rider_upsert':
      case 'rider_update':
      case 'nearby_rider':
        final rider = NearbyRider.fromJson(
          payload['rider'] is Map<String, dynamic>
              ? payload['rider'] as Map<String, dynamic>
              : payload,
        );
        if (rider.id.isEmpty) {
          throw const FormatException('A rider update has no rider ID.');
        }
        _riders.update(
          rider.id,
          (existing) => existing.copyWith(
            status: rider.status,
            distance: rider.distance,
            location: rider.location,
            updatedAt: rider.updatedAt,
            isCritical: rider.isCritical,
            isNeedHelp: rider.isNeedHelp,
            latitude: rider.latitude,
            longitude: rider.longitude,
          ),
          ifAbsent: () => rider,
        );
      case 'rider_removed':
      case 'nearby_rider_removed':
        final id = payload['rider_id']?.toString() ?? payload['id']?.toString();
        if (id != null) _riders.remove(id);
      case 'error':
        _connectionError =
            payload['message']?.toString() ?? 'Comms server error.';
      default:
        return;
    }
    notifyListeners();
  }

  void _handleSocketError(dynamic error) {
    _handleConnectionFailure(error?.toString() ?? 'Socket.IO connection failed.');
  }

  void _handleSocketClosed(dynamic _) {
    _gpsSocket = null;
    _incidentsSocket = null;
    if (!_disposed)
      _handleConnectionFailure('The Comms connection was closed.');
  }

  void _handleConnectionFailure(String message) {
    if (_disposed) return;
    _connectionError = message;
    _connectionState = CommsConnectionState.disconnected;
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer?.isActive == true) return;
    final seconds = (1 << _reconnectAttempt.clamp(0, 5)).toInt();
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }

  void _setConnectionState(CommsConnectionState state) {
    _connectionState = state;
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
        throw const PermissionDeniedException(
          'Location permission was denied.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException(
          'Location permission is permanently denied. Enable it in Settings.',
        );
      }
      _position = await Geolocator.getCurrentPosition();
      _sendLocation();
    } on LocationServiceDisabledException {
      _locationError = 'Turn on location services to center the map.';
    } on PermissionDeniedException catch (error) {
      _locationError = error.message;
    } on TimeoutException {
      _locationError = 'Location lookup timed out. Try again.';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void _sendLocation() {
    final position = _position;
    if (!isConnected || position == null) return;
    _gpsSocket?.emit('location_update', {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _gpsSocket?.dispose();
    _incidentsSocket?.dispose();
    _gpsSocket = null;
    _incidentsSocket = null;
    super.dispose();
  }
}

class CommsConnectionException implements Exception {
  const CommsConnectionException(this.message);

  final String message;
}

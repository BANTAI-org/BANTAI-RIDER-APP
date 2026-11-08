// lib/features/rescue/services/rescue_sockets.dart

import 'dart:async';
import 'dart:developer' as developer;

import 'package:socket_io_client/socket_io_client.dart' as io;

// ───────────────────────────────────────────────────────────────
// Event names — keep in sync with `events/incident-events.ts`
// ───────────────────────────────────────────────────────────────

class RescueSocketEventNames {
  RescueSocketEventNames._();

  static const incidentCreated        = 'incident.created';
  static const statusChanged          = 'incident.status_changed';
  static const threatLevelChanged     = 'incident.threat_level_changed';
  static const verified               = 'incident.verified';
  static const escalated              = 'incident.escalated';
  static const peerResponded          = 'incident.peer_responded';
  static const peerStandDown          = 'incident.peer_stand_down';
  static const peerNearby             = 'incident.peer_nearby';
  static const trackingUpdated        = 'incident.tracking_updated';
}

// ───────────────────────────────────────────────────────────────
// Payload models
// ───────────────────────────────────────────────────────────────

/// Geometry returned by `IncidentCreatedEvent`.
class RescueLocation {
  const RescueLocation({required this.longitude, required this.latitude});

  final double longitude;
  final double latitude;

  static RescueLocation? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final lng = raw['longitude'];
    final lat = raw['latitude'];
    if (lng is! num || lat is! num) return null;
    return RescueLocation(
      longitude: lng.toDouble(),
      latitude: lat.toDouble(),
    );
  }
}

/// `incident.created` — the driver's own incident has just been detected.
class IncidentCreatedEvent {
  const IncidentCreatedEvent({
    required this.incidentId,
    required this.triggerSource,
    required this.threatType,
    required this.threatCategory,
    required this.severity,
    required this.location,
    required this.driverId,
  });

  final String incidentId;
  final String triggerSource;
  final String threatType;
  final String threatCategory;
  final String? severity;
  final RescueLocation? location;
  final String? driverId;

  static IncidentCreatedEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    if (id == null) return null;
    return IncidentCreatedEvent(
      incidentId: id,
      triggerSource: _asString(raw['triggerSource']) ?? 'UNKNOWN',
      threatType: _asString(raw['threatType']) ?? 'OTHER',
      threatCategory: _asString(raw['threatCategory']) ?? 'ASSIST',
      severity: _asString(raw['severity']),
      location: RescueLocation.tryParse(raw['location']),
      driverId: _asString(raw['driverId']),
    );
  }
}

/// Base shape shared by status / threat-level / verified / escalated /
/// peer-responded events (all emitted with `this.base(incident)` spread).
abstract class _IncidentEnvelope {
  const _IncidentEnvelope({
    required this.incidentId,
    this.driverId,
    this.claimedById,
    this.updatedAt,
  });

  final String incidentId;
  final String? driverId;
  final String? claimedById;
  final String? updatedAt;
}

class IncidentStatusChangedEvent extends _IncidentEnvelope {
  const IncidentStatusChangedEvent({
    required super.incidentId,
    super.driverId,
    super.claimedById,
    super.updatedAt,
    required this.status,
  });

  final String status;

  static IncidentStatusChangedEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final status = _asString(raw['status']);
    if (id == null || status == null) return null;
    return IncidentStatusChangedEvent(
      incidentId: id,
      driverId: _asString(raw['driverId']),
      claimedById: _asString(raw['claimedById']),
      updatedAt: _asString(raw['updatedAt']),
      status: status,
    );
  }
}

class IncidentThreatLevelChangedEvent extends _IncidentEnvelope {
  const IncidentThreatLevelChangedEvent({
    required super.incidentId,
    super.driverId,
    super.claimedById,
    super.updatedAt,
    required this.threatLevel,
  });

  final String threatLevel;

  static IncidentThreatLevelChangedEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final level = _asString(raw['threatLevel']);
    if (id == null || level == null) return null;
    return IncidentThreatLevelChangedEvent(
      incidentId: id,
      driverId: _asString(raw['driverId']),
      claimedById: _asString(raw['claimedById']),
      updatedAt: _asString(raw['updatedAt']),
      threatLevel: level,
    );
  }
}

class IncidentVerifiedEvent extends _IncidentEnvelope {
  const IncidentVerifiedEvent({
    required super.incidentId,
    super.driverId,
    super.claimedById,
    super.updatedAt,
    required this.verifiedById,
  });

  final String verifiedById;

  static IncidentVerifiedEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final verifiedById = _asString(raw['verifiedById']);
    if (id == null || verifiedById == null) return null;
    return IncidentVerifiedEvent(
      incidentId: id,
      driverId: _asString(raw['driverId']),
      claimedById: _asString(raw['claimedById']),
      updatedAt: _asString(raw['updatedAt']),
      verifiedById: verifiedById,
    );
  }
}

class IncidentEscalatedEvent extends _IncidentEnvelope {
  const IncidentEscalatedEvent({
    required super.incidentId,
    super.driverId,
    super.claimedById,
    super.updatedAt,
    required this.escalationId,
    required this.commandCenterId,
    required this.reason,
  });

  final String escalationId;
  final String commandCenterId;
  final String reason;

  static IncidentEscalatedEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final escalationId = _asString(raw['escalationId']);
    final ccId = _asString(raw['commandCenterId']);
    final reason = _asString(raw['reason']);
    if (id == null || escalationId == null || ccId == null || reason == null) {
      return null;
    }
    return IncidentEscalatedEvent(
      incidentId: id,
      driverId: _asString(raw['driverId']),
      claimedById: _asString(raw['claimedById']),
      updatedAt: _asString(raw['updatedAt']),
      escalationId: escalationId,
      commandCenterId: ccId,
      reason: reason,
    );
  }
}

class IncidentPeerRespondedEvent extends _IncidentEnvelope {
  const IncidentPeerRespondedEvent({
    required super.incidentId,
    super.driverId,
    super.claimedById,
    super.updatedAt,
    required this.peerDriverId,
    required this.status,
  });

  final String peerDriverId;
  final String status;

  static IncidentPeerRespondedEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final peerId = _asString(raw['peerDriverId']);
    final status = _asString(raw['status']);
    if (id == null || peerId == null || status == null) return null;
    return IncidentPeerRespondedEvent(
      incidentId: id,
      driverId: _asString(raw['driverId']),
      claimedById: _asString(raw['claimedById']),
      updatedAt: _asString(raw['updatedAt']),
      peerDriverId: peerId,
      status: status,
    );
  }
}

/// `incident.peer_stand_down` — sent to a driver who was helping and is
/// being told to clear the scene.
class IncidentPeerStandDownEvent {
  const IncidentPeerStandDownEvent({
    required this.incidentId,
    required this.peerDriverId,
    required this.reason,
    required this.updatedAt,
  });

  final String incidentId;
  final String peerDriverId;
  final String reason;
  final String updatedAt;

  static IncidentPeerStandDownEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final peerId = _asString(raw['peerDriverId']);
    final reason = _asString(raw['reason']);
    if (id == null || peerId == null || reason == null) return null;
    return IncidentPeerStandDownEvent(
      incidentId: id,
      peerDriverId: peerId,
      reason: reason,
      updatedAt: _asString(raw['updatedAt']) ?? DateTime.now().toIso8601String(),
    );
  }
}

/// `incident.peer_nearby` — "someone just crashed N meters away, want to help?"
class IncidentPeerNearbyEvent {
  const IncidentPeerNearbyEvent({
    required this.incidentId,
    required this.distanceMeters,
  });

  final String incidentId;
  final double distanceMeters;

  static IncidentPeerNearbyEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final dist = _asDouble(raw['distanceMeters']);
    if (id == null || dist == null) return null;
    return IncidentPeerNearbyEvent(
      incidentId: id,
      distanceMeters: dist,
    );
  }
}

/// `incident.tracking_updated` — live responder position / ETA.
class IncidentTrackingUpdatedEvent {
  const IncidentTrackingUpdatedEvent({
    required this.incidentId,
    required this.responderId,
    required this.responderName,
    required this.distanceMeters,
    required this.etaSeconds,
    required this.lastSeenAt,
    required this.computedAt,
  });

  final String incidentId;
  final String responderId;
  final String? responderName;
  final double distanceMeters;
  final int etaSeconds;
  final String lastSeenAt;
  final String computedAt;

  static IncidentTrackingUpdatedEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final id = _asString(raw['incidentId']);
    final responderId = _asString(raw['responderId']);
    if (id == null || responderId == null) return null;
    return IncidentTrackingUpdatedEvent(
      incidentId: id,
      responderId: responderId,
      responderName: _asString(raw['responderName']),
      distanceMeters: _asDouble(raw['distanceMeters']) ?? 0,
      etaSeconds: _asInt(raw['etaSeconds']) ?? 0,
      lastSeenAt: _asString(raw['lastSeenAt']) ??
          DateTime.now().toIso8601String(),
      computedAt: _asString(raw['computedAt']) ??
          DateTime.now().toIso8601String(),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Cancellable subscription handle
// ───────────────────────────────────────────────────────────────

/// Mirrors `SocketListener` from `socket_service.dart` — callers keep
/// the handle and `cancel()` on dispose.
class RescueSocketSubscription {
  RescueSocketSubscription._(this._cancel);
  final void Function() _cancel;
  bool _cancelled = false;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _cancel();
  }
}

// ───────────────────────────────────────────────────────────────
// Service
// ───────────────────────────────────────────────────────────────

class RescueSocketService {
  RescueSocketService({String? baseUrl})
      : _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:3000',
            );

  final String _baseUrl;

  io.Socket? _socket;
  bool _disposed = false;

  final _connectedController   = StreamController<void>.broadcast();
  final _reconnectedController = StreamController<void>.broadcast();
  final _disconnectedController = StreamController<String?>.broadcast();
  final _reconnectingController = StreamController<int>.broadcast();
  final _errorController        = StreamController<Object>.broadcast();

  // ── Introspection ────────────────────────────────────────────
  bool   get isConnected  => _socket?.connected ?? false;
  String? get socketId    => _socket?.id;
  bool   get isDisposed   => _disposed;

  // ── Lifecycle streams ────────────────────────────────────────

  /// Fires the first time the socket connects, and every time a
  /// reconnect succeeds. **The controller should re-`GET /incidents/all`
  /// inside this callback** — the server does NOT replay
  /// `incident.tracking_updated` or re-join `incident:<id>` after a
  /// reconnect, so any incident created while offline is invisible
  /// to the socket until REST re-hydrates it.
  Stream<void> get onConnected => _connectedController.stream;
  Stream<void> get onReconnected => _reconnectedController.stream;
  Stream<String?> get onDisconnected => _disconnectedController.stream;
  Stream<int> get onReconnecting => _reconnectingController.stream;
  Stream<Object> get onError => _errorController.stream;

  // ── Connect / disconnect ─────────────────────────────────────

  Future<void> connect({required String accessToken}) async {
    if (_disposed) {
      throw StateError('RescueSocketService has been disposed');
    }
    _teardownSocket();

    final socket = io.io(
      '$_baseUrl/incidents',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setReconnectionAttempts(20)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(15000)
          .setAuth({'token': accessToken})
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      developer.log(
        'rescue socket connected (id=${socket.id})',
        name: 'RescueSocketService',
      );
      if (!_connectedController.isClosed) _connectedController.add(null);
    });

    socket.onDisconnect((reason) {
      developer.log(
        'rescue socket disconnected: $reason',
        name: 'RescueSocketService',
      );
      if (!_disconnectedController.isClosed) {
        _disconnectedController.add(reason?.toString());
      }
    });

    socket.onReconnect((_) {
      developer.log(
        'rescue socket reconnected',
        name: 'RescueSocketService',
      );
      if (!_reconnectedController.isClosed) _reconnectedController.add(null);
    });

    socket.onReconnectAttempt((attempt) {
      if (!_reconnectingController.isClosed) {
        _reconnectingController.add(attempt is int ? attempt : 0);
      }
    });

    socket.onConnectError((err) {
      developer.log(
        'rescue socket connect_error: $err',
        name: 'RescueSocketService',
      );
      if (!_errorController.isClosed) _errorController.add(err as Object);
    });

    socket.connect();
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _teardownSocket();
    _connectedController.close();
    _reconnectedController.close();
    _disconnectedController.close();
    _reconnectingController.close();
    _errorController.close();
  }

  // ── Incident event subscriptions ─────────────────────────────
  //
  // Every method returns a [RescueSocketSubscription]; cancel it in
  // `dispose()`. `socket.off(eventName, handler)` removes exactly the
  // listener we added, so multiple subscribers to the same event
  // don't interfere.

  RescueSocketSubscription onIncidentCreated(
    void Function(IncidentCreatedEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.incidentCreated,
      IncidentCreatedEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onStatusChanged(
    void Function(IncidentStatusChangedEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.statusChanged,
      IncidentStatusChangedEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onThreatLevelChanged(
    void Function(IncidentThreatLevelChangedEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.threatLevelChanged,
      IncidentThreatLevelChangedEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onVerified(
    void Function(IncidentVerifiedEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.verified,
      IncidentVerifiedEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onEscalated(
    void Function(IncidentEscalatedEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.escalated,
      IncidentEscalatedEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onPeerResponded(
    void Function(IncidentPeerRespondedEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.peerResponded,
      IncidentPeerRespondedEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onPeerStandDown(
    void Function(IncidentPeerStandDownEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.peerStandDown,
      IncidentPeerStandDownEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onPeerNearby(
    void Function(IncidentPeerNearbyEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.peerNearby,
      IncidentPeerNearbyEvent.tryParse,
      handler,
    );
  }

  RescueSocketSubscription onTrackingUpdated(
    void Function(IncidentTrackingUpdatedEvent event) handler,
  ) {
    return _subscribe(
      RescueSocketEventNames.trackingUpdated,
      IncidentTrackingUpdatedEvent.tryParse,
      handler,
    );
  }

  // ── Internals ────────────────────────────────────────────────

  RescueSocketSubscription _subscribe<T>(
    String eventName,
    T? Function(dynamic raw) parse,
    void Function(T event) handler,
  ) {
    final socket = _socket;
    if (socket == null) {
      throw StateError(
        'Cannot subscribe to "$eventName" — RescueSocketService.connect() '
        'has not been called yet.',
      );
    }

    void wrapped(dynamic data) {
      final parsed = parse(data);
      if (parsed == null) {
        developer.log(
          'RescueSocketService: malformed payload on "$eventName": $data',
          name: 'RescueSocketService',
        );
        return;
      }
      try {
        handler(parsed);
      } catch (err, stack) {
        developer.log(
          'RescueSocketService: handler for "$eventName" threw',
          name: 'RescueSocketService',
          error: err,
          stackTrace: stack,
        );
      }
    }

    socket.on(eventName, wrapped);
    return RescueSocketSubscription._(() {
      socket.off(eventName, wrapped);
    });
  }

  void _teardownSocket() {
    final socket = _socket;
    _socket = null;
    if (socket == null) return;
    try {
      socket.offAny();
      socket.dispose();
    } catch (_) {
      // The underlying transport may already be gone — dispose should
      // never throw into the caller.
    }
  }
}

String? _asString(dynamic v) => v is String ? v : null;
double? _asDouble(dynamic v) => v is num ? v.toDouble() : null;
int?    _asInt(dynamic v)    => v is num ? v.toInt()    : null;
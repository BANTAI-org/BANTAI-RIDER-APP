/// Mirrors `incident_status_enum` in migration 001.
enum IncidentStatus {
  detected('DETECTED'),
  dispatching('DISPATCHING'),
  claimed('CLAIMED'),
  enRoute('EN_ROUTE'),
  onScene('ON_SCENE'),
  awaitingVerification('AWAITING_VERIFICATION'),
  escalated('ESCALATED'),
  resolved('RESOLVED'),
  cancelled('CANCELLED');

  const IncidentStatus(this.value);
  final String value;

  static IncidentStatus fromString(String? raw) {
    if (raw == null) return IncidentStatus.detected;
    final upper = raw.toUpperCase();
    for (final s in IncidentStatus.values) {
      if (s.value == upper) return s;
    }
    return IncidentStatus.detected;
  }

  bool get isTerminal => this == resolved || this == cancelled;
  bool get isOpen => !isTerminal;
}

enum ThreatCategory {
  assist('ASSIST'),
  deEscalatable('DE_ESCALATABLE'),
  hazard('HAZARD'),
  unknown('UNKNOWN'); 

  const ThreatCategory(this.wire);
  final String wire;

  static ThreatCategory fromWire(String value) => ThreatCategory.values
      .firstWhere((e) => e.wire == value,
          orElse: () => throw FormatException('Unknown ThreatCategory: $value'));
}

/// Mirrors `threat_level_enum`. Live scene-safety state.
enum ThreatLevel {
  activeThreat('ACTIVE_THREAT'),
  deEscalated('DE_ESCALATED'),
  clear('CLEAR');

  const ThreatLevel(this.value);
  final String value;

  static ThreatLevel fromString(String? raw) {
    if (raw == null) return ThreatLevel.activeThreat;
    final upper = raw.toUpperCase();
    for (final l in ThreatLevel.values) {
      if (l.value == upper) return l;
    }
    return ThreatLevel.activeThreat;
  }
}

enum ThreatType {
  gun('GUN'),
  blade('BLADE'),
  confrontation('CONFRONTATION'),
  collision('COLLISION'),
  personDown('PERSON_DOWN'),
  other('OTHER');

  const ThreatType(this.value);
  final String value;

  static ThreatType fromString(String? raw) {
    if (raw == null) return ThreatType.other;
    final upper = raw.toUpperCase();
    for (final t in ThreatType.values) {
      if (t.value == upper) return t;
    }
    return ThreatType.other;
  }

  bool get isWeapon => this == gun || this == blade;
}

enum IncidentSeverity {
  unknown('UNKNOWN'),
  minor('MINOR'),
  serious('SERIOUS'),
  critical('CRITICAL');

  const IncidentSeverity(this.value);
  final String value;

  static IncidentSeverity fromString(String? raw) {
    if (raw == null) return IncidentSeverity.unknown;
    final upper = raw.toUpperCase();
    for (final s in IncidentSeverity.values) {
      if (s.value == upper) return s;
    }
    return IncidentSeverity.unknown;
  }
}

enum TriggerSource {
  edgeAi('EDGE_AI'),
  manualSos('MANUAL_SOS'),
  centerManual('CENTER_MANUAL'),
  crashImu('CRASH_IMU');

  const TriggerSource(this.value);
  final String value;

  static TriggerSource fromString(String? raw) {
    if (raw == null) return TriggerSource.manualSos;
    final upper = raw.toUpperCase();
    for (final t in TriggerSource.values) {
      if (t.value == upper) return t;
    }
    return TriggerSource.manualSos;
  }
}

enum IncidentOutcome {
  confirmed('confirmed'),
  falsePositive('false_positive'),
  unresolved('unresolved');

  const IncidentOutcome(this.value);
  final String value;

  static IncidentOutcome fromString(String? raw) {
    if (raw == null) return IncidentOutcome.unresolved;
    final lower = raw.toLowerCase();
    for (final o in IncidentOutcome.values) {
      if (o.value == lower) return o;
    }
    return IncidentOutcome.unresolved;
  }
}

enum DriverBriefVisibility {
  minimal,
  full;

  static DriverBriefVisibility fromString(String? raw) =>
      raw == 'full' ? DriverBriefVisibility.full : DriverBriefVisibility.minimal;
}
enum TriggerSource {
  manualSos('MANUAL_SOS');

  const TriggerSource(this.wire);
  final String wire;
}

enum ThreatType {
  gun('GUN'),
  blade('BLADE'),
  confrontation('CONFRONTATION'),
  collision('COLLISION'),
  personDown('PERSON_DOWN'),
  other('OTHER');

  const ThreatType(this.wire);

  final String wire;
  static ThreatType fromWire(String value) {
    return ThreatType.values.firstWhere(
      (e) => e.wire == value,
      orElse: () => throw FormatException('Unknown ThreatType: $value'),
    );
  }
}

enum ThreatCategory {
  hazard('HAZARD'),
  assist('ASSIST'),
  deEscalatable('DE_ESCALATABLE');


  const ThreatCategory(this.wire);
  final String wire;
}

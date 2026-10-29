enum TriggerSource {
  manualSos('MANUAL_SOS');

  const TriggerSource(this.wire);
  final String wire;
}

enum ThreatType {
  confrontation('CONFRONTATION'); // TODO: add the rest / the right default

  const ThreatType(this.wire);
  final String wire;
}

enum ThreatCategory {
  hazard('HAZARD'); // TODO: add the rest / the right default

  const ThreatCategory(this.wire);
  final String wire;
}

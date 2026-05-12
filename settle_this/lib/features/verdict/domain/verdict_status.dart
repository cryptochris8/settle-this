enum VerdictStatus {
  completed('completed'),
  blocked('blocked'),
  needsSoftRedirect('needs_soft_redirect'),
  error('error');

  const VerdictStatus(this.wireValue);

  final String wireValue;

  static VerdictStatus fromWire(Object? value) {
    final s = value?.toString();
    return VerdictStatus.values.firstWhere(
      (v) => v.wireValue == s,
      orElse: () => VerdictStatus.error,
    );
  }
}

enum WhoWasMoreRight {
  sideA('side_a', 'Mostly you'),
  sideB('side_b', 'Mostly them'),
  both('both', 'Both had a point'),
  neither('neither', 'Neither, really'),
  unclear('unclear', 'Not enough evidence');

  const WhoWasMoreRight(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static WhoWasMoreRight fromWire(Object? value) {
    final s = value?.toString();
    return WhoWasMoreRight.values.firstWhere(
      (v) => v.wireValue == s,
      orElse: () => WhoWasMoreRight.unclear,
    );
  }
}

enum VerdictConfidence {
  low('low'),
  medium('medium'),
  high('high');

  const VerdictConfidence(this.wireValue);

  final String wireValue;

  static VerdictConfidence fromWire(Object? value) {
    final s = value?.toString();
    return VerdictConfidence.values.firstWhere(
      (v) => v.wireValue == s,
      orElse: () => VerdictConfidence.low,
    );
  }
}

enum SafetyRiskLevel {
  low('low'),
  medium('medium'),
  high('high');

  const SafetyRiskLevel(this.wireValue);

  final String wireValue;

  static SafetyRiskLevel fromWire(Object? value) {
    final s = value?.toString();
    return SafetyRiskLevel.values.firstWhere(
      (v) => v.wireValue == s,
      orElse: () => SafetyRiskLevel.low,
    );
  }
}

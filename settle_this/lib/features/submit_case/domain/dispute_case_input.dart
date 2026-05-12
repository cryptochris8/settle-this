import '../../../app/constants.dart';
import 'relationship_type.dart';
import 'tone_mode.dart';

class DisputeCaseInput {
  const DisputeCaseInput({
    this.scenario = '',
    this.sideA,
    this.sideB,
    this.relationshipType,
    this.tone = ToneMode.defaultTone,
    this.saveCase = true,
  });

  final String scenario;
  final String? sideA;
  final String? sideB;
  final RelationshipType? relationshipType;
  final ToneMode tone;
  final bool saveCase;

  bool get hasMinScenario => scenario.length >= AppConstants.minScenarioChars;
  bool get isScenarioWithinLimit =>
      scenario.length <= AppConstants.maxScenarioChars;
  bool get isScenarioValid => hasMinScenario && isScenarioWithinLimit;
  bool get hasRelationshipType => relationshipType != null;

  bool get isSideAWithinLimit =>
      (sideA?.length ?? 0) <= AppConstants.maxSideChars;
  bool get isSideBWithinLimit =>
      (sideB?.length ?? 0) <= AppConstants.maxSideChars;
  bool get areSidesValid => isSideAWithinLimit && isSideBWithinLimit;

  bool get canContinueFromSubmit =>
      isScenarioValid && hasRelationshipType && areSidesValid;

  bool get readyForVerdict => canContinueFromSubmit;

  DisputeCaseInput copyWith({
    String? scenario,
    String? Function()? sideA,
    String? Function()? sideB,
    RelationshipType? Function()? relationshipType,
    ToneMode? tone,
    bool? saveCase,
  }) {
    return DisputeCaseInput(
      scenario: scenario ?? this.scenario,
      sideA: sideA == null ? this.sideA : sideA(),
      sideB: sideB == null ? this.sideB : sideB(),
      relationshipType: relationshipType == null
          ? this.relationshipType
          : relationshipType(),
      tone: tone ?? this.tone,
      saveCase: saveCase ?? this.saveCase,
    );
  }

  Map<String, Object?> toCallablePayload() {
    return <String, Object?>{
      'scenario': scenario,
      'sideA': ?sideA,
      'sideB': ?sideB,
      'relationshipType': ?relationshipType?.wireValue,
      'tone': tone.wireValue,
      'saveCase': saveCase,
    };
  }
}

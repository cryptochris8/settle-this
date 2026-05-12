import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dispute_case_input.dart';
import '../domain/relationship_type.dart';
import '../domain/tone_mode.dart';

class SubmitCaseFormNotifier extends Notifier<DisputeCaseInput> {
  @override
  DisputeCaseInput build() => const DisputeCaseInput();

  void setScenario(String value) {
    state = state.copyWith(scenario: value);
  }

  void setSideA(String? value) {
    final cleaned = (value == null || value.trim().isEmpty) ? null : value;
    state = state.copyWith(sideA: () => cleaned);
  }

  void setSideB(String? value) {
    final cleaned = (value == null || value.trim().isEmpty) ? null : value;
    state = state.copyWith(sideB: () => cleaned);
  }

  void setRelationship(RelationshipType? type) {
    state = state.copyWith(relationshipType: () => type);
  }

  void setTone(ToneMode tone) {
    state = state.copyWith(tone: tone);
  }

  void setSaveCase(bool save) {
    state = state.copyWith(saveCase: save);
  }

  void reset() {
    state = const DisputeCaseInput();
  }
}

final submitCaseFormProvider =
    NotifierProvider<SubmitCaseFormNotifier, DisputeCaseInput>(
  SubmitCaseFormNotifier.new,
);

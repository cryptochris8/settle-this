import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settle_this/features/submit_case/application/submit_case_form.dart';
import 'package:settle_this/features/submit_case/domain/relationship_type.dart';
import 'package:settle_this/features/submit_case/domain/tone_mode.dart';

void main() {
  group('SubmitCaseFormNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('starts empty and not ready to submit', () {
      final form = container.read(submitCaseFormProvider);
      expect(form.scenario, isEmpty);
      expect(form.tone, ToneMode.balancedReferee);
      expect(form.saveCase, isTrue);
      expect(form.canContinueFromSubmit, isFalse);
    });

    test('requires scenario length and relationship to continue', () {
      final notifier = container.read(submitCaseFormProvider.notifier)
        ..setScenario('too short');
      expect(container.read(submitCaseFormProvider).canContinueFromSubmit,
          isFalse);

      notifier.setScenario('A' * 60);
      expect(container.read(submitCaseFormProvider).hasMinScenario, isTrue);
      expect(container.read(submitCaseFormProvider).canContinueFromSubmit,
          isFalse);

      notifier.setRelationship(RelationshipType.partner);
      expect(container.read(submitCaseFormProvider).canContinueFromSubmit,
          isTrue);
    });

    test('blank sides are stored as null', () {
      container.read(submitCaseFormProvider.notifier)
        ..setSideA('   ')
        ..setSideB('');
      expect(container.read(submitCaseFormProvider).sideA, isNull);
      expect(container.read(submitCaseFormProvider).sideB, isNull);
    });

    test('reset clears all fields', () {
      container.read(submitCaseFormProvider.notifier)
        ..setScenario('A' * 60)
        ..setRelationship(RelationshipType.coworker)
        ..setTone(ToneMode.courtroomJudge)
        ..setSaveCase(false)
        ..reset();

      final form = container.read(submitCaseFormProvider);
      expect(form.scenario, isEmpty);
      expect(form.relationshipType, isNull);
      expect(form.tone, ToneMode.balancedReferee);
      expect(form.saveCase, isTrue);
    });
  });
}

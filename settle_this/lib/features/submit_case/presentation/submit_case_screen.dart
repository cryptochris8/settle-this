import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/pii_detector.dart';
import '../../../shared/widgets/wizard_steps.dart';
import '../application/submit_case_form.dart';
import '../domain/relationship_type.dart';

class SubmitCaseScreen extends ConsumerStatefulWidget {
  const SubmitCaseScreen({super.key});

  @override
  ConsumerState<SubmitCaseScreen> createState() => _SubmitCaseScreenState();
}

class _SubmitCaseScreenState extends ConsumerState<SubmitCaseScreen> {
  late final TextEditingController _scenarioController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(submitCaseFormProvider);
    _scenarioController = TextEditingController(text: form.scenario);
  }

  @override
  void dispose() {
    _scenarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = ref.watch(submitCaseFormProvider);
    final findings = PiiDetector.findings(form.scenario);

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Something')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WizardSteps(
                currentStep: 1,
                totalSteps: 4,
                label: 'Tell us what happened',
              ),
              const SizedBox(height: 18),
              Text(
                'Keep it clear, honest, and low-stakes. Avoid full names, '
                'addresses, workplaces, or private identifying details.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
              _ScenarioField(
                controller: _scenarioController,
                onChanged: ref.read(submitCaseFormProvider.notifier).setScenario,
              ),
              const SizedBox(height: 8),
              _ScenarioHelper(
                length: form.scenario.length,
                hasMinimum: form.hasMinScenario,
                withinLimit: form.isScenarioWithinLimit,
              ),
              if (findings.any) ...[
                const SizedBox(height: 12),
                _PiiWarning(findings: findings),
              ],
              const SizedBox(height: 24),
              Text(
                'Who is this with?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _RelationshipPicker(
                selected: form.relationshipType,
                onChanged: ref
                    .read(submitCaseFormProvider.notifier)
                    .setRelationship,
              ),
              const SizedBox(height: 24),
              SwitchListTile.adaptive(
                value: form.saveCase,
                onChanged: ref.read(submitCaseFormProvider.notifier).setSaveCase,
                contentPadding: EdgeInsets.zero,
                title: const Text('Save this verdict to my history'),
                subtitle: const Text(
                  'Off keeps things ephemeral. On lets you revisit later.',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: form.canContinueFromSubmit
                    ? () => context.push(AppRoutes.submitSides)
                    : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenarioField extends StatelessWidget {
  const _ScenarioField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: 8,
      minLines: 5,
      maxLength: AppConstants.maxScenarioChars,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        hintText:
            'Example: My partner says I loaded the dishwasher wrong, but I think cups can absolutely go wherever they fit...',
        counterText: '',
      ),
    );
  }
}

class _ScenarioHelper extends StatelessWidget {
  const _ScenarioHelper({
    required this.length,
    required this.hasMinimum,
    required this.withinLimit,
  });

  final int length;
  final bool hasMinimum;
  final bool withinLimit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = !withinLimit
        ? SettleThisColors.blocked
        : !hasMinimum
            ? SettleThisColors.inkSoft
            : SettleThisColors.success;
    final message = !hasMinimum
        ? 'A few more details help — at least ${AppConstants.minScenarioChars} characters.'
        : !withinLimit
            ? 'A bit too long — keep it under ${AppConstants.maxScenarioChars} characters.'
            : 'Looks good.';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
        Text(
          '$length / ${AppConstants.maxScenarioChars}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: SettleThisColors.inkSoft,
          ),
        ),
      ],
    );
  }
}

class _PiiWarning extends StatelessWidget {
  const _PiiWarning({required this.findings});

  final PiiFindings findings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SettleThisColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: SettleThisColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Looks like ${findings.labels.join(', ')} may be in your text. '
              'Consider removing identifying details before submitting.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: SettleThisColors.navyDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipPicker extends StatelessWidget {
  const _RelationshipPicker({required this.selected, required this.onChanged});

  final RelationshipType? selected;
  final ValueChanged<RelationshipType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RelationshipType.values.map((type) {
        final isSelected = selected == type;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (s) => onChanged(s ? type : null),
        );
      }).toList(),
    );
  }
}

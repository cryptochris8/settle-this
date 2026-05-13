import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/wizard_steps.dart';
import '../application/submit_case_form.dart';

class SideInputScreen extends ConsumerStatefulWidget {
  const SideInputScreen({super.key});

  @override
  ConsumerState<SideInputScreen> createState() => _SideInputScreenState();
}

class _SideInputScreenState extends ConsumerState<SideInputScreen> {
  late final TextEditingController _sideAController;
  late final TextEditingController _sideBController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(submitCaseFormProvider);
    _sideAController = TextEditingController(text: form.sideA ?? '');
    _sideBController = TextEditingController(text: form.sideB ?? '');
  }

  @override
  void dispose() {
    _sideAController.dispose();
    _sideBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = ref.watch(submitCaseFormProvider);
    final notifier = ref.read(submitCaseFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Something')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WizardSteps(
                currentStep: 2,
                totalSteps: 4,
                label: 'Both sides',
              ),
              const SizedBox(height: 18),
              Text(
                'Optional. If each side has a slightly different version, '
                'capture both — the referee weighs them separately.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'My side',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _SideField(
                controller: _sideAController,
                onChanged: notifier.setSideA,
                hint: 'How you remember it.',
              ),
              const SizedBox(height: 24),
              Text(
                'Their side',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _SideField(
                controller: _sideBController,
                onChanged: notifier.setSideB,
                hint: 'How they remember it.',
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: form.areSidesValid
                    ? () => context.push(AppRoutes.submitTone)
                    : null,
                child: const Text('Continue'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push(AppRoutes.submitTone),
                child: const Text('Skip — just use the scenario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideField extends StatelessWidget {
  const _SideField({
    required this.controller,
    required this.onChanged,
    required this.hint,
  });

  final TextEditingController controller;
  final ValueChanged<String?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: 3,
      maxLines: 6,
      maxLength: AppConstants.maxSideChars,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: hint),
    );
  }
}

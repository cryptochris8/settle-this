import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/wizard_steps.dart';
import '../application/submit_case_form.dart';
import '../domain/tone_mode.dart';

const Map<ToneMode, IconData> _toneIcons = {
  ToneMode.balancedReferee: Icons.balance,
  ToneMode.playfulRoast: Icons.local_fire_department_outlined,
  ToneMode.courtroomJudge: Icons.gavel,
};

class ToneSelectorScreen extends ConsumerWidget {
  const ToneSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final form = ref.watch(submitCaseFormProvider);
    final notifier = ref.read(submitCaseFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settle Something')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WizardSteps(
                currentStep: 3,
                totalSteps: 4,
                label: 'Choose the vibe',
              ),
              const SizedBox(height: 12),
              Text(
                'Pick how the referee should rule.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: ToneMode.values.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final tone = ToneMode.values[i];
                    return _ToneCard(
                      tone: tone,
                      icon: _toneIcons[tone]!,
                      selected: form.tone == tone,
                      onTap: () => notifier.setTone(tone),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push(AppRoutes.submitReview),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToneCard extends StatelessWidget {
  const _ToneCard({
    required this.tone,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final ToneMode tone;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? SettleThisColors.cream
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? SettleThisColors.gavelGold
                  : SettleThisColors.creamDeep,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? SettleThisColors.gavelGold
                      : SettleThisColors.creamDeep,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tone.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tone.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SettleThisColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: SettleThisColors.success,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

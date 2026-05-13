import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Wizard progress indicator used at the top of the submit-case flow.
///
/// Renders "STEP N OF M" caption + a gold progress bar + the current step's
/// label. Drop at the top of each step screen body so the user always knows
/// where they are without staring at the URL.
class WizardSteps extends StatelessWidget {
  const WizardSteps({
    required this.currentStep,
    required this.totalSteps,
    required this.label,
    super.key,
  });

  /// 1-indexed.
  final int currentStep;
  final int totalSteps;
  final String label;

  double get _progress => currentStep / totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Step $currentStep of $totalSteps: $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STEP $currentStep OF $totalSteps',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: SettleThisColors.inkSoft,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: SettleThisColors.creamDeep,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      SettleThisColors.gavelGold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: SettleThisColors.navyDeep,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/verdict/domain/verdict_status.dart';

class VerdictBadge extends StatelessWidget {
  const VerdictBadge({required this.who, super.key});

  final WhoWasMoreRight who;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (who) {
      WhoWasMoreRight.sideA => SettleThisColors.success,
      WhoWasMoreRight.sideB => SettleThisColors.coral,
      WhoWasMoreRight.both => SettleThisColors.gavelGold,
      WhoWasMoreRight.neither => SettleThisColors.inkSoft,
      WhoWasMoreRight.unclear => SettleThisColors.inkSoft,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        'Verdict: ${who.label}',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: color == SettleThisColors.gavelGold
              ? SettleThisColors.navyDeep
              : color,
        ),
      ),
    );
  }
}

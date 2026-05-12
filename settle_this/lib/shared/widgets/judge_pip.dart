import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Stand-in mascot for Judge Pip until the real illustration ships.
///
/// Renders a circular badge with a "scales of justice" glyph. The silhouette
/// is identical to the planned commissioned art so swapping to
/// `Image.asset('assets/pip_triumph.png')` is a one-line change inside this
/// widget — every call site stays untouched.
///
/// Two visual modes:
/// - **default** (filled navy, gold glyph) — Pip Triumphant. Use for verdict
///   hero, share card, home screen host.
/// - **quiet** (cream fill, navy glyph) — Pip Listening. Use for
///   soft-redirect, blocked, error states, anywhere the energy should drop.
class JudgePip extends StatelessWidget {
  const JudgePip({
    this.size = 56,
    this.quiet = false,
    super.key,
  });

  final double size;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'The tiny judge',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: quiet ? SettleThisColors.cream : SettleThisColors.navy,
          shape: BoxShape.circle,
          border: Border.all(
            color: SettleThisColors.gavelGold,
            width: size > 80 ? 3 : 2,
          ),
          boxShadow: quiet
              ? null
              : [
                  BoxShadow(
                    color: SettleThisColors.gavelGold.withValues(alpha: 0.18),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          '⚖',
          style: TextStyle(
            fontSize: size * 0.5,
            color: quiet
                ? SettleThisColors.navyDeep
                : SettleThisColors.gavelGold,
          ),
        ),
      ),
    );
  }
}

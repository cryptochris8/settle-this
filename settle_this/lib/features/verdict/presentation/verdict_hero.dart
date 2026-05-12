import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/verdict_badge.dart';
import '../domain/verdict_status.dart';

/// Hero block at the top of the verdict result screen.
///
/// Renders a faux-docket header strip, the verdict badge + title, and a
/// circular "tiny judge" mascot stub that slides in from the right on first
/// build. The stub is a gold scales-of-justice glyph on a navy circle —
/// designed to be swapped for a `Image.asset` of the real Judge Pip art in
/// one place once the illustration ships.
///
/// On soft-redirect the badge is suppressed and the mascot uses a quieter
/// treatment (filled cream circle, scale icon at lower opacity) — same
/// silhouette, calmer energy.
class VerdictHero extends StatefulWidget {
  const VerdictHero({
    required this.title,
    required this.who,
    required this.isSoftRedirect,
    super.key,
  });

  final String title;
  final WhoWasMoreRight who;
  final bool isSoftRedirect;

  @override
  State<VerdictHero> createState() => _VerdictHeroState();
}

class _VerdictHeroState extends State<VerdictHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduce = MediaQuery.disableAnimationsOf(context);
      if (reduce) {
        _ctrl.value = 1.0;
      } else {
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DocketHeaderStrip(isSoftRedirect: widget.isSoftRedirect),
        const SizedBox(height: 18),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 72),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isSoftRedirect) ...[
                    VerdictBadge(who: widget.who),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    widget.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: SettleThisColors.navyDeep,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -8,
              right: 0,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  final slide = (1 - _ctrl.value) * 48;
                  return Transform.translate(
                    offset: Offset(slide, 0),
                    child: Opacity(opacity: _ctrl.value, child: child),
                  );
                },
                child: _PipStub(quiet: widget.isSoftRedirect),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocketHeaderStrip extends StatelessWidget {
  const _DocketHeaderStrip({required this.isSoftRedirect});

  final bool isSoftRedirect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isSoftRedirect ? 'A SERIOUS MOMENT' : 'CASE FILED · TODAY';
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: SettleThisColors.creamDeep,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: SettleThisColors.inkSoft,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: SettleThisColors.creamDeep,
          ),
        ),
      ],
    );
  }
}

/// Stand-in for Judge Pip until the real illustration ships. Same circular
/// silhouette so the swap is a one-line change — replace this widget's body
/// with `Image.asset('assets/pip_triumph.png', width: 56, height: 56)` (and
/// `pip_listening.png` when `quiet` is true).
class _PipStub extends StatelessWidget {
  const _PipStub({required this.quiet});

  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'The tiny judge',
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: quiet ? SettleThisColors.cream : SettleThisColors.navy,
          shape: BoxShape.circle,
          border: Border.all(
            color: SettleThisColors.gavelGold,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '⚖', // ⚖ scales of justice — placeholder until Pip art lands
          style: TextStyle(
            fontSize: 28,
            color: quiet
                ? SettleThisColors.navyDeep
                : SettleThisColors.gavelGold,
          ),
        ),
      ),
    );
  }
}

/// 3-dot gold divider used between section pairs on the verdict screen to
/// give the scroll a subtle "court docket" beat. Decorative only.
class DocketDivider extends StatelessWidget {
  const DocketDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            3,
            (i) => Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: SettleThisColors.gavelGold.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../domain/verdict.dart';

/// Tone variants for [VerdictSection]. Drives the surface tint, leading
/// "docket-tab" color, and icon accent.
enum VerdictSectionTone { neutral, gotRight, missed, fix }

class VerdictSection extends StatelessWidget {
  const VerdictSection({
    required this.title,
    required this.body,
    this.icon,
    this.tone = VerdictSectionTone.neutral,
    super.key,
  });

  final String title;
  final String body;
  final IconData? icon;
  final VerdictSectionTone tone;

  ({Color surface, Color accent}) _palette() {
    switch (tone) {
      case VerdictSectionTone.gotRight:
        return (
          surface: SettleThisColors.surfaceGotRight,
          accent: SettleThisColors.accentGotRight,
        );
      case VerdictSectionTone.missed:
        return (
          surface: SettleThisColors.surfaceMissed,
          accent: SettleThisColors.accentMissed,
        );
      case VerdictSectionTone.fix:
        return (
          surface: SettleThisColors.surfaceFix,
          accent: SettleThisColors.accentFix,
        );
      case VerdictSectionTone.neutral:
        return (
          surface: Colors.white,
          accent: SettleThisColors.navy,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final pal = _palette();
    final isTinted = tone != VerdictSectionTone.neutral;

    return Semantics(
      container: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pal.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isTinted
                ? pal.accent.withValues(alpha: 0.18)
                : SettleThisColors.creamDeep,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Docket-tab — 4px colored leading bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: pal.accent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 18, color: pal.accent),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              title.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: SettleThisColors.inkSoft,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: SettleThisColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cream chat-bubble card containing the AI-drafted line the user can paste
/// into iMessage / WhatsApp / wherever. Bottom-left corner is squared off so
/// the silhouette reads instantly as "sent message."
class VerdictTextToSendCard extends StatelessWidget {
  const VerdictTextToSendCard({
    required this.text,
    required this.onCopy,
    super.key,
  });

  final String text;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Semantics(
      label: 'Text you can send',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SettleThisColors.cream,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(
            color: SettleThisColors.gavelGold,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: SettleThisColors.navy,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TEXT YOU CAN SEND',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: SettleThisColors.inkSoft,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ExcludeSemantics(
                child: Text(
                  '“',
                  style: TextStyle(
                    fontSize: 36,
                    height: 0.6,
                    color: SettleThisColors.gavelGold.withValues(alpha: 0.25),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onCopy();
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Copy & send'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark-navy "stage with spotlight" punchline card. Subtle radial gold
/// gradient + filigree top border + two pulsing sparkles. Sparkle motion is
/// suppressed when `MediaQuery.disableAnimationsOf` returns true.
class FunnyRulingCard extends StatefulWidget {
  const FunnyRulingCard({required this.ruling, super.key});

  final String ruling;

  @override
  State<FunnyRulingCard> createState() => _FunnyRulingCardState();
}

class _FunnyRulingCardState extends State<FunnyRulingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (!reduce && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (reduce) {
      _ctrl.stop();
      _ctrl.value = 0.5;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ruling.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Semantics(
      label: 'Final funny ruling',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SettleThisColors.navy,
          borderRadius: BorderRadius.circular(20),
          gradient: const RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.1,
            colors: [
              Color(0x33E8B43C),
              SettleThisColors.navy,
            ],
            stops: [0.0, 0.7],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 80,
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SettleThisColors.gavelGold.withValues(alpha: 0),
                        SettleThisColors.gavelGold,
                        SettleThisColors.gavelGold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 16,
              child: _Sparkle(animation: _ctrl),
            ),
            Positioned(
              bottom: 14,
              right: 16,
              child: _Sparkle(animation: _ctrl, delayed: true),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE GAVEL DROPS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: SettleThisColors.gavelGold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.ruling,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: SettleThisColors.cream,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.animation, this.delayed = false});

  final Animation<double> animation;
  final bool delayed;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = delayed ? (animation.value + 0.5) % 1.0 : animation.value;
          final scale = 0.95 + (t * 0.1);
          return Transform.scale(scale: scale, child: child);
        },
        child: Icon(
          Icons.auto_awesome,
          size: 14,
          color: SettleThisColors.gavelGold.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class VerdictSafetyNoteCard extends StatelessWidget {
  const VerdictSafetyNoteCard({required this.note, super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SettleThisColors.warmSand,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SettleThisColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: SettleThisColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SettleThisColors.navyDeep,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerdictPreviewCard extends StatelessWidget {
  const VerdictPreviewCard({
    required this.title,
    required this.summary,
    required this.who,
    required this.onTap,
    super.key,
  });

  final String title;
  final String summary;
  final String who;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verdict: $who',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: SettleThisColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension VerdictBodyText on Verdict {
  bool get hasFunnyRuling => funnyFinalRuling.trim().isNotEmpty;
  bool get hasTextToSend => textToSend.trim().isNotEmpty;
}

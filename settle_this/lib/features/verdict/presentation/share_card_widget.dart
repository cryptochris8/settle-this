import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/judge_pip.dart';
import '../domain/verdict.dart';

/// Visual share card. Captured to PNG via RepaintBoundary, so layout is
/// fixed-width (1080×1350) and self-contained — no theme inheritance, every
/// style is declared inline.
class ShareCardWidget extends StatelessWidget {
  const ShareCardWidget({
    required this.shareCard,
    required this.domain,
    super.key,
  });

  final ShareCardData shareCard;
  final String domain;

  static const double cardWidth = 1080;
  static const double cardHeight = 1350;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Material(
        color: SettleThisColors.cream,
        child: Padding(
          padding: const EdgeInsets.all(72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardHeader(),
              const SizedBox(height: 56),
              // Decorative quote glyph above the headline — matches the
              // in-app text-to-send card so the brand language is consistent
              // across surfaces.
              const Text(
                '“',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 96,
                  height: 0.6,
                  color: Color(0x55E8B43C), // gold @ 33%
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shareCard.headline,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 92,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                shareCard.verdictOneLiner,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 44,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: SettleThisColors.ink,
                ),
              ),
              const Spacer(),
              _RulingPanel(text: shareCard.shortRuling),
              const SizedBox(height: 32),
              _CardFooter(domain: domain),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const JudgePip(size: 120),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Settle This',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: SettleThisColors.navyDeep,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'CASE FILED · TODAY',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: SettleThisColors.inkSoft,
                letterSpacing: 2,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The dark-navy "RULING" panel — matches the in-app FunnyRulingCard's
/// "stage with spotlight" treatment so social posts and the app feel like
/// the same brand. No sparkle animation here — share card renders to a
/// static PNG.
class _RulingPanel extends StatelessWidget {
  const _RulingPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SettleThisColors.navy,
        borderRadius: BorderRadius.circular(28),
        gradient: const RadialGradient(
          center: Alignment(0, -0.6),
          radius: 1.0,
          colors: [
            Color(0x44E8B43C), // gold @ 27% center
            SettleThisColors.navy,
          ],
          stops: [0.0, 0.7],
        ),
      ),
      child: Stack(
        children: [
          // Filigree top divider
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 140,
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x00E8B43C),
                      SettleThisColors.gavelGold,
                      Color(0x00E8B43C),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Decorative sparkles in opposite corners
          const Positioned(
            top: 28,
            left: 28,
            child: Icon(
              Icons.auto_awesome,
              size: 28,
              color: Color(0xAAE8B43C),
            ),
          ),
          const Positioned(
            bottom: 28,
            right: 28,
            child: Icon(
              Icons.auto_awesome,
              size: 28,
              color: Color(0xAAE8B43C),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 56, 36, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THE GAVEL DROPS',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w800,
                    color: SettleThisColors.gavelGold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 40,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: SettleThisColors.cream,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.domain});

  final String domain;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generated by Settle This',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: SettleThisColors.inkSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              domain,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: SettleThisColors.navy.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: SettleThisColors.coral.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: SettleThisColors.coral),
          ),
          child: const Text(
            'AI-generated verdict',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SettleThisColors.coral,
            ),
          ),
        ),
      ],
    );
  }
}

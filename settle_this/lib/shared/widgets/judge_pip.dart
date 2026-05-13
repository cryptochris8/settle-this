import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Mascot widget for Judge Pip — the "tiny judge" character that hosts the
/// app's verdict, home, error, and share-card surfaces.
///
/// **Asset swap**: until the commissioned art ships, this renders a circular
/// navy/cream badge with a scales-of-justice glyph as a stand-in. When the
/// real Pip PNGs land:
///
/// 1. Drop `pip_triumph.png` (+ @2x, @3x) and `pip_listening.png` (+ @2x, @3x)
///    into `settle_this/assets/pip/`.
/// 2. Add `- assets/pip/pip_triumph.png` and `- assets/pip/pip_listening.png`
///    to the `flutter/assets:` block of `pubspec.yaml`.
/// 3. Flip [kArtReady] below to `true`.
///
/// The full brief for whoever commissions the art lives in
/// `settle_this/assets/pip/COMMISSION_BRIEF.md`.
///
/// Two visual modes:
/// - **default** (filled navy, gold glyph) — Pip Triumphant. Verdict hero,
///   home screen host, share card.
/// - **quiet** (cream fill, navy glyph) — Pip Listening. Soft-redirect,
///   blocked, errors — anywhere the energy should drop.
class JudgePip extends StatelessWidget {
  const JudgePip({
    this.size = 56,
    this.quiet = false,
    super.key,
  });

  final double size;
  final bool quiet;

  /// Set to `true` after dropping commissioned art into `assets/pip/` and
  /// declaring the files in `pubspec.yaml`. Until then the stub renders.
  static const bool kArtReady = false;

  String get _assetPath => quiet
      ? 'assets/pip/pip_listening.png'
      : 'assets/pip/pip_triumph.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'The tiny judge',
      child: kArtReady ? _buildAsset() : _buildStub(),
    );
  }

  Widget _buildAsset() {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => _buildStub(),
    );
  }

  Widget _buildStub() {
    return Container(
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
    );
  }
}

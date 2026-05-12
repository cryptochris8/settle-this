import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../domain/verdict.dart';

class VerdictSection extends StatelessWidget {
  const VerdictSection({
    required this.title,
    required this.body,
    this.icon,
    super.key,
  });

  final String title;
  final String body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: SettleThisColors.navy),
                  const SizedBox(width: 8),
                ],
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SettleThisColors.inkSoft,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return Card(
      color: SettleThisColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SettleThisColors.gavelGold, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.send, size: 18, color: SettleThisColors.navy),
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
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FunnyRulingCard extends StatelessWidget {
  const FunnyRulingCard({required this.ruling, super.key});

  final String ruling;

  @override
  Widget build(BuildContext context) {
    if (ruling.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SettleThisColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINAL FUNNY RULING',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: SettleThisColors.gavelGold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ruling,
            style: theme.textTheme.titleMedium?.copyWith(
              color: SettleThisColors.cream,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
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
        color: const Color(0xFFFFF6E0),
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

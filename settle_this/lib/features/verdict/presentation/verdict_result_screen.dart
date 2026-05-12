import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/verdict_badge.dart';
import '../../history/data/history_repository.dart';
import '../domain/dispute_case.dart';
import '../domain/verdict.dart';
import '../domain/verdict_status.dart';
import 'verdict_card_widget.dart';

class VerdictResultScreen extends ConsumerWidget {
  const VerdictResultScreen({required this.caseId, super.key});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseAsync = ref.watch(caseStreamProvider(caseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verdict'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Home',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: caseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (dispute) {
          if (dispute == null) {
            return const _ErrorState(
              message: 'We couldn’t find that case. It may have been deleted.',
            );
          }
          return _VerdictBody(dispute: dispute);
        },
      ),
    );
  }
}

class _VerdictBody extends ConsumerWidget {
  const _VerdictBody({required this.dispute});

  final DisputeCase dispute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verdict = dispute.verdict;
    if (verdict == null) {
      return const _ErrorState(
        message: 'No verdict on this case yet.',
        showHomeButton: true,
      );
    }
    if (dispute.status == VerdictStatus.blocked) {
      return _BlockedBody(verdict: verdict);
    }
    final isSoftRedirect = dispute.status == VerdictStatus.needsSoftRedirect;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isSoftRedirect) VerdictBadge(who: verdict.whoWasMoreRight),
          if (!isSoftRedirect) const SizedBox(height: 16),
          Text(
            verdict.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            verdict.summaryVerdict,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          if (verdict.safetyNote != null && verdict.safetyNote!.isNotEmpty)
            VerdictSafetyNoteCard(note: verdict.safetyNote!),
          const SizedBox(height: 16),
          if (!isSoftRedirect) ...[
            VerdictSection(
              title: 'What you got right',
              body: verdict.sideAGotRight,
              icon: Icons.thumb_up_outlined,
              tone: VerdictSectionTone.gotRight,
            ),
            const SizedBox(height: 8),
            VerdictSection(
              title: 'What they got right',
              body: verdict.sideBGotRight,
              icon: Icons.handshake_outlined,
              tone: VerdictSectionTone.gotRight,
            ),
            const SizedBox(height: 8),
          ],
          VerdictSection(
            title: 'What was missed',
            body: verdict.whatWasMissed,
            icon: Icons.search_off,
            tone: VerdictSectionTone.missed,
          ),
          const SizedBox(height: 8),
          VerdictSection(
            title: 'The practical fix',
            body: verdict.practicalFix,
            icon: Icons.handyman_outlined,
            tone: VerdictSectionTone.fix,
          ),
          const SizedBox(height: 16),
          if (verdict.hasFunnyRuling) ...[
            FunnyRulingCard(ruling: verdict.funnyFinalRuling),
            const SizedBox(height: 16),
          ],
          VerdictTextToSendCard(
            text: verdict.textToSend,
            onCopy: () => _copyToClipboard(context, verdict.textToSend),
          ),
          const SizedBox(height: 24),
          _ActionRow(dispute: dispute),
          const SizedBox(height: 24),
          _FeedbackBlock(caseId: dispute.caseId),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied — paste it where you need it.')),
    );
  }
}

class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.dispute});

  final DisputeCase dispute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (dispute.canShare)
          FilledButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Share Verdict'),
            onPressed: () =>
                context.push('/verdict/${dispute.caseId}/share-card'),
          ),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Settle Another'),
          onPressed: () => context.go(AppRoutes.submit),
        ),
      ],
    );
  }
}

class _FeedbackBlock extends ConsumerStatefulWidget {
  const _FeedbackBlock({required this.caseId});

  final String caseId;

  @override
  ConsumerState<_FeedbackBlock> createState() => _FeedbackBlockState();
}

class _FeedbackBlockState extends ConsumerState<_FeedbackBlock> {
  static const Map<String, String> _tags = {
    'helpful': 'Helpful',
    'funny': 'Funny',
    'fair': 'Fair',
    'too_harsh': 'Too harsh',
    'not_helpful': 'Not helpful',
    'unsafe': 'Report unsafe',
  };
  final Set<String> _selected = {};
  bool _submitted = false;

  Future<void> _submit(bool helpful) async {
    if (_submitted) return;
    setState(() => _submitted = true);
    try {
      await ref.read(historyRepositoryProvider).submitFeedback(
            caseId: widget.caseId,
            helpful: helpful,
            tags: _selected.toList(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for the feedback.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitted = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save feedback: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How did this verdict land?',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.entries.map((entry) {
                final selected = _selected.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: _submitted
                      ? null
                      : (s) {
                          setState(() {
                            if (s) {
                              _selected.add(entry.key);
                            } else {
                              _selected.remove(entry.key);
                            }
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.thumb_down_outlined),
                    label: const Text('Not great'),
                    onPressed: _submitted ? null : () => _submit(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Helpful'),
                    onPressed: _submitted ? null : () => _submit(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedBody extends StatelessWidget {
  const _BlockedBody({required this.verdict});

  final Verdict verdict;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 72,
            color: SettleThisColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            verdict.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: SettleThisColors.navyDeep,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            verdict.summaryVerdict,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: SettleThisColors.inkSoft,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (verdict.safetyNote != null)
            VerdictSafetyNoteCard(note: verdict.safetyNote!),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    this.showHomeButton = true,
  });

  final String message;
  final bool showHomeButton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: SettleThisColors.warning,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (showHomeButton) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Back to home'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

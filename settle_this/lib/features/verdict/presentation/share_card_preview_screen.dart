import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/services/share_service.dart';
import '../../history/data/history_repository.dart';
import '../domain/dispute_case.dart';
import 'share_card_widget.dart';

class ShareCardPreviewScreen extends ConsumerStatefulWidget {
  const ShareCardPreviewScreen({required this.caseId, super.key});

  final String caseId;

  @override
  ConsumerState<ShareCardPreviewScreen> createState() =>
      _ShareCardPreviewScreenState();
}

class _ShareCardPreviewScreenState
    extends ConsumerState<ShareCardPreviewScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  final ShareService _shareService = ShareService();
  bool _busy = false;

  Future<void> _share(DisputeCase dispute) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final verdict = dispute.verdict!;
      final card = verdict.shareCard!;
      final text =
          '${card.headline}\n${card.verdictOneLiner}\n— Settle This';
      await _shareService.shareCardImage(
        boundaryKey: _boundaryKey,
        text: text,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseAsync = ref.watch(caseStreamProvider(widget.caseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Share verdict')),
      body: caseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (dispute) {
          if (dispute == null) {
            return const Center(child: Text('Case not found.'));
          }
          if (!dispute.canShare) {
            return _UnshareableState(onBack: () => context.go(AppRoutes.home));
          }
          return _PreviewBody(
            dispute: dispute,
            boundaryKey: _boundaryKey,
            busy: _busy,
            onShare: () => _share(dispute),
          );
        },
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({
    required this.dispute,
    required this.boundaryKey,
    required this.busy,
    required this.onShare,
  });

  final DisputeCase dispute;
  final GlobalKey boundaryKey;
  final bool busy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final shareCard = dispute.verdict!.shareCard!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: ShareCardWidget.cardWidth / ShareCardWidget.cardHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FittedBox(
                fit: BoxFit.cover,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: ShareCardWidget(shareCard: shareCard),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            label: const Text('Share'),
            onPressed: busy ? null : onShare,
          ),
        ],
      ),
    );
  }
}

class _UnshareableState extends StatelessWidget {
  const _UnshareableState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 64,
            color: SettleThisColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            'This verdict is not sharable.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share cards are disabled for redirected, blocked, or PII-flagged verdicts.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SettleThisColors.inkSoft,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onBack, child: const Text('Back')),
        ],
      ),
    );
  }
}

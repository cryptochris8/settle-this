import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../verdict/domain/dispute_case.dart';
import '../../verdict/domain/verdict_status.dart';
import '../data/history_repository.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Past verdicts')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load history: $e',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SettleThisColors.inkSoft,
                  ),
            ),
          ),
        ),
        data: (cases) =>
            cases.isEmpty ? const _EmptyHistory() : _HistoryList(cases: cases),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.gavel,
              size: 56,
              color: SettleThisColors.gavelGold,
            ),
            const SizedBox(height: 16),
            Text(
              'No verdicts yet.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your first tiny courtroom awaits.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: SettleThisColors.inkSoft,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.submit),
              icon: const Icon(Icons.gavel),
              label: const Text('Settle Something'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.cases});

  final List<DisputeCase> cases;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemBuilder: (context, i) => _HistoryTile(dispute: cases[i]),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemCount: cases.length,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.dispute});

  final DisputeCase dispute;

  static String _statusBadge(VerdictStatus status) {
    return switch (status) {
      VerdictStatus.completed => 'Verdict',
      VerdictStatus.needsSoftRedirect => 'Serious response',
      VerdictStatus.blocked => 'Blocked',
      VerdictStatus.error => 'Error',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final created = dispute.createdAt;
    final dateLabel = created == null
        ? '—'
        : DateFormat.yMMMd().add_jm().format(created);
    return Card(
      child: InkWell(
        onTap: () => context.push('/history/${dispute.caseId}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SettleThisColors.creamDeep,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _statusBadge(dispute.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: SettleThisColors.navyDeep,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SettleThisColors.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dispute.verdict?.title ?? '—',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (dispute.verdict != null) ...[
                const SizedBox(height: 4),
                Text(
                  dispute.verdict!.summaryVerdict,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SettleThisColors.inkSoft,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

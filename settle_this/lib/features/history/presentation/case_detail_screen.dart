import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../verdict/presentation/verdict_result_screen.dart';
import '../data/history_repository.dart';

class CaseDetailScreen extends ConsumerWidget {
  const CaseDetailScreen({required this.caseId, super.key});

  final String caseId;

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete this verdict?'),
            content: const Text(
              'Soft-deleted verdicts are removed from your history. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            color: SettleThisColors.blocked,
            onPressed: () async {
              final confirmed = await _confirmDelete(context);
              if (!confirmed) return;
              if (!context.mounted) return;
              await ref.read(historyRepositoryProvider).deleteCase(caseId);
              if (!context.mounted) return;
              context.go(AppRoutes.history);
            },
          ),
        ],
      ),
      body: VerdictResultScreen(caseId: caseId),
    );
  }
}

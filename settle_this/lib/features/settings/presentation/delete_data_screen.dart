import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../history/data/history_repository.dart';

class DeleteDataScreen extends ConsumerStatefulWidget {
  const DeleteDataScreen({super.key});

  @override
  ConsumerState<DeleteDataScreen> createState() => _DeleteDataScreenState();
}

class _DeleteDataScreenState extends ConsumerState<DeleteDataScreen> {
  bool _busy = false;

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteAllCases() async {
    final ok = await _confirm(
      title: 'Delete all saved verdicts?',
      body:
          'This soft-deletes every verdict in your history. The app will not show them again.',
      confirmLabel: 'Delete all',
    );
    if (!ok) return;
    setState(() => _busy = true);

    final cases = await ref.read(historyStreamProvider.future);
    final repo = ref.read(historyRepositoryProvider);
    for (final c in cases) {
      await repo.deleteCase(c.caseId);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved verdicts deleted.')),
    );
  }

  Future<void> _deleteAccount() async {
    final ok = await _confirm(
      title: 'Delete your account?',
      body:
          'Cases, settings, and feedback are removed. This cannot be undone.',
      confirmLabel: 'Delete account',
    );
    if (!ok) return;
    setState(() => _busy = true);

    String? error;
    try {
      if (Firebase.apps.isEmpty) {
        throw Exception(
          'Backend is not configured yet — finish flutterfire configure first.',
        );
      }
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      await functions
          .httpsCallable('deleteAccount')
          .call<Map<Object?, Object?>>(<String, Object?>{});
      await ref.read(authRepositoryProvider).signOut();
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete account: $error')),
      );
      return;
    }
    context.go(AppRoutes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Delete data')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'You are in control of your data.',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete saved verdicts',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Removes every saved verdict from your history.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SettleThisColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _busy ? null : _deleteAllCases,
                        child: const Text('Delete saved verdicts'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: const Color(0xFFFFF6F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: SettleThisColors.coral),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete your account',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: SettleThisColors.coral,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Deletes your profile, all cases, usage counters, and Firebase auth account. This is irreversible.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SettleThisColors.navyDeep,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SettleThisColors.coral,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _busy ? null : _deleteAccount,
                        child: const Text('Delete account'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_busy) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

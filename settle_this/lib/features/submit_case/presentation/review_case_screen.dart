import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../application/submit_case_form.dart';

class ReviewCaseScreen extends ConsumerWidget {
  const ReviewCaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final form = ref.watch(submitCaseFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'One last look before the gavel comes down.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
              _ReviewSection(
                title: 'Scenario',
                onEdit: () => context.go(AppRoutes.submit),
                child: Text(form.scenario),
              ),
              const SizedBox(height: 12),
              _ReviewSection(
                title: 'Relationship',
                onEdit: () => context.go(AppRoutes.submit),
                child: Text(form.relationshipType?.label ?? '—'),
              ),
              if (form.sideA != null || form.sideB != null) ...[
                const SizedBox(height: 12),
                _ReviewSection(
                  title: 'Both sides',
                  onEdit: () => context.go(AppRoutes.submitSides),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (form.sideA != null)
                        _LabeledLine(label: 'My side', text: form.sideA!),
                      if (form.sideA != null && form.sideB != null)
                        const SizedBox(height: 8),
                      if (form.sideB != null)
                        _LabeledLine(label: 'Their side', text: form.sideB!),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _ReviewSection(
                title: 'Tone',
                onEdit: () => context.go(AppRoutes.submitTone),
                child: Text(form.tone.label),
              ),
              const SizedBox(height: 12),
              _ReviewSection(
                title: 'Save to history',
                onEdit: () => context.go(AppRoutes.submit),
                child: Text(form.saveCase ? 'Yes' : 'No'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: form.readyForVerdict
                    ? () => context.push(AppRoutes.verdictLoading)
                    : null,
                icon: const Icon(Icons.gavel),
                label: const Text('Settle It'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ],
            ),
            DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium ?? const TextStyle(),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledLine extends StatelessWidget {
  const _LabeledLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: SettleThisColors.inkSoft,
          ),
        ),
        const SizedBox(height: 2),
        Text(text),
      ],
    );
  }
}

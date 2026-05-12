import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/judge_pip.dart';
import '../../history/data/history_repository.dart';
import '../../verdict/domain/dispute_case.dart';
import '../../verdict/presentation/verdict_card_widget.dart';

const int _kFreeVerdictsPerDay = 3;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(historyStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle This'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const _HostBlock(),
              const SizedBox(height: 28),
              Text(
                'What are we settling today?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tell us what happened — the tiny gavel handles the rest.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: SettleThisColors.inkSoft,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: _UsageChip(
                  used: 0,
                  total: _kFreeVerdictsPerDay,
                ),
              ),
              const SizedBox(height: 24),
              _HeroSettleButton(
                onPressed: () => context.push(AppRoutes.submit),
              ),
              const SizedBox(height: 28),
              historyAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (cases) => _RecentVerdicts(
                  cases: cases.take(2).toList(growable: false),
                  totalCount: cases.length,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostBlock extends StatelessWidget {
  const _HostBlock();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const JudgePip(size: 88),
        const SizedBox(height: 10),
        Text(
          'YOUR TINY JUDGE IS IN',
          style: theme.textTheme.labelSmall?.copyWith(
            color: SettleThisColors.inkSoft,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _UsageChip extends StatelessWidget {
  const _UsageChip({required this.used, required this.total});

  final int used;
  final int total;

  int get _remaining => (total - used).clamp(0, total);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final out = _remaining == 0;
    final color = out ? SettleThisColors.coral : SettleThisColors.gavelGold;
    final label = out
        ? 'Out of free verdicts — courtroom reopens tomorrow'
        : '$_remaining of $total free verdicts left today';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: SettleThisColors.cream,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(out ? Icons.lock_clock : Icons.bolt, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: SettleThisColors.navyDeep,
            ),
          ),
          if (!out) ...[
            const SizedBox(width: 8),
            _UsageDots(used: used, total: total),
          ],
        ],
      ),
    );
  }
}

class _UsageDots extends StatelessWidget {
  const _UsageDots({required this.used, required this.total});

  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(total, (i) {
          final spent = i < used;
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: spent
                  ? SettleThisColors.creamDeep
                  : SettleThisColors.gavelGold,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

class _HeroSettleButton extends StatelessWidget {
  const _HeroSettleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                SettleThisColors.gavelGold,
                Color(0xFFF1C24F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: SettleThisColors.gavelGold.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: SettleThisColors.navyDeep.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.gavel,
                  size: 22,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settle Something',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: SettleThisColors.navyDeep,
                      ),
                    ),
                    Text(
                      'Drop a dispute · get a verdict in seconds',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SettleThisColors.navyDeep
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: SettleThisColors.navyDeep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentVerdicts extends StatelessWidget {
  const _RecentVerdicts({required this.cases, required this.totalCount});

  final List<DisputeCase> cases;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (cases.isEmpty) {
      return _EmptyHistoryCard(theme: theme);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'RECENT VERDICTS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: SettleThisColors.inkSoft,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push(AppRoutes.history),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...cases.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: VerdictPreviewCard(
              title: c.verdict?.title ?? '—',
              summary: c.verdict?.summaryVerdict ?? '',
              who: c.verdict?.whoWasMoreRight.label ?? 'Unclear',
              onTap: () => context.push('/history/${c.caseId}'),
            ),
          ),
        ),
        if (totalCount > cases.length)
          Center(
            child: Text(
              '+${totalCount - cases.length} more in history',
              style: theme.textTheme.bodySmall?.copyWith(
                color: SettleThisColors.inkSoft,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SettleThisColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettleThisColors.creamDeep),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book_outlined,
              color: SettleThisColors.inkSoft,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No verdicts yet',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your first tiny courtroom awaits.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SettleThisColors.inkSoft,
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

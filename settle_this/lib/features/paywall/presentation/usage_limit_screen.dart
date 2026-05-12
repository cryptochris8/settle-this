import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';

class UsageLimitScreen extends StatelessWidget {
  const UsageLimitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Out of verdicts')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_clock,
                size: 72,
                color: SettleThisColors.gavelGold,
              ),
              const SizedBox(height: 24),
              Text(
                'The courtroom is closed for today.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your free verdicts are done for today. The courtroom reopens tomorrow, or upgrade to Plus to settle more.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.push(AppRoutes.paywall),
                child: const Text('Upgrade to Plus'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Maybe later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

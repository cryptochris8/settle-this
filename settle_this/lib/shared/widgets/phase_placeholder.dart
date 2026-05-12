import 'package:flutter/material.dart';

import '../../app/theme.dart';

class PhasePlaceholder extends StatelessWidget {
  const PhasePlaceholder({
    required this.title,
    required this.phase,
    required this.description,
    super.key,
  });

  final String title;
  final String phase;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: SettleThisColors.gavelGold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  phase,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SettleThisColors.navyDeep,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

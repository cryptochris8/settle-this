import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../paywall/data/subscription_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final subscription = ref.watch(subscriptionStatusProvider);
    final isPlus = subscription.value?.isPlus ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingsSection(
            title: 'ACCOUNT',
            children: [
              _LineTile(
                icon: Icons.person_outline,
                label: 'Account',
                trailing: Text(
                  auth.value?.email ??
                      (auth.value?.isAnonymous ?? false ? 'Guest' : '—'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SettleThisColors.inkSoft,
                      ),
                ),
              ),
              _LineTile(
                icon: Icons.workspace_premium,
                label: 'Subscription',
                trailing: Text(
                  isPlus ? 'Plus' : 'Free',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPlus
                            ? SettleThisColors.gavelGold
                            : SettleThisColors.inkSoft,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                onTap: () => context.push(AppRoutes.paywall),
              ),
            ],
          ),
          _SettingsSection(
            title: 'PRIVACY',
            children: [
              _LineTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy & disclaimers',
                onTap: () => context.push(AppRoutes.settingsPrivacy),
              ),
              _LineTile(
                icon: Icons.delete_outline,
                label: 'Delete data',
                onTap: () => context.push(AppRoutes.settingsDeleteData),
              ),
            ],
          ),
          const _SettingsSection(
            title: 'ABOUT',
            children: [
              _LineTile(
                icon: Icons.gavel,
                label: 'Settle This',
                trailing: Text('v1.0.0'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: SettleThisColors.inkSoft,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            child: Column(
              children: List<Widget>.generate(
                children.length * 2 - 1,
                (i) =>
                    i.isEven ? children[i ~/ 2] : const _Divider(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: SettleThisColors.navy),
      title: Text(label),
      trailing: trailing == null
          ? (onTap == null ? null : const Icon(Icons.chevron_right))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                trailing!,
                if (onTap != null) const Icon(Icons.chevron_right),
              ],
            ),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56);
  }
}

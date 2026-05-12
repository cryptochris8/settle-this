import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../data/onboarding_repository.dart';

const String _disclaimerBody =
    'Settle This is for entertainment and general perspective on everyday '
    'low-stakes disagreements. It is not therapy, legal advice, medical '
    'advice, crisis support, or a substitute for professional help.';

const List<String> _bullets = [
  'Serious or unsafe topics get a calm redirect, not a funny verdict.',
  'Avoid full names, addresses, phone numbers, workplaces, or other identifying details.',
  'You can delete saved cases or your account at any time from Settings.',
];

class DisclaimerScreen extends ConsumerStatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  ConsumerState<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends ConsumerState<DisclaimerScreen> {
  bool _agreed = false;

  Future<void> _accept() async {
    if (!_agreed) return;
    await ref.read(onboardingProvider.notifier).acceptDisclaimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Before we get started',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _disclaimerBody,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.check_circle,
                          size: 18,
                          color: SettleThisColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          b,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: SettleThisColors.inkSoft,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I understand and agree to use Settle This for fun, low-stakes disputes only.',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _agreed ? _accept : null,
                child: const Text('Accept and continue'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

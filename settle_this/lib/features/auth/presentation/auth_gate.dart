import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Splash shown while the router resolves where to send the user. The router's
/// redirect logic moves the user off this screen as soon as auth + onboarding
/// state is ready.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.gavel,
                size: 64,
                color: SettleThisColors.navy,
              ),
              const SizedBox(height: 16),
              Text(
                'Settle This',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../data/auth_repository.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _continueAsGuest() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showStubMessage(String provider) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('$provider sign-in arrives in a later phase.')),
    );
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
              const SizedBox(height: 32),
              const Icon(
                Icons.login_outlined,
                size: 64,
                color: SettleThisColors.navy,
              ),
              const SizedBox(height: 24),
              Text(
                'Almost there.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Continue as a guest to get a verdict in seconds, or sign in '
                'to keep your history across devices.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _busy ? null : _continueAsGuest,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.flash_on),
                label: const Text('Continue as guest'),
              ),
              const SizedBox(height: 16),
              const _Divider(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showStubMessage('Apple'),
                icon: const Icon(Icons.apple),
                label: const Text('Continue with Apple'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showStubMessage('Google'),
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Continue with Google'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SettleThisColors.blocked,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                'By continuing, you agree to use Settle This for low-stakes, '
                'private disputes only.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

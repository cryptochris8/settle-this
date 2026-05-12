import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/constants.dart';
import '../../../app/theme.dart';
import '../data/onboarding_repository.dart';

class AgeGateScreen extends ConsumerStatefulWidget {
  const AgeGateScreen({super.key});

  @override
  ConsumerState<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends ConsumerState<AgeGateScreen> {
  DateTime? _picked;
  bool _showUnderageBlock = false;

  static int _ageFromDob(DateTime dob, DateTime now) {
    var age = now.year - dob.year;
    final hasHadBirthdayThisYear = now.month > dob.month ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hasHadBirthdayThisYear) age--;
    return age;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - AppConstants.minimumAge, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 110),
      lastDate: now,
      helpText: 'Select your date of birth',
    );
    if (picked == null) return;
    setState(() {
      _picked = picked;
      _showUnderageBlock = false;
    });
  }

  Future<void> _continue() async {
    final dob = _picked;
    if (dob == null) return;
    final age = _ageFromDob(dob, DateTime.now());
    if (age < AppConstants.minimumAge) {
      setState(() => _showUnderageBlock = true);
      return;
    }
    await ref.read(onboardingProvider.notifier).setDateOfBirth(dob);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dob = _picked;
    final dobLabel = dob == null
        ? 'Pick your date of birth'
        : DateFormat.yMMMMd().format(dob);

    if (_showUnderageBlock) {
      return _UnderageBlocked(onTryAgain: () {
        setState(() {
          _picked = null;
          _showUnderageBlock = false;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(
                Icons.cake_outlined,
                size: 72,
                color: SettleThisColors.gavelGold,
              ),
              const SizedBox(height: 24),
              Text(
                'How old are you?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Settle This is built for adults. We do not store your date of '
                'birth in any analytics.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: _pickDob,
                icon: const Icon(Icons.calendar_today),
                label: Text(dobLabel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: dob == null ? null : _continue,
                child: const Text('Continue'),
              ),
              const SizedBox(height: 12),
              const TextButton(
                onPressed: SystemNavigator.pop,
                child: Text('Exit'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderageBlocked extends StatelessWidget {
  const _UnderageBlocked({required this.onTryAgain});

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 72,
                color: SettleThisColors.warning,
              ),
              const SizedBox(height: 24),
              Text(
                'Sorry, this app is 18 and up.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SettleThisColors.navyDeep,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Come back when you are old enough to argue about laundry.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SettleThisColors.inkSoft,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: onTryAgain,
                child: const Text('I entered the wrong date'),
              ),
              const FilledButton(
                onPressed: SystemNavigator.pop,
                child: Text('Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/judge_pip.dart';
import '../../home/data/usage_repository.dart';
import '../../submit_case/application/submit_case_form.dart';
import '../../submit_case/data/verdict_repository.dart';

const List<String> _quips = [
  'Reviewing both sides...',
  'Dusting off the tiny gavel...',
  'Checking for household crimes...',
  'Preparing a fair ruling...',
  'Writing something you can safely send...',
];

const Duration _quipInterval = Duration(milliseconds: 900);

class VerdictLoadingScreen extends ConsumerStatefulWidget {
  const VerdictLoadingScreen({super.key});

  @override
  ConsumerState<VerdictLoadingScreen> createState() =>
      _VerdictLoadingScreenState();
}

class _VerdictLoadingScreenState extends ConsumerState<VerdictLoadingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _quipTimer;
  late final AnimationController _gavelController;
  int _quipIndex = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _gavelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _quipTimer = Timer.periodic(_quipInterval, (_) {
      if (!mounted) return;
      setState(() => _quipIndex = (_quipIndex + 1) % _quips.length);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _runVerdict());
  }

  Future<void> _runVerdict() async {
    final input = ref.read(submitCaseFormProvider);
    if (!input.readyForVerdict) {
      if (!mounted) return;
      context.go(AppRoutes.home);
      return;
    }
    try {
      final response =
          await ref.read(verdictRepositoryProvider).createVerdict(input);
      if (!mounted) return;
      ref.read(submitCaseFormProvider.notifier).reset();
      // Force the usage counter on /home to re-fetch — a verdict was just
      // spent. Next time the user lands on home, the chip reflects reality.
      ref.invalidate(userUsageProvider);
      context.go('/verdict/${response.caseId}');
    } on VerdictException catch (e) {
      if (!mounted) return;
      if (e.code == 'resource-exhausted') {
        // Out of quota — refresh the home counter so it shows "out" next
        // time too, and route to the usage limit screen.
        ref.invalidate(userUsageProvider);
        context.go(AppRoutes.usageLimit);
        return;
      }
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went sideways: $e');
    }
  }

  void _retry() {
    setState(() => _error = null);
    _runVerdict();
  }

  @override
  void dispose() {
    _quipTimer?.cancel();
    _gavelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = _error;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: error == null
              ? _LoadingBody(
                  controller: _gavelController,
                  quip: _quips[_quipIndex],
                )
              : _ErrorBody(
                  message: error,
                  theme: theme,
                  onRetry: _retry,
                  onHome: () => context.go(AppRoutes.home),
                ),
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.controller, required this.quip});

  final AnimationController controller;
  final String quip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Pip "thinking" stage. Gentle rocking + a soft halo behind the
        // character. Real Pip art (kArtReady=true) renders the commissioned
        // illustration; until then the stub fills the same circle. Either
        // way, the parent rocks the whole composition.
        RotationTransition(
          turns: Tween<double>(begin: -0.04, end: 0.04).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SettleThisColors.gavelGold.withValues(alpha: 0.22),
                      SettleThisColors.gavelGold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              const JudgePip(size: 96),
            ],
          ),
        ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            quip,
            key: ValueKey(quip),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: SettleThisColors.navyDeep,
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.theme,
    required this.onRetry,
    required this.onHome,
  });

  final String message;
  final ThemeData theme;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.error_outline,
          size: 64,
          color: SettleThisColors.warning,
        ),
        const SizedBox(height: 16),
        Text(
          'The tiny judge dropped the paperwork.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: SettleThisColors.inkSoft,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: onRetry, child: const Text('Try again')),
        const SizedBox(height: 8),
        TextButton(onPressed: onHome, child: const Text('Back to home')),
      ],
    );
  }
}

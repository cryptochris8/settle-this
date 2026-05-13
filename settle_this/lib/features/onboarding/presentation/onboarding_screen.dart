import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/judge_pip.dart';
import '../data/onboarding_repository.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    this.quiet = false,
  });

  final String title;
  final String body;

  /// When true, render the calmer Pip Listening variant — used for the
  /// "serious topics" page so the energy matches the message.
  final bool quiet;
}

const List<_OnboardingPage> _pages = [
  _OnboardingPage(
    title: 'Settle silly arguments without starting a bigger one.',
    body:
        'Get a funny, fair AI verdict for everyday disagreements — laundry, '
        'pets, chores, leftovers, texting, and all the tiny chaos of real life.',
  ),
  _OnboardingPage(
    title: 'A referee, not a therapist.',
    body:
        'Settle This is for low-stakes everyday disagreements. It gives '
        'perspective, a practical next step, and a little humor.',
  ),
  _OnboardingPage(
    quiet: true,
    title: 'Some things deserve real help.',
    body:
        'This app does not provide therapy, legal, medical, emergency, or '
        'crisis advice. Serious or unsafe topics will get a calm redirect '
        'instead of a funny verdict.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLastPage => _index == _pages.length - 1;

  Future<void> _next() async {
    if (_isLastPage) {
      await ref.read(onboardingProvider.notifier).completeOnboarding();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _skip() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextButton(
                  onPressed: _skip,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: JudgePip(size: 120, quiet: page.quiet)),
                        const SizedBox(height: 36),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: SettleThisColors.navyDeep,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: SettleThisColors.inkSoft,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _PageDots(count: _pages.length, active: _index),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLastPage ? "Let's settle something" : 'Next'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? SettleThisColors.navy
                : SettleThisColors.creamDeep,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

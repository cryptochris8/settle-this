import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/history/presentation/case_detail_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/onboarding/presentation/age_gate_screen.dart';
import '../features/onboarding/presentation/disclaimer_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/paywall/presentation/usage_limit_screen.dart';
import '../features/settings/presentation/delete_data_screen.dart';
import '../features/settings/presentation/privacy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/submit_case/presentation/review_case_screen.dart';
import '../features/submit_case/presentation/side_input_screen.dart';
import '../features/submit_case/presentation/submit_case_screen.dart';
import '../features/submit_case/presentation/tone_selector_screen.dart';
import '../features/verdict/domain/dispute_case.dart';
import '../features/verdict/presentation/share_card_preview_screen.dart';
import '../features/verdict/presentation/verdict_loading_screen.dart';
import '../features/verdict/presentation/verdict_result_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String ageGate = '/age-gate';
  static const String disclaimer = '/disclaimer';
  static const String signIn = '/sign-in';
  static const String home = '/home';
  static const String submit = '/submit';
  static const String submitSides = '/submit/sides';
  static const String submitTone = '/submit/tone';
  static const String submitReview = '/submit/review';
  static const String verdictLoading = '/verdict/loading';
  static const String verdictDetail = '/verdict/:caseId';
  static const String verdictShareCard = '/verdict/:caseId/share-card';
  static const String history = '/history';
  static const String historyDetail = '/history/:caseId';
  static const String paywall = '/paywall';
  static const String usageLimit = '/usage-limit';
  static const String settings = '/settings';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsDeleteData = '/settings/delete-data';

  static const Set<String> _gatingRoutes = {
    splash,
    onboarding,
    ageGate,
    disclaimer,
    signIn,
  };

  static bool isGatingRoute(String location) =>
      _gatingRoutes.contains(location);
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _subs = [
      ref.listen(authStateProvider, (_, _) => notifyListeners()),
      ref.listen(onboardingProvider, (_, _) => notifyListeners()),
    ];
  }

  late final List<ProviderSubscription<Object?>> _subs;

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.close();
    }
    super.dispose();
  }
}

String? _resolveRedirect(GoRouterState state, Ref ref) {
  final onboarding = ref.read(onboardingProvider);
  final auth = ref.read(authStateProvider);
  final location = state.matchedLocation;

  if (auth.isLoading) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (!onboarding.onboardingComplete) {
    return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }
  if (!onboarding.isAdult) {
    return location == AppRoutes.ageGate ? null : AppRoutes.ageGate;
  }
  if (!onboarding.disclaimerAccepted) {
    return location == AppRoutes.disclaimer ? null : AppRoutes.disclaimer;
  }
  if (auth.value == null) {
    return location == AppRoutes.signIn ? null : AppRoutes.signIn;
  }

  if (AppRoutes.isGatingRoute(location)) {
    return AppRoutes.home;
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) => _resolveRedirect(state, ref),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.ageGate,
        builder: (context, state) => const AgeGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.disclaimer,
        builder: (context, state) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.submit,
        builder: (context, state) => const SubmitCaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.submitSides,
        builder: (context, state) => const SideInputScreen(),
      ),
      GoRoute(
        path: AppRoutes.submitTone,
        builder: (context, state) => const ToneSelectorScreen(),
      ),
      GoRoute(
        path: AppRoutes.submitReview,
        builder: (context, state) => const ReviewCaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.verdictLoading,
        builder: (context, state) => const VerdictLoadingScreen(),
      ),
      GoRoute(
        path: AppRoutes.verdictDetail,
        builder: (context, state) => VerdictResultScreen(
          caseId: state.pathParameters['caseId'] ?? '',
          initialCase: state.extra as DisputeCase?,
        ),
      ),
      GoRoute(
        path: AppRoutes.verdictShareCard,
        builder: (context, state) => ShareCardPreviewScreen(
          caseId: state.pathParameters['caseId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.historyDetail,
        builder: (context, state) => CaseDetailScreen(
          caseId: state.pathParameters['caseId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppRoutes.usageLimit,
        builder: (context, state) => const UsageLimitScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacy,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsDeleteData,
        builder: (context, state) => const DeleteDataScreen(),
      ),
    ],
  );
});

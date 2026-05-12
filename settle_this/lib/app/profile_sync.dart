import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/user_profile_repository.dart';
import '../features/onboarding/data/onboarding_repository.dart';

/// Watches auth state and ensures `users/{uid}` exists / is touched whenever a
/// user signs in. Read once at app root so the side-effect runs for the whole
/// session.
final profileSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
    final user = next.value;
    if (user == null) return;

    final onboarding = ref.read(onboardingProvider);
    final repo = ref.read(userProfileRepositoryProvider);
    repo
        .ensureProfile(
          user,
          ageVerifiedAt: onboarding.ageVerifiedAt,
          acceptedDisclaimerVersion: onboarding.acceptedDisclaimerVersion,
          disclaimerAcceptedAt: onboarding.disclaimerAcceptedAt,
        )
        .catchError((Object error, StackTrace stack) {
      if (kDebugMode) {
        debugPrint('Profile sync failed: $error');
      }
    });
  });
});

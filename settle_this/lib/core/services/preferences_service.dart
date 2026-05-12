import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bootstrapped from `main()` via `overrideWithValue`. Reading this provider
/// before the override is applied throws — this is intentional: it surfaces a
/// missing-bootstrap bug loudly at the failing call site.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() with the '
    'pre-loaded SharedPreferences instance.',
  );
});

class PreferenceKeys {
  PreferenceKeys._();

  static const String onboardingComplete = 'onboarding_complete';
  static const String dateOfBirthIso = 'date_of_birth_iso';
  static const String ageVerifiedAtIso = 'age_verified_at_iso';
  static const String disclaimerVersion = 'disclaimer_accepted_version';
  static const String disclaimerAcceptedAtIso = 'disclaimer_accepted_at_iso';
}

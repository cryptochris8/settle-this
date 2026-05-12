import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/constants.dart';
import '../../../core/services/preferences_service.dart';

class OnboardingState {
  const OnboardingState({
    required this.onboardingComplete,
    required this.dateOfBirth,
    required this.ageVerifiedAt,
    required this.acceptedDisclaimerVersion,
    required this.disclaimerAcceptedAt,
  });

  final bool onboardingComplete;
  final DateTime? dateOfBirth;
  final DateTime? ageVerifiedAt;
  final String? acceptedDisclaimerVersion;
  final DateTime? disclaimerAcceptedAt;

  bool get isAdult {
    final dob = dateOfBirth;
    if (dob == null) return false;
    final now = DateTime.now();
    var age = now.year - dob.year;
    final hasHadBirthdayThisYear = now.month > dob.month ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hasHadBirthdayThisYear) age--;
    return age >= AppConstants.minimumAge;
  }

  bool get disclaimerAccepted =>
      acceptedDisclaimerVersion == AppConstants.currentDisclaimerVersion;

  OnboardingState copyWith({
    bool? onboardingComplete,
    DateTime? dateOfBirth,
    DateTime? ageVerifiedAt,
    String? acceptedDisclaimerVersion,
    DateTime? disclaimerAcceptedAt,
  }) {
    return OnboardingState(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      ageVerifiedAt: ageVerifiedAt ?? this.ageVerifiedAt,
      acceptedDisclaimerVersion:
          acceptedDisclaimerVersion ?? this.acceptedDisclaimerVersion,
      disclaimerAcceptedAt:
          disclaimerAcceptedAt ?? this.disclaimerAcceptedAt,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  late SharedPreferences _prefs;

  @override
  OnboardingState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _readFromPrefs();
  }

  OnboardingState _readFromPrefs() {
    return OnboardingState(
      onboardingComplete:
          _prefs.getBool(PreferenceKeys.onboardingComplete) ?? false,
      dateOfBirth: _readDate(PreferenceKeys.dateOfBirthIso),
      ageVerifiedAt: _readDate(PreferenceKeys.ageVerifiedAtIso),
      acceptedDisclaimerVersion:
          _prefs.getString(PreferenceKeys.disclaimerVersion),
      disclaimerAcceptedAt: _readDate(PreferenceKeys.disclaimerAcceptedAtIso),
    );
  }

  DateTime? _readDate(String key) {
    final iso = _prefs.getString(key);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(PreferenceKeys.onboardingComplete, true);
    state = state.copyWith(onboardingComplete: true);
  }

  Future<void> setDateOfBirth(DateTime dob) async {
    final now = DateTime.now();
    await _prefs.setString(
      PreferenceKeys.dateOfBirthIso,
      dob.toIso8601String(),
    );
    await _prefs.setString(
      PreferenceKeys.ageVerifiedAtIso,
      now.toIso8601String(),
    );
    state = state.copyWith(dateOfBirth: dob, ageVerifiedAt: now);
  }

  Future<void> acceptDisclaimer() async {
    final now = DateTime.now();
    await _prefs.setString(
      PreferenceKeys.disclaimerVersion,
      AppConstants.currentDisclaimerVersion,
    );
    await _prefs.setString(
      PreferenceKeys.disclaimerAcceptedAtIso,
      now.toIso8601String(),
    );
    state = state.copyWith(
      acceptedDisclaimerVersion: AppConstants.currentDisclaimerVersion,
      disclaimerAcceptedAt: now,
    );
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized analytics surface. Every callsite goes through a typed method
/// here so we keep an allowlist of event parameters (security finding F8.2 —
/// no event parameter may carry scenario, verdict, or feedback freeText).
class AnalyticsService {
  FirebaseAnalytics? _resolveAnalytics() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseAnalytics.instance;
    } on FirebaseException {
      return null;
    }
  }

  Future<void> _log(String name, [Map<String, Object?>? params]) async {
    final analytics = _resolveAnalytics();
    if (analytics == null) {
      if (kDebugMode) debugPrint('analytics(noop): $name $params');
      return;
    }
    final filtered = <String, Object>{};
    params?.forEach((key, value) {
      if (value == null) return;
      if (value is num || value is String || value is bool) {
        filtered[key] = value;
      }
    });
    await analytics.logEvent(name: name, parameters: filtered);
  }

  // Onboarding
  Future<void> onboardingStarted() => _log('onboarding_started');
  Future<void> onboardingCompleted() => _log('onboarding_completed');
  Future<void> ageGatePassed() => _log('age_gate_passed');
  Future<void> ageGateFailed() => _log('age_gate_failed');
  Future<void> disclaimerAccepted() => _log('disclaimer_accepted');
  Future<void> signInStarted(String method) =>
      _log('sign_in_started', {'method': method});
  Future<void> signInCompleted(String method) =>
      _log('sign_in_completed', {'method': method});

  // Verdict funnel
  Future<void> submitCaseStarted() => _log('submit_case_started');
  Future<void> relationshipTypeSelected(String type) =>
      _log('relationship_type_selected', {'relationship': type});
  Future<void> toneSelected(String tone) =>
      _log('tone_selected', {'tone': tone});
  Future<void> caseReviewed() => _log('case_reviewed');
  Future<void> createVerdictStarted({required String tone}) =>
      _log('create_verdict_started', {'tone': tone});
  Future<void> createVerdictCompleted({
    required String tone,
    required String status,
    String riskLevel = 'unknown',
  }) =>
      _log('create_verdict_completed', {
        'tone': tone,
        'status': status,
        'risk_level': riskLevel,
      });
  Future<void> createVerdictFailed(String code) =>
      _log('create_verdict_failed', {'code': code});
  Future<void> safetySoftRedirectShown() =>
      _log('safety_soft_redirect_shown');
  Future<void> safetyBlockShown() => _log('safety_block_shown');

  // Engagement
  Future<void> verdictViewed(String caseId) =>
      _log('verdict_viewed', {'case_id': caseId});
  Future<void> verdictShared() => _log('verdict_shared');
  Future<void> shareCardCreated() => _log('share_card_created');
  Future<void> textToSendCopied() => _log('text_to_send_copied');
  Future<void> caseSaved() => _log('case_saved');
  Future<void> caseDeleted() => _log('case_deleted');
  Future<void> historyOpened() => _log('history_opened');
  Future<void> feedbackSubmitted({required bool helpful}) =>
      _log('feedback_submitted', {'helpful': helpful});
  Future<void> tryAnotherToneTapped() => _log('try_another_tone_tapped');
  Future<void> settleAnotherTapped() => _log('settle_another_tapped');

  // Monetization
  Future<void> paywallViewed() => _log('paywall_viewed');
  Future<void> paywallCtaTapped(String packageId) =>
      _log('paywall_cta_tapped', {'package_id': packageId});
  Future<void> purchaseStarted() => _log('purchase_started');
  Future<void> purchaseCompleted() => _log('purchase_completed');
  Future<void> purchaseFailed(String code) =>
      _log('purchase_failed', {'code': code});
  Future<void> restorePurchaseTapped() => _log('restore_purchase_tapped');
  Future<void> usageLimitReached() => _log('usage_limit_reached');
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

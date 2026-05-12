import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps Crashlytics so scenario / verdict text never accidentally lands in a
/// stack-trace report (security finding F8.1).
///
/// Callers pass opaque ids (caseId) and short tags only. Reasons may include
/// the AppErrorCode but never the user's free text.
class CrashlyticsService {
  FirebaseCrashlytics? _resolveCrashlytics() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseCrashlytics.instance;
    } on FirebaseException {
      return null;
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    Map<String, Object?> data = const {},
    bool fatal = false,
  }) async {
    final crashlytics = _resolveCrashlytics();
    if (crashlytics == null) {
      if (kDebugMode) debugPrint('crashlytics(noop): $reason — $error');
      return;
    }
    for (final entry in data.entries) {
      final v = entry.value;
      if (v is num) {
        await crashlytics.setCustomKey(entry.key, v.toDouble());
      } else if (v is bool) {
        await crashlytics.setCustomKey(entry.key, v);
      } else if (v is String) {
        await crashlytics.setCustomKey(entry.key, v);
      }
    }
    await crashlytics.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  Future<void> log(String message) async {
    final crashlytics = _resolveCrashlytics();
    if (crashlytics == null) return;
    await crashlytics.log(message);
  }

  Future<void> setUserId(String? uid) async {
    final crashlytics = _resolveCrashlytics();
    if (crashlytics == null || uid == null) return;
    await crashlytics.setUserIdentifier(uid);
  }
}

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  return CrashlyticsService();
});

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';

/// Snapshot of the user's current usage quota for the day.
///
/// Shape mirrors the `getUserUsage` Cloud Function's return value in
/// `functions/src/cases/getUserUsage.ts`.
class UserUsage {
  const UserUsage({
    required this.freeVerdictsUsed,
    required this.paidVerdictsUsed,
    required this.freeVerdictsPerDay,
    required this.remainingFreeVerdicts,
    required this.isPaid,
    required this.subscriptionStatus,
  });

  final int freeVerdictsUsed;
  final int paidVerdictsUsed;
  final int freeVerdictsPerDay;
  final int remainingFreeVerdicts;
  final bool isPaid;
  final String subscriptionStatus;

  /// Conservative fallback used when Firebase isn't reachable or the user
  /// isn't signed in yet. Always lets the UI render *something* friendly.
  static const UserUsage offline = UserUsage(
    freeVerdictsUsed: 0,
    paidVerdictsUsed: 0,
    freeVerdictsPerDay: 3,
    remainingFreeVerdicts: 3,
    isPaid: false,
    subscriptionStatus: 'free',
  );

  bool get isOutOfFree => !isPaid && remainingFreeVerdicts <= 0;

  factory UserUsage.fromJson(Map<dynamic, dynamic> raw) {
    return UserUsage(
      freeVerdictsUsed: (raw['freeVerdictsUsed'] as num?)?.toInt() ?? 0,
      paidVerdictsUsed: (raw['paidVerdictsUsed'] as num?)?.toInt() ?? 0,
      freeVerdictsPerDay:
          (raw['freeVerdictsPerDay'] as num?)?.toInt() ?? 3,
      remainingFreeVerdicts:
          (raw['remainingFreeVerdicts'] as num?)?.toInt() ?? 3,
      isPaid: raw['isPaid'] as bool? ?? false,
      subscriptionStatus:
          (raw['subscriptionStatus'] as String?) ?? 'free',
    );
  }
}

class UsageRepository {
  FirebaseFunctions? _resolveFunctions() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFunctions.instanceFor(region: 'us-central1');
    } on FirebaseException {
      return null;
    }
  }

  Future<UserUsage> fetchUsage() async {
    final functions = _resolveFunctions();
    if (functions == null) return UserUsage.offline;
    try {
      final result = await functions
          .httpsCallable('getUserUsage')
          .call<Map<Object?, Object?>>(<String, Object?>{});
      return UserUsage.fromJson(result.data);
    } on FirebaseFunctionsException {
      return UserUsage.offline;
    }
  }
}

final usageRepositoryProvider = Provider<UsageRepository>((_) {
  return UsageRepository();
});

/// Live read of the user's daily usage. Re-fetches whenever the auth state
/// changes (sign in / sign out swaps the uid).
///
/// To force a refresh after a verdict is submitted, call
/// `ref.invalidate(userUsageProvider)` from the caller — the next watcher
/// triggers a fresh fetch.
final userUsageProvider = FutureProvider<UserUsage>((ref) {
  // Re-fetch on auth change so signing in/out flips the value.
  ref.watch(authStateProvider);
  return ref.watch(usageRepositoryProvider).fetchUsage();
});

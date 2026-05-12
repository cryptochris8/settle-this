import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants.dart';

class UserProfileRepository {
  FirebaseFirestore? _resolveFirestore() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFirestore.instance;
    } on FirebaseException {
      return null;
    }
  }

  Future<void> ensureProfile(
    User user, {
    required DateTime? ageVerifiedAt,
    required String? acceptedDisclaimerVersion,
    required DateTime? disclaimerAcceptedAt,
  }) async {
    final firestore = _resolveFirestore();
    if (firestore == null) return;

    final doc = firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    final now = FieldValue.serverTimestamp();

    final ageTimestamp =
        ageVerifiedAt == null ? null : Timestamp.fromDate(ageVerifiedAt);
    final disclaimerTimestamp = disclaimerAcceptedAt == null
        ? null
        : Timestamp.fromDate(disclaimerAcceptedAt);

    final touch = <String, Object?>{
      'lastActiveAt': now,
      'ageVerifiedAt': ?ageTimestamp,
      'acceptedDisclaimerVersion': ?acceptedDisclaimerVersion,
      'acceptedDisclaimerAt': ?disclaimerTimestamp,
    };

    if (!snapshot.exists) {
      await doc.set(<String, Object?>{
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': now,
        'authProvider': _resolveProvider(user),
        'isAnonymous': user.isAnonymous,
        'subscription': <String, Object?>{
          'status': 'free',
        },
        'settings': <String, Object?>{
          'defaultTone': 'balanced_referee',
          'allowPg13Humor': false,
          'saveHistoryByDefault': true,
          'analyticsOptOut': false,
        },
        'counters': <String, Object?>{
          'totalCasesCreated': 0,
          'totalShares': 0,
          'totalHelpfulVotes': 0,
        },
        'appVersionAtCreate': AppConstants.firebaseEnv,
        ...touch,
      });
    } else {
      await doc.update(touch);
    }
  }

  String _resolveProvider(User user) {
    if (user.isAnonymous) return 'anonymous';
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.contains('apple.com')) return 'apple';
    if (providers.contains('google.com')) return 'google';
    if (providers.contains('password')) return 'email';
    return providers.isEmpty ? 'unknown' : providers.first;
  }
}

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository();
});

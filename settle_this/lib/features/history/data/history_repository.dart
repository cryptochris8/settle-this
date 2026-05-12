import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../verdict/domain/dispute_case.dart';

class HistoryRepository {
  HistoryRepository(this._uid);

  final String? _uid;

  FirebaseFirestore? _resolveFirestore() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFirestore.instance;
    } on FirebaseException {
      return null;
    }
  }

  FirebaseFunctions? _resolveFunctions() {
    if (Firebase.apps.isEmpty) return null;
    try {
      return FirebaseFunctions.instanceFor(region: 'us-central1');
    } on FirebaseException {
      return null;
    }
  }

  Stream<List<DisputeCase>> watchHistory() {
    final firestore = _resolveFirestore();
    final uid = _uid;
    if (firestore == null || uid == null) {
      return Stream<List<DisputeCase>>.value(const []);
    }
    return firestore
        .collection('users')
        .doc(uid)
        .collection('cases')
        .where('deletedAt', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DisputeCase.fromFirestore).toList());
  }

  Future<DisputeCase?> getCase(String caseId) async {
    final firestore = _resolveFirestore();
    final uid = _uid;
    if (firestore == null || uid == null) return null;
    final snap = await firestore
        .collection('users')
        .doc(uid)
        .collection('cases')
        .doc(caseId)
        .get();
    if (!snap.exists) return null;
    return DisputeCase.fromFirestore(snap);
  }

  Stream<DisputeCase?> watchCase(String caseId) {
    final firestore = _resolveFirestore();
    final uid = _uid;
    if (firestore == null || uid == null) {
      return Stream<DisputeCase?>.value(null);
    }
    return firestore
        .collection('users')
        .doc(uid)
        .collection('cases')
        .doc(caseId)
        .snapshots()
        .map((snap) => snap.exists ? DisputeCase.fromFirestore(snap) : null);
  }

  Future<void> deleteCase(String caseId) async {
    final functions = _resolveFunctions();
    if (functions != null) {
      try {
        await functions
            .httpsCallable('deleteCase')
            .call<Map<Object?, Object?>>(
          <String, Object?>{'caseId': caseId, 'hard': false},
        );
        return;
      } on FirebaseFunctionsException {
        // fall through to client-side soft delete
      }
    }

    final firestore = _resolveFirestore();
    final uid = _uid;
    if (firestore == null || uid == null) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('cases')
        .doc(caseId)
        .update({'deletedAt': FieldValue.serverTimestamp()});
  }

  Future<void> submitFeedback({
    required String caseId,
    required bool helpful,
    required List<String> tags,
    String? freeText,
  }) async {
    final functions = _resolveFunctions();
    if (functions == null) return;
    await functions
        .httpsCallable('submitFeedback')
        .call<Map<Object?, Object?>>(<String, Object?>{
      'caseId': caseId,
      'rating': helpful ? 'thumbs_up' : 'thumbs_down',
      'tags': tags,
      'freeText': freeText,
    });
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final auth = ref.watch(authStateProvider);
  return HistoryRepository(auth.value?.uid);
});

final historyStreamProvider = StreamProvider<List<DisputeCase>>((ref) {
  return ref.watch(historyRepositoryProvider).watchHistory();
});

final caseStreamProvider =
    StreamProvider.family<DisputeCase?, String>((ref, caseId) {
  return ref.watch(historyRepositoryProvider).watchCase(caseId);
});

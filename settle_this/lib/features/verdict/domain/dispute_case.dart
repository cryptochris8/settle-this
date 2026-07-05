import 'package:cloud_firestore/cloud_firestore.dart';

import '../../submit_case/domain/relationship_type.dart';
import '../../submit_case/domain/tone_mode.dart';
import 'verdict.dart';
import 'verdict_status.dart';

class DisputeCase {
  const DisputeCase({
    required this.caseId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.relationshipType,
    required this.tone,
    required this.verdict,
    required this.safety,
    required this.containsPotentialPii,
    required this.shareCount,
    this.scenarioSanitized = '',
    this.sideASanitized,
    this.sideBSanitized,
    this.deletedAt,
    this.userRating,
  });

  final String caseId;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VerdictStatus status;
  final RelationshipType relationshipType;
  final ToneMode tone;
  final Verdict? verdict;
  final CaseSafety safety;
  final bool containsPotentialPii;
  final int shareCount;
  /// Sanitized scenario text (PII redacted server-side). Empty for older
  /// cases written before this field landed.
  final String scenarioSanitized;
  final String? sideASanitized;
  final String? sideBSanitized;
  final DateTime? deletedAt;
  final String? userRating;

  bool get canShare =>
      status == VerdictStatus.completed &&
      safety.safeForShare &&
      verdict?.shareCard != null &&
      !containsPotentialPii;

  factory DisputeCase.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snap) {
    final raw = snap.data() ?? const {};
    final input = raw['input'] as Map? ?? const {};
    final safety = raw['safety'] as Map? ?? const {};
    final share = raw['share'] as Map? ?? const {};
    final feedback = raw['feedback'] as Map? ?? const {};

    return DisputeCase(
      caseId: (raw['caseId'] as String?) ?? snap.id,
      userId: (raw['userId'] as String?) ?? '',
      createdAt: _toDate(raw['createdAt']),
      updatedAt: _toDate(raw['updatedAt']),
      status: VerdictStatus.fromWire(raw['status']),
      relationshipType: _relationshipFrom(raw['relationshipType']),
      tone: _toneFrom(raw['tone']),
      verdict: raw['verdict'] is Map
          ? Verdict.fromJson(raw['verdict'] as Map)
          : null,
      safety: CaseSafety.fromJson(safety),
      containsPotentialPii: input['containsPotentialPII'] as bool? ?? false,
      scenarioSanitized: (input['scenarioSanitized'] as String?) ?? '',
      sideASanitized: input['sideASanitized'] as String?,
      sideBSanitized: input['sideBSanitized'] as String?,
      shareCount: (share['shareCount'] as num?)?.toInt() ?? 0,
      deletedAt: _toDate(raw['deletedAt']),
      userRating: feedback['userRating'] as String?,
    );
  }

  /// A client-only, non-persisted case built from the inline verdict that
  /// `createVerdict` returns. Used for the "Save to history" = off path, where
  /// nothing is written to Firestore and re-reading by caseId would fail.
  ///
  /// `safeForShare` is derived from the presence of a share card: the server
  /// only emits a non-null shareCard when the case is fully share-safe (low
  /// risk, no PII, completed), so `canShare` stays correct without a stored
  /// safety document.
  factory DisputeCase.ephemeral({
    required VerdictResponse response,
    required String scenario,
    String? sideA,
    String? sideB,
    required RelationshipType relationshipType,
    required ToneMode tone,
  }) {
    final now = DateTime.now();
    final verdict = response.verdict;
    return DisputeCase(
      caseId: response.caseId,
      userId: '',
      createdAt: now,
      updatedAt: now,
      status: response.status,
      relationshipType: relationshipType,
      tone: tone,
      verdict: verdict,
      safety: CaseSafety(
        riskLevel: SafetyRiskLevel.low,
        safeForHumor: true,
        safeForShare: verdict?.shareCard != null,
        categories: const [],
      ),
      containsPotentialPii: false,
      shareCount: 0,
      scenarioSanitized: scenario,
      sideASanitized: sideA,
      sideBSanitized: sideB,
    );
  }

  static RelationshipType _relationshipFrom(Object? value) {
    final s = value?.toString();
    return RelationshipType.values.firstWhere(
      (r) => r.wireValue == s,
      orElse: () => RelationshipType.other,
    );
  }

  static ToneMode _toneFrom(Object? value) {
    final s = value?.toString();
    return ToneMode.values.firstWhere(
      (t) => t.wireValue == s,
      orElse: () => ToneMode.balancedReferee,
    );
  }

  static DateTime? _toDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

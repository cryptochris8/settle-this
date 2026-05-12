import 'verdict_status.dart';

class ShareCardData {
  const ShareCardData({
    required this.headline,
    required this.verdictOneLiner,
    required this.shortRuling,
  });

  final String headline;
  final String verdictOneLiner;
  final String shortRuling;

  static ShareCardData? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final headline = raw['headline'] as String?;
    final oneLiner = raw['verdictOneLiner'] as String?;
    final ruling = raw['shortRuling'] as String?;
    if (headline == null || oneLiner == null || ruling == null) return null;
    return ShareCardData(
      headline: headline,
      verdictOneLiner: oneLiner,
      shortRuling: ruling,
    );
  }

  Map<String, Object?> toJson() => {
        'headline': headline,
        'verdictOneLiner': verdictOneLiner,
        'shortRuling': shortRuling,
      };
}

class Verdict {
  const Verdict({
    required this.title,
    required this.summaryVerdict,
    required this.whoWasMoreRight,
    required this.confidence,
    required this.sideAGotRight,
    required this.sideBGotRight,
    required this.whatWasMissed,
    required this.practicalFix,
    required this.funnyFinalRuling,
    required this.textToSend,
    required this.shareCard,
    required this.safetyNote,
  });

  final String title;
  final String summaryVerdict;
  final WhoWasMoreRight whoWasMoreRight;
  final VerdictConfidence confidence;
  final String sideAGotRight;
  final String sideBGotRight;
  final String whatWasMissed;
  final String practicalFix;
  final String funnyFinalRuling;
  final String textToSend;
  final ShareCardData? shareCard;
  final String? safetyNote;

  factory Verdict.fromJson(Map<dynamic, dynamic> raw) {
    return Verdict(
      title: (raw['title'] as String?) ?? '',
      summaryVerdict: (raw['summaryVerdict'] as String?) ?? '',
      whoWasMoreRight: WhoWasMoreRight.fromWire(raw['whoWasMoreRight']),
      confidence: VerdictConfidence.fromWire(raw['confidence']),
      sideAGotRight: (raw['sideAGotRight'] as String?) ?? '',
      sideBGotRight: (raw['sideBGotRight'] as String?) ?? '',
      whatWasMissed: (raw['whatWasMissed'] as String?) ?? '',
      practicalFix: (raw['practicalFix'] as String?) ?? '',
      funnyFinalRuling: (raw['funnyFinalRuling'] as String?) ?? '',
      textToSend: (raw['textToSend'] as String?) ?? '',
      shareCard: ShareCardData.fromJson(raw['shareCard']),
      safetyNote: raw['safetyNote'] as String?,
    );
  }

  Map<String, Object?> toJson() => {
        'title': title,
        'summaryVerdict': summaryVerdict,
        'whoWasMoreRight': whoWasMoreRight.wireValue,
        'confidence': confidence.wireValue,
        'sideAGotRight': sideAGotRight,
        'sideBGotRight': sideBGotRight,
        'whatWasMissed': whatWasMissed,
        'practicalFix': practicalFix,
        'funnyFinalRuling': funnyFinalRuling,
        'textToSend': textToSend,
        'shareCard': shareCard?.toJson(),
        'safetyNote': safetyNote,
      };
}

class CaseSafety {
  const CaseSafety({
    required this.riskLevel,
    required this.safeForHumor,
    required this.safeForShare,
    required this.categories,
    this.blockedReason,
  });

  final SafetyRiskLevel riskLevel;
  final bool safeForHumor;
  final bool safeForShare;
  final List<String> categories;
  final String? blockedReason;

  factory CaseSafety.fromJson(Map<dynamic, dynamic> raw) {
    return CaseSafety(
      riskLevel: SafetyRiskLevel.fromWire(raw['riskLevel']),
      safeForHumor: raw['safeForHumor'] as bool? ?? false,
      safeForShare: raw['safeForShare'] as bool? ?? false,
      categories: (raw['categories'] as List?)?.cast<String>() ?? const [],
      blockedReason: raw['blockedReason'] as String?,
    );
  }
}

class VerdictResponse {
  const VerdictResponse({
    required this.caseId,
    required this.status,
    required this.verdict,
  });

  final String caseId;
  final VerdictStatus status;
  final Verdict? verdict;

  factory VerdictResponse.fromJson(Map<dynamic, dynamic> raw) {
    return VerdictResponse(
      caseId: (raw['caseId'] as String?) ?? '',
      status: VerdictStatus.fromWire(raw['status']),
      verdict: raw['verdict'] is Map
          ? Verdict.fromJson(raw['verdict'] as Map)
          : null,
    );
  }
}

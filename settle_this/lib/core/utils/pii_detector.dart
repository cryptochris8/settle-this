/// Lightweight client-side PII heuristic. The authoritative check still runs
/// in the Cloud Function (`13_BACKEND_FUNCTIONS_SPEC.md`) — this exists only to
/// surface a friendly warning before the user submits.
class PiiDetector {
  PiiDetector._();

  static final RegExp _email = RegExp(
    r'[\w.+-]+@[\w-]+\.[\w.-]+',
  );

  static final RegExp _phone = RegExp(
    r'(?:\+?\d[\s().-]?){8,}\d',
  );

  // Heuristic: digit-prefixed line that looks like a street address.
  static final RegExp _streetAddress = RegExp(
    r'\b\d{1,5}\s+[A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)*\s+'
    r'(?:Street|St|Avenue|Ave|Road|Rd|Drive|Dr|Lane|Ln|Boulevard|Blvd|Way|Court|Ct|Place|Pl)\b',
    caseSensitive: false,
  );

  static final RegExp _socialHandle = RegExp(r'(?:^|\s)@\w{2,}');

  static final RegExp _url = RegExp(
    r'\bhttps?://\S+\b',
    caseSensitive: false,
  );

  static PiiFindings findings(String text) {
    if (text.isEmpty) return const PiiFindings();
    return PiiFindings(
      hasEmail: _email.hasMatch(text),
      hasPhone: _phone.hasMatch(text),
      hasStreetAddress: _streetAddress.hasMatch(text),
      hasSocialHandle: _socialHandle.hasMatch(text),
      hasUrl: _url.hasMatch(text),
    );
  }
}

class PiiFindings {
  const PiiFindings({
    this.hasEmail = false,
    this.hasPhone = false,
    this.hasStreetAddress = false,
    this.hasSocialHandle = false,
    this.hasUrl = false,
  });

  final bool hasEmail;
  final bool hasPhone;
  final bool hasStreetAddress;
  final bool hasSocialHandle;
  final bool hasUrl;

  bool get any =>
      hasEmail || hasPhone || hasStreetAddress || hasSocialHandle || hasUrl;

  List<String> get labels => [
        if (hasEmail) 'email',
        if (hasPhone) 'phone',
        if (hasStreetAddress) 'address',
        if (hasSocialHandle) 'social handle',
        if (hasUrl) 'link',
      ];
}

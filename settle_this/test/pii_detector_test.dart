import 'package:flutter_test/flutter_test.dart';
import 'package:settle_this/core/utils/pii_detector.dart';

void main() {
  group('PiiDetector', () {
    test('clean text has no findings', () {
      final f = PiiDetector.findings(
        'My partner says I loaded the dishwasher wrong. Cups can go anywhere.',
      );
      expect(f.any, isFalse);
      expect(f.labels, isEmpty);
    });

    test('detects email', () {
      final f = PiiDetector.findings('Email me at sam.smith@example.com.');
      expect(f.hasEmail, isTrue);
    });

    test('detects phone number', () {
      final f = PiiDetector.findings('Call me at 555-123-4567 tonight.');
      expect(f.hasPhone, isTrue);
    });

    test('detects street address', () {
      final f = PiiDetector.findings(
        'They live at 123 Maple Street and never clean.',
      );
      expect(f.hasStreetAddress, isTrue);
    });

    test('detects social handle', () {
      final f = PiiDetector.findings('@notjohnsmith was rude in the chat.');
      expect(f.hasSocialHandle, isTrue);
    });

    test('detects URL', () {
      final f = PiiDetector.findings(
        'They posted at https://reddit.com/r/AmITheAhole.',
      );
      expect(f.hasUrl, isTrue);
    });
  });
}

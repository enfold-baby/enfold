import 'package:enfold/features/learn/models/learn_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enfold/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

void main() {
  final l10n = lookupAppL10n(const Locale('en'));
  test('a pending placeholder never reads as reviewed', () {
    const reviewer = LearnReviewer(
      name: 'Pending physician review',
      credentials: '',
      specialty: 'Neonatology / Pediatrics',
      reviewedAt: '2026-07-01',
    );
    expect(reviewer.isReviewed, isFalse);
    expect(reviewer.displayLine(l10n), 'General educational information, not medical advice');
    expect(reviewer.displayLine(l10n), isNot(contains('Reviewed by')));
  });

  test('a named clinician with credentials shows the review line', () {
    const reviewer = LearnReviewer(
      name: 'Dr. Ana Pop',
      credentials: 'MD',
      specialty: 'Pediatrics',
      reviewedAt: '2026-10-01',
    );
    expect(reviewer.isReviewed, isTrue);
    expect(reviewer.displayLine(l10n), 'Reviewed by Dr. Ana Pop, MD · Pediatrics · 2026-10-01');
  });
}

import 'package:bloomdue_baby/features/learn/models/learn_card.dart';
import 'package:bloomdue_baby/features/learn/utils/learn_card_filter.dart';
import 'package:flutter_test/flutter_test.dart';

LearnCard _card({
  required String id,
  required String title,
  String summary = '',
  bool triage = false,
}) {
  return LearnCard(
    id: id,
    title: title,
    summary: summary,
    whatsNormal: '',
    watchFor: const [],
    callDoctorIf: const [],
    reviewer: const LearnReviewer(
      name: 'Pending physician review',
      credentials: '',
      specialty: 'Neonatology / Pediatrics',
      reviewedAt: '2026-07-01',
    ),
    disclaimer: 'Educational only.',
    triage: triage
        ? const LearnTriage(
            intro: 'Test',
            startId: 'start',
            outcomes: {},
            nodes: {},
          )
        : null,
  );
}

void main() {
  final cards = [
    _card(
      id: 'fever-newborn',
      title: 'Fever in a newborn',
      summary: 'Temperature guidance',
      triage: true,
    ),
    _card(
      id: 'wet-diapers-day-1-7',
      title: 'How many wet diapers',
      summary: 'Day-by-day counts',
    ),
  ];

  test('empty query returns all cards', () {
    expect(filterLearnCards(cards, ''), cards);
    expect(filterLearnCards(cards, '   '), cards);
  });

  test('matches title and summary case-insensitively', () {
    expect(filterLearnCards(cards, 'fever'), hasLength(1));
    expect(filterLearnCards(cards, 'WET'), hasLength(1));
    expect(filterLearnCards(cards, 'day-by-day'), hasLength(1));
  });

  test('matches card id with hyphens as spaces', () {
    expect(filterLearnCards(cards, 'wet diapers'), hasLength(1));
  });

  test('matches triage keyword for triage cards', () {
    expect(filterLearnCards(cards, 'triage'), hasLength(1));
  });

  test('returns empty list when nothing matches', () {
    expect(filterLearnCards(cards, 'vaccine schedule'), isEmpty);
  });
}
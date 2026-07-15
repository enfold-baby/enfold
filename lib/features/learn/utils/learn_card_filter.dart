import '../models/learn_card.dart';

bool learnCardMatchesQuery(LearnCard card, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;

  final haystack = [
    card.title,
    card.summary,
    card.id.replaceAll('-', ' '),
    if (card.triage != null) 'triage',
  ].join(' ').toLowerCase();

  return haystack.contains(q);
}

List<LearnCard> filterLearnCards(List<LearnCard> cards, String query) {
  return [
    for (final card in cards)
      if (learnCardMatchesQuery(card, query)) card,
  ];
}
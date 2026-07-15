import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/learn_card.dart';

class LearnContentService {
  const LearnContentService();

  static const _manifestPath = 'content/manifest.json';
  static const _cardDir = 'content/cards';

  Future<List<String>> loadCardIds() async {
    final raw = await rootBundle.loadString(_manifestPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['cards'] as List<dynamic>).cast<String>();
  }

  Future<List<LearnCard>> loadAllCards() async {
    final ids = await loadCardIds();
    final cards = await Future.wait(ids.map(loadCard));
    return cards;
  }

  Future<LearnCard> loadCard(String id) async {
    final raw = await rootBundle.loadString('$_cardDir/$id.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final card = LearnCard.fromJson(json);
    if (card.id != id) {
      throw FormatException('Card id mismatch: expected $id, got ${card.id}');
    }
    return card;
  }
}
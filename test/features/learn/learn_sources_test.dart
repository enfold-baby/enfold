import 'dart:convert';
import 'dart:io';

import 'package:enfold/features/learn/models/learn_card.dart';
import 'package:flutter_test/flutter_test.dart';

/// App Review (guideline 1.4.1) requires citations on medical content, so
/// every shipped card must carry at least one https source with a title.
void main() {
  test('every learn card ships with citations', () {
    final manifest = jsonDecode(File('content/manifest.json').readAsStringSync())
        as Map<String, dynamic>;
    final ids = (manifest['cards'] as List<dynamic>).cast<String>();
    expect(ids, isNotEmpty);
    for (final id in ids) {
      final json = jsonDecode(File('content/cards/$id.json').readAsStringSync())
          as Map<String, dynamic>;
      final card = LearnCard.fromJson(json);
      expect(card.sources, isNotEmpty, reason: '$id has no sources');
      for (final source in card.sources) {
        expect(source.title.trim(), isNotEmpty, reason: '$id source without title');
        expect(source.url, startsWith('https://'), reason: '$id source ${source.url}');
      }
    }
  });

  test('cards without a sources key still parse', () {
    final card = LearnCard.fromJson({
      'id': 'x',
      'title': 't',
      'summary': 's',
      'whatsNormal': 'n',
      'watchFor': <String>[],
      'callDoctorIf': <String>[],
      'reviewer': {
        'name': 'Pending physician review',
        'credentials': '',
        'specialty': 'Pediatrics',
        'reviewedAt': '2026-07-01',
      },
      'disclaimer': 'd',
    });
    expect(card.sources, isEmpty);
  });
}

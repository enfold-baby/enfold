import 'package:bloomdue_baby/features/learn/models/learn_card.dart';
import 'package:bloomdue_baby/features/learn/services/learn_content_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const service = LearnContentService();

  test('loads manifest with twenty-five beta cards', () async {
    final ids = await service.loadCardIds();
    expect(ids, hasLength(25));
    expect(ids, contains('fever-newborn'));
    expect(ids, contains('dehydration-signs'));
    expect(ids, contains('vitamin-d-supplementation'));
  });

  test('parses fever card with triage', () async {
    final card = await service.loadCard('fever-newborn');
    expect(card.title, contains('Fever'));
    expect(card.triage, isNotNull);
    expect(card.triage!.nodes, contains('temp'));
    expect(card.triage!.outcomes[TriageLevel.red], isNotNull);
  });

  test('parses wet diapers card without triage', () async {
    final card = await service.loadCard('wet-diapers-day-1-7');
    expect(card.watchFor, isNotEmpty);
    expect(card.triage, isNull);
  });

  test('parses cluster feeding card with pending review', () async {
    final card = await service.loadCard('cluster-feeding');
    expect(card.title, contains('Cluster feeding'));
    expect(card.reviewer.name, 'Pending physician review');
    expect(card.callDoctorIf, isNotEmpty);
    expect(card.triage, isNull);
  });

  test('parses ER guide card with triage flow', () async {
    final card = await service.loadCard('er-vs-call-pediatrician');
    expect(card.title, contains('ER'));
    expect(card.triage, isNotNull);
    expect(card.triage!.startId, 'breathing');
    expect(card.triage!.nodes, contains('dehydration'));
    expect(card.triage!.outcomes[TriageLevel.red], isNotNull);
  });

  test('parses dehydration card with pending review', () async {
    final card = await service.loadCard('dehydration-signs');
    expect(card.title, contains('Dehydration'));
    expect(card.reviewer.name, 'Pending physician review');
    expect(card.watchFor, isNotEmpty);
    expect(card.triage, isNull);
  });
}
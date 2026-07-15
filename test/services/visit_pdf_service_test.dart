import 'package:bloomdue_baby/features/today/models/log_type.dart';
import 'package:bloomdue_baby/services/database/app_database.dart';
import 'package:bloomdue_baby/services/export/visit_pdf_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VisitPdfService', () {
    const service = VisitPdfService();

    test('buildSevenDaySummary returns non-empty PDF bytes', () async {
      final generatedAt = DateTime(2026, 7, 1, 12);
      final events = [
        CareEvent(
          id: '1',
          babyId: 'baby',
          type: LogType.feed.apiType,
          occurredAt: generatedAt.subtract(const Duration(hours: 2)),
          detailsJson: '{}',
          note: '',
          clientUpdatedAt: generatedAt,
          pendingSync: true,
        ),
        CareEvent(
          id: '2',
          babyId: 'baby',
          type: LogType.diaper.apiType,
          occurredAt: generatedAt.subtract(const Duration(hours: 1)),
          detailsJson: '{"wet":true,"dirty":true}',
          note: 'after feeding',
          clientUpdatedAt: generatedAt,
          pendingSync: true,
        ),
      ];

      final bytes = await service.buildSevenDaySummary(
        babyName: 'Baby',
        events: events,
        generatedAt: generatedAt,
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('empty events still produces valid PDF', () async {
      final bytes = await service.buildSevenDaySummary(
        babyName: 'Baby',
        events: const [],
        generatedAt: DateTime(2026, 7, 1),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/datetime/clock_format.dart';
import '../../features/logs/providers/logs_providers.dart';
import '../../features/today/models/care_log_details.dart';
import '../../l10n/generated/app_localizations.dart';
import '../database/app_database.dart';

class VisitPdfService {
  const VisitPdfService();

  static const brandName = 'Enfold';

  /// The PDF follows the app language, so [l10n] carries every label on it.
  Future<Uint8List> buildSevenDaySummary({
    required AppL10n l10n,
    required String babyName,
    required List<CareEvent> events,
    required DateTime generatedAt,
    int days = 7,
    bool useImperialUnits = false,
    bool use24HourTime = false,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = ClockFormat.time(use24Hour: use24HourTime);
    final rangeEnd = _dateOnly(generatedAt).add(const Duration(days: 1));
    final rangeStart = rangeEnd.subtract(Duration(days: days));

    final dailyCounts = _dailyCounts(events, rangeStart, rangeEnd, days);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            brandName,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            l10n.pdfTitle,
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            l10n.pdfTagline,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 20),
          pw.Text(l10n.pdfChild(babyName)),
          pw.Text(
            l10n.pdfPeriod(
              dateFormat.format(rangeStart),
              dateFormat.format(rangeEnd.subtract(const Duration(days: 1))),
            ),
          ),
          pw.Text(l10n.pdfGenerated(dateFormat.format(generatedAt))),
          pw.SizedBox(height: 16),
          pw.Text(
            l10n.pdfDailyTotals,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: [
              l10n.pdfColumnDate,
              l10n.pdfColumnFeeds,
              l10n.pdfColumnDiapers,
              l10n.pdfColumnSleep,
            ],
            data: [
              for (final row in dailyCounts)
                [
                  dateFormat.format(row.date),
                  '${row.feeds}',
                  '${row.diapers}',
                  '${row.sleeps}',
                ],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            l10n.pdfEventLog,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (events.isEmpty)
            pw.Text(l10n.pdfNoEvents)
          else
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (final event in events)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '${dateFormat.format(event.occurredAt)} ${timeFormat.format(event.occurredAt)} - ${_eventLine(event, l10n, useImperial: useImperialUnits)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),
          pw.SizedBox(height: 24),
          pw.Text(
            l10n.pdfDisclaimer,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  String _eventLine(
    CareEvent event,
    AppL10n l10n, {
    required bool useImperial,
  }) {
    final details = CareLogDetails.fromJsonString(event.detailsJson);
    final type = resolveLogType(event.type, details);
    final label = type?.label(l10n) ?? event.type;
    final summary =
        type == null ? '' : details.summarize(l10n, type, useImperial: useImperial);
    final parts = <String>[label];
    if (summary.isNotEmpty) parts.add(summary);
    if (event.note.isNotEmpty) parts.add(event.note);
    return parts.join(' - ');
  }

  List<_DayCounts> _dailyCounts(
    List<CareEvent> events,
    DateTime rangeStart,
    DateTime rangeEnd,
    int days,
  ) {
    final buckets = <DateTime, _DayCounts>{};
    for (var i = 0; i < days; i++) {
      final day = rangeStart.add(Duration(days: i));
      buckets[day] = _DayCounts(date: day);
    }

    for (final event in events) {
      final day = _dateOnly(event.occurredAt);
      if (day.isBefore(rangeStart) || !day.isBefore(rangeEnd)) continue;
      final bucket = buckets[day];
      if (bucket == null) continue;
      switch (event.type) {
        case 'feeding':
          bucket.feeds++;
        case 'diaper':
          bucket.diapers++;
        case 'sleep':
          bucket.sleeps++;
      }
    }

    return buckets.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _DayCounts {
  _DayCounts({required this.date});

  final DateTime date;
  int feeds = 0;
  int diapers = 0;
  int sleeps = 0;
}
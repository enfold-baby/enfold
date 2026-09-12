import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/database/database_provider.dart';
import '../../../services/export/visit_pdf_service.dart';
import '../providers/time_format_providers.dart';
import '../providers/units_providers.dart';

final visitPdfServiceProvider = Provider<VisitPdfService>(
  (ref) => const VisitPdfService(),
);

Future<void> shareVisitPdf(Uint8List bytes) {
  return Printing.sharePdf(
    bytes: bytes,
    filename: 'enfold-7day-summary.pdf',
  );
}

/// Explains the visit PDF before opening the system share sheet.
Future<bool> confirmVisitPdfExport(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        key: const Key('export_pdf_confirm_dialog'),
        title: const Text('Share a 7-day visit PDF?'),
        content: const Text(
          'Creates a one-page summary of feeds, diapers, sleep, and other care '
          'from the last 7 days, handy for a partner or a pediatrician visit.',
        ),
        actions: [
          TextButton(
            key: const Key('export_pdf_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('export_pdf_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Create PDF'),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

class ExportSection extends ConsumerStatefulWidget {
  const ExportSection({super.key});

  @override
  ConsumerState<ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends ConsumerState<ExportSection> {
  bool _busy = false;
  String? _status;

  Future<void> _exportPdf() async {
    final confirmed = await confirmVisitPdfExport(context);
    if (!confirmed || !mounted) return;
    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final babyId = await db.careLogDao.ensureDefaultBaby();
      final baby = await db.careLogDao.getBaby(babyId);
      final events = await db.careLogDao.getLogsForLastDays(babyId, 7);
      final useImperial = await ref.read(useImperialUnitsProvider.future);
      final use24Hour = await ref.read(use24HourTimeProvider.future);
      final pdfService = ref.read(visitPdfServiceProvider);
      final bytes = await pdfService.buildSevenDaySummary(
        babyName: baby?.name ?? 'Baby',
        events: events,
        generatedAt: DateTime.now(),
        useImperialUnits: useImperial,
        use24HourTime: use24Hour,
      );

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'enfold-7day-summary.pdf',
      );

      if (!mounted) return;
      setState(() => _status = 'PDF ready to share or print.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Could not create PDF. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Visit export',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '7-day feed, diaper, and sleep summary for your pediatrician.',
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                key: const Key('export_7day_pdf'),
                onPressed: _busy ? null : _exportPdf,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_busy ? 'Creating PDF…' : 'Export 7-day PDF'),
              ),
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(
                  _status!,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.mutedText(brightness),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
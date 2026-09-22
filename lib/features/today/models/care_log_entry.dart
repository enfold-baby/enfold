import 'package:intl/intl.dart';

import '../../../core/datetime/clock_format.dart';
import 'care_log_details.dart';
import 'log_type.dart';
import '../../../l10n/generated/app_localizations.dart';

class CareLogEntry {
  const CareLogEntry({
    required this.id,
    required this.type,
    required this.loggedAt,
    required this.pendingSync,
    this.details = CareLogDetails.empty,
    this.note = '',
    this.deletedAt,
    this.loggedByUserId,
    this.loggedByDisplayName,
  });

  final String id;
  final LogType type;
  final DateTime loggedAt;
  final bool pendingSync;
  final CareLogDetails details;
  final String note;
  final DateTime? deletedAt;
  final String? loggedByUserId;
  final String? loggedByDisplayName;

  String? loggedByLabel(
    AppL10n l10n, {
    String? currentUserId,
    bool showAttribution = true,
  }) {
    if (!showAttribution || loggedByUserId == null) return null;
    if (currentUserId != null && loggedByUserId == currentUserId) {
      return l10n.attributionYou;
    }
    final name = loggedByDisplayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return l10n.attributionPartner;
  }

  /// Primary time shown on log tiles.
  ///
  /// Completed sleep uses start–end so a nap logged at wake and one
  /// saved as a range look the same. In-progress sleep shows the start.
  String listTimeLabel({String locale = 'en_US', bool use24Hour = false}) {
    final dateFmt = DateFormat('MMM d', locale);
    final timeFmt = ClockFormat.time(use24Hour: use24Hour, locale: locale);
    if (type == LogType.sleep) {
      final start = details.sleepStart ?? loggedAt;
      if (details.sleepInProgress == true) {
        return '${dateFmt.format(start)} · ${timeFmt.format(start)}';
      }
      final end = details.sleepEnd;
      if (end != null) {
        if (_sameCalendarDay(start, end)) {
          return '${dateFmt.format(start)} · ${timeFmt.format(start)}–${timeFmt.format(end)}';
        }
        return '${dateFmt.format(start)}, ${timeFmt.format(start)} – ${dateFmt.format(end)}, ${timeFmt.format(end)}';
      }
    }
    return '${dateFmt.format(loggedAt)} · ${timeFmt.format(loggedAt)}';
  }

  static bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String? detailSummary(AppL10n l10n, {bool useImperial = false}) {
    final summary = details.summarize(l10n, type, useImperial: useImperial);
    if (summary.isEmpty && note.isEmpty) return null;
    if (summary.isEmpty) return note;
    if (note.isEmpty) return summary;
    return '$summary · $note';
  }
}
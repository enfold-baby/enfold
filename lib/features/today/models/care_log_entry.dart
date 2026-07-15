import 'care_log_details.dart';
import 'log_type.dart';

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

  String? loggedByLabel({String? currentUserId, bool showAttribution = true}) {
    if (!showAttribution || loggedByUserId == null) return null;
    if (currentUserId != null && loggedByUserId == currentUserId) {
      return 'you';
    }
    final name = loggedByDisplayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Partner';
  }

  String? detailSummary({bool useImperial = false}) {
    final summary = details.summarize(type, useImperial: useImperial);
    if (summary.isEmpty && note.isEmpty) return null;
    if (summary.isEmpty) return note;
    if (note.isEmpty) return summary;
    return '$summary · $note';
  }
}
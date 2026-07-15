import '../../today/models/care_log_entry.dart';

bool matchesFeedFilters(
  CareLogEntry entry, {
  String? feedMode,
  String? breastDelivery,
}) {
  if (feedMode != null) {
    final mode = entry.details.feedMode == 'bottle'
        ? 'formula'
        : entry.details.feedMode;
    if (mode != feedMode) return false;
  }
  if (breastDelivery != null &&
      entry.details.breastDelivery != breastDelivery) {
    return false;
  }
  return true;
}

bool matchesDiaperFilters(
  CareLogEntry entry, {
  bool? wet,
  bool? dirty,
  String? stoolConsistency,
}) {
  if (wet != null && entry.details.wet != wet) return false;
  if (dirty != null && entry.details.dirty != dirty) return false;
  if (stoolConsistency != null &&
      entry.details.stoolConsistency != stoolConsistency) {
    return false;
  }
  return true;
}

bool matchesSleepFilters(
  CareLogEntry entry, {
  bool? inProgress,
}) {
  if (inProgress == null) return true;
  final sleeping = entry.details.sleepInProgress == true;
  return inProgress ? sleeping : !sleeping;
}
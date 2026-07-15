import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';
import '../../logs/models/log_period_filter.dart';
import '../../logs/providers/logs_providers.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';
import '../../today/providers/today_log_provider.dart';

bool matchesMedicationFilters(
  CareLogEntry entry, {
  String? category,
}) {
  if (category == null) return true;
  return entry.details.medicationCategory == category;
}

final medicationLogPeriodProvider = StateProvider<LogPeriodFilter>(
  (ref) => const LogPeriodFilter(),
);

final medicationCategoryFilterProvider = StateProvider<String?>((ref) => null);

final medicationLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  final period = ref.watch(medicationLogPeriodProvider);
  final category = ref.watch(medicationCategoryFilterProvider);
  final range = period.resolveRange(_todayEnd);

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: range.start,
          end: range.end,
          type: LogType.medication.apiType,
        )
        .map((rows) {
          final entries = mapCareEvents(rows);
          return [
            for (final entry in entries)
              if (matchesMedicationFilters(entry, category: category)) entry,
          ];
        }),
  );
});

final todayMedicationLogsProvider = Provider<AsyncValue<List<CareLogEntry>>>(
  (ref) {
    final logsAsync = ref.watch(todayLogProvider);
    return logsAsync.whenData(
      (logs) => [
        for (final entry in logs)
          if (entry.type == LogType.medication) entry,
      ],
    );
  },
);

DateTime _todayEnd() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return start.add(const Duration(days: 1));
}
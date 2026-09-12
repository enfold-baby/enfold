import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';
import '../../logs/models/log_period_filter.dart';
import '../../logs/providers/logs_providers.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';
import '../../today/providers/today_log_provider.dart';
import '../../../core/datetime/calendar_day.dart';

bool matchesPumpingFilters(
  CareLogEntry entry, {
  String? side,
}) {
  if (side == null) return true;
  return entry.details.breastSide == side;
}

final pumpingLogPeriodProvider = StateProvider<LogPeriodFilter>(
  (ref) => const LogPeriodFilter(),
);

final pumpingSideFilterProvider = StateProvider<String?>((ref) => null);

final pumpingLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  final period = ref.watch(pumpingLogPeriodProvider);
  final side = ref.watch(pumpingSideFilterProvider);
  final day = ref.watch(currentCalendarDayProvider);
  final range = period.resolveRange(() => calendarDayEnd(day));

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: range.start,
          end: range.end,
          type: LogType.pumping.apiType,
        )
        .map((rows) {
          final entries = mapCareEvents(rows);
          return [
            for (final entry in entries)
              if (matchesPumpingFilters(entry, side: side)) entry,
          ];
        }),
  );
});

final todayPumpingLogsProvider = Provider<AsyncValue<List<CareLogEntry>>>(
  (ref) {
    final logsAsync = ref.watch(todayLogProvider);
    return logsAsync.whenData(
      (logs) => [
        for (final entry in logs)
          if (entry.type == LogType.pumping) entry,
      ],
    );
  },
);


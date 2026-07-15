import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';
import '../../logs/models/log_period_filter.dart';
import '../../logs/providers/logs_providers.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';
import '../../today/providers/today_log_provider.dart';

final tummyLogPeriodProvider = StateProvider<LogPeriodFilter>(
  (ref) => const LogPeriodFilter(),
);

final tummyLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  final period = ref.watch(tummyLogPeriodProvider);
  final range = period.resolveRange(_todayEnd);

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: range.start,
          end: range.end,
          type: LogType.tummyTime.apiType,
        )
        .map((rows) {
          return [
            for (final entry in mapCareEvents(rows))
              if (entry.type == LogType.tummyTime) entry,
          ];
        }),
  );
});

final todayTummyLogsProvider = Provider<AsyncValue<List<CareLogEntry>>>(
  (ref) {
    final logsAsync = ref.watch(todayLogProvider);
    return logsAsync.whenData(
      (logs) => [
        for (final entry in logs)
          if (entry.type == LogType.tummyTime) entry,
      ],
    );
  },
);

int tummyMinutesToday(List<CareLogEntry> logs) {
  var total = 0;
  for (final entry in logs) {
    total += entry.details.durationMinutes ?? 0;
  }
  return total;
}

String formatTummyMinutes(int minutes) {
  if (minutes <= 0) return '0m';
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (remainder == 0) return '${hours}h';
  return '${hours}h ${remainder}m';
}

DateTime _todayEnd() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return start.add(const Duration(days: 1));
}
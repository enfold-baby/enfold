import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/app_database.dart';
import '../../../services/database/database_provider.dart';
import '../../today/models/care_log_details.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';
import '../models/log_detail_filters.dart';
import '../models/log_period_filter.dart';
import '../../../core/datetime/calendar_day.dart';

LogType? resolveLogType(String apiType, CareLogDetails details) {
  if (apiType == 'note' &&
      details.activity == CareLogDetails.tummyTimeActivity) {
    return LogType.tummyTime;
  }
  return LogType.fromApiType(apiType);
}

List<CareLogEntry> mapCareEvents(List<CareEvent> rows) {
  return [
    for (final row in rows)
      if (resolveLogType(
        row.type,
        CareLogDetails.fromJsonString(row.detailsJson),
      )
          case final type?)
        CareLogEntry(
          id: row.id,
          type: type,
          loggedAt: row.occurredAt,
          pendingSync: row.pendingSync,
          details: CareLogDetails.fromJsonString(row.detailsJson),
          note: row.note,
          deletedAt: row.deletedAt,
          loggedByUserId: row.loggedByUserId,
          loggedByDisplayName: row.loggedByDisplayName,
        ),
  ];
}

const hubLogsPageSize = 10;

final hubLogTypeFilterProvider = StateProvider<Set<LogType>>((ref) => {});

final hubLogPeriodProvider = StateProvider<LogPeriodFilter>(
  (ref) => const LogPeriodFilter(),
);

final hubLogsVisibleCountProvider = StateProvider<int>(
  (ref) => hubLogsPageSize,
);

final deletedLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao.watchSoftDeletedLogs(babyId).map(mapCareEvents),
  );
});

final hubLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  final typeFilter = ref.watch(hubLogTypeFilterProvider);
  final period = ref.watch(hubLogPeriodProvider);
  final day = ref.watch(currentCalendarDayProvider);
  final range = period.resolveRange(() => calendarDayEnd(day));

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: range.start,
          end: range.end,
        )
        .map((rows) {
          final entries = mapCareEvents(rows);
          if (typeFilter.isEmpty) return entries;
          return [
            for (final entry in entries)
              if (typeFilter.contains(entry.type)) entry,
          ];
        }),
  );
});

final feedLogPeriodProvider = StateProvider<LogPeriodFilter>(
  (ref) => const LogPeriodFilter(),
);

final feedModeFilterProvider = StateProvider<String?>((ref) => null);
final feedDeliveryFilterProvider = StateProvider<String?>((ref) => null);

final feedLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  final period = ref.watch(feedLogPeriodProvider);
  final feedMode = ref.watch(feedModeFilterProvider);
  final breastDelivery = ref.watch(feedDeliveryFilterProvider);
  final day = ref.watch(currentCalendarDayProvider);
  final range = period.resolveRange(() => calendarDayEnd(day));

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: range.start,
          end: range.end,
          type: LogType.feed.apiType,
        )
        .map((rows) {
          final entries = mapCareEvents(rows);
          return [
            for (final entry in entries)
              if (matchesFeedFilters(
                entry,
                feedMode: feedMode,
                breastDelivery: feedMode == 'breast' ? breastDelivery : null,
              ))
                entry,
          ];
        }),
  );
});

final diaperLogPeriodProvider = StateProvider<LogPeriodFilter>(
  (ref) => const LogPeriodFilter(),
);

final diaperWetFilterProvider = StateProvider<bool?>((ref) => null);
final diaperDirtyFilterProvider = StateProvider<bool?>((ref) => null);
final diaperConsistencyFilterProvider = StateProvider<String?>((ref) => null);

final diaperLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  final period = ref.watch(diaperLogPeriodProvider);
  final wet = ref.watch(diaperWetFilterProvider);
  final dirty = ref.watch(diaperDirtyFilterProvider);
  final consistency = ref.watch(diaperConsistencyFilterProvider);
  final day = ref.watch(currentCalendarDayProvider);
  final range = period.resolveRange(() => calendarDayEnd(day));

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: range.start,
          end: range.end,
          type: LogType.diaper.apiType,
        )
        .map((rows) {
          final entries = mapCareEvents(rows);
          return [
            for (final entry in entries)
              if (matchesDiaperFilters(
                entry,
                wet: wet,
                dirty: dirty,
                stoolConsistency: consistency,
              ))
                entry,
          ];
        }),
  );
});

final sleepLogPeriodProvider = StateProvider<LogPeriodFilter>(
  (ref) => const LogPeriodFilter(),
);

final sleepStatusFilterProvider = StateProvider<bool?>((ref) => null);

final sleepLogsProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  final period = ref.watch(sleepLogPeriodProvider);
  final inProgress = ref.watch(sleepStatusFilterProvider);
  final day = ref.watch(currentCalendarDayProvider);
  final range = period.resolveRange(() => calendarDayEnd(day));

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: range.start,
          end: range.end,
          type: LogType.sleep.apiType,
        )
        .map((rows) {
          final entries = mapCareEvents(rows);
          return [
            for (final entry in entries)
              if (matchesSleepFilters(entry, inProgress: inProgress)) entry,
          ];
        }),
  );
});

final openSleepProvider = StreamProvider<CareLogEntry?>((ref) {
  final db = ref.read(databaseProvider);
  final end = calendarDayEnd(ref.watch(currentCalendarDayProvider));
  final start = end.subtract(const Duration(days: 90));

  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao
        .watchLogsInRange(
          babyId: babyId,
          start: start,
          end: end,
          type: LogType.sleep.apiType,
        )
        .map((rows) {
          for (final entry in mapCareEvents(rows)) {
            if (entry.details.sleepInProgress == true) return entry;
          }
          return null;
        }),
  );
});


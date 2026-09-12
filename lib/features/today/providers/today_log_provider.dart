import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/display_name.dart';
import '../../../services/auth/auth_providers.dart';
import '../../../services/database/database_provider.dart';
import '../../../services/sync/sync_providers.dart';
import '../../logs/providers/logs_providers.dart' show mapCareEvents;
import '../models/care_log_details.dart';
import '../models/care_log_entry.dart';
import '../models/log_type.dart';
import '../../../core/datetime/calendar_day.dart';

final todayLogProvider = StreamProvider<List<CareLogEntry>>((ref) {
  final db = ref.read(databaseProvider);
  // Re-subscribe after midnight so "today" moves with the calendar.
  ref.watch(currentCalendarDayProvider);
  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.careLogDao.watchTodayLogs(babyId).map(mapCareEvents),
  );
});

final careLogActionsProvider = Provider<CareLogActions>((ref) {
  return CareLogActions(ref);
});

class CareLogActions {
  CareLogActions(this._ref);

  final Ref _ref;

  Future<void> quickLog(LogType type) async {
    await saveLog(
      type: type,
      occurredAt: DateTime.now(),
      details: CareLogDetails.empty,
    );
  }

  Future<void> detailedLog(
    LogType type, {
    required CareLogDetails details,
    String note = '',
    DateTime? occurredAt,
  }) async {
    await saveLog(
      type: type,
      occurredAt: occurredAt ?? DateTime.now(),
      details: details,
      note: note,
    );
  }

  ({String? userId, String? displayName}) _authorStamp() {
    final session = _ref.read(authSessionProvider).valueOrNull;
    if (session == null) return (userId: null, displayName: null);
    return (
      userId: session.user.id,
      displayName: authorLabelForUser(session.user),
    );
  }

  Future<void> saveLog({
    required LogType type,
    required DateTime occurredAt,
    required CareLogDetails details,
    String note = '',
  }) async {
    final db = _ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final author = _authorStamp();
    await db.careLogDao.insertLog(
      babyId: babyId,
      type: type.apiType,
      occurredAt: occurredAt,
      detailsJson: details.toJsonString(),
      note: note,
      loggedByUserId: author.userId,
      loggedByDisplayName: author.displayName,
    );
    await _ref.read(syncActionsProvider).syncIfSignedIn();
  }

  Future<String> startSleepNow() => startSleepAt(DateTime.now());

  /// Open a sleep that started in the past (or just now) and is still going.
  Future<String> startSleepAt(DateTime start, {String note = ''}) async {
    final db = _ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final began = start.isAfter(DateTime.now()) ? DateTime.now() : start;
    final details = CareLogDetails(
      sleepStart: began,
      sleepInProgress: true,
    );
    final author = _authorStamp();
    final id = await db.careLogDao.insertLog(
      babyId: babyId,
      type: LogType.sleep.apiType,
      occurredAt: began,
      detailsJson: details.toJsonString(),
      note: note,
      loggedByUserId: author.userId,
      loggedByDisplayName: author.displayName,
    );
    await _ref.read(syncActionsProvider).syncIfSignedIn();
    return id;
  }

  Future<void> wakeFromSleep(String logId) async {
    final db = _ref.read(databaseProvider);
    final row = await db.careLogDao.getLog(logId);
    if (row == null) return;

    final details = CareLogDetails.fromJsonString(row.detailsJson);
    final end = DateTime.now();
    final start = details.sleepStart ?? row.occurredAt;
    final updated = CareLogDetails(
      sleepStart: start,
      sleepEnd: end,
      sleepInProgress: false,
      durationMinutes: end.difference(start).inMinutes,
    );
    final author = _authorStamp();
    await db.careLogDao.updateLog(
      logId: logId,
      occurredAt: end,
      detailsJson: updated.toJsonString(),
      loggedByUserId: author.userId,
      loggedByDisplayName: author.displayName,
    );
    await _ref.read(syncActionsProvider).syncIfSignedIn();
  }

  Future<void> updateLogEntry({
    required String logId,
    required LogType type,
    required DateTime occurredAt,
    required CareLogDetails details,
    String note = '',
  }) async {
    final db = _ref.read(databaseProvider);
    final author = _authorStamp();
    await db.careLogDao.updateLog(
      logId: logId,
      type: type.apiType,
      occurredAt: occurredAt,
      detailsJson: details.toJsonString(),
      note: note,
      loggedByUserId: author.userId,
      loggedByDisplayName: author.displayName,
    );
    await _ref.read(syncActionsProvider).syncIfSignedIn();
  }

  Future<void> softDeleteLog(String logId) async {
    final db = _ref.read(databaseProvider);
    await db.careLogDao.softDeleteLog(logId);
    await _ref.read(syncActionsProvider).syncIfSignedIn();
  }

  Future<void> restoreLog(String logId) async {
    final db = _ref.read(databaseProvider);
    await db.careLogDao.restoreLog(logId);
    await _ref.read(syncActionsProvider).syncIfSignedIn();
  }

  Future<bool> permanentDeleteLog(String logId) async {
    final db = _ref.read(databaseProvider);
    final row = await db.careLogDao.getLog(logId);
    if (row == null || row.deletedAt == null) return false;

    if (row.pendingSync) {
      await _ref.read(syncActionsProvider).syncIfSignedIn();
    }

    return db.careLogDao.hardDeleteLog(logId);
  }

  Future<int> purgeExpiredSoftDeletes() async {
    final db = _ref.read(databaseProvider);
    return db.careLogDao.purgeExpiredSoftDeletes();
  }
}
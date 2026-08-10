import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/logs/log_retention.dart';
import '../api/family_models.dart';
import 'app_database.dart';
import 'tables.dart';

part 'care_log_dao.g.dart';

@DriftAccessor(tables: [Babies, CareEvents])
class CareLogDao extends DatabaseAccessor<AppDatabase> with _$CareLogDaoMixin {
  CareLogDao(super.db);

  static const _uuid = Uuid();

  Expression<bool> _isActive($CareEventsTable e) => e.deletedAt.isNull();

  Future<String> ensureDefaultBaby() async {
    final existing = await (select(babies)..limit(1)).getSingleOrNull();
    if (existing != null) return existing.id;

    final id = _uuid.v4();
    await into(babies).insert(
      BabiesCompanion.insert(
        id: id,
        name: 'Baby',
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  Stream<List<CareEvent>> watchTodayLogs(String babyId) {
    final range = _todayRange();
    return (select(careEvents)
          ..where(
            (e) =>
                _isActive(e) &
                e.babyId.equals(babyId) &
                e.occurredAt.isBiggerOrEqualValue(range.start) &
                e.occurredAt.isSmallerThanValue(range.end),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]))
        .watch();
  }

  Future<List<CareEvent>> getTodayLogs(String babyId) {
    final range = _todayRange();
    return (select(careEvents)
          ..where(
            (e) =>
                _isActive(e) &
                e.babyId.equals(babyId) &
                e.occurredAt.isBiggerOrEqualValue(range.start) &
                e.occurredAt.isSmallerThanValue(range.end),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]))
        .get();
  }

  Future<List<CareEvent>> getLogsForLastDays(String babyId, int days) {
    final end = _todayRange().end;
    final start = end.subtract(Duration(days: days));
    return (select(careEvents)
          ..where(
            (e) =>
                _isActive(e) &
                e.babyId.equals(babyId) &
                e.occurredAt.isBiggerOrEqualValue(start) &
                e.occurredAt.isSmallerThanValue(end),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]))
        .get();
  }

  Stream<List<CareEvent>> watchLogsForLastDays(String babyId, int days) {
    final range = dateRangeForDays(days);
    return watchLogsInRange(
      babyId: babyId,
      start: range.start,
      end: range.end,
    );
  }

  Stream<List<CareEvent>> watchLogsInRange({
    required String babyId,
    required DateTime start,
    required DateTime end,
    String? type,
  }) {
    return (select(careEvents)
          ..where(
            (e) => _rangeWhere(e, babyId: babyId, start: start, end: end, type: type),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]))
        .watch();
  }

  Future<List<CareEvent>> getLogsInRange({
    required String babyId,
    required DateTime start,
    required DateTime end,
    String? type,
  }) {
    return (select(careEvents)
          ..where(
            (e) => _rangeWhere(e, babyId: babyId, start: start, end: end, type: type),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)]))
        .get();
  }

  Expression<bool> _rangeWhere(
    $CareEventsTable e, {
    required String babyId,
    required DateTime start,
    required DateTime end,
    String? type,
  }) {
    var expr = _isActive(e) &
        e.babyId.equals(babyId) &
        e.occurredAt.isBiggerOrEqualValue(start) &
        e.occurredAt.isSmallerThanValue(end);
    if (type != null) {
      expr = expr & e.type.equals(type);
    }
    return expr;
  }

  ({DateTime start, DateTime end}) dateRangeForDays(int days) {
    final end = _todayRange().end;
    final start = end.subtract(Duration(days: days));
    return (start: start, end: end);
  }

  Stream<List<CareEvent>> watchSoftDeletedLogs(String babyId) {
    return (select(careEvents)
          ..where(
            (e) => e.babyId.equals(babyId) & e.deletedAt.isNotNull(),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.deletedAt)]))
        .watch();
  }

  Future<CareEvent?> getLog(String logId) {
    return (select(careEvents)..where((e) => e.id.equals(logId)))
        .getSingleOrNull();
  }

  Future<CareEvent?> getActiveLog(String logId) {
    return (select(careEvents)
          ..where((e) => e.id.equals(logId) & _isActive(e)))
        .getSingleOrNull();
  }

  Future<void> updateLog({
    required String logId,
    String? type,
    String? detailsJson,
    DateTime? occurredAt,
    String? note,
    String? loggedByUserId,
    String? loggedByDisplayName,
  }) async {
    await (update(careEvents)..where((e) => e.id.equals(logId))).write(
      CareEventsCompanion(
        type: type != null ? Value(type) : const Value.absent(),
        detailsJson:
            detailsJson != null ? Value(detailsJson) : const Value.absent(),
        occurredAt:
            occurredAt != null ? Value(occurredAt) : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        loggedByUserId: loggedByUserId != null
            ? Value(loggedByUserId)
            : const Value.absent(),
        loggedByDisplayName: loggedByDisplayName != null
            ? Value(loggedByDisplayName)
            : const Value.absent(),
        clientUpdatedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ),
    );
  }

  Future<void> softDeleteLog(String logId) async {
    final now = DateTime.now();
    await (update(careEvents)..where((e) => e.id.equals(logId))).write(
      CareEventsCompanion(
        deletedAt: Value(now),
        clientUpdatedAt: Value(now),
        pendingSync: const Value(true),
      ),
    );
  }

  Future<void> restoreLog(String logId) async {
    final now = DateTime.now();
    await (update(careEvents)..where((e) => e.id.equals(logId))).write(
      CareEventsCompanion(
        deletedAt: const Value(null),
        clientUpdatedAt: Value(now),
        pendingSync: const Value(true),
      ),
    );
  }

  Future<bool> hardDeleteLog(String logId) async {
    final removed = await (delete(careEvents)
          ..where((e) => e.id.equals(logId) & e.deletedAt.isNotNull()))
        .go();
    return removed > 0;
  }

  Future<int> purgeExpiredSoftDeletes({
    int retentionDays = LogRetention.recoveryDays,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    return (delete(careEvents)
          ..where(
            (e) =>
                e.deletedAt.isNotNull() &
                e.deletedAt.isSmallerThanValue(cutoff),
          ))
        .go();
  }

  Future<Baby?> getBaby(String babyId) {
    return (select(babies)..where((b) => b.id.equals(babyId)))
        .getSingleOrNull();
  }

  Stream<Baby> watchBaby(String babyId) {
    return (select(babies)..where((b) => b.id.equals(babyId))).watchSingle();
  }

  Future<void> updateBabyProfile({
    required String babyId,
    required String name,
    DateTime? birthDate,
    required bool isPreemie,
  }) async {
    await (update(babies)..where((b) => b.id.equals(babyId))).write(
      BabiesCompanion(
        name: Value(name),
        birthDate: Value(birthDate),
        isPreemie: Value(isPreemie),
      ),
    );
  }

  Future<void> insertQuickLog({
    required String babyId,
    required String type,
    required DateTime occurredAt,
  }) {
    return insertLog(
      babyId: babyId,
      type: type,
      occurredAt: occurredAt,
    );
  }

  /// Soft-delete local synced rows missing from a partner's server pull.
  Future<int> reconcileRemoteDeletions({
    required String babyId,
    required Set<String> remoteIds,
    DateTime? since,
  }) async {
    final local = await (select(careEvents)
          ..where(
            (e) =>
                e.babyId.equals(babyId) &
                _isActive(e) &
                e.pendingSync.equals(false),
          ))
        .get();

    var removed = 0;
    final now = DateTime.now();
    for (final row in local) {
      if (since != null && row.occurredAt.isBefore(since)) continue;
      if (remoteIds.contains(row.id)) continue;
      await (update(careEvents)..where((e) => e.id.equals(row.id))).write(
        CareEventsCompanion(
          deletedAt: Value(now),
          pendingSync: const Value(false),
        ),
      );
      removed++;
    }
    return removed;
  }

  Future<int> upsertRemoteCareEvents({
    required String babyId,
    required List<RemoteCareEvent> events,
    DateTime? since,
  }) async {
    var merged = 0;
    for (final remote in events) {
      if (since != null && remote.occurredAt.isBefore(since)) continue;

      final existing = await (select(careEvents)
            ..where((e) => e.id.equals(remote.id)))
          .getSingleOrNull();

      final detailsJson = jsonEncode(remote.details);
      final updatedAt = remote.clientUpdatedAt ?? remote.occurredAt;

      if (existing != null) {
        if (existing.pendingSync) continue;
        if (existing.deletedAt != null) continue;
        await (update(careEvents)..where((e) => e.id.equals(remote.id))).write(
          CareEventsCompanion(
            type: Value(remote.type),
            occurredAt: Value(remote.occurredAt),
            detailsJson: Value(detailsJson),
            note: Value(remote.note),
            loggedByUserId: Value(remote.createdByUserId),
            loggedByDisplayName: Value(remote.createdByDisplayName),
            clientUpdatedAt: Value(updatedAt),
            pendingSync: const Value(false),
          ),
        );
        continue;
      }

      await into(careEvents).insert(
        CareEventsCompanion.insert(
          id: remote.id,
          babyId: babyId,
          type: remote.type,
          occurredAt: remote.occurredAt,
          detailsJson: Value(detailsJson),
          note: Value(remote.note),
          loggedByUserId: Value(remote.createdByUserId),
          loggedByDisplayName: Value(remote.createdByDisplayName),
          clientUpdatedAt: updatedAt,
          pendingSync: const Value(false),
        ),
      );
      merged++;
    }
    return merged;
  }

  Future<String> insertLog({
    required String babyId,
    required String type,
    required DateTime occurredAt,
    String detailsJson = '{}',
    String note = '',
    String? loggedByUserId,
    String? loggedByDisplayName,
  }) async {
    final id = _uuid.v4();
    await into(careEvents).insert(
      CareEventsCompanion.insert(
        id: id,
        babyId: babyId,
        type: type,
        occurredAt: occurredAt,
        detailsJson: Value(detailsJson),
        note: Value(note),
        loggedByUserId: Value(loggedByUserId),
        loggedByDisplayName: Value(loggedByDisplayName),
        clientUpdatedAt: occurredAt,
        pendingSync: const Value(true),
      ),
    );
    return id;
  }

  /// Wipe local care logs and unlink the baby from any server child.
  /// Used when switching accounts and choosing "start fresh".
  Future<void> clearLocalCareData() async {
    await transaction(() async {
      await delete(careEvents).go();
      await update(babies).write(
        const BabiesCompanion(serverChildId: Value(null)),
      );
    });
  }

  /// Drop server child mapping so the next sync re-links under the new account.
  Future<void> unlinkServerChild() async {
    await update(babies).write(
      const BabiesCompanion(serverChildId: Value(null)),
    );
  }

  ({DateTime start, DateTime end}) _todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return (start: start, end: start.add(const Duration(days: 1)));
  }
}
import 'package:bloomdue_baby/features/logs/log_retention.dart';
import 'package:bloomdue_baby/features/today/models/log_type.dart';
import 'package:bloomdue_baby/services/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _testDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('CareLogDao soft delete', () {
    test('soft deleted logs are hidden from today queries', () async {
      final db = _testDb();
      addTearDown(db.close);

      final babyId = await db.careLogDao.ensureDefaultBaby();
      final id = await db.careLogDao.insertLog(
        babyId: babyId,
        type: LogType.feed.apiType,
        occurredAt: DateTime.now(),
      );

      await db.careLogDao.softDeleteLog(id);

      final today = await db.careLogDao.getTodayLogs(babyId);
      expect(today, isEmpty);

      final row = await db.careLogDao.getLog(id);
      expect(row?.deletedAt, isNotNull);
    });

    test('restore brings log back to active lists', () async {
      final db = _testDb();
      addTearDown(db.close);

      final babyId = await db.careLogDao.ensureDefaultBaby();
      final id = await db.careLogDao.insertLog(
        babyId: babyId,
        type: LogType.diaper.apiType,
        occurredAt: DateTime.now(),
      );

      await db.careLogDao.softDeleteLog(id);
      await db.careLogDao.restoreLog(id);

      final today = await db.careLogDao.getTodayLogs(babyId);
      expect(today, hasLength(1));
      expect(today.first.deletedAt, isNull);
    });

    test('hard delete removes a soft-deleted log', () async {
      final db = _testDb();
      addTearDown(db.close);

      final babyId = await db.careLogDao.ensureDefaultBaby();
      final id = await db.careLogDao.insertLog(
        babyId: babyId,
        type: LogType.feed.apiType,
        occurredAt: DateTime.now(),
      );

      await db.careLogDao.softDeleteLog(id);
      final removed = await db.careLogDao.hardDeleteLog(id);

      expect(removed, isTrue);
      expect(await db.careLogDao.getLog(id), isNull);
    });

    test('purge permanently removes logs older than retention window', () async {
      final db = _testDb();
      addTearDown(db.close);

      final babyId = await db.careLogDao.ensureDefaultBaby();
      final id = await db.careLogDao.insertLog(
        babyId: babyId,
        type: LogType.sleep.apiType,
        occurredAt: DateTime.now(),
      );

      final oldDelete = DateTime.now().subtract(
        Duration(days: LogRetention.recoveryDays + 1),
      );
      await (db.update(db.careEvents)..where((e) => e.id.equals(id))).write(
        CareEventsCompanion(deletedAt: Value(oldDelete)),
      );

      final purged = await db.careLogDao.purgeExpiredSoftDeletes();
      expect(purged, 1);
      expect(await db.careLogDao.getLog(id), isNull);
    });
  });
}
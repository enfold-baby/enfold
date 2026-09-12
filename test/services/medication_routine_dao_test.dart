import 'package:enfold/services/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upsert daily updates the same vitamin by name', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final babyId = await db.careLogDao.ensureDefaultBaby();

    final first = await db.medicationRoutineDao.upsertDaily(
      babyId: babyId,
      name: 'Vitamin D drops',
      dose: '1 drop',
      hour: 9,
      minute: 0,
    );
    final second = await db.medicationRoutineDao.upsertDaily(
      babyId: babyId,
      name: '  vitamin d drops ',
      dose: '1 drop',
      hour: 8,
      minute: 30,
    );

    expect(second, first);
    final rows = await db.medicationRoutineDao.listForBaby(babyId);
    expect(rows, hasLength(1));
    expect(rows.first.hour, 8);
    expect(rows.first.minute, 30);
    expect(rows.first.enabled, isTrue);
  });

  test('disable by name turns the reminder off', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    await db.medicationRoutineDao.upsertDaily(
      babyId: babyId,
      name: 'Vigantol',
      hour: 9,
      minute: 0,
    );
    await db.medicationRoutineDao.disableByName(
      babyId: babyId,
      name: 'vigantol',
    );
    final row = await db.medicationRoutineDao.findByName(
      babyId: babyId,
      name: 'Vigantol',
    );
    expect(row?.enabled, isFalse);
  });
}

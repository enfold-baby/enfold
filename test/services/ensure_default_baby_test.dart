import 'package:enfold/services/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

void main() {
  test('concurrent ensureDefaultBaby calls create exactly one baby', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final ids = await Future.wait(
      List.generate(6, (_) => db.careLogDao.ensureDefaultBaby()),
    );
    final rows = await db.select(db.babies).get();

    expect(rows, hasLength(1));
    expect(ids.toSet(), {rows.single.id});
  });

  test('a name saved on the default baby is read back by the same id',
      () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final first = await db.careLogDao.ensureDefaultBaby();
    await db.careLogDao.updateBabyProfile(
      babyId: first,
      name: 'Mia',
      birthDate: null,
      isPreemie: false,
    );
    final again = await db.careLogDao.ensureDefaultBaby();
    final baby = await db.careLogDao.watchBaby(again).first;

    expect(again, first);
    expect(baby.name, 'Mia');
    expect(db, isA<AppDatabase>());
  });
}

import 'package:enfold/services/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _testDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('GrowthDao', () {
    test('stores measurements and milestones', () async {
      final db = _testDb();
      addTearDown(db.close);

      final babyId = await db.careLogDao.ensureDefaultBaby();
      await db.growthDao.insertMeasurement(
        babyId: babyId,
        measuredAt: DateTime(2026, 7, 8),
        weightKg: 3.4,
        lengthCm: 50,
      );
      await db.growthDao.setMilestoneAchieved(
        babyId: babyId,
        milestoneKey: 'social_smile',
        achievedAt: DateTime(2026, 7, 8),
      );

      final measurements = await db.growthDao.watchMeasurements(babyId).first;
      expect(measurements, hasLength(1));
      expect(measurements.first.weightKg, 3.4);

      final milestones =
          await db.growthDao.watchMilestoneAchievements(babyId).first;
      expect(milestones, hasLength(1));
      expect(milestones.first.milestoneKey, 'social_smile');

      await db.growthDao.clearMilestone(
        babyId: babyId,
        milestoneKey: 'social_smile',
      );
      final cleared =
          await db.growthDao.watchMilestoneAchievements(babyId).first;
      expect(cleared, isEmpty);
    });
  });
}
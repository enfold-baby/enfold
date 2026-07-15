import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';
import 'tables.dart';

part 'growth_dao.g.dart';

@DriftAccessor(tables: [GrowthMeasurements, MilestoneAchievements])
class GrowthDao extends DatabaseAccessor<AppDatabase> with _$GrowthDaoMixin {
  GrowthDao(super.db);

  static const _uuid = Uuid();

  Stream<List<GrowthMeasurement>> watchMeasurements(String babyId) {
    return (select(growthMeasurements)
          ..where((m) => m.babyId.equals(babyId))
          ..orderBy([(m) => OrderingTerm.desc(m.measuredAt)]))
        .watch();
  }

  Future<GrowthMeasurement?> getMeasurement(String id) {
    return (select(growthMeasurements)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> insertMeasurement({
    required String babyId,
    required DateTime measuredAt,
    double? weightKg,
    double? lengthCm,
    double? headCm,
    String note = '',
  }) async {
    final id = _uuid.v4();
    await into(growthMeasurements).insert(
      GrowthMeasurementsCompanion.insert(
        id: id,
        babyId: babyId,
        measuredAt: measuredAt,
        weightKg: Value(weightKg),
        lengthCm: Value(lengthCm),
        headCm: Value(headCm),
        note: Value(note),
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  Future<void> deleteMeasurement(String id) async {
    await (delete(growthMeasurements)..where((m) => m.id.equals(id))).go();
  }

  Stream<List<MilestoneAchievement>> watchMilestoneAchievements(String babyId) {
    return (select(milestoneAchievements)
          ..where((m) => m.babyId.equals(babyId))
          ..orderBy([(m) => OrderingTerm.desc(m.achievedAt)]))
        .watch();
  }

  Future<void> setMilestoneAchieved({
    required String babyId,
    required String milestoneKey,
    required DateTime achievedAt,
  }) async {
    await into(milestoneAchievements).insertOnConflictUpdate(
      MilestoneAchievementsCompanion.insert(
        babyId: babyId,
        milestoneKey: milestoneKey,
        achievedAt: achievedAt,
      ),
    );
  }

  Future<void> clearMilestone({
    required String babyId,
    required String milestoneKey,
  }) async {
    await (delete(milestoneAchievements)
          ..where(
            (m) =>
                m.babyId.equals(babyId) &
                m.milestoneKey.equals(milestoneKey),
          ))
        .go();
  }
}
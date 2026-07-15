// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_dao.dart';

// ignore_for_file: type=lint
mixin _$GrowthDaoMixin on DatabaseAccessor<AppDatabase> {
  $GrowthMeasurementsTable get growthMeasurements =>
      attachedDatabase.growthMeasurements;
  $MilestoneAchievementsTable get milestoneAchievements =>
      attachedDatabase.milestoneAchievements;
  GrowthDaoManager get managers => GrowthDaoManager(this);
}

class GrowthDaoManager {
  final _$GrowthDaoMixin _db;
  GrowthDaoManager(this._db);
  $$GrowthMeasurementsTableTableManager get growthMeasurements =>
      $$GrowthMeasurementsTableTableManager(
        _db.attachedDatabase,
        _db.growthMeasurements,
      );
  $$MilestoneAchievementsTableTableManager get milestoneAchievements =>
      $$MilestoneAchievementsTableTableManager(
        _db.attachedDatabase,
        _db.milestoneAchievements,
      );
}

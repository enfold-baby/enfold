import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/app_database.dart';
import '../../../services/database/database_provider.dart';
import '../data/milestone_catalog.dart';
import '../models/growth_measurement_entry.dart';
import '../models/milestone_definition.dart';

GrowthMeasurementEntry _mapMeasurement(GrowthMeasurement row) {
  return GrowthMeasurementEntry(
    id: row.id,
    measuredAt: row.measuredAt,
    weightKg: row.weightKg,
    lengthCm: row.lengthCm,
    headCm: row.headCm,
    note: row.note,
  );
}

final growthMeasurementsProvider =
    StreamProvider<List<GrowthMeasurementEntry>>((ref) {
  final db = ref.read(databaseProvider);
  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.growthDao
        .watchMeasurements(babyId)
        .map((rows) => rows.map(_mapMeasurement).toList()),
  );
});

final milestoneStatusesProvider = StreamProvider<List<MilestoneStatus>>((ref) {
  final db = ref.read(databaseProvider);
  return Stream.fromFuture(db.careLogDao.ensureDefaultBaby()).asyncExpand(
    (babyId) => db.growthDao.watchMilestoneAchievements(babyId).map((rows) {
      final achievedByKey = {
        for (final row in rows) row.milestoneKey: row.achievedAt,
      };
      return [
        for (final definition in MilestoneCatalog.entries)
          MilestoneStatus(
            definition: definition,
            achievedAt: achievedByKey[definition.key],
          ),
      ];
    }),
  );
});

final growthActionsProvider = Provider<GrowthActions>((ref) {
  return GrowthActions(ref);
});

class GrowthActions {
  GrowthActions(this._ref);

  final Ref _ref;

  Future<void> saveMeasurement({
    required DateTime measuredAt,
    double? weightKg,
    double? lengthCm,
    double? headCm,
    String note = '',
  }) async {
    final db = _ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    await db.growthDao.insertMeasurement(
      babyId: babyId,
      measuredAt: measuredAt,
      weightKg: weightKg,
      lengthCm: lengthCm,
      headCm: headCm,
      note: note,
    );
  }

  Future<void> deleteMeasurement(String id) async {
    await _ref.read(databaseProvider).growthDao.deleteMeasurement(id);
  }

  Future<void> toggleMilestone(MilestoneDefinition definition) async {
    final db = _ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final achievements = await db.growthDao
        .watchMilestoneAchievements(babyId)
        .first;
    final hasAchievement = achievements.any(
      (row) => row.milestoneKey == definition.key,
    );

    if (hasAchievement) {
      await db.growthDao.clearMilestone(
        babyId: babyId,
        milestoneKey: definition.key,
      );
    } else {
      await db.growthDao.setMilestoneAchieved(
        babyId: babyId,
        milestoneKey: definition.key,
        achievedAt: DateTime.now(),
      );
    }
  }
}
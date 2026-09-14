import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/family_models.dart';
import 'app_database.dart';
import 'tables.dart';

part 'growth_dao.g.dart';

/// Growth rows sync like care events: edits mark `pendingSync`, deletes are
/// soft (`deletedAt`) until the server has them, then the row is dropped.
@DriftAccessor(tables: [GrowthMeasurements, MilestoneAchievements])
class GrowthDao extends DatabaseAccessor<AppDatabase> with _$GrowthDaoMixin {
  GrowthDao(super.db);

  static const _uuid = Uuid();

  Stream<List<GrowthMeasurement>> watchMeasurements(String babyId) {
    return (select(growthMeasurements)
          ..where((m) => m.babyId.equals(babyId) & m.deletedAt.isNull())
          ..orderBy([(m) => OrderingTerm.desc(m.measuredAt)]))
        .watch();
  }

  Future<GrowthMeasurement?> getMeasurement(String id) {
    return (select(growthMeasurements)
          ..where((m) => m.id.equals(id) & m.deletedAt.isNull()))
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
    await (update(growthMeasurements)..where((m) => m.id.equals(id))).write(
      GrowthMeasurementsCompanion(
        deletedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ),
    );
  }

  Stream<List<MilestoneAchievement>> watchMilestoneAchievements(String babyId) {
    return (select(milestoneAchievements)
          ..where((m) => m.babyId.equals(babyId) & m.deletedAt.isNull())
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
        pendingSync: const Value(true),
        deletedAt: const Value(null),
      ),
    );
  }

  Future<void> clearMilestone({
    required String babyId,
    required String milestoneKey,
  }) async {
    await (update(milestoneAchievements)
          ..where(
            (m) =>
                m.babyId.equals(babyId) &
                m.milestoneKey.equals(milestoneKey),
          ))
        .write(
      MilestoneAchievementsCompanion(
        deletedAt: Value(DateTime.now()),
        pendingSync: const Value(true),
      ),
    );
  }

  // --- Sync ---------------------------------------------------------------

  Future<List<GrowthMeasurement>> pendingMeasurements(String babyId) {
    return (select(growthMeasurements)
          ..where((m) => m.babyId.equals(babyId) & m.pendingSync.equals(true)))
        .get();
  }

  /// The server now matches [pushed]. Guarded so a change made while the
  /// request was in flight stays pending.
  Future<void> markMeasurementPushed(GrowthMeasurement pushed) async {
    if (pushed.deletedAt != null) {
      await (delete(growthMeasurements)
            ..where((m) => m.id.equals(pushed.id) & m.deletedAt.isNotNull()))
          .go();
      return;
    }
    await (update(growthMeasurements)
          ..where((m) => m.id.equals(pushed.id) & m.deletedAt.isNull()))
        .write(const GrowthMeasurementsCompanion(pendingSync: Value(false)));
  }

  Future<List<MilestoneAchievement>> pendingMilestones(String babyId) {
    return (select(milestoneAchievements)
          ..where((m) => m.babyId.equals(babyId) & m.pendingSync.equals(true)))
        .get();
  }

  Future<void> markMilestonePushed(MilestoneAchievement pushed) async {
    Expression<bool> sameRow(MilestoneAchievements m) =>
        m.babyId.equals(pushed.babyId) &
        m.milestoneKey.equals(pushed.milestoneKey);
    if (pushed.deletedAt != null) {
      await (delete(milestoneAchievements)
            ..where((m) => sameRow(m) & m.deletedAt.isNotNull()))
          .go();
      return;
    }
    await (update(milestoneAchievements)
          ..where(
            (m) =>
                sameRow(m) &
                m.deletedAt.isNull() &
                m.achievedAt.equals(pushed.achievedAt),
          ))
        .write(const MilestoneAchievementsCompanion(pendingSync: Value(false)));
  }

  /// Makes synced local rows match the family's full server list. Rows with
  /// unpushed local changes are left alone. Returns rows added or removed.
  Future<int> mergeRemoteMeasurements({
    required String babyId,
    required List<RemoteGrowthMeasurement> remote,
  }) {
    return transaction(() async {
      final local = {
        for (final row in await (select(growthMeasurements)
              ..where((m) => m.babyId.equals(babyId)))
            .get())
          row.id: row,
      };
      var changed = 0;

      for (final item in remote) {
        final existing = local[item.id];
        final companion = GrowthMeasurementsCompanion(
          measuredAt: Value(item.measuredAt),
          weightKg: Value(item.weightKg),
          lengthCm: Value(item.lengthCm),
          headCm: Value(item.headCm),
          note: Value(item.note),
          pendingSync: const Value(false),
        );
        if (existing == null) {
          await into(growthMeasurements).insert(
            companion.copyWith(
              id: Value(item.id),
              babyId: Value(babyId),
              createdAt: Value(DateTime.now()),
            ),
          );
          changed++;
        } else if (!existing.pendingSync) {
          await (update(growthMeasurements)
                ..where((m) => m.id.equals(item.id)))
              .write(companion);
        }
      }

      final remoteIds = {for (final item in remote) item.id};
      for (final row in local.values) {
        if (row.pendingSync || remoteIds.contains(row.id)) continue;
        await (delete(growthMeasurements)..where((m) => m.id.equals(row.id)))
            .go();
        changed++;
      }
      return changed;
    });
  }

  /// Same as [mergeRemoteMeasurements] for milestones. A family with several
  /// server children can hold one key twice; the earliest date wins.
  Future<int> mergeRemoteMilestones({
    required String babyId,
    required List<RemoteMilestone> remote,
  }) {
    return transaction(() async {
      final byKey = <String, RemoteMilestone>{};
      for (final item in remote) {
        final seen = byKey[item.milestoneKey];
        if (seen == null || item.achievedAt.isBefore(seen.achievedAt)) {
          byKey[item.milestoneKey] = item;
        }
      }

      final local = {
        for (final row in await (select(milestoneAchievements)
              ..where((m) => m.babyId.equals(babyId)))
            .get())
          row.milestoneKey: row,
      };
      var changed = 0;

      for (final item in byKey.values) {
        final existing = local[item.milestoneKey];
        if (existing != null && existing.pendingSync) continue;
        await into(milestoneAchievements).insertOnConflictUpdate(
          MilestoneAchievementsCompanion.insert(
            babyId: babyId,
            milestoneKey: item.milestoneKey,
            achievedAt: item.achievedAt,
            note: Value(item.note),
            pendingSync: const Value(false),
            deletedAt: const Value(null),
          ),
        );
        if (existing == null) changed++;
      }

      for (final row in local.values) {
        if (row.pendingSync || byKey.containsKey(row.milestoneKey)) continue;
        await (delete(milestoneAchievements)
              ..where(
                (m) =>
                    m.babyId.equals(babyId) &
                    m.milestoneKey.equals(row.milestoneKey),
              ))
            .go();
        changed++;
      }
      return changed;
    });
  }
}

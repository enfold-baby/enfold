import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'care_log_dao.dart';
import 'growth_dao.dart';
import 'medication_routine_dao.dart';
import 'pregnancy_dao.dart';
import 'settings_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Babies,
    CareEvents,
    PregnancyProfiles,
    PregnancyAppointments,
    AppSettings,
    GrowthMeasurements,
    MilestoneAchievements,
    MedicationRoutines,
  ],
  daos: [
    CareLogDao,
    GrowthDao,
    PregnancyDao,
    SettingsDao,
    MedicationRoutineDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(babies, babies.serverChildId);
          }
          if (from < 3) {
            await m.createTable(pregnancyProfiles);
            await m.createTable(pregnancyAppointments);
          }
          if (from < 4) {
            await m.createTable(appSettings);
          }
          if (from < 5) {
            await m.addColumn(appSettings, appSettings.useImperialUnits);
          }
          if (from < 6) {
            await m.addColumn(careEvents, careEvents.deletedAt);
          }
          if (from < 7) {
            await m.createTable(growthMeasurements);
            await m.createTable(milestoneAchievements);
          }
          if (from < 8) {
            await m.addColumn(careEvents, careEvents.loggedByUserId);
            await m.addColumn(careEvents, careEvents.loggedByDisplayName);
            await m.addColumn(
              appSettings,
              appSettings.partnerActivityPushEnabled,
            );
            await m.addColumn(
              appSettings,
              appSettings.partnerGentleNudgeEnabled,
            );
          }
          if (from < 9) {
            await m.addColumn(appSettings, appSettings.themeMode);
          }
          if (from < 10) {
            await m.addColumn(appSettings, appSettings.lastSignedInUserId);
          }
          if (from < 11) {
            await m.addColumn(appSettings, appSettings.careRemindersEnabled);
          }
          if (from < 12) {
            await m.addColumn(appSettings, appSettings.use24HourTime);
          }
          if (from < 13) {
            await m.createTable(medicationRoutines);
          }
          if (from < 14) {
            await m.addColumn(appSettings, appSettings.showAwakeTime);
          }
          if (from < 15) {
            // Existing growth rows default to pending, so they upload once.
            await m.addColumn(growthMeasurements, growthMeasurements.pendingSync);
            await m.addColumn(growthMeasurements, growthMeasurements.deletedAt);
            await m.addColumn(
              milestoneAchievements,
              milestoneAchievements.pendingSync,
            );
            await m.addColumn(
              milestoneAchievements,
              milestoneAchievements.deletedAt,
            );
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'enfold');
  }
}
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'care_log_dao.dart';
import 'growth_dao.dart';
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
  ],
  daos: [CareLogDao, GrowthDao, PregnancyDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

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
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'bloomdue');
  }
}
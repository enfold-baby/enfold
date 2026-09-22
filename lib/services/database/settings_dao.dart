import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'app_database.dart';
import 'tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  static const _singletonId = 1;

  Future<AppSetting> ensureSettings() async {
    final existing = await (select(appSettings)
          ..where((s) => s.id.equals(_singletonId)))
        .getSingleOrNull();
    if (existing != null) return existing;

    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        id: const Value(_singletonId),
        onboardingCompleted: const Value(false),
        useImperialUnits: const Value(false),
        partnerActivityPushEnabled: const Value(false),
        partnerGentleNudgeEnabled: const Value(false),
        themeMode: const Value('system'),
      ),
    );
    return (select(appSettings)..where((s) => s.id.equals(_singletonId)))
        .getSingle();
  }

  Future<bool> isOnboardingCompleted() async {
    final settings = await ensureSettings();
    return settings.onboardingCompleted;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(onboardingCompleted: Value(value)),
    );
  }

  Future<bool> useImperialUnits() async {
    final settings = await ensureSettings();
    return settings.useImperialUnits;
  }

  Future<void> setUseImperialUnits(bool value) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(useImperialUnits: Value(value)),
    );
  }

  Future<bool> partnerActivityPushEnabled() async {
    final settings = await ensureSettings();
    return settings.partnerActivityPushEnabled;
  }

  Future<bool> partnerGentleNudgeEnabled() async {
    final settings = await ensureSettings();
    return settings.partnerGentleNudgeEnabled;
  }

  Future<void> setPartnerActivityPushEnabled(bool value) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(partnerActivityPushEnabled: Value(value)),
    );
  }

  Future<void> setPartnerGentleNudgeEnabled(bool value) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(partnerGentleNudgeEnabled: Value(value)),
    );
  }

  Future<ThemeMode> themeMode() async {
    final settings = await ensureSettings();
    return _parseThemeMode(settings.themeMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(themeMode: Value(_encodeThemeMode(mode))),
    );
  }

  Future<String?> lastSignedInUserId() async {
    final settings = await ensureSettings();
    return settings.lastSignedInUserId;
  }

  Future<void> setLastSignedInUserId(String? userId) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(lastSignedInUserId: Value(userId)),
    );
  }

  Future<bool> careRemindersEnabled() async {
    final settings = await ensureSettings();
    return settings.careRemindersEnabled;
  }

  Future<void> setCareRemindersEnabled(bool value) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(careRemindersEnabled: Value(value)),
    );
  }

  Stream<bool> watchCareRemindersEnabled() async* {
    await ensureSettings();
    yield* (select(appSettings)..where((s) => s.id.equals(_singletonId)))
        .watch()
        .map((rows) => rows.isEmpty ? false : rows.first.careRemindersEnabled);
  }

  Future<bool> use24HourTime() async {
    final settings = await ensureSettings();
    return settings.use24HourTime;
  }

  Future<void> setUse24HourTime(bool value) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(use24HourTime: Value(value)),
    );
  }

  Future<bool> showAwakeTime() async {
    final settings = await ensureSettings();
    return settings.showAwakeTime;
  }

  Future<void> setShowAwakeTime(bool value) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(showAwakeTime: Value(value)),
    );
  }

  Stream<bool> watchShowAwakeTime() async* {
    await ensureSettings();
    yield* (select(appSettings)..where((s) => s.id.equals(_singletonId)))
        .watch()
        .map((rows) => rows.isEmpty ? true : rows.first.showAwakeTime);
  }

  /// Null means "follow the device language".
  Future<String?> languageTag() async {
    final settings = await ensureSettings();
    return settings.languageTag;
  }

  Future<void> setLanguageTag(String? tag) async {
    await ensureSettings();
    await (update(appSettings)..where((s) => s.id.equals(_singletonId))).write(
      AppSettingsCompanion(languageTag: Value(tag)),
    );
  }

  static ThemeMode _parseThemeMode(String raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encodeThemeMode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
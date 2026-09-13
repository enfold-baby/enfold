import 'package:enfold/services/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _testDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('SettingsDao', () {
    test('ensureSettings is safe under concurrent calls', () async {
      final db = _testDb();
      addTearDown(db.close);

      final results = await Future.wait([
        db.settingsDao.ensureSettings(),
        db.settingsDao.ensureSettings(),
        db.settingsDao.ensureSettings(),
      ]);

      expect(results.map((s) => s.id).toSet(), {1});
      expect(await db.settingsDao.isOnboardingCompleted(), isFalse);
    });

    test('setOnboardingCompleted persists flag', () async {
      final db = _testDb();
      addTearDown(db.close);

      await db.settingsDao.setOnboardingCompleted(true);
      expect(await db.settingsDao.isOnboardingCompleted(), isTrue);
    });

    test('theme mode defaults to system and persists', () async {
      final db = _testDb();
      addTearDown(db.close);

      expect(await db.settingsDao.themeMode(), ThemeMode.system);

      await db.settingsDao.setThemeMode(ThemeMode.dark);
      expect(await db.settingsDao.themeMode(), ThemeMode.dark);

      await db.settingsDao.setThemeMode(ThemeMode.light);
      expect(await db.settingsDao.themeMode(), ThemeMode.light);
    });

    test('partner notification toggles default off and persist', () async {
      final db = _testDb();
      addTearDown(db.close);

      expect(await db.settingsDao.partnerActivityPushEnabled(), isFalse);
      expect(await db.settingsDao.partnerGentleNudgeEnabled(), isFalse);

      await db.settingsDao.setPartnerActivityPushEnabled(true);
      await db.settingsDao.setPartnerGentleNudgeEnabled(true);

      expect(await db.settingsDao.partnerActivityPushEnabled(), isTrue);
      expect(await db.settingsDao.partnerGentleNudgeEnabled(), isTrue);
    });

    test('care reminders default off and persist', () async {
      final db = _testDb();
      addTearDown(db.close);

      expect(await db.settingsDao.careRemindersEnabled(), isFalse);
      await db.settingsDao.setCareRemindersEnabled(true);
      expect(await db.settingsDao.careRemindersEnabled(), isTrue);
    });

    test('24-hour clock defaults off and persists', () async {
      final db = _testDb();
      addTearDown(db.close);

      expect(await db.settingsDao.use24HourTime(), isFalse);
      await db.settingsDao.setUse24HourTime(true);
      expect(await db.settingsDao.use24HourTime(), isTrue);
    });

    test('time awake defaults on and persists', () async {
      final db = _testDb();
      addTearDown(db.close);

      expect(await db.settingsDao.showAwakeTime(), isTrue);
      await db.settingsDao.setShowAwakeTime(false);
      expect(await db.settingsDao.showAwakeTime(), isFalse);
    });

    test('lastSignedInUserId defaults null and persists', () async {
      final db = _testDb();
      addTearDown(db.close);

      expect(await db.settingsDao.lastSignedInUserId(), isNull);
      await db.settingsDao.setLastSignedInUserId('user-42');
      expect(await db.settingsDao.lastSignedInUserId(), 'user-42');
    });
  });
}
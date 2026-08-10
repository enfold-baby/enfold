import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

/// How to treat on-device data when signing into a different account.
enum AccountSwitchChoice {
  /// Keep local logs and upload them under the new account.
  uploadLocal,

  /// Wipe local care data and pull this account's history from the server.
  startFresh,
}

/// Local data isolation helpers for multi-account use on one install.
class AccountSwitchService {
  AccountSwitchService(this._db);

  final AppDatabase _db;

  Future<String?> lastSignedInUserId() {
    return _db.settingsDao.lastSignedInUserId();
  }

  Future<void> setLastSignedInUserId(String? userId) {
    return _db.settingsDao.setLastSignedInUserId(userId);
  }

  /// True when [incomingUserId] differs from the last account on this device.
  Future<bool> isAccountSwitch(String incomingUserId) async {
    final last = await lastSignedInUserId();
    return last != null && last != incomingUserId;
  }

  /// Clear care logs, growth, milestones, pregnancy rows; unlink server child.
  Future<void> clearLocalCareData() async {
    await _db.transaction(() async {
      await _db.delete(_db.careEvents).go();
      await _db.delete(_db.growthMeasurements).go();
      await _db.delete(_db.milestoneAchievements).go();
      await _db.delete(_db.pregnancyAppointments).go();
      await _db.delete(_db.pregnancyProfiles).go();
      await _db.update(_db.babies).write(
            const BabiesCompanion(serverChildId: Value(null)),
          );
    });
  }

  /// Keep local rows but drop server child mapping for re-link under new account.
  Future<void> unlinkServerChild() {
    return _db.careLogDao.unlinkServerChild();
  }

  /// Apply the user's choice after signing into a different account.
  Future<void> applySwitchChoice(AccountSwitchChoice choice) async {
    switch (choice) {
      case AccountSwitchChoice.uploadLocal:
        await unlinkServerChild();
      case AccountSwitchChoice.startFresh:
        await clearLocalCareData();
    }
  }
}

final accountSwitchServiceProvider = Provider<AccountSwitchService>((ref) {
  return AccountSwitchService(ref.watch(databaseProvider));
});

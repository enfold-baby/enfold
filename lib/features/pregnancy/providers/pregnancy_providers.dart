import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/app_database.dart';
import '../../../services/database/database_provider.dart';

final pregnancyProfileProvider = StreamProvider<PregnancyProfile>((ref) async* {
  final db = ref.read(databaseProvider);
  await db.pregnancyDao.ensureProfile();
  yield* db.pregnancyDao.watchProfile();
});

final pregnancyAppointmentsProvider =
    StreamProvider<List<PregnancyAppointment>>((ref) async* {
  final db = ref.read(databaseProvider);
  await db.pregnancyDao.ensureProfile();
  yield* db.pregnancyDao.watchAppointments();
});

final pregnancyActionsProvider = Provider<PregnancyActions>((ref) {
  return PregnancyActions(ref);
});

class PregnancyActions {
  PregnancyActions(this._ref);

  final Ref _ref;

  Future<void> setDueDate(DateTime? dueDate) async {
    await _ref.read(databaseProvider).pregnancyDao.setDueDate(dueDate);
  }

  Future<int> incrementKick() async {
    return _ref.read(databaseProvider).pregnancyDao.incrementKickCount();
  }

  Future<void> resetKicks() async {
    await _ref.read(databaseProvider).pregnancyDao.resetKickCount();
  }

  Future<void> addAppointment({
    required String title,
    DateTime? scheduledAt,
    String notes = '',
  }) async {
    await _ref.read(databaseProvider).pregnancyDao.addAppointment(
          title: title,
          scheduledAt: scheduledAt,
          notes: notes,
        );
  }

  Future<void> deleteAppointment(String id) async {
    await _ref.read(databaseProvider).pregnancyDao.deleteAppointment(id);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/app_database.dart';
import '../../../services/database/database_provider.dart';
import '../../baby/providers/baby_profile_providers.dart';

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

/// True while a due date is set and no birth date yet — pregnancy tools
/// belong on Today, not as a permanent tab after baby arrives.
final isExpectingProvider = Provider<bool>((ref) {
  final dueDate = ref.watch(pregnancyProfileProvider).valueOrNull?.dueDate;
  final birthDate = ref.watch(activeBabyProvider).valueOrNull?.birthDate;
  return dueDate != null && birthDate == null;
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
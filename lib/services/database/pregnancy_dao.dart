import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';
import 'tables.dart';

part 'pregnancy_dao.g.dart';

@DriftAccessor(tables: [PregnancyProfiles, PregnancyAppointments])
class PregnancyDao extends DatabaseAccessor<AppDatabase>
    with _$PregnancyDaoMixin {
  PregnancyDao(super.db);

  static const _uuid = Uuid();

  Future<PregnancyProfile> ensureProfile() async {
    final existing =
        await (select(pregnancyProfiles)..limit(1)).getSingleOrNull();
    if (existing != null) return existing;

    final now = DateTime.now();
    final id = _uuid.v4();
    await into(pregnancyProfiles).insert(
      PregnancyProfilesCompanion.insert(
        id: id,
        updatedAt: now,
      ),
    );
    return (select(pregnancyProfiles)..where((p) => p.id.equals(id)))
        .getSingle();
  }

  Stream<PregnancyProfile> watchProfile() {
    return (select(pregnancyProfiles)..limit(1)).watchSingle();
  }

  Future<void> setDueDate(DateTime? dueDate) async {
    final profile = await ensureProfile();
    await (update(pregnancyProfiles)..where((p) => p.id.equals(profile.id)))
        .write(
      PregnancyProfilesCompanion(
        dueDate: Value(dueDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> incrementKickCount() async {
    final profile = await ensureProfile();
    final today = _dateOnly(DateTime.now());
    final kickDate = profile.kickCountDate;
    final count = kickDate != null && _dateOnly(kickDate) == today
        ? profile.kickCountToday + 1
        : 1;

    await (update(pregnancyProfiles)..where((p) => p.id.equals(profile.id)))
        .write(
      PregnancyProfilesCompanion(
        kickCountToday: Value(count),
        kickCountDate: Value(today),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return count;
  }

  Future<void> resetKickCount() async {
    final profile = await ensureProfile();
    await (update(pregnancyProfiles)..where((p) => p.id.equals(profile.id)))
        .write(
      PregnancyProfilesCompanion(
        kickCountToday: const Value(0),
        kickCountDate: Value(_dateOnly(DateTime.now())),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<PregnancyAppointment>> watchAppointments() {
    return (select(pregnancyAppointments)
          ..orderBy([
            (a) => OrderingTerm.desc(a.scheduledAt),
            (a) => OrderingTerm.desc(a.createdAt),
          ]))
        .watch();
  }

  Future<void> addAppointment({
    required String title,
    DateTime? scheduledAt,
    String notes = '',
  }) async {
    await into(pregnancyAppointments).insert(
      PregnancyAppointmentsCompanion.insert(
        id: _uuid.v4(),
        title: title,
        scheduledAt: Value(scheduledAt),
        notes: Value(notes),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteAppointment(String id) async {
    await (delete(pregnancyAppointments)..where((a) => a.id.equals(id))).go();
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
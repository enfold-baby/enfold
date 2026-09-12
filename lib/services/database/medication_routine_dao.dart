import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/medication/utils/medication_name.dart';
import 'app_database.dart';
import 'tables.dart';

part 'medication_routine_dao.g.dart';

@DriftAccessor(tables: [MedicationRoutines])
class MedicationRoutineDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationRoutineDaoMixin {
  MedicationRoutineDao(super.db);

  static const _uuid = Uuid();

  Stream<List<MedicationRoutine>> watchForBaby(String babyId) {
    return (select(medicationRoutines)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([
            (r) => OrderingTerm.asc(r.hour),
            (r) => OrderingTerm.asc(r.minute),
            (r) => OrderingTerm.asc(r.name),
          ]))
        .watch();
  }

  Future<List<MedicationRoutine>> listForBaby(String babyId) {
    return (select(medicationRoutines)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([
            (r) => OrderingTerm.asc(r.hour),
            (r) => OrderingTerm.asc(r.minute),
            (r) => OrderingTerm.asc(r.name),
          ]))
        .get();
  }

  Future<MedicationRoutine?> getById(String id) {
    return (select(medicationRoutines)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  Future<MedicationRoutine?> findByName({
    required String babyId,
    required String name,
  }) async {
    final rows = await (select(medicationRoutines)
          ..where((r) => r.babyId.equals(babyId)))
        .get();
    final needle = normalizeMedicationName(name);
    if (needle.isEmpty) return null;
    for (final row in rows) {
      if (normalizeMedicationName(row.name) == needle) return row;
    }
    return null;
  }

  Future<String> upsertDaily({
    required String babyId,
    required String name,
    String dose = '',
    String category = 'vitamin',
    required int hour,
    required int minute,
    bool enabled = true,
  }) async {
    final trimmed = name.trim();
    final existing = await findByName(babyId: babyId, name: trimmed);
    final now = DateTime.now();
    if (existing != null) {
      await (update(medicationRoutines)..where((r) => r.id.equals(existing.id)))
          .write(
        MedicationRoutinesCompanion(
          name: Value(trimmed),
          dose: Value(dose),
          category: Value(category),
          hour: Value(hour),
          minute: Value(minute),
          enabled: Value(enabled),
          snoozeUntil: const Value(null),
          updatedAt: Value(now),
        ),
      );
      return existing.id;
    }

    final id = _uuid.v4();
    await into(medicationRoutines).insert(
      MedicationRoutinesCompanion.insert(
        id: id,
        babyId: babyId,
        name: trimmed,
        dose: Value(dose),
        category: Value(category),
        hour: hour,
        minute: minute,
        enabled: Value(enabled),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  Future<void> setEnabled(String id, bool enabled) async {
    await (update(medicationRoutines)..where((r) => r.id.equals(id))).write(
      MedicationRoutinesCompanion(
        enabled: Value(enabled),
        snoozeUntil: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setTime(String id, {required int hour, required int minute}) {
    return (update(medicationRoutines)..where((r) => r.id.equals(id))).write(
      MedicationRoutinesCompanion(
        hour: Value(hour),
        minute: Value(minute),
        snoozeUntil: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setSnoozeUntil(String id, DateTime? until) {
    return (update(medicationRoutines)..where((r) => r.id.equals(id))).write(
      MedicationRoutinesCompanion(
        snoozeUntil: Value(until),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> disableByName({
    required String babyId,
    required String name,
  }) async {
    final existing = await findByName(babyId: babyId, name: name);
    if (existing == null) return;
    await setEnabled(existing.id, false);
  }

  Future<void> deleteRoutine(String id) {
    return (delete(medicationRoutines)..where((r) => r.id.equals(id))).go();
  }

  Future<void> clearAll() {
    return delete(medicationRoutines).go();
  }
}

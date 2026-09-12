// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_routine_dao.dart';

// ignore_for_file: type=lint
mixin _$MedicationRoutineDaoMixin on DatabaseAccessor<AppDatabase> {
  $MedicationRoutinesTable get medicationRoutines =>
      attachedDatabase.medicationRoutines;
  MedicationRoutineDaoManager get managers => MedicationRoutineDaoManager(this);
}

class MedicationRoutineDaoManager {
  final _$MedicationRoutineDaoMixin _db;
  MedicationRoutineDaoManager(this._db);
  $$MedicationRoutinesTableTableManager get medicationRoutines =>
      $$MedicationRoutinesTableTableManager(
        _db.attachedDatabase,
        _db.medicationRoutines,
      );
}

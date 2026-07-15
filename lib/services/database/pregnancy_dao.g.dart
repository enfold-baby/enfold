// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy_dao.dart';

// ignore_for_file: type=lint
mixin _$PregnancyDaoMixin on DatabaseAccessor<AppDatabase> {
  $PregnancyProfilesTable get pregnancyProfiles =>
      attachedDatabase.pregnancyProfiles;
  $PregnancyAppointmentsTable get pregnancyAppointments =>
      attachedDatabase.pregnancyAppointments;
  PregnancyDaoManager get managers => PregnancyDaoManager(this);
}

class PregnancyDaoManager {
  final _$PregnancyDaoMixin _db;
  PregnancyDaoManager(this._db);
  $$PregnancyProfilesTableTableManager get pregnancyProfiles =>
      $$PregnancyProfilesTableTableManager(
        _db.attachedDatabase,
        _db.pregnancyProfiles,
      );
  $$PregnancyAppointmentsTableTableManager get pregnancyAppointments =>
      $$PregnancyAppointmentsTableTableManager(
        _db.attachedDatabase,
        _db.pregnancyAppointments,
      );
}

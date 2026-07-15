// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_log_dao.dart';

// ignore_for_file: type=lint
mixin _$CareLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $BabiesTable get babies => attachedDatabase.babies;
  $CareEventsTable get careEvents => attachedDatabase.careEvents;
  CareLogDaoManager get managers => CareLogDaoManager(this);
}

class CareLogDaoManager {
  final _$CareLogDaoMixin _db;
  CareLogDaoManager(this._db);
  $$BabiesTableTableManager get babies =>
      $$BabiesTableTableManager(_db.attachedDatabase, _db.babies);
  $$CareEventsTableTableManager get careEvents =>
      $$CareEventsTableTableManager(_db.attachedDatabase, _db.careEvents);
}

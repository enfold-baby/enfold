import 'package:drift/drift.dart';

/// Local mirror of VPS `children` — UUID string matches server on sync.
class Babies extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  BoolColumn get isPreemie =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get serverChildId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local mirror of VPS `care_events` — types: feeding, diaper, sleep, …
class CareEvents extends Table {
  TextColumn get id => text()();
  TextColumn get babyId => text()();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get detailsJson =>
      text().withDefault(const Constant('{}'))();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get clientUpdatedAt => dateTime()();
  BoolColumn get pendingSync =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get loggedByUserId => text().nullable()();
  TextColumn get loggedByDisplayName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local pregnancy profile — due date, daily kick count (offline-first).
class PregnancyProfiles extends Table {
  TextColumn get id => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get kickCountToday =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get kickCountDate => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Appointment notes for prenatal visits.
class PregnancyAppointments extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Weight, length, and head measurements — stored in metric (kg, cm).
class GrowthMeasurements extends Table {
  TextColumn get id => text()();
  TextColumn get babyId => text()();
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get lengthCm => real().nullable()();
  RealColumn get headCm => real().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Achieved developmental milestones (catalog keys are app-defined).
class MilestoneAchievements extends Table {
  TextColumn get babyId => text()();
  TextColumn get milestoneKey => text()();
  DateTimeColumn get achievedAt => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {babyId, milestoneKey};
}

/// Singleton app flags (row id = 1).
class AppSettings extends Table {
  IntColumn get id => integer()();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get useImperialUnits =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get partnerActivityPushEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get partnerGentleNudgeEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get themeMode =>
      text().withDefault(const Constant('system'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
import 'package:bloomdue_baby/services/auth/account_switch_service.dart';
import 'package:bloomdue_baby/services/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AccountSwitchService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = AccountSwitchService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('lastSignedInUserId defaults null and persists', () async {
    expect(await service.lastSignedInUserId(), isNull);

    await service.setLastSignedInUserId('user-a');
    expect(await service.lastSignedInUserId(), 'user-a');

    await service.setLastSignedInUserId(null);
    expect(await service.lastSignedInUserId(), isNull);
  });

  test('isAccountSwitch is false for first sign-in and same user', () async {
    expect(await service.isAccountSwitch('user-a'), isFalse);

    await service.setLastSignedInUserId('user-a');
    expect(await service.isAccountSwitch('user-a'), isFalse);
    expect(await service.isAccountSwitch('user-b'), isTrue);
  });

  test('uploadLocal unlinks server child but keeps care logs', () async {
    const babyId = 'baby-1';
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: babyId,
            name: 'Baby',
            createdAt: DateTime.now(),
            serverChildId: const Value('server-child'),
          ),
        );
    await db.into(db.careEvents).insert(
          CareEventsCompanion.insert(
            id: 'event-1',
            babyId: babyId,
            type: 'feeding',
            occurredAt: DateTime.now(),
            clientUpdatedAt: DateTime.now(),
          ),
        );

    await service.applySwitchChoice(AccountSwitchChoice.uploadLocal);

    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.serverChildId, isNull);
    expect(await db.select(db.careEvents).get(), hasLength(1));
  });

  test('startFresh clears care, growth, pregnancy and unlinks child', () async {
    const babyId = 'baby-1';
    final now = DateTime.now();
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: babyId,
            name: 'Baby',
            createdAt: now,
            serverChildId: const Value('server-child'),
          ),
        );
    await db.into(db.careEvents).insert(
          CareEventsCompanion.insert(
            id: 'event-1',
            babyId: babyId,
            type: 'feeding',
            occurredAt: now,
            clientUpdatedAt: now,
          ),
        );
    await db.into(db.growthMeasurements).insert(
          GrowthMeasurementsCompanion.insert(
            id: 'g1',
            babyId: babyId,
            measuredAt: now,
            createdAt: now,
            weightKg: const Value(3.5),
          ),
        );
    await db.into(db.milestoneAchievements).insert(
          MilestoneAchievementsCompanion.insert(
            babyId: babyId,
            milestoneKey: 'smile',
            achievedAt: now,
          ),
        );
    await db.into(db.pregnancyProfiles).insert(
          PregnancyProfilesCompanion.insert(
            id: 'p1',
            updatedAt: now,
            dueDate: Value(now.add(const Duration(days: 100))),
          ),
        );
    await db.into(db.pregnancyAppointments).insert(
          PregnancyAppointmentsCompanion.insert(
            id: 'a1',
            title: 'Scan',
            createdAt: now,
          ),
        );

    await service.applySwitchChoice(AccountSwitchChoice.startFresh);

    expect(await db.select(db.careEvents).get(), isEmpty);
    expect(await db.select(db.growthMeasurements).get(), isEmpty);
    expect(await db.select(db.milestoneAchievements).get(), isEmpty);
    expect(await db.select(db.pregnancyProfiles).get(), isEmpty);
    expect(await db.select(db.pregnancyAppointments).get(), isEmpty);

    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.id, babyId);
    expect(baby.serverChildId, isNull);
  });
}

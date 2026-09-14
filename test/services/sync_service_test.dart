import 'package:enfold/services/api/api_exception.dart';
import 'package:enfold/services/api/enfold_api_client.dart';
import 'package:enfold/services/api/family_models.dart';
import 'package:enfold/services/auth/auth_session.dart';
import 'package:enfold/services/database/app_database.dart';
import 'package:enfold/services/sync/sync_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class FakeEnfoldApi extends EnfoldApiClient {
  FakeEnfoldApi() : super(httpClient: http.Client());

  final String childId = 'server-child-1';
  int createCalls = 0;
  int createChildCalls = 0;
  List<ChildProfile> existingChildren = const [];

  @override
  Future<List<ChildProfile>> listChildren(String token) async =>
      existingChildren;

  @override
  Future<ChildProfile> createChild({
    required String token,
    required String name,
    DateTime? birthDate,
  }) async {
    createChildCalls++;
    return ChildProfile(id: childId, name: name);
  }

  @override
  Future<List<RemoteCareEvent>> listCareEvents({
    required String token,
    required String childId,
    DateTime? since,
  }) async {
    return const [];
  }

  @override
  Future<void> updateCareEvent({
    required String token,
    required String eventId,
    required String type,
    required DateTime occurredAt,
    Map<String, dynamic> details = const {},
    String note = '',
    DateTime? clientUpdatedAt,
  }) async {
    throw ApiException('Care event not found', statusCode: 404);
  }

  @override
  Future<void> createCareEvent({
    required String token,
    required String id,
    required String childId,
    required String type,
    required DateTime occurredAt,
    Map<String, dynamic> details = const {},
    String note = '',
    DateTime? clientUpdatedAt,
  }) async {
    createCalls++;
  }
}

void main() {
  late AppDatabase db;
  late FakeEnfoldApi api;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = FakeEnfoldApi();
    sync = SyncService(api: api, db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('pushes pending logs and marks them synced', () async {
    const localBabyId = 'local-baby';
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: localBabyId,
            name: 'Baby',
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.careEvents).insert(
          CareEventsCompanion.insert(
            id: 'event-1',
            babyId: localBabyId,
            type: 'feeding',
            occurredAt: DateTime.now(),
            clientUpdatedAt: DateTime.now(),
            pendingSync: const Value(true),
          ),
        );

    final result = await sync.syncPending(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    expect(result.ok, isTrue);
    expect(result.pushed, 1);
    expect(result.pulled, 0);
    expect(api.createCalls, 1);

    final row = await (db.select(db.careEvents)..limit(1)).getSingle();
    expect(row.pendingSync, isFalse);

    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.serverChildId, api.childId);
  });

  test('ensure path never creates a second child when family already has one',
      () async {
    const localBabyId = 'local-baby';
    api.existingChildren = [
      const ChildProfile(id: 'host-child', name: 'Damian', familyId: 'fam'),
    ];

    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: localBabyId,
            name: 'Local',
            createdAt: DateTime.now(),
            serverChildId: const Value('stale-solo-child'),
          ),
        );
    await db.into(db.careEvents).insert(
          CareEventsCompanion.insert(
            id: 'event-1',
            babyId: localBabyId,
            type: 'sleep',
            occurredAt: DateTime.now(),
            clientUpdatedAt: DateTime.now(),
            pendingSync: const Value(true),
          ),
        );

    final result = await sync.syncPending(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    expect(result.ok, isTrue, reason: result.error);
    // Care event is still pushed to the host child…
    expect(api.createCalls, 1);
    // …but we must not create another server baby.
    expect(api.createChildCalls, 0);
    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.serverChildId, 'host-child');
  });

  test('rebindToFamilyPrimaryChild attaches to oldest host child', () async {
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: 'local-baby',
            name: 'Local',
            createdAt: DateTime.now(),
            serverChildId: const Value('old-solo'),
          ),
        );
    api.existingChildren = [
      const ChildProfile(id: 'host-child', name: 'Damian', familyId: 'fam'),
      const ChildProfile(id: 'extra', name: 'Extra', familyId: 'fam'),
    ];

    final name = await sync.rebindToFamilyPrimaryChild(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    expect(name, 'Damian');
    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.serverChildId, 'host-child');
    expect(api.createChildCalls, 0);
  });
}
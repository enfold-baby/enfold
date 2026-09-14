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

class SyncTrackingApi extends EnfoldApiClient {
  SyncTrackingApi() : super(httpClient: http.Client());

  final String childId = 'server-child-1';
  final Set<String> serverEvents = {};
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  @override
  Future<List<ChildProfile>> listChildren(String token) async => [
        ChildProfile(id: childId, name: 'Baby'),
      ];

  @override
  Future<ChildProfile> createChild({
    required String token,
    required String name,
    DateTime? birthDate,
  }) async {
    return ChildProfile(id: childId, name: name);
  }

  @override
  Future<List<RemoteCareEvent>> listCareEvents({
    required String token,
    required String childId,
    DateTime? since,
  }) async {
    return [
      for (final id in serverEvents)
        RemoteCareEvent(
          id: id,
          childId: childId,
          type: 'feeding',
          occurredAt: DateTime.now(),
          details: const {},
          note: 'remote',
        ),
    ];
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
    serverEvents.add(id);
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
    if (!serverEvents.contains(eventId)) {
      throw ApiException('Care event not found', statusCode: 404);
    }
    updateCalls++;
  }

  @override
  Future<void> deleteCareEvent({
    required String token,
    required String eventId,
  }) async {
    if (!serverEvents.contains(eventId)) {
      throw ApiException('Care event not found', statusCode: 404);
    }
    deleteCalls++;
    serverEvents.remove(eventId);
  }
}

void main() {
  late AppDatabase db;
  late SyncTrackingApi api;
  late SyncService sync;

  const session = AuthSession(
    token: 'token',
    user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = SyncTrackingApi();
    sync = SyncService(api: api, db: db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedBabyAndEvent({
    required String eventId,
    required bool pendingSync,
    DateTime? deletedAt,
    String note = 'hello',
    bool onServer = true,
  }) async {
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: 'local-baby',
            name: 'Baby',
            createdAt: DateTime.now(),
            serverChildId: const Value('server-child-1'),
          ),
        );
    await db.into(db.careEvents).insert(
          CareEventsCompanion.insert(
            id: eventId,
            babyId: 'local-baby',
            type: 'feeding',
            occurredAt: DateTime.now(),
            note: Value(note),
            clientUpdatedAt: DateTime.now(),
            pendingSync: Value(pendingSync),
            deletedAt: Value(deletedAt),
          ),
        );
    if (!pendingSync && onServer) {
      api.serverEvents.add(eventId);
    }
  }

  test('syncPending patches an edited synced log', () async {
    await seedBabyAndEvent(eventId: 'event-edit', pendingSync: true);
    api.serverEvents.add('event-edit');

    final result = await sync.syncPending(session: session);

    expect(result.ok, isTrue);
    expect(result.pushed, 1);
    expect(api.updateCalls, 1);
    expect(api.createCalls, 0);

    final row = await (db.select(db.careEvents)..limit(1)).getSingle();
    expect(row.pendingSync, isFalse);
  });

  test('syncPending deletes a synced log on server', () async {
    await seedBabyAndEvent(
      eventId: 'event-del',
      pendingSync: true,
      deletedAt: DateTime.now(),
    );
    api.serverEvents.add('event-del');

    final result = await sync.syncPending(session: session);

    expect(result.ok, isTrue);
    expect(result.deleted, 1);
    expect(api.deleteCalls, 1);
    expect(api.serverEvents, isEmpty);

    final row = await (db.select(db.careEvents)..limit(1)).getSingle();
    expect(row.pendingSync, isFalse);
    expect(row.deletedAt, isNot(null));
  });

  test('pullRemote removes partner-deleted events locally', () async {
    await seedBabyAndEvent(
      eventId: 'gone-event',
      pendingSync: false,
      onServer: false,
    );

    final result = await sync.pullRemote(session: session);

    expect(result.ok, isTrue);
    expect(result.deleted, 1);

    final row = await (db.select(db.careEvents)..limit(1)).getSingle();
    expect(row.deletedAt, isNot(null));
    expect(row.pendingSync, isFalse);
  });
}
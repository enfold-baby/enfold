import 'package:bloomdue_baby/services/api/api_exception.dart';
import 'package:bloomdue_baby/services/api/bloomdue_api_client.dart';
import 'package:bloomdue_baby/services/api/family_models.dart';
import 'package:bloomdue_baby/services/auth/auth_session.dart';
import 'package:bloomdue_baby/services/database/app_database.dart';
import 'package:bloomdue_baby/services/sync/sync_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class FakeBloomdueApi extends BloomdueApiClient {
  FakeBloomdueApi() : super(httpClient: http.Client());

  final String childId = 'server-child-1';
  int createCalls = 0;

  @override
  Future<List<ChildProfile>> listChildren(String token) async => [];

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
  late FakeBloomdueApi api;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = FakeBloomdueApi();
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
}
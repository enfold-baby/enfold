import 'package:bloomdue_baby/services/api/bloomdue_api_client.dart';
import 'package:bloomdue_baby/services/api/family_models.dart';
import 'package:bloomdue_baby/services/auth/auth_session.dart';
import 'package:bloomdue_baby/services/database/app_database.dart';
import 'package:bloomdue_baby/services/sync/sync_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class FakePullApi extends BloomdueApiClient {
  FakePullApi() : super(httpClient: http.Client());

  final String childId = 'server-child-1';
  final remoteEvent = RemoteCareEvent(
    id: 'partner-event-1',
    childId: 'server-child-1',
    type: 'feeding',
    occurredAt: DateTime.now(),
    details: const {'feed_mode': 'bottle', 'bottle_ml': 60},
    note: 'from partner',
    createdByUserId: 'partner-user',
    createdByDisplayName: 'Raul',
  );

  @override
  Future<List<ChildProfile>> listChildren(String token) async {
    return [ChildProfile(id: childId, name: 'Baby', familyId: 'fam-1')];
  }

  @override
  Future<List<RemoteCareEvent>> listCareEvents({
    required String token,
    required String childId,
  }) async {
    return [remoteEvent];
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
  }) async {}
}

void main() {
  late AppDatabase db;
  late FakePullApi api;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = FakePullApi();
    sync = SyncService(api: api, db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('pullRemote merges partner care events locally', () async {
    const localBabyId = 'local-baby';
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: localBabyId,
            name: 'Baby',
            createdAt: DateTime.now(),
            serverChildId: const Value('server-child-1'),
          ),
        );

    final result = await sync.pullRemote(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    expect(result.ok, isTrue);
    expect(result.pulled, 1);

    final logs = await db.careLogDao.getTodayLogs(localBabyId);
    expect(logs, hasLength(1));
    expect(logs.first.id, 'partner-event-1');
    expect(logs.first.note, 'from partner');
    expect(logs.first.pendingSync, isFalse);
    expect(logs.first.loggedByUserId, 'partner-user');
    expect(logs.first.loggedByDisplayName, 'Raul');
  });
}
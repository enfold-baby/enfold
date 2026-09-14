import 'package:enfold/services/api/api_exception.dart';
import 'package:enfold/services/api/enfold_api_client.dart';
import 'package:enfold/services/api/family_models.dart';
import 'package:enfold/services/auth/auth_session.dart';
import 'package:enfold/services/database/app_database.dart';
import 'package:enfold/services/database/care_log_dao.dart';
import 'package:enfold/services/sync/sync_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class FakePullApi extends EnfoldApiClient {
  FakePullApi() : super(httpClient: http.Client());

  final String childId = 'server-child-1';
  String childName = 'Baby';
  DateTime? childBirthDate;
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
  List<RemoteCareEvent> extraEvents = const [];

  @override
  Future<List<ChildProfile>> listChildren(String token) async {
    return [
      ChildProfile(
        id: childId,
        name: childName,
        familyId: 'fam-1',
        birthDate: childBirthDate,
      ),
    ];
  }

  @override
  Future<List<RemoteCareEvent>> listCareEvents({
    required String token,
    required String childId,
    DateTime? since,
  }) async {
    return [remoteEvent, ...extraEvents];
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

  test('pullRemote fullHistory includes events outside lookback window', () async {
    const localBabyId = 'local-baby';
    final oldEvent = RemoteCareEvent(
      id: 'old-event',
      childId: 'server-child-1',
      type: 'diaper',
      occurredAt: DateTime.now().subtract(const Duration(days: 14)),
      details: const {},
      note: 'old',
    );
    api.extraEvents = [oldEvent];

    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: localBabyId,
            name: 'Baby',
            createdAt: DateTime.now(),
            serverChildId: const Value('server-child-1'),
          ),
        );

    final limited = await sync.pullRemote(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );
    expect(limited.pulled, 1); // only today's partner event

    final full = await sync.pullRemote(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
      fullHistory: true,
    );
    expect(full.pulled, 1); // old event newly merged

    final all = await db.select(db.careEvents).get();
    expect(all.map((e) => e.id).toSet(), {'partner-event-1', 'old-event'});
  });

  test('pullRemote re-links when local serverChildId is from old family', () async {
    const localBabyId = 'local-baby';
    final staleId = 'stale-child';
    final goodId = 'server-child-1';
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: localBabyId,
            name: 'Baby',
            createdAt: DateTime.now(),
            serverChildId: Value(staleId),
          ),
        );

    final staleApi = _StaleThenGoodPullApi(staleId: staleId, goodId: goodId);
    final staleSync = SyncService(api: staleApi, db: db);

    final result = await staleSync.pullRemote(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    expect(result.ok, isTrue, reason: result.error);
    expect(result.pulled, 1);
    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.serverChildId, goodId);
  });

  test('pullRemote merges care events from all family children', () async {
    const localBabyId = 'local-baby';
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: localBabyId,
            name: 'Baby',
            createdAt: DateTime.now(),
            serverChildId: const Value('child-a'),
          ),
        );

    final multi = SyncService(api: _MultiChildPullApi(), db: db);
    final result = await multi.pullRemote(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    expect(result.ok, isTrue, reason: result.error);
    expect(result.pulled, 2);
    final ids = (await db.select(db.careEvents).get()).map((e) => e.id).toSet();
    expect(ids, {'feed-a', 'sleep-b'});
  });

  test('pullRemote fills a placeholder baby from the server child', () async {
    api.childName = 'Mia';
    api.childBirthDate = DateTime(2026, 7, 14);
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: 'local-baby',
            name: CareLogDao.defaultBabyName,
            createdAt: DateTime.now(),
          ),
        );

    await sync.pullRemote(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    final baby = await db.select(db.babies).getSingle();
    expect(baby.name, 'Mia');
    expect(baby.birthDate, DateTime(2026, 7, 14));
    expect(baby.serverChildId, 'server-child-1');
  });

  test('pullRemote keeps a name and birth date set on this phone', () async {
    api.childName = 'Mia';
    api.childBirthDate = DateTime(2026, 7, 14);
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: 'local-baby',
            name: 'Noah',
            birthDate: Value(DateTime(2026, 8, 1)),
            createdAt: DateTime.now(),
          ),
        );

    await sync.pullRemote(
      session: const AuthSession(
        token: 'token',
        user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
      ),
    );

    final baby = await db.select(db.babies).getSingle();
    expect(baby.name, 'Noah');
    expect(baby.birthDate, DateTime(2026, 8, 1));
  });
}

class _StaleThenGoodPullApi extends EnfoldApiClient {
  _StaleThenGoodPullApi({required this.staleId, required this.goodId})
      : super(httpClient: http.Client());

  final String staleId;
  final String goodId;

  @override
  Future<List<ChildProfile>> listChildren(String token) async {
    // Stale id is not in the current family — only the good child is.
    return [ChildProfile(id: goodId, name: 'Partner Baby', familyId: 'fam')];
  }

  @override
  Future<List<RemoteCareEvent>> listCareEvents({
    required String token,
    required String childId,
    DateTime? since,
  }) async {
    if (childId == staleId) {
      throw ApiException('Child not found', statusCode: 404);
    }
    return [
      RemoteCareEvent(
        id: 'partner-event-1',
        childId: goodId,
        type: 'feeding',
        occurredAt: DateTime.now(),
        details: const {},
        note: 'ok',
      ),
    ];
  }
}

class _MultiChildPullApi extends EnfoldApiClient {
  _MultiChildPullApi() : super(httpClient: http.Client());

  @override
  Future<List<ChildProfile>> listChildren(String token) async {
    return const [
      ChildProfile(id: 'child-a', name: 'Baby A', familyId: 'fam'),
      ChildProfile(id: 'child-b', name: 'Baby B', familyId: 'fam'),
    ];
  }

  @override
  Future<List<RemoteCareEvent>> listCareEvents({
    required String token,
    required String childId,
    DateTime? since,
  }) async {
    if (childId == 'child-a') {
      return [
        RemoteCareEvent(
          id: 'feed-a',
          childId: 'child-a',
          type: 'feeding',
          occurredAt: DateTime.now(),
          details: const {},
          note: 'from a',
        ),
      ];
    }
    return [
      RemoteCareEvent(
        id: 'sleep-b',
        childId: 'child-b',
        type: 'sleep',
        occurredAt: DateTime.now(),
        details: const {},
        note: 'from b',
      ),
    ];
  }
}

import 'package:enfold/services/api/api_exception.dart';
import 'package:enfold/services/api/enfold_api_client.dart';
import 'package:enfold/services/api/family_models.dart';
import 'package:enfold/services/auth/auth_session.dart';
import 'package:enfold/services/database/app_database.dart';
import 'package:enfold/services/sync/sync_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// In-memory stand-in for the family server's growth endpoints.
class FakeGrowthApi extends EnfoldApiClient {
  FakeGrowthApi() : super(httpClient: http.Client());

  List<String> childIds = ['server-child-1'];
  final measurements = <String, RemoteGrowthMeasurement>{};
  final milestones = <String, RemoteMilestone>{}; // "child|key"
  final deletedMilestoneKeys = <String>[];
  bool growthEndpointsMissing = false;

  @override
  Future<List<ChildProfile>> listChildren(String token) async => [
        for (final id in childIds) ChildProfile(id: id, name: 'Ana'),
      ];

  void _maybeMissing() {
    if (growthEndpointsMissing) throw ApiException('Not Found', statusCode: 404);
  }

  @override
  Future<List<RemoteGrowthMeasurement>> listGrowthMeasurements({
    required String token,
    required String childId,
  }) async {
    _maybeMissing();
    return measurements.values.where((m) => m.childId == childId).toList();
  }

  @override
  Future<void> putGrowthMeasurement({
    required String token,
    required String id,
    required String childId,
    required DateTime measuredAt,
    double? weightKg,
    double? lengthCm,
    double? headCm,
    String note = '',
  }) async {
    _maybeMissing();
    measurements[id] = RemoteGrowthMeasurement(
      id: id,
      childId: childId,
      measuredAt: measuredAt,
      weightKg: weightKg,
      lengthCm: lengthCm,
      headCm: headCm,
      note: note,
    );
  }

  @override
  Future<void> deleteGrowthMeasurement({
    required String token,
    required String id,
  }) async {
    if (measurements.remove(id) == null) {
      throw ApiException('Growth measurement not found', statusCode: 404);
    }
  }

  @override
  Future<List<RemoteMilestone>> listMilestones({
    required String token,
    required String childId,
  }) async {
    _maybeMissing();
    return milestones.values.where((m) => m.childId == childId).toList();
  }

  @override
  Future<void> putMilestone({
    required String token,
    required String childId,
    required String milestoneKey,
    required DateTime achievedAt,
    String note = '',
  }) async {
    milestones['$childId|$milestoneKey'] = RemoteMilestone(
      childId: childId,
      milestoneKey: milestoneKey,
      achievedAt: achievedAt,
      note: note,
    );
  }

  @override
  Future<void> deleteMilestone({
    required String token,
    required String childId,
    required String milestoneKey,
  }) async {
    if (milestones.remove('$childId|$milestoneKey') == null) {
      throw ApiException('Milestone not found', statusCode: 404);
    }
    deletedMilestoneKeys.add('$childId|$milestoneKey');
  }
}

const _session = AuthSession(
  token: 'token',
  user: AuthUser(id: 'u1', email: 'a@b.com', displayName: ''),
);

void main() {
  late AppDatabase db;
  late FakeGrowthApi api;
  late SyncService sync;
  const babyId = 'local-baby';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    api = FakeGrowthApi();
    sync = SyncService(api: api, db: db);
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: babyId,
            name: 'Ana',
            createdAt: DateTime.now(),
            serverChildId: const Value('server-child-1'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('pushes a new measurement and milestone, then marks them synced', () async {
    final id = await db.growthDao.insertMeasurement(
      babyId: babyId,
      measuredAt: DateTime(2026, 9, 1),
      weightKg: 4.2,
      lengthCm: 54,
    );
    await db.growthDao.setMilestoneAchieved(
      babyId: babyId,
      milestoneKey: 'social_smile',
      achievedAt: DateTime(2026, 9, 2),
    );

    final result = await sync.syncGrowth(session: _session);

    expect(result.ok, isTrue, reason: result.error);
    expect(result.pushed, 2);
    expect(api.measurements[id]!.weightKg, 4.2);
    expect(api.milestones['server-child-1|social_smile'], isNotNull);
    expect(await db.growthDao.pendingMeasurements(babyId), isEmpty);
    expect(await db.growthDao.pendingMilestones(babyId), isEmpty);
  });

  test('a partner phone pulls the family growth data', () async {
    api.measurements['m-1'] = RemoteGrowthMeasurement(
      id: 'm-1',
      childId: 'server-child-1',
      measuredAt: DateTime(2026, 8, 20),
      weightKg: 3.9,
      headCm: 36.5,
    );
    api.milestones['server-child-1|coos'] = RemoteMilestone(
      childId: 'server-child-1',
      milestoneKey: 'coos',
      achievedAt: DateTime(2026, 8, 25),
    );

    final result = await sync.syncGrowth(session: _session);

    expect(result.ok, isTrue, reason: result.error);
    final rows = await db.growthDao.watchMeasurements(babyId).first;
    expect(rows.single.id, 'm-1');
    expect(rows.single.headCm, 36.5);
    expect(rows.single.pendingSync, isFalse);
    final achieved = await db.growthDao.watchMilestoneAchievements(babyId).first;
    expect(achieved.single.milestoneKey, 'coos');
  });

  test('local deletes reach the server and then leave the phone', () async {
    final id = await db.growthDao.insertMeasurement(
      babyId: babyId,
      measuredAt: DateTime(2026, 9, 1),
      weightKg: 4.2,
    );
    await db.growthDao.setMilestoneAchieved(
      babyId: babyId,
      milestoneKey: 'coos',
      achievedAt: DateTime(2026, 9, 2),
    );
    await sync.syncGrowth(session: _session);

    await db.growthDao.deleteMeasurement(id);
    await db.growthDao.clearMilestone(babyId: babyId, milestoneKey: 'coos');
    expect(await db.growthDao.watchMeasurements(babyId).first, isEmpty);

    final result = await sync.syncGrowth(session: _session);

    expect(result.ok, isTrue, reason: result.error);
    expect(result.deleted, 2);
    expect(api.measurements, isEmpty);
    expect(api.milestones, isEmpty);
    expect(await db.select(db.growthMeasurements).get(), isEmpty);
    expect(await db.select(db.milestoneAchievements).get(), isEmpty);
  });

  test('a clear removes the key from every family child', () async {
    api.childIds = ['server-child-1', 'server-child-2'];
    api.milestones['server-child-2|coos'] = RemoteMilestone(
      childId: 'server-child-2',
      milestoneKey: 'coos',
      achievedAt: DateTime(2026, 8, 25),
    );
    await sync.syncGrowth(session: _session);
    await db.growthDao.clearMilestone(babyId: babyId, milestoneKey: 'coos');

    await sync.syncGrowth(session: _session);

    expect(api.deletedMilestoneKeys, ['server-child-2|coos']);
    expect(await db.growthDao.watchMilestoneAchievements(babyId).first, isEmpty);
  });

  test('a partner delete removes the synced row but keeps unpushed ones', () async {
    api.measurements['m-1'] = RemoteGrowthMeasurement(
      id: 'm-1',
      childId: 'server-child-1',
      measuredAt: DateTime(2026, 8, 20),
      weightKg: 3.9,
    );
    await sync.syncGrowth(session: _session);
    api.measurements.remove('m-1');
    api.growthEndpointsMissing = true;
    final localId = await db.growthDao.insertMeasurement(
      babyId: babyId,
      measuredAt: DateTime(2026, 9, 1),
      weightKg: 4.2,
    );
    // Server unreachable for growth: nothing changes locally.
    expect((await sync.syncGrowth(session: _session)).ok, isFalse);
    expect((await db.growthDao.watchMeasurements(babyId).first).length, 2);

    api.growthEndpointsMissing = false;
    await sync.syncGrowth(session: _session);

    final rows = await db.growthDao.watchMeasurements(babyId).first;
    expect(rows.map((r) => r.id), [localId]);
  });

  test('growth rows from before sync start pending, so they upload once', () async {
    await db.into(db.growthMeasurements).insert(
          GrowthMeasurementsCompanion.insert(
            id: 'old-1',
            babyId: babyId,
            measuredAt: DateTime(2026, 7, 1),
            createdAt: DateTime(2026, 7, 1),
            weightKg: const Value(3.4),
          ),
        );
    await sync.syncGrowth(session: _session);
    expect(api.measurements.keys, ['old-1']);
  });
}

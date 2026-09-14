import 'dart:convert';

import 'package:drift/drift.dart';

import '../api/api_exception.dart';
import '../api/enfold_api_client.dart';
import '../api/family_models.dart';
import '../auth/auth_session.dart';
import '../database/app_database.dart';
import '../database/care_log_dao.dart';

class SyncResult {
  const SyncResult({
    required this.pushed,
    this.pulled = 0,
    this.deleted = 0,
    this.error,
  });

  final int pushed;
  final int pulled;
  final int deleted;
  final String? error;

  bool get ok => error == null;
}

class SyncService {
  SyncService({
    required EnfoldApiClient api,
    required AppDatabase db,
  })  : _api = api,
        _db = db;

  final EnfoldApiClient _api;
  final AppDatabase _db;

  static const pullLookbackDays = 2;
  static final _fullHistorySince = DateTime.utc(2000);

  Future<SyncResult> syncAll({
    required AuthSession session,
    bool fullHistory = false,
  }) async {
    final pushResult = await syncPending(session: session);
    if (!pushResult.ok) return pushResult;

    final pullResult = await pullRemote(
      session: session,
      fullHistory: fullHistory,
    );

    // Growth runs on its own so a failure there never holds back care logs.
    final growthResult = await syncGrowth(session: session);

    return SyncResult(
      pushed: pushResult.pushed + growthResult.pushed,
      pulled: pullResult.pulled + growthResult.pulled,
      deleted: pushResult.deleted + pullResult.deleted + growthResult.deleted,
      error: pullResult.error ?? growthResult.error,
    );
  }

  /// Push local growth measurements and milestones, then take the family's
  /// full list (it is small, so no lookback window).
  Future<SyncResult> syncGrowth({required AuthSession session}) async {
    try {
      final baby = await (_db.select(_db.babies)..limit(1)).getSingleOrNull();
      if (baby == null) return const SyncResult(pushed: 0);

      final pendingMeasurements = await _db.growthDao.pendingMeasurements(baby.id);
      final pendingMilestones = await _db.growthDao.pendingMilestones(baby.id);

      var pushed = 0;
      var deleted = 0;
      if (pendingMeasurements.isNotEmpty || pendingMilestones.isNotEmpty) {
        var childId = await _linkedServerChildId(
          session: session,
          baby: baby,
          createIfMissing: true,
        );
        if (childId == null) {
          return const SyncResult(pushed: 0, error: 'Could not link a baby profile');
        }

        // A stale child link after join/leave: re-link once and retry.
        Future<void> withChild(Future<void> Function(String childId) send) async {
          try {
            await send(childId!);
          } on ApiException catch (e) {
            if (!_isChildNotFound(e)) rethrow;
            childId = await _relinkServerChild(
              session: session,
              baby: baby,
              createIfMissing: true,
            );
            if (childId == null) rethrow;
            await send(childId!);
          }
        }

        for (final row in pendingMeasurements) {
          if (row.deletedAt != null) {
            try {
              await _api.deleteGrowthMeasurement(token: session.token, id: row.id);
            } on ApiException catch (e) {
              if (e.statusCode != 404) rethrow;
            }
            deleted++;
          } else {
            await withChild(
              (id) => _api.putGrowthMeasurement(
                token: session.token,
                id: row.id,
                childId: id,
                measuredAt: row.measuredAt,
                weightKg: row.weightKg,
                lengthCm: row.lengthCm,
                headCm: row.headCm,
                note: row.note,
              ),
            );
            pushed++;
          }
          await _db.growthDao.markMeasurementPushed(row);
        }

        final clearedMilestones =
            pendingMilestones.where((row) => row.deletedAt != null).toList();
        // A cleared key may sit under any of the family's server children.
        final familyChildIds = clearedMilestones.isEmpty
            ? const <String>[]
            : (await _api.listChildren(session.token)).map((c) => c.id).toList();

        for (final row in pendingMilestones) {
          if (row.deletedAt != null) {
            for (final id in familyChildIds) {
              try {
                await _api.deleteMilestone(
                  token: session.token,
                  childId: id,
                  milestoneKey: row.milestoneKey,
                );
              } on ApiException catch (e) {
                if (e.statusCode != 404) rethrow;
              }
            }
            deleted++;
          } else {
            await withChild(
              (id) => _api.putMilestone(
                token: session.token,
                childId: id,
                milestoneKey: row.milestoneKey,
                achievedAt: row.achievedAt,
                note: row.note,
              ),
            );
            pushed++;
          }
          await _db.growthDao.markMilestonePushed(row);
        }
      }

      final children = await _api.listChildren(session.token);
      if (children.isEmpty) {
        return SyncResult(pushed: pushed, deleted: deleted);
      }
      final measurements = <RemoteGrowthMeasurement>[];
      final milestones = <RemoteMilestone>[];
      for (final child in children) {
        try {
          measurements.addAll(
            await _api.listGrowthMeasurements(token: session.token, childId: child.id),
          );
          milestones.addAll(
            await _api.listMilestones(token: session.token, childId: child.id),
          );
        } on ApiException catch (e) {
          if (!_isChildNotFound(e)) rethrow;
        }
      }

      final pulled = await _db.growthDao.mergeRemoteMeasurements(
            babyId: baby.id,
            remote: measurements,
          ) +
          await _db.growthDao.mergeRemoteMilestones(
            babyId: baby.id,
            remote: milestones,
          );

      return SyncResult(pushed: pushed, pulled: pulled, deleted: deleted);
    } on ApiException catch (e) {
      return SyncResult(pushed: 0, error: e.message);
    } catch (e) {
      return SyncResult(pushed: 0, error: e.toString());
    }
  }

  Future<SyncResult> syncPending({required AuthSession session}) async {
    try {
      final baby = await (_db.select(_db.babies)..limit(1)).getSingleOrNull();
      if (baby == null) return const SyncResult(pushed: 0);

      final serverChildId = await _linkedServerChildId(
        session: session,
        baby: baby,
        createIfMissing: true,
      );
      if (serverChildId == null) {
        return const SyncResult(pushed: 0, error: 'Could not link a baby profile');
      }

      var pushed = 0;
      var deleted = 0;

      final pendingDeletes = await (_db.select(_db.careEvents)
            ..where(
              (e) =>
                  e.babyId.equals(baby.id) &
                  e.pendingSync.equals(true) &
                  e.deletedAt.isNotNull(),
            )
            ..orderBy([(e) => OrderingTerm.asc(e.occurredAt)]))
          .get();

      for (final event in pendingDeletes) {
        try {
          await _api.deleteCareEvent(
            token: session.token,
            eventId: event.id,
          );
        } on ApiException catch (e) {
          if (e.statusCode != 404) rethrow;
        }
        await (_db.update(_db.careEvents)..where((e) => e.id.equals(event.id)))
            .write(const CareEventsCompanion(pendingSync: Value(false)));
        deleted++;
      }

      final pendingUpserts = await (_db.select(_db.careEvents)
            ..where(
              (e) =>
                  e.babyId.equals(baby.id) &
                  e.pendingSync.equals(true) &
                  e.deletedAt.isNull(),
            )
            ..orderBy([(e) => OrderingTerm.asc(e.occurredAt)]))
          .get();

      for (final event in pendingUpserts) {
        final details = _decodeDetails(event.detailsJson);
        final payload = (
          type: event.type,
          occurredAt: event.occurredAt,
          details: details,
          note: event.note,
          clientUpdatedAt: event.clientUpdatedAt,
        );

        var synced = false;
        try {
          await _api.updateCareEvent(
            token: session.token,
            eventId: event.id,
            type: payload.type,
            occurredAt: payload.occurredAt,
            details: payload.details,
            note: payload.note,
            clientUpdatedAt: payload.clientUpdatedAt,
          );
          synced = true;
        } on ApiException catch (e) {
          if (e.statusCode != 404) rethrow;
        }

        if (!synced) {
          try {
            await _api.createCareEvent(
              token: session.token,
              id: event.id,
              childId: serverChildId,
              type: payload.type,
              occurredAt: payload.occurredAt,
              details: payload.details,
              note: payload.note,
              clientUpdatedAt: payload.clientUpdatedAt,
            );
          } on ApiException catch (e) {
            // Stale child after join/leave — re-link once and retry create.
            if (!_isChildNotFound(e)) rethrow;
            final relinked = await _relinkServerChild(
              session: session,
              baby: baby,
              createIfMissing: true,
            );
            if (relinked == null) rethrow;
            await _api.createCareEvent(
              token: session.token,
              id: event.id,
              childId: relinked,
              type: payload.type,
              occurredAt: payload.occurredAt,
              details: payload.details,
              note: payload.note,
              clientUpdatedAt: payload.clientUpdatedAt,
            );
          }
        }

        await (_db.update(_db.careEvents)..where((e) => e.id.equals(event.id)))
            .write(const CareEventsCompanion(pendingSync: Value(false)));
        pushed++;
      }

      return SyncResult(pushed: pushed, deleted: deleted);
    } on ApiException catch (e) {
      return SyncResult(pushed: 0, error: e.message);
    } catch (e) {
      return SyncResult(pushed: 0, error: e.toString());
    }
  }

  Future<SyncResult> pullRemote({
    required AuthSession session,
    bool fullHistory = false,
  }) async {
    try {
      final baby = await (_db.select(_db.babies)..limit(1)).getSingleOrNull();
      if (baby == null) return const SyncResult(pushed: 0);

      // After partners join, a family often has *multiple* server children
      // (each device created one). Pull every child's events so partners see
      // each other's logs; keep one primary child id for future pushes.
      final children = await _api.listChildren(session.token);
      if (children.isEmpty) return const SyncResult(pushed: 0);

      final primaryId = _pickPrimaryChildId(
        children: children,
        preferredId: baby.serverChildId,
      );
      if (baby.serverChildId != primaryId) {
        await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id)))
            .write(BabiesCompanion(serverChildId: Value(primaryId)));
      }
      await _adoptServerChildProfile(
        baby: baby,
        child: children.firstWhere((c) => c.id == primaryId),
      );

      DateTime? since;
      if (!fullHistory) {
        final lookback = DateTime.now().subtract(
          const Duration(days: pullLookbackDays),
        );
        since = DateTime(lookback.year, lookback.month, lookback.day);
      }

      final byId = <String, RemoteCareEvent>{};
      for (final child in children) {
        try {
          final events = await _api.listCareEvents(
            token: session.token,
            childId: child.id,
            // Deletions are reconciled over this window, so it must come back
            // complete (the server caps requests without `since` at 200).
            since: since ?? _fullHistorySince,
          );
          for (final event in events) {
            byId[event.id] = event;
          }
        } on ApiException catch (e) {
          if (!_isChildNotFound(e)) rethrow;
        }
      }
      final remoteEvents = byId.values.toList();

      final pulled = await _db.careLogDao.upsertRemoteCareEvents(
        babyId: baby.id,
        events: remoteEvents,
        since: since,
      );

      final removed = await _db.careLogDao.reconcileRemoteDeletions(
        babyId: baby.id,
        remoteIds: remoteEvents.map((e) => e.id).toSet(),
        since: since,
      );

      return SyncResult(pushed: 0, pulled: pulled, deleted: removed);
    } on ApiException catch (e) {
      return SyncResult(pushed: 0, error: e.message);
    } catch (e) {
      return SyncResult(pushed: 0, error: e.toString());
    }
  }

  bool _isChildNotFound(ApiException e) {
    if (e.statusCode != 404) return false;
    final msg = e.message.toLowerCase();
    return msg.contains('child') || msg == 'not found';
  }

  /// Prefer a still-valid linked child; otherwise oldest family child
  /// (`listChildren` is ordered by `created_at` ascending on the server).
  ///
  /// Never invent a new child when the family already has one — partners
  /// joining must attach to the host baby, not create a duplicate.
  String _pickPrimaryChildId({
    required List<ChildProfile> children,
    required String? preferredId,
  }) {
    assert(children.isNotEmpty);
    if (preferredId != null &&
        preferredId.isNotEmpty &&
        children.any((c) => c.id == preferredId)) {
      return preferredId;
    }
    return children.first.id;
  }

  /// A fresh install (or a reinstall) starts with a placeholder "Baby" and no
  /// birth date. Fill those from the family's server child so the real name
  /// shows up, without ever overwriting a name or date set on this phone.
  Future<void> _adoptServerChildProfile({
    required Baby baby,
    required ChildProfile child,
  }) async {
    final serverName = child.name.trim();
    final adoptName = baby.name == CareLogDao.defaultBabyName &&
        serverName.isNotEmpty &&
        serverName != baby.name;
    final adoptBirthDate = baby.birthDate == null && child.birthDate != null;
    if (!adoptName && !adoptBirthDate) return;
    await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id))).write(
      BabiesCompanion(
        name: adoptName ? Value(serverName) : const Value.absent(),
        birthDate:
            adoptBirthDate ? Value(child.birthDate) : const Value.absent(),
      ),
    );
  }

  /// After join: drop any solo-family child link and bind to the host primary.
  /// Returns the shared baby's display name when available.
  Future<String?> rebindToFamilyPrimaryChild({
    required AuthSession session,
  }) async {
    final baby = await (_db.select(_db.babies)..limit(1)).getSingleOrNull();
    if (baby == null) return null;

    await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id))).write(
      const BabiesCompanion(serverChildId: Value(null)),
    );

    final children = await _api.listChildren(session.token);
    if (children.isEmpty) return null;

    final primary = children.first;
    await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id))).write(
      BabiesCompanion(serverChildId: Value(primary.id)),
    );
    return primary.name;
  }

  Future<String?> _linkedServerChildId({
    required AuthSession session,
    required Baby baby,
    required bool createIfMissing,
  }) async {
    final children = await _api.listChildren(session.token);
    if (children.isNotEmpty) {
      final id = _pickPrimaryChildId(
        children: children,
        preferredId: baby.serverChildId,
      );
      if (baby.serverChildId != id) {
        await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id)))
            .write(BabiesCompanion(serverChildId: Value(id)));
      }
      return id;
    }
    if (!createIfMissing) return null;
    return _ensureServerChild(
      session,
      baby: baby,
      name: baby.name,
      birthDate: baby.birthDate,
    );
  }

  Future<String?> _relinkServerChild({
    required AuthSession session,
    required Baby baby,
    required bool createIfMissing,
  }) async {
    await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id))).write(
      const BabiesCompanion(serverChildId: Value(null)),
    );
    final refreshed = await (_db.select(_db.babies)
          ..where((b) => b.id.equals(baby.id)))
        .getSingle();
    return _linkedServerChildId(
      session: session,
      baby: refreshed,
      createIfMissing: createIfMissing,
    );
  }

  Future<String> _ensureServerChild(
    AuthSession session, {
    required Baby baby,
    required String name,
    DateTime? birthDate,
  }) async {
    final children = await _api.listChildren(session.token);
    // Hard rule: if the family already has a child (host baby), never create
    // another — that caused partner sync to split events across two babies.
    final String id;
    if (children.isNotEmpty) {
      id = children.first.id;
    } else {
      id = (await _api.createChild(
        token: session.token,
        name: name,
        birthDate: birthDate,
      ))
          .id;
    }
    await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id))).write(
      BabiesCompanion(serverChildId: Value(id)),
    );
    return id;
  }

  Map<String, dynamic> _decodeDetails(String json) {
    if (json.isEmpty || json == '{}') return {};
    final decoded = jsonDecode(json);
    return decoded is Map<String, dynamic> ? decoded : {};
  }
}
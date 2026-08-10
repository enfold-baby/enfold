import 'dart:convert';

import 'package:drift/drift.dart';

import '../api/api_exception.dart';
import '../api/bloomdue_api_client.dart';
import '../api/family_models.dart';
import '../auth/auth_session.dart';
import '../database/app_database.dart';

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
    required BloomdueApiClient api,
    required AppDatabase db,
  })  : _api = api,
        _db = db;

  final BloomdueApiClient _api;
  final AppDatabase _db;

  static const pullLookbackDays = 2;

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
    if (!pullResult.ok) {
      return SyncResult(
        pushed: pushResult.pushed,
        pulled: pullResult.pulled,
        deleted: pushResult.deleted + pullResult.deleted,
        error: pullResult.error,
      );
    }

    return SyncResult(
      pushed: pushResult.pushed,
      pulled: pullResult.pulled,
      deleted: pushResult.deleted + pullResult.deleted,
    );
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

      var serverChildId = await _linkedServerChildId(
        session: session,
        baby: baby,
        createIfMissing: false,
      );
      if (serverChildId == null) return const SyncResult(pushed: 0);

      List<RemoteCareEvent> remoteEvents;
      try {
        remoteEvents = await _api.listCareEvents(
          token: session.token,
          childId: serverChildId,
        );
      } on ApiException catch (e) {
        if (!_isChildNotFound(e)) rethrow;
        // Local serverChildId is from an old family (common after join).
        final relinked = await _relinkServerChild(
          session: session,
          baby: baby,
          createIfMissing: false,
        );
        if (relinked == null) return const SyncResult(pushed: 0);
        remoteEvents = await _api.listCareEvents(
          token: session.token,
          childId: relinked,
        );
        serverChildId = relinked;
      }

      DateTime? since;
      if (!fullHistory) {
        final lookback = DateTime.now().subtract(
          const Duration(days: pullLookbackDays),
        );
        since = DateTime(lookback.year, lookback.month, lookback.day);
      }

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

  Future<String?> _linkedServerChildId({
    required AuthSession session,
    required Baby baby,
    required bool createIfMissing,
  }) async {
    final existing = baby.serverChildId;
    if (existing != null && existing.isNotEmpty) return existing;
    if (createIfMissing) {
      return _ensureServerChild(
        session,
        baby: baby,
        name: baby.name,
        birthDate: baby.birthDate,
      );
    }
    return _resolveAndPersistServerChild(session: session, baby: baby);
  }

  Future<String?> _relinkServerChild({
    required AuthSession session,
    required Baby baby,
    required bool createIfMissing,
  }) async {
    await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id))).write(
      const BabiesCompanion(serverChildId: Value(null)),
    );
    if (createIfMissing) {
      return _ensureServerChild(
        session,
        baby: baby,
        name: baby.name,
        birthDate: baby.birthDate,
      );
    }
    return _resolveAndPersistServerChild(session: session, baby: baby);
  }

  Future<String?> _resolveAndPersistServerChild({
    required AuthSession session,
    required Baby baby,
  }) async {
    final children = await _api.listChildren(session.token);
    if (children.isEmpty) return null;
    final id = children.first.id;
    await (_db.update(_db.babies)..where((b) => b.id.equals(baby.id))).write(
      BabiesCompanion(serverChildId: Value(id)),
    );
    return id;
  }

  Future<String> _ensureServerChild(
    AuthSession session, {
    required Baby baby,
    required String name,
    DateTime? birthDate,
  }) async {
    final children = await _api.listChildren(session.token);
    final id = children.isNotEmpty
        ? children.first.id
        : (await _api.createChild(
            token: session.token,
            name: name,
            birthDate: birthDate,
          ))
            .id;
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
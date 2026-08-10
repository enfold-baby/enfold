import 'package:bloomdue_baby/features/settings/widgets/account_section.dart';
import 'package:bloomdue_baby/services/api/bloomdue_api_client.dart';
import 'package:bloomdue_baby/services/auth/account_switch_service.dart';
import 'package:bloomdue_baby/services/auth/auth_providers.dart';
import 'package:bloomdue_baby/services/auth/auth_session.dart';
import 'package:bloomdue_baby/services/database/app_database.dart';
import 'package:bloomdue_baby/services/database/database_provider.dart';
import 'package:bloomdue_baby/services/sync/sync_providers.dart';
import 'package:bloomdue_baby/services/sync/sync_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _SeqAuthNotifier extends AuthSessionNotifier {
  _SeqAuthNotifier(this._sessions);
  final List<AuthSession> _sessions;
  int _i = 0;
  AuthSession? _current;

  @override
  Future<AuthSession?> build() async => _current;

  @override
  Future<String?> requestMagicCode(String email) async => '123456';

  @override
  Future<void> verifyMagicCode({
    required String email,
    required String code,
  }) async {
    _current = _sessions[_i.clamp(0, _sessions.length - 1)];
    _i++;
    state = AsyncData(_current);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    state = const AsyncData(null);
  }
}

class _NoopSync extends SyncService {
  _NoopSync() : super(api: BloomdueApiClient(httpClient: http.Client()), db: AppDatabase.forTesting(NativeDatabase.memory()));

  @override
  Future<SyncResult> syncAll({
    required AuthSession session,
    bool fullHistory = false,
  }) async {
    return const SyncResult(pushed: 0, pulled: 0);
  }
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpAccount(WidgetTester tester, ProviderContainer container) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: AccountSection())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('different account shows switch dialog; start fresh clears logs',
      (tester) async {
    const userA = AuthUser(id: 'user-a', email: 'raul@globinary.io', displayName: 'Raul');
    const userB = AuthUser(id: 'user-b', email: 'raulgldn@gmail.com', displayName: 'Raul G');

    await db.settingsDao.setLastSignedInUserId(userA.id);
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: 'baby-1',
            name: 'E2E',
            createdAt: DateTime.now(),
            serverChildId: const Value('server-a'),
          ),
        );
    await db.into(db.careEvents).insert(
          CareEventsCompanion.insert(
            id: 'evt-a',
            babyId: 'baby-1',
            type: 'diaper',
            occurredAt: DateTime.now(),
            clientUpdatedAt: DateTime.now(),
          ),
        );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        accountSwitchServiceProvider.overrideWithValue(AccountSwitchService(db)),
        authSessionProvider.overrideWith(
          () => _SeqAuthNotifier([
            const AuthSession(token: 'tb', user: userB),
          ]),
        ),
        syncServiceProvider.overrideWithValue(_NoopSync()),
      ],
    );
    addTearDown(container.dispose);

    await pumpAccount(tester, container);

    await tester.enterText(find.byKey(const Key('auth_email')), userB.email);
    await tester.tap(find.byKey(const Key('auth_send_code')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth_code')), '123456');
    await tester.tap(find.byKey(const Key('auth_verify')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account_switch_dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('account_switch_fresh')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Signed in as ${userB.email}'), findsOneWidget);
    expect(await db.select(db.careEvents).get(), isEmpty);
    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.serverChildId, isNull);
    expect(await db.settingsDao.lastSignedInUserId(), userB.id);
  });

  testWidgets('upload local keeps logs and unlinks server child', (tester) async {
    const userA = AuthUser(id: 'user-a', email: 'raul@globinary.io', displayName: 'Raul');
    const userB = AuthUser(id: 'user-b', email: 'raulgldn@gmail.com', displayName: 'Raul G');

    await db.settingsDao.setLastSignedInUserId(userA.id);
    await db.into(db.babies).insert(
          BabiesCompanion.insert(
            id: 'baby-1',
            name: 'E2E',
            createdAt: DateTime.now(),
            serverChildId: const Value('server-a'),
          ),
        );
    await db.into(db.careEvents).insert(
          CareEventsCompanion.insert(
            id: 'evt-a',
            babyId: 'baby-1',
            type: 'diaper',
            occurredAt: DateTime.now(),
            clientUpdatedAt: DateTime.now(),
          ),
        );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        accountSwitchServiceProvider.overrideWithValue(AccountSwitchService(db)),
        authSessionProvider.overrideWith(
          () => _SeqAuthNotifier([
            const AuthSession(token: 'tb', user: userB),
          ]),
        ),
        syncServiceProvider.overrideWithValue(_NoopSync()),
      ],
    );
    addTearDown(container.dispose);

    await pumpAccount(tester, container);

    await tester.enterText(find.byKey(const Key('auth_email')), userB.email);
    await tester.tap(find.byKey(const Key('auth_send_code')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth_code')), '123456');
    await tester.tap(find.byKey(const Key('auth_verify')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('account_switch_upload')));
    await tester.pumpAndSettle();

    expect(await db.select(db.careEvents).get(), hasLength(1));
    final baby = await (db.select(db.babies)..limit(1)).getSingle();
    expect(baby.serverChildId, isNull);
  });

  testWidgets('cancel leaves signed out', (tester) async {
    const userA = AuthUser(id: 'user-a', email: 'raul@globinary.io', displayName: 'Raul');
    const userB = AuthUser(id: 'user-b', email: 'raulgldn@gmail.com', displayName: 'Raul G');

    await db.settingsDao.setLastSignedInUserId(userA.id);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        accountSwitchServiceProvider.overrideWithValue(AccountSwitchService(db)),
        authSessionProvider.overrideWith(
          () => _SeqAuthNotifier([
            const AuthSession(token: 'tb', user: userB),
          ]),
        ),
        syncServiceProvider.overrideWithValue(_NoopSync()),
      ],
    );
    addTearDown(container.dispose);

    await pumpAccount(tester, container);

    await tester.enterText(find.byKey(const Key('auth_email')), userB.email);
    await tester.tap(find.byKey(const Key('auth_send_code')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('auth_code')), '123456');
    await tester.tap(find.byKey(const Key('auth_verify')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('account_switch_cancel')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sign-in cancelled'), findsOneWidget);
    expect(find.byKey(const Key('auth_email')), findsOneWidget);
    expect(find.textContaining('Signed in as'), findsNothing);
  });
}

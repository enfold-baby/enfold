import 'package:enfold/features/settings/widgets/partner_section.dart';
import 'package:enfold/services/api/api_exception.dart';
import 'package:enfold/services/api/enfold_api_client.dart';
import 'package:enfold/services/api/family_models.dart';
import 'package:enfold/services/auth/auth_providers.dart';
import 'package:enfold/services/auth/auth_session.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../helpers/pump_until.dart';
import '../helpers/test_database.dart';
import '../helpers/localized_app.dart';

class _SignedInAuthNotifier extends AuthSessionNotifier {
  @override
  Future<AuthSession?> build() async {
    return AuthSession(
      token: 'token',
      user: AuthUser(
        id: 'user-1',
        email: 'parent@enfold.baby',
        displayName: 'Parent',
      ),
    );
  }
}

class _FakePartnerApi extends EnfoldApiClient {
  _FakePartnerApi() : super(httpClient: http.Client());

  @override
  Future<FamilyInfo> getFamily(String token) async {
    throw ApiException('Not found', statusCode: 404);
  }
}

class _SharedFamilyApi extends EnfoldApiClient {
  _SharedFamilyApi() : super(httpClient: http.Client());

  var leaveCalls = 0;

  @override
  Future<FamilyInfo> getFamily(String token) async {
    return const FamilyInfo(
      id: 'fam-1',
      members: [
        FamilyMember(id: 'u1', email: 'parent@enfold.baby', displayName: 'Parent'),
        FamilyMember(id: 'u2', email: 'partner@enfold.baby', displayName: 'Partner'),
      ],
    );
  }

  @override
  Future<FamilyInfo> leaveFamily(String token) async {
    leaveCalls++;
    return const FamilyInfo(
      id: 'fam-solo',
      members: [
        FamilyMember(id: 'u1', email: 'parent@enfold.baby', displayName: 'Parent'),
      ],
    );
  }
}

void main() {
  testWidgets('partner section shows invite UI when signed in', (tester) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(_FakePartnerApi()),
        authSessionProvider.overrideWith(_SignedInAuthNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const Scaffold(body: PartnerSection())),
      ),
    );
    await pumpUntilFound(tester, find.text('Partner sharing'));
    await pumpUntilFound(tester, find.byKey(const Key('partner_create_invite')));

    expect(find.byKey(const Key('partner_create_invite')), findsOneWidget);
    expect(find.byKey(const Key('partner_join_code')), findsOneWidget);
    expect(find.byKey(const Key('partner_join')), findsOneWidget);
  });

  testWidgets('leave family button shows when shared and confirms', (tester) async {
    final db = createTestDatabase();
    final api = _SharedFamilyApi();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(api),
        authSessionProvider.overrideWith(_SignedInAuthNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedApp(const Scaffold(body: PartnerSection())),
      ),
    );
    await pumpUntilFound(tester, find.byKey(const Key('partner_leave_family')));
    await tester.tap(find.byKey(const Key('partner_leave_family')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('partner_leave_dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('partner_leave_confirm')));
    await tester.pumpAndSettle();
    expect(api.leaveCalls, 1);
  });
}
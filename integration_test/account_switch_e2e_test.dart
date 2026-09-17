import 'dart:convert';

import 'package:enfold/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

/// Local docker API as seen from the Android emulator host bridge.
const _apiBase = 'http://10.0.2.2:8282';

/// Two inboxes you own; the local API prints dev codes so no mail is needed.
const accountA = String.fromEnvironment('ACCOUNT_A', defaultValue: 'parent-a@example.com');
const accountB = String.fromEnvironment('ACCOUNT_B', defaultValue: 'parent-b@example.com');

Future<String> _requestDevCode(String email) async {
  final response = await http.post(
    Uri.parse('$_apiBase/v1/auth/magic-code/request'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );
  expect(
    response.statusCode,
    anyOf(200, 201),
    reason: 'magic-code request failed: ${response.body}',
  );
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final code = body['dev_code'] as String?;
  expect(code, isNotNull, reason: 'dev_code missing — is DEV logging enabled?');
  return code!;
}

Future<String> _tokenFor(String email) async {
  final code = await _requestDevCode(email);
  final response = await http.post(
    Uri.parse('$_apiBase/v1/auth/magic-code/verify'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'code': code}),
  );
  expect(response.statusCode, 200, reason: response.body);
  return (jsonDecode(response.body) as Map)['access_token'] as String;
}

Future<List<Map<String, dynamic>>> _listChildren(String token) async {
  final response = await http.get(
    Uri.parse('$_apiBase/v1/children'),
    headers: {'Authorization': 'Bearer $token'},
  );
  expect(response.statusCode, 200, reason: response.body);
  final body = jsonDecode(response.body);
  final list = body is List ? body : <dynamic>[];
  return list.cast<Map<String, dynamic>>();
}

Future<List<Map<String, dynamic>>> _listCareEvents(
  String token,
  String childId,
) async {
  final uri = Uri.parse('$_apiBase/v1/care-events').replace(
    queryParameters: {'child_id': childId},
  );
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  expect(response.statusCode, 200, reason: response.body);
  final body = jsonDecode(response.body);
  final list = body is List ? body : <dynamic>[];
  return list.cast<Map<String, dynamic>>();
}

String _visibleTexts(WidgetTester tester) {
  final texts = find.byType(Text).evaluate().map((e) {
    final w = e.widget;
    if (w is Text) return w.data ?? w.textSpan?.toPlainText() ?? '';
    return '';
  }).where((t) => t.trim().isNotEmpty).take(40);
  return texts.join(' | ');
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 25),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder. Visible: ${_visibleTexts(tester)}');
}

/// Local API may advertise a newer build → dismiss "Update available".
Future<void> _dismissUpdateIfPresent(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 300));
    final later = find.text('Later');
    if (later.evaluate().isNotEmpty) {
      await tester.tap(later);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      return;
    }
    if (find.text('Update available').evaluate().isEmpty &&
        find.byKey(const Key('log_feed')).evaluate().isNotEmpty) {
      return;
    }
  }
}

Future<void> _completeOnboarding(WidgetTester tester) async {
  app.main();
  // Match demo_screenshots_test timing — live binding needs real wall time.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle(const Duration(seconds: 5));
  await _dismissUpdateIfPresent(tester);

  if (find.byKey(const Key('onboarding_skip')).evaluate().isNotEmpty) {
    // Prefer skip — fewer steps, less keyboard/scroll flakiness on emulators.
    await tester.ensureVisible(find.byKey(const Key('onboarding_skip')));
    await tester.tap(find.byKey(const Key('onboarding_skip')), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  } else if (find.byKey(const Key('onboarding_get_started')).evaluate().isNotEmpty) {
    await tester.tap(find.byKey(const Key('onboarding_get_started')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byKey(const Key('onboarding_skip')), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  await _dismissUpdateIfPresent(tester);
  if (find.text('Today').evaluate().isNotEmpty) {
    await tester.tap(find.text('Today').last);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  await _pumpUntil(tester, find.byKey(const Key('log_feed')));
  expect(find.byKey(const Key('onboarding_get_started')), findsNothing);
  expect(find.text("You're doing fine."), findsOneWidget);
}

/// Tap diaper tile → list → FAB add → save (avoids long-press hit-test issues).
Future<void> _logDiaperOffline(WidgetTester tester) async {
  await _dismissUpdateIfPresent(tester);
  await _pumpUntil(tester, find.byKey(const Key('log_diaper')));
  await tester.tap(find.byKey(const Key('log_diaper')), warnIfMissed: false);
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await _pumpUntil(tester, find.byKey(const Key('add_diaper_log')));
  await tester.tap(find.byKey(const Key('add_diaper_log')));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await _pumpUntil(tester, find.byKey(const Key('save_diaper_log')));

  final wet = find.text('Wet');
  if (wet.evaluate().isNotEmpty) {
    await tester.tap(wet.first);
    await tester.pump();
  }

  await tester.tap(find.byKey(const Key('save_diaper_log')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Pop form/list back to shell Today.
  for (var i = 0; i < 3; i++) {
    if (find.byKey(const Key('log_feed')).evaluate().isNotEmpty) break;
    final back = find.byTooltip('Back');
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    } else {
      break;
    }
  }
  if (find.text('Today').evaluate().isNotEmpty) {
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  await _dismissUpdateIfPresent(tester);
  await _pumpUntil(tester, find.byKey(const Key('log_feed')));
}

Future<void> _logFeedOffline(WidgetTester tester) async {
  await _dismissUpdateIfPresent(tester);
  await _pumpUntil(tester, find.byKey(const Key('log_feed')));
  await tester.tap(find.byKey(const Key('log_feed')), warnIfMissed: false);
  await tester.pumpAndSettle(const Duration(seconds: 2));
  final addFeed = find.byKey(const Key('add_feed_log'));
  await _pumpUntil(tester, addFeed);
  await tester.tap(addFeed);
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await _pumpUntil(tester, find.byKey(const Key('save_feed_log')));
  await tester.tap(find.byKey(const Key('save_feed_log')));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  for (var i = 0; i < 3; i++) {
    if (find.byKey(const Key('log_feed')).evaluate().isNotEmpty &&
        find.text("You're doing fine.").evaluate().isNotEmpty) {
      break;
    }
    final back = find.byTooltip('Back');
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    } else {
      break;
    }
  }
  if (find.text('Today').evaluate().isNotEmpty) {
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  await _dismissUpdateIfPresent(tester);
}

Future<void> _openSettings(WidgetTester tester) async {
  await _dismissUpdateIfPresent(tester);
  final settingsTab = find.text('Settings');
  await _pumpUntil(tester, settingsTab);
  await tester.ensureVisible(settingsTab);
  await tester.tap(settingsTab);
  await tester.pumpAndSettle(const Duration(seconds: 2));
  expect(find.text('Account & sync'), findsOneWidget);
}

Future<void> _goToday(WidgetTester tester) async {
  await tester.tap(find.text('Today'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await _dismissUpdateIfPresent(tester);
  await _pumpUntil(tester, find.byKey(const Key('log_feed')));
}

enum AccountSwitchAction { upload, fresh, cancel }

Future<void> _scrollSettingsTo(WidgetTester tester, Finder target) async {
  await _pumpUntil(tester, target);
  // Settings is a tall scroll view; buttons near Account can be under app bars
  // or clipped by the bottom nav — bring them fully on-screen before tapping.
  for (var i = 0; i < 8; i++) {
    try {
      await tester.ensureVisible(target);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      return;
    } catch (_) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }
  }
  await tester.ensureVisible(target);
}

Future<void> _signIn(
  WidgetTester tester, {
  required String email,
  AccountSwitchAction? switchAction,
}) async {
  final code = await _requestDevCode(email);

  final emailField = find.byKey(const Key('auth_email'));
  await _scrollSettingsTo(tester, emailField);
  await tester.tap(emailField, warnIfMissed: false);
  await tester.enterText(emailField, email);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle(const Duration(milliseconds: 400));

  final send = find.byKey(const Key('auth_send_code'));
  await _scrollSettingsTo(tester, send);
  await tester.tap(send, warnIfMissed: false);
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await _pumpUntil(tester, find.byKey(const Key('auth_code')));

  final codeField = find.byKey(const Key('auth_code'));
  await _scrollSettingsTo(tester, codeField);
  await tester.enterText(codeField, code);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle(const Duration(milliseconds: 400));

  final verify = find.byKey(const Key('auth_verify'));
  await _scrollSettingsTo(tester, verify);
  await tester.tap(verify, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  if (switchAction != null) {
    await _pumpUntil(tester, find.byKey(const Key('account_switch_dialog')));
    switch (switchAction) {
      case AccountSwitchAction.upload:
        await tester.tap(find.byKey(const Key('account_switch_upload')));
      case AccountSwitchAction.fresh:
        await tester.tap(find.byKey(const Key('account_switch_fresh')));
      case AccountSwitchAction.cancel:
        await tester.tap(find.byKey(const Key('account_switch_cancel')));
    }
    await tester.pumpAndSettle(const Duration(seconds: 6));
  } else {
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.byKey(const Key('account_switch_dialog')),
      findsNothing,
      reason: 'First sign-in on clean install should not show switch dialog',
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
}

Future<void> _signOut(WidgetTester tester) async {
  await _pumpUntil(tester, find.byKey(const Key('auth_sign_out')));
  await tester.ensureVisible(find.byKey(const Key('auth_sign_out')));
  await tester.tap(find.byKey(const Key('auth_sign_out')));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await _pumpUntil(tester, find.byKey(const Key('auth_email')));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'e2e account isolation: A → B start fresh → cancel → A upload',
    (tester) async {
      // ── 1) Onboarding + offline diaper ────────────────────────────────
      await _completeOnboarding(tester);
      await _logDiaperOffline(tester);

      // ── 2) Sign in account A (no switch dialog) ───────────────────────
      await _openSettings(tester);
      await _signIn(tester, email: accountA);
      expect(find.textContaining('Signed in as $accountA'), findsOneWidget);

      // API: A has a child + diaper after sync.
      final tokenA = await _tokenFor(accountA);
      final childrenA = await _listChildren(tokenA);
      expect(childrenA, isNotEmpty, reason: 'A should have a child after sync');
      final childAId = childrenA.first['id'] as String;
      final eventsA = await _listCareEvents(tokenA, childAId);
      expect(
        eventsA.any((e) => e['type'] == 'diaper'),
        isTrue,
        reason: 'Diaper should upload to A. events=$eventsA',
      );

      // ── 3) Sign out → B Start fresh ───────────────────────────────────
      await _signOut(tester);
      await _signIn(
        tester,
        email: accountB,
        switchAction: AccountSwitchAction.fresh,
      );
      expect(find.textContaining('Signed in as $accountB'), findsOneWidget);

      await _goToday(tester);
      final empty = find.byKey(const Key('empty_logs'));
      final quiet = find.text('A quiet start');
      // Scroll recent into view if needed.
      if (empty.evaluate().isEmpty && quiet.evaluate().isEmpty) {
        await tester.drag(
          find.byType(Scrollable).first,
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
      }
      expect(
        empty.evaluate().isNotEmpty || quiet.evaluate().isNotEmpty,
        isTrue,
        reason: 'Start fresh should clear local care logs',
      );

      // ── 4) Cancel switch back to A ────────────────────────────────────
      await _openSettings(tester);
      await _signOut(tester);
      await _signIn(
        tester,
        email: accountA,
        switchAction: AccountSwitchAction.cancel,
      );
      expect(find.textContaining('Sign-in cancelled'), findsOneWidget);
      expect(find.byKey(const Key('auth_email')), findsOneWidget);
      expect(find.textContaining('Signed in as'), findsNothing);

      // ── 5) Offline feed + upload to A ─────────────────────────────────
      await _goToday(tester);
      await _logFeedOffline(tester);

      await _openSettings(tester);
      await _signIn(
        tester,
        email: accountA,
        switchAction: AccountSwitchAction.upload,
      );
      expect(find.textContaining('Signed in as $accountA'), findsOneWidget);

      final tokenA2 = await _tokenFor(accountA);
      final childrenA2 = await _listChildren(tokenA2);
      expect(childrenA2, isNotEmpty);
      final eventsA2 = await _listCareEvents(
        tokenA2,
        childrenA2.first['id'] as String,
      );
      expect(
        eventsA2.any((e) => e['type'] == 'diaper' || e['type'] == 'feeding'),
        isTrue,
        reason: 'A should still have care events after upload path',
      );
    },
  );
}

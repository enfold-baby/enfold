import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enfold/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

CareLogEntry _entry({
  String? loggedByUserId,
  String? loggedByDisplayName,
}) {
  return CareLogEntry(
    id: 'e1',
    type: LogType.feed,
    loggedAt: DateTime(2026, 7, 8, 10),
    pendingSync: false,
    loggedByUserId: loggedByUserId,
    loggedByDisplayName: loggedByDisplayName,
  );
}

void main() {
  final l10n = lookupAppL10n(const Locale('en'));
  test('loggedByLabel returns you for current user', () {
    final entry = _entry(loggedByUserId: 'user-1', loggedByDisplayName: 'Raul');
    expect(
      entry.loggedByLabel(l10n, currentUserId: 'user-1', showAttribution: true),
      'you',
    );
  });

  test('loggedByLabel returns partner display name', () {
    final entry = _entry(loggedByUserId: 'user-2', loggedByDisplayName: 'Raul');
    expect(
      entry.loggedByLabel(l10n, currentUserId: 'user-1', showAttribution: true),
      'Raul',
    );
  });

  test('loggedByLabel falls back to Partner without display name', () {
    final entry = _entry(loggedByUserId: 'user-2');
    expect(
      entry.loggedByLabel(l10n, currentUserId: 'user-1', showAttribution: true),
      'Partner',
    );
  });

  test('loggedByLabel hidden when attribution disabled or missing author', () {
    expect(
      _entry(loggedByUserId: 'user-2', loggedByDisplayName: 'Raul')
          .loggedByLabel(l10n, showAttribution: false),
      isNull,
    );
    expect(_entry().loggedByLabel(l10n, showAttribution: true), isNull);
  });
}
import 'package:enfold/features/logs/widgets/log_entry_actions.dart';
import 'package:enfold/features/today/models/care_log_details.dart';
import 'package:enfold/features/today/models/care_log_entry.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:enfold/services/database/app_database.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/localized_app.dart';

class _DeleteHarness extends ConsumerWidget {
  const _DeleteHarness({required this.entry});

  final CareLogEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showLogEntryActions(context, ref, entry),
          child: const Text('Open actions'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('confirming delete soft-deletes the log', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final babyId = await db.careLogDao.ensureDefaultBaby();
    final logId = await db.careLogDao.insertLog(
      babyId: babyId,
      type: LogType.feed.apiType,
      occurredAt: DateTime.now(),
      note: 'test2',
    );

    final entry = CareLogEntry(
      id: logId,
      type: LogType.feed,
      loggedAt: DateTime.now(),
      pendingSync: true,
      details: CareLogDetails.empty,
      note: 'test2',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: localizedApp(_DeleteHarness(entry: entry)),
      ),
    );

    await tester.tap(find.text('Open actions'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('delete_log_$logId')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete_log_confirm')));
    await tester.pumpAndSettle();

    final row = await db.careLogDao.getLog(logId);
    expect(row?.deletedAt, isNotNull);

    final today = await db.careLogDao.getTodayLogs(babyId);
    expect(today, isEmpty);
  });
}
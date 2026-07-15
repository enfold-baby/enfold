import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../today/models/care_log_entry.dart';
import '../today/providers/today_log_provider.dart';
import 'providers/logs_providers.dart';
import 'widgets/log_period_bar.dart';
import 'widgets/paginated_log_list.dart';
import 'widgets/type_filter_chips.dart';

class SleepLogsScreen extends ConsumerWidget {
  const SleepLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(sleepLogsProvider);
    final openSleep = ref.watch(openSleepProvider).valueOrNull;
    final timeFormat = DateFormat.jm();

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep logs')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_sleep_log'),
        onPressed: () => context.push(AppRoutes.logSleepAdd),
        backgroundColor: AppColors.sleepBlue,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              'All sleep',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: sleepLogPeriodProvider),
            if (openSleep != null) ...[
              const SizedBox(height: 16),
              _ActiveSleepBanner(
                entry: openSleep,
                timeFormat: timeFormat,
                onWakeUp: () async {
                  await ref
                      .read(careLogActionsProvider)
                      .wakeFromSleep(openSleep.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Wake-up logged')),
                    );
                },
              ),
            ],
            const SizedBox(height: 20),
            DetailFilterChips<bool>(
              label: 'Status',
              options: const [
                DetailFilterOption(value: true, label: 'Sleeping now'),
                DetailFilterOption(value: false, label: 'Completed'),
              ],
              selected: ref.watch(sleepStatusFilterProvider),
              onSelected: (value) =>
                  ref.read(sleepStatusFilterProvider.notifier).state = value,
            ),
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('sleep_logs_empty'),
              emptyMessage: 'No sleep logs in this period. Tap + to add one.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSleepBanner extends StatelessWidget {
  const _ActiveSleepBanner({
    required this.entry,
    required this.timeFormat,
    required this.onWakeUp,
  });

  final CareLogEntry entry;
  final DateFormat timeFormat;
  final VoidCallback onWakeUp;

  @override
  Widget build(BuildContext context) {
    final start = entry.details.sleepStart ?? entry.loggedAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sleepBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sleepBlue.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bedtime, color: AppColors.sleepBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sleeping since ${timeFormat.format(start)}',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: AppColors.sleepBlue,
              ),
            ),
          ),
          FilledButton(
            onPressed: onWakeUp,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sleepBlue,
              foregroundColor: AppColors.cream,
            ),
            child: const Text('Wake up'),
          ),
        ],
      ),
    );
  }
}
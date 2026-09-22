import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'providers/logs_providers.dart';
import 'widgets/log_period_bar.dart';
import 'widgets/paginated_log_list.dart';
import 'widgets/active_sleep_banner.dart';
import 'widgets/type_filter_chips.dart';
import '../../widgets/sync_refresh.dart';

class SleepLogsScreen extends ConsumerWidget {
  const SleepLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(sleepLogsProvider);
    final openSleep = ref.watch(openSleepProvider).valueOrNull;
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sleepLogsTitle)),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_sleep_log'),
        onPressed: () => context.push(AppRoutes.logSleepAdd),
        backgroundColor: AppColors.sleepBlue,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('sleep_logs_pull_to_refresh'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              l10n.sleepLogsAll,
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: sleepLogPeriodProvider),
            if (openSleep != null) ...[
              const SizedBox(height: 16),
              ActiveSleepBanner(
                entry: openSleep,
                onWakeUp: () async {
                  await ref
                      .read(careLogActionsProvider)
                      .wakeFromSleep(openSleep.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(l10n.commonWakeUpLogged)),
                    );
                },
                onAdjustStart: () => context.push(
                  AppRoutes.logEdit(LogType.sleep, openSleep.id),
                ),
              ),
            ],
            const SizedBox(height: 20),
            DetailFilterChips<bool>(
              label: l10n.sleepLogsStatusFilter,
              options: [
                DetailFilterOption(value: true, label: l10n.sleepModeNow),
                DetailFilterOption(
                  value: false,
                  label: l10n.sleepLogsCompleted,
                ),
              ],
              selected: ref.watch(sleepStatusFilterProvider),
              onSelected: (value) =>
                  ref.read(sleepStatusFilterProvider.notifier).state = value,
            ),
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('sleep_logs_empty'),
              emptyMessage: l10n.sleepLogsEmpty,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../today/models/care_log_entry.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'models/hub_type_filter.dart';
import 'providers/logs_providers.dart';
import 'widgets/deleted_logs_section.dart';
import 'widgets/log_period_bar.dart';
import 'widgets/log_type_card.dart';
import 'widgets/paginated_log_list.dart';
import 'widgets/type_filter_chips.dart';
import '../../widgets/sync_refresh.dart';

class LogsHubScreen extends ConsumerStatefulWidget {
  const LogsHubScreen({super.key});

  @override
  ConsumerState<LogsHubScreen> createState() => _LogsHubScreenState();
}

class _LogsHubScreenState extends ConsumerState<LogsHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(careLogActionsProvider).purgeExpiredSoftDeletes();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(hubLogPeriodProvider, (previous, next) {
      if (previous != next) {
        ref.read(hubLogsVisibleCountProvider.notifier).state = hubLogsPageSize;
      }
    });
    ref.listen(hubLogTypeFilterProvider, (previous, next) {
      if (previous != next) {
        ref.read(hubLogsVisibleCountProvider.notifier).state = hubLogsPageSize;
      }
    });

    final logsAsync = ref.watch(hubLogsProvider);
    final openSleep = ref.watch(openSleepProvider).valueOrNull;
    final typeFilter = ref.watch(hubLogTypeFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat.jm();

    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('logs_pull_to_refresh'),
          child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Your log history',
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.cream : AppColors.bark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse everything here, or open a type for focused filters.',
              style: GoogleFonts.nunito(
                fontSize: 15,
                height: 1.45,
                color: AppColors.barkSoft,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final type in LogType.values)
                  SizedBox(
                    width: (MediaQuery.sizeOf(context).width - 52) / 2,
                    child: LogTypeCard(
                      key: Key('logs_hub_${type.formSegment}'),
                      type: type,
                      onTap: () => context.push(AppRoutes.logList(type)),
                    ),
                  ),
              ],
            ),
            if (openSleep != null) ...[
              const SizedBox(height: 20),
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
            const SizedBox(height: 28),
            Text(
              'Filter',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 10),
            HubTypeFilterChips(
              selected: typeFilter,
              onAllTap: () =>
                  ref.read(hubLogTypeFilterProvider.notifier).state =
                      HubTypeFilter.selectAll(),
              onTypeTap: (type) {
                ref.read(hubLogTypeFilterProvider.notifier).state =
                    HubTypeFilter.toggleType(typeFilter, type);
              },
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: hubLogPeriodProvider),
            const SizedBox(height: 24),
            Text(
              ref.watch(hubLogPeriodProvider).periodLabel(),
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 12),
            PaginatedLogList(
              logsAsync: logsAsync,
              pageSize: hubLogsPageSize,
              visibleCountProvider: hubLogsVisibleCountProvider,
              emptyKey: const Key('logs_hub_empty'),
              emptyMessage: HubTypeFilter.emptyMessage(typeFilter),
            ),
            const DeletedLogsSection(),
          ],
        ),
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
      key: const Key('active_sleep_banner'),
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
            key: const Key('wake_up_button'),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'models/hub_type_filter.dart';
import 'providers/logs_providers.dart';
import 'widgets/deleted_logs_section.dart';
import 'widgets/log_period_bar.dart';
import 'widgets/log_type_card.dart';
import 'widgets/paginated_log_list.dart';
import 'widgets/active_sleep_banner.dart';
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
                color: AppColors.mutedText(Theme.of(context).brightness),
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
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 52) / 2,
                  child: _HubLinkCard(
                    key: const Key('logs_hub_growth'),
                    label: 'Growth',
                    icon: Icons.monitor_weight_outlined,
                    color: AppColors.sage,
                    onTap: () => context.push(AppRoutes.logsGrowth),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 52) / 2,
                  child: _HubLinkCard(
                    key: const Key('logs_hub_milestones'),
                    label: 'Milestones',
                    icon: Icons.emoji_events_outlined,
                    color: AppColors.bloom,
                    onTap: () => context.push(AppRoutes.logsGrowth),
                  ),
                ),
              ],
            ),
            if (openSleep != null) ...[
              const SizedBox(height: 20),
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
                      const SnackBar(content: Text('Wake-up logged')),
                    );
                },
                onAdjustStart: () => context.push(
                  AppRoutes.logEdit(LogType.sleep, openSleep.id),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'Filter',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.accent(Theme.of(context).brightness),
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
                color: AppColors.accent(Theme.of(context).brightness),
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

class _HubLinkCard extends StatelessWidget {
  const _HubLinkCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.nightElevated : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.nightLine
                  : AppColors.bark.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.cream, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
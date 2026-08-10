import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth/auth_providers.dart';
import '../../services/database/database_provider.dart';
import '../../services/sync/sync_providers.dart';
import '../../services/sync/sync_service.dart';
import '../../widgets/bloom_brand_mark.dart';
import '../../widgets/bloom_illustrations.dart';
import '../../widgets/bloom_section_header.dart';
import '../../widgets/bloom_surface.dart';
import '../growth/providers/growth_providers.dart';
import '../logs/widgets/log_entry_actions.dart';
import '../logs/widgets/log_entry_tile.dart';
import '../medication/providers/medication_providers.dart';
import '../medication/widgets/medication_entry_card.dart';
import '../partner/providers/partner_providers.dart';
import '../partner/widgets/gentle_nudge_banner.dart';
import '../pumping/providers/pumping_providers.dart';
import '../settings/providers/units_providers.dart';
import '../settings/widgets/export_section.dart';
import '../tummy_time/providers/tummy_time_providers.dart';
import 'models/care_log_entry.dart';
import 'models/log_type.dart';
import 'models/today_summary.dart';
import 'providers/today_log_provider.dart';
import 'widgets/activity_entry_card.dart';
import 'widgets/growth_entry_card.dart';
import 'widgets/quick_log_tile.dart';
import 'widgets/today_summary_cards.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  static String greetingForHour(int hour) {
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 22) return 'Good evening';
    return 'Good night';
  }

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  var _autoSynced = false;
  LogType? _dismissedNudgeType;

  void _openLogList(BuildContext context, LogType type) {
    context.go(AppRoutes.logList(type));
  }

  void _openLogForm(BuildContext context, LogType type) {
    context.push(AppRoutes.logForm(type));
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(todayLogProvider);
    final session = ref.watch(authSessionProvider).valueOrNull;
    final isSignedIn = session != null;
    final lastSync = ref.watch(lastSyncResultProvider);

    if (isSignedIn && !_autoSynced) {
      _autoSynced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(syncActionsProvider).syncIfSignedIn();
      });
    }
    if (!isSignedIn) _autoSynced = false;

    final useImperial =
        ref.watch(useImperialUnitsProvider).valueOrNull ?? false;
    final growthMeasurements =
        ref.watch(growthMeasurementsProvider).valueOrNull ?? const [];
    final milestoneStatuses =
        ref.watch(milestoneStatusesProvider).valueOrNull ?? const [];
    final milestonesAchieved = milestoneStatuses
        .where((status) => status.isAchieved)
        .length;
    final medicationLogs =
        ref.watch(todayMedicationLogsProvider).valueOrNull ?? const [];
    final tummyLogs = ref.watch(todayTummyLogsProvider).valueOrNull ?? const [];
    final pumpingLogs =
        ref.watch(todayPumpingLogsProvider).valueOrNull ?? const [];
    final partnerNudge = ref.watch(partnerNudgeProvider).valueOrNull;
    final showPartnerNudge =
        partnerNudge != null && partnerNudge.type != _dismissedNudgeType;
    final showAttribution = ref.watch(hasPartnerProvider).valueOrNull ?? false;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BloomBrandMark(size: 30, showBackdrop: false),
            const SizedBox(width: 8),
            Text('BloomDue', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton.filledTonal(
            key: const Key('export_pdf_app_bar'),
            tooltip: 'Export 7-day PDF',
            onPressed: () => _exportPdf(context, ref),
            icon: const Icon(Icons.ios_share_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          key: const Key('today_pull_to_refresh'),
          color: AppColors.sage,
          onRefresh: _refreshToday,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _TodayHero(
                greeting: TodayScreen.greetingForHour(now.hour),
                syncCopy: isSignedIn ? _partnerSyncCopy(lastSync) : null,
              ),
              const SizedBox(height: 26),
              const BloomSectionHeader(
                title: 'Quick actions',
                subtitle: 'Open a log, or hold a tile to add details.',
              ),
              const SizedBox(height: 12),
              _quickActionGrid(),
              const SizedBox(height: 28),
              logsAsync.when(
                loading: () => const SizedBox(
                  height: 132,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (logs) =>
                    TodaySummaryCards(summary: TodaySummary.fromEntries(logs)),
              ),
              if (showPartnerNudge) ...[
                const SizedBox(height: 18),
                GentleNudgeBanner(
                  nudge: partnerNudge,
                  onDismiss: () =>
                      setState(() => _dismissedNudgeType = partnerNudge.type),
                ),
              ],
              const SizedBox(height: 28),
              const BloomSectionHeader(
                title: 'Recent',
                subtitle: 'The latest care moments, all in one place.',
              ),
              const SizedBox(height: 12),
              ..._recentLogSection(
                logsAsync: logsAsync,
                isSignedIn: isSignedIn,
                useImperial: useImperial,
                showAttribution: showAttribution,
                currentUserId: session?.user.id,
              ),
              const SizedBox(height: 30),
              const BloomSectionHeader(
                title: 'More care',
                subtitle: 'Growth, medication, tummy time, and pumping.',
              ),
              const SizedBox(height: 12),
              GrowthEntryCard(
                latestMeasurement: growthMeasurements.isEmpty
                    ? null
                    : growthMeasurements.first,
                milestonesAchieved: milestonesAchieved,
                useImperial: useImperial,
                onTap: () => context.push(AppRoutes.growth),
              ),
              const SizedBox(height: 14),
              MedicationEntryCard(
                todayLogs: medicationLogs,
                onTap: () => context.push(AppRoutes.logMedication),
                onAdd: () => context.push(AppRoutes.logMedicationAdd),
              ),
              const SizedBox(height: 14),
              ActivityEntryCard(
                tummyLogs: tummyLogs,
                pumpingLogs: pumpingLogs,
                useImperial: useImperial,
                onTapTummy: () => context.push(AppRoutes.logTummy),
                onTapPumping: () => context.push(AppRoutes.logPumping),
                onAddTummy: () => context.push(AppRoutes.logTummyAdd),
                onAddPumping: () => context.push(AppRoutes.logPumpingAdd),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pull-to-refresh: sync with partner server when signed in, then reload local streams.
  Future<void> _refreshToday() async {
    final result = await ref.read(syncActionsProvider).syncIfSignedIn();
    ref.invalidate(todayLogProvider);
    ref.invalidate(todayMedicationLogsProvider);
    ref.invalidate(todayTummyLogsProvider);
    ref.invalidate(todayPumpingLogsProvider);
    ref.invalidate(growthMeasurementsProvider);
    ref.invalidate(milestoneStatusesProvider);
    ref.invalidate(partnerNudgeProvider);
    ref.invalidate(hasPartnerProvider);

    try {
      await ref.read(todayLogProvider.future);
    } catch (_) {
      // Offline / empty — still finish the indicator.
    }

    if (!mounted) return;
    if (ref.read(authSessionProvider).valueOrNull != null &&
        result.ok == false) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Couldn’t sync right now. Your local logs are safe.'),
          ),
        );
    }
  }

  Widget _quickActionGrid() {
    return Column(
      key: const Key('today_quick_actions_heading'),
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 148,
                child: QuickLogTile(
                  key: const Key('log_feed'),
                  type: LogType.feed,
                  color: AppColors.sage,
                  onTap: () => _openLogList(context, LogType.feed),
                  onLongPress: () => _openLogForm(context, LogType.feed),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 148,
                child: QuickLogTile(
                  key: const Key('log_diaper'),
                  type: LogType.diaper,
                  color: AppColors.bloom,
                  onTap: () => _openLogList(context, LogType.diaper),
                  onLongPress: () => _openLogForm(context, LogType.diaper),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 148,
                child: QuickLogTile(
                  key: const Key('log_sleep'),
                  type: LogType.sleep,
                  color: AppColors.sleepBlue,
                  onTap: () => _openLogList(context, LogType.sleep),
                  onLongPress: () => _openLogForm(context, LogType.sleep),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 148,
                child: QuickLogTile(
                  key: const Key('log_medication_quick'),
                  type: LogType.medication,
                  color: AppColors.medicationAmber,
                  onTap: () => _openLogList(context, LogType.medication),
                  onLongPress: () => _openLogForm(context, LogType.medication),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _recentLogSection({
    required AsyncValue<List<CareLogEntry>> logsAsync,
    required bool isSignedIn,
    required bool useImperial,
    required bool showAttribution,
    required String? currentUserId,
  }) {
    return logsAsync.when(
      loading: () => [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (error, _) => const [
        _RecentPlaceholder(
          icon: Icons.cloud_off_outlined,
          title: 'Recent logs are resting',
          message: 'You can still add a care moment above and try again later.',
        ),
      ],
      data: (logs) {
        if (logs.isEmpty) {
          return const [
            _RecentPlaceholder(
              key: Key('empty_logs'),
              icon: Icons.nights_stay_outlined,
              title: 'A quiet start',
              message:
                  'Nothing logged yet today. Tap a button when you\'re ready.',
            ),
          ];
        }

        return [
          for (final entry in logs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LogEntryTile(
                entry: entry,
                useImperial: useImperial,
                isSignedIn: isSignedIn,
                showAttribution: showAttribution,
                currentUserId: currentUserId,
                onTap: () => showLogEntryActions(context, ref, entry),
              ),
            ),
        ];
      },
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final babyId = await db.careLogDao.ensureDefaultBaby();
      final baby = await db.careLogDao.getBaby(babyId);
      final events = await db.careLogDao.getLogsForLastDays(babyId, 7);
      final useImperial = await ref.read(useImperialUnitsProvider.future);
      final pdfService = ref.read(visitPdfServiceProvider);
      final bytes = await pdfService.buildSevenDaySummary(
        babyName: baby?.name ?? 'Baby',
        events: events,
        generatedAt: DateTime.now(),
        useImperialUnits: useImperial,
      );
      if (!context.mounted) return;
      await shareVisitPdf(bytes);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not create PDF. Try again.')),
        );
    }
  }

  String _partnerSyncCopy(SyncResult? lastSync) {
    if (lastSync == null) return 'Syncing shared care…';
    if (!lastSync.ok) return 'Sync needs a little attention';
    if (lastSync.pulled > 0) {
      return '${lastSync.pulled} new partner log${lastSync.pulled == 1 ? '' : 's'}';
    }
    return 'Shared care is up to date';
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({required this.greeting, this.syncCopy});

  final String greeting;
  final String? syncCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 16, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.nightElevated, AppColors.nightCard]
              : [AppColors.sageMist, AppColors.bloomMist],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : Colors.white.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.nightAccent : AppColors.sageDeep,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're doing fine.",
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'One calm care moment at a time.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText(brightness),
                  ),
                ),
                if (syncCopy != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    key: const Key('partner_sync_status'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface(
                        brightness,
                      ).withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sync_rounded,
                          color: AppColors.sage,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            syncCopy!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.mutedText(brightness),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 104,
              height: 116,
              child: Image.asset(
                BloomIllustrations.familyCare,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                color: isDark
                    ? AppColors.nightCard.withValues(alpha: 0.72)
                    : null,
                colorBlendMode: isDark ? BlendMode.multiply : null,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPlaceholder extends StatelessWidget {
  const _RecentPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return BloomSurface(
      color: AppColors.softSurface(brightness),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.sage),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

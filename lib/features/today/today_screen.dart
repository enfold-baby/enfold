import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'models/care_log_entry.dart';
import 'models/log_type.dart';
import '../../services/auth/auth_providers.dart';
import '../../services/database/database_provider.dart';
import '../../services/sync/sync_service.dart';
import '../../services/sync/sync_providers.dart';
import '../settings/providers/units_providers.dart';
import '../settings/widgets/export_section.dart';
import 'models/today_summary.dart';
import 'providers/today_log_provider.dart';
import '../logs/widgets/log_entry_actions.dart';
import '../logs/widgets/log_entry_tile.dart';
import '../growth/providers/growth_providers.dart';
import '../medication/providers/medication_providers.dart';
import '../medication/widgets/medication_entry_card.dart';
import '../partner/providers/partner_providers.dart';
import '../partner/widgets/gentle_nudge_banner.dart';
import '../pumping/providers/pumping_providers.dart';
import '../tummy_time/providers/tummy_time_providers.dart';
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
    if (!isSignedIn) {
      _autoSynced = false;
    }
    final useImperial = ref.watch(useImperialUnitsProvider).valueOrNull ?? false;
    final growthMeasurements =
        ref.watch(growthMeasurementsProvider).valueOrNull ?? const [];
    final milestoneStatuses =
        ref.watch(milestoneStatusesProvider).valueOrNull ?? const [];
    final milestonesAchieved =
        milestoneStatuses.where((status) => status.isAchieved).length;
    final medicationLogs =
        ref.watch(todayMedicationLogsProvider).valueOrNull ?? const [];
    final tummyLogs =
        ref.watch(todayTummyLogsProvider).valueOrNull ?? const [];
    final pumpingLogs =
        ref.watch(todayPumpingLogsProvider).valueOrNull ?? const [];
    final partnerNudge = ref.watch(partnerNudgeProvider).valueOrNull;
    final showPartnerNudge =
        partnerNudge != null && partnerNudge.type != _dismissedNudgeType;
    final showAttribution =
        ref.watch(hasPartnerProvider).valueOrNull ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's log"),
        actions: [
          IconButton(
            key: const Key('export_pdf_app_bar'),
            tooltip: 'Export 7-day PDF',
            onPressed: () => _exportPdf(context, ref),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              TodayScreen.greetingForHour(now.hour),
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.barkSoft,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "You're doing fine.",
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.cream : AppColors.bark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to open logs. Long-press to log with detail.',
              style: GoogleFonts.nunito(
                fontSize: 15,
                height: 1.45,
                color: AppColors.barkSoft,
              ),
            ),
            if (isSignedIn) ...[
              const SizedBox(height: 8),
              Text(
                _partnerSyncCopy(lastSync),
                key: const Key('partner_sync_status'),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppColors.sage,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 24),
            logsAsync.when(
              loading: () => const SizedBox(
                height: 108,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (logs) => TodaySummaryCards(
                summary: TodaySummary.fromEntries(logs),
              ),
            ),
            if (showPartnerNudge) ...[
              const SizedBox(height: 16),
              GentleNudgeBanner(
                nudge: partnerNudge!,
                onDismiss: () =>
                    setState(() => _dismissedNudgeType = partnerNudge.type),
              ),
            ],
            const SizedBox(height: 24),
            GrowthEntryCard(
              latestMeasurement:
                  growthMeasurements.isEmpty ? null : growthMeasurements.first,
              milestonesAchieved: milestonesAchieved,
              useImperial: useImperial,
              onTap: () => context.push(AppRoutes.growth),
            ),
            const SizedBox(height: 16),
            MedicationEntryCard(
              todayLogs: medicationLogs,
              onTap: () => context.push(AppRoutes.logMedication),
              onAdd: () => context.push(AppRoutes.logMedicationAdd),
            ),
            const SizedBox(height: 16),
            ActivityEntryCard(
              tummyLogs: tummyLogs,
              pumpingLogs: pumpingLogs,
              useImperial: useImperial,
              onTapTummy: () => context.push(AppRoutes.logTummy),
              onTapPumping: () => context.push(AppRoutes.logPumping),
              onAddTummy: () => context.push(AppRoutes.logTummyAdd),
              onAddPumping: () => context.push(AppRoutes.logPumpingAdd),
            ),
            const SizedBox(height: 28),
            Text(
              'Quick actions',
              key: const Key('today_quick_actions_heading'),
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickLogTile(
                    key: const Key('log_feed'),
                    type: LogType.feed,
                    color: AppColors.sage,
                    onTap: () => _openLogList(context, LogType.feed),
                    onLongPress: () => _openLogForm(context, LogType.feed),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickLogTile(
                    key: const Key('log_diaper'),
                    type: LogType.diaper,
                    color: AppColors.bloom,
                    onTap: () => _openLogList(context, LogType.diaper),
                    onLongPress: () => _openLogForm(context, LogType.diaper),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickLogTile(
                    key: const Key('log_sleep'),
                    type: LogType.sleep,
                    color: AppColors.sleepBlue,
                    onTap: () => _openLogList(context, LogType.sleep),
                    onLongPress: () => _openLogForm(context, LogType.sleep),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Recent',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 12),
            ..._recentLogSection(
              logsAsync: logsAsync,
              isDark: isDark,
              isSignedIn: isSignedIn,
              useImperial: useImperial,
              showAttribution: showAttribution,
              currentUserId: session?.user.id,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _recentLogSection({
    required AsyncValue<List<CareLogEntry>> logsAsync,
    required bool isDark,
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
      error: (error, _) => [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.nightElevated : AppColors.creamDeep,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.nightLine
                  : AppColors.bark.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            'Could not load recent logs. Tap a button above to start logging.',
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: AppColors.barkSoft,
            ),
          ),
        ),
      ],
      data: (logs) {
        if (logs.isEmpty) {
          return [
            Container(
              key: const Key('empty_logs'),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.nightElevated : AppColors.creamDeep,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.nightLine
                      : AppColors.bark.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                'Nothing logged yet today. Tap a button when you\'re ready.',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.barkSoft,
                ),
              ),
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
    if (lastSync == null) return 'Signed in · syncing with partner…';
    if (!lastSync.ok) return 'Sync issue · tap Settings → Sync now';
    if (lastSync.pulled > 0) {
      return 'Includes ${lastSync.pulled} log${lastSync.pulled == 1 ? '' : 's'} from partner';
    }
    return 'Shared log stays up to date when you sync';
  }

}
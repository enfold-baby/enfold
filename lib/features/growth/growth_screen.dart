import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/datetime/log_date_bounds.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../baby/providers/baby_profile_providers.dart';
import '../settings/providers/units_providers.dart';
import 'data/milestone_catalog.dart';
import 'models/milestone_definition.dart';
import 'providers/growth_providers.dart';
import 'utils/baby_age.dart';
import 'widgets/growth_trend_chart.dart';
import 'widgets/measurement_summary_card.dart';
import 'widgets/measurement_tile.dart';
import 'widgets/milestone_tile.dart';
import '../../widgets/sync_refresh.dart';
import '../../widgets/paginated_column.dart';
import 'models/growth_measurement_entry.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(growthMeasurementsProvider);
    final milestonesAsync = ref.watch(milestoneStatusesProvider);
    final babyAsync = ref.watch(activeBabyProvider);
    final useImperial = ref.watch(useImperialUnitsProvider).valueOrNull ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ageLabel = babyAsync.valueOrNull?.birthDate != null
        ? babyAgeLabel(babyAsync.valueOrNull!.birthDate)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Growth & milestones')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_growth_measurement'),
        onPressed: () {
          final location = GoRouter.of(context).state.matchedLocation;
          context.push(AppRoutes.growthAddFrom(location));
        },
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('growth_pull_to_refresh'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              'Growing beautifully',
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.cream : AppColors.bark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ageLabel != null
                  ? '$ageLabel · log checkups when you have them.'
                  : 'Set birth date in Settings for age hints. Log measurements anytime.',
              style: GoogleFonts.nunito(
                fontSize: 15,
                height: 1.45,
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Measurements',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.accent(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 12),
            measurementsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(
                'Could not load measurements.',
                style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness)),
              ),
              data: (measurements) {
                final latest = measurements.isEmpty ? null : measurements.first;
                return Column(
                  children: [
                    MeasurementSummaryCard(
                      latest: latest,
                      useImperial: useImperial,
                    ),
                    const SizedBox(height: 16),
                    GrowthTrendChart(
                      measurements: measurements,
                      useImperial: useImperial,
                    ),
                    if (measurements.length > 1) ...[
                      const SizedBox(height: 20),
                      Text(
                        'History',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.accent(Theme.of(context).brightness),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PaginatedColumn<GrowthMeasurementEntry>(
                        items: measurements.skip(1).toList(),
                        loadMoreKey: const Key('load_more_measurements'),
                        itemBuilder: (context, entry) => MeasurementTile(
                          entry: entry,
                          useImperial: useImperial,
                          onDelete: () => _confirmDelete(context, ref, entry.id),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            milestonesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (statuses) {
                final achieved =
                    statuses.where((status) => status.isAchieved).length;
                final groups = <String, List<MilestoneStatus>>{};
                for (final status in statuses) {
                  groups.putIfAbsent(status.definition.group, () => []).add(status);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestones',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.accent(Theme.of(context).brightness),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$achieved of ${MilestoneCatalog.totalCount} celebrated · '
                      'every baby has their own pace.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.mutedText(Theme.of(context).brightness),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final group in groups.keys)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: Text(
                              group,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.cream : AppColors.bark,
                              ),
                            ),
                          ),
                          for (final status in groups[group]!)
                            MilestoneTile(
                              status: status,
                              onToggle: () => handleMilestoneToggle(
                                context,
                                ref,
                                status,
                              ),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete measurement?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(growthActionsProvider).deleteMeasurement(id);
  }
}

enum _MilestoneEditChoice { changeDate, clear }

Future<void> handleMilestoneToggle(
  BuildContext context,
  WidgetRef ref,
  MilestoneStatus status,
) async {
  final actions = ref.read(growthActionsProvider);
  if (status.isAchieved) {
    final choice = await showDialog<_MilestoneEditChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const Key('milestone_edit_dialog'),
          title: Text(status.definition.title),
          content: const Text(
            'Change the date they reached this, or mark it as not yet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('milestone_clear'),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_MilestoneEditChoice.clear),
              child: const Text('Not yet'),
            ),
            FilledButton(
              key: const Key('milestone_change_date'),
              onPressed: () => Navigator.of(dialogContext)
                  .pop(_MilestoneEditChoice.changeDate),
              child: const Text('Change date'),
            ),
          ],
        );
      },
    );
    if (!context.mounted || choice == null) return;
    if (choice == _MilestoneEditChoice.clear) {
      await actions.clearMilestone(status.definition);
      return;
    }
    final date = await pickMilestoneDate(context, status.achievedAt);
    if (date == null || !context.mounted) return;
    await actions.setMilestoneAchieved(status.definition, date);
    return;
  }

  final date = await pickMilestoneDate(context, DateTime.now());
  if (date == null || !context.mounted) return;
  await actions.setMilestoneAchieved(status.definition, date);
}

Future<DateTime?> pickMilestoneDate(
  BuildContext context,
  DateTime? initial,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  var initialDate = initial ?? today;
  if (initialDate.isAfter(today)) initialDate = today;
  initialDate = LogDateBounds.clampInitial(initialDate, now: today);
  if (initialDate.isAfter(today)) initialDate = today;
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: LogDateBounds.firstDate(today),
    lastDate: today,
    helpText: 'When did they reach this?',
  );
}
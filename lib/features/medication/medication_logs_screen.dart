import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../logs/widgets/log_period_bar.dart';
import '../logs/widgets/paginated_log_list.dart';
import '../logs/widgets/type_filter_chips.dart';
import 'data/medication_presets.dart';
import 'providers/medication_providers.dart';
import 'widgets/medication_routines_section.dart';
import '../../widgets/sync_refresh.dart';

class MedicationLogsScreen extends ConsumerWidget {
  const MedicationLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(medicationLogsProvider);
    final category = ref.watch(medicationCategoryFilterProvider);
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicationLogsTitle)),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_medication_log'),
        onPressed: () => context.push(AppRoutes.logMedicationAdd),
        backgroundColor: AppColors.medicationAmber,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('medication_logs_pull_to_refresh'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              l10n.medicationLogsAll,
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const MedicationRoutinesSection(),
            LogPeriodBar(periodProvider: medicationLogPeriodProvider),
            const SizedBox(height: 20),
            DetailFilterChips<String>(
              label: l10n.medicationCategoryLabel,
              options: [
                for (final value in MedicationPresets.categoryValues)
                  DetailFilterOption(
                    value: value,
                    label: MedicationPresets.categoryLabel(l10n, value),
                  ),
              ],
              selected: category,
              onSelected: (value) =>
                  ref.read(medicationCategoryFilterProvider.notifier).state =
                      value,
            ),
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('medication_logs_empty'),
              emptyMessage: l10n.medicationLogsEmpty,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'providers/logs_providers.dart';
import 'widgets/log_period_bar.dart';
import 'widgets/paginated_log_list.dart';
import 'widgets/type_filter_chips.dart';
import '../../widgets/sync_refresh.dart';

class DiaperLogsScreen extends ConsumerWidget {
  const DiaperLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(diaperLogsProvider);
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaperLogsTitle)),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_diaper_log'),
        onPressed: () => context.push(AppRoutes.logDiaperAdd),
        backgroundColor: AppColors.bloom,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('diaper_logs_pull_to_refresh'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              l10n.diaperLogsAll,
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: diaperLogPeriodProvider),
            const SizedBox(height: 20),
            DetailFilterChips<String>(
              label: l10n.diaperLogsContentsFilter,
              options: [
                DetailFilterOption(value: 'wet', label: l10n.diaperLogsWet),
                DetailFilterOption(
                  value: 'dirty',
                  label: l10n.diaperLogsDirty,
                ),
              ],
              selected: _diaperContentsSelection(ref),
              onSelected: (value) => _setDiaperContentsFilter(ref, value),
            ),
            const SizedBox(height: 16),
            DetailFilterChips<String>(
              label: l10n.diaperLogsConsistencyFilter,
              options: [
                DetailFilterOption(
                  value: 'normal',
                  label: l10n.diaperStoolNormal,
                ),
                DetailFilterOption(
                  value: 'soft',
                  label: l10n.diaperStoolSoft,
                ),
                DetailFilterOption(
                  value: 'hard',
                  label: l10n.diaperStoolHard,
                ),
                DetailFilterOption(
                  value: 'loose',
                  label: l10n.diaperStoolLoose,
                ),
              ],
              selected: ref.watch(diaperConsistencyFilterProvider),
              onSelected: (value) =>
                  ref.read(diaperConsistencyFilterProvider.notifier).state =
                      value,
            ),
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('diaper_logs_empty'),
              emptyMessage: l10n.diaperLogsEmpty,
            ),
          ],
        ),
        ),
      ),
    );
  }

  String? _diaperContentsSelection(WidgetRef ref) {
    if (ref.watch(diaperWetFilterProvider) == true) return 'wet';
    if (ref.watch(diaperDirtyFilterProvider) == true) return 'dirty';
    return null;
  }

  void _setDiaperContentsFilter(WidgetRef ref, String? value) {
    ref.read(diaperWetFilterProvider.notifier).state =
        value == 'wet' ? true : null;
    ref.read(diaperDirtyFilterProvider.notifier).state =
        value == 'dirty' ? true : null;
  }
}
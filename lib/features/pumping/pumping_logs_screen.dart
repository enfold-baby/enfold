import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../logs/widgets/log_period_bar.dart';
import '../logs/widgets/paginated_log_list.dart';
import '../logs/widgets/type_filter_chips.dart';
import 'providers/pumping_providers.dart';
import '../../widgets/sync_refresh.dart';

class PumpingLogsScreen extends ConsumerWidget {
  const PumpingLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(pumpingLogsProvider);
    final side = ref.watch(pumpingSideFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pumping')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_pumping_log'),
        onPressed: () => context.push(AppRoutes.logPumpingAdd),
        backgroundColor: AppColors.pumpLavender,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('pumping_logs_pull_to_refresh'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              'All pumping sessions',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: pumpingLogPeriodProvider),
            const SizedBox(height: 20),
            DetailFilterChips<String>(
              label: 'Side',
              options: const [
                DetailFilterOption(value: 'left', label: 'Left'),
                DetailFilterOption(value: 'right', label: 'Right'),
                DetailFilterOption(value: 'both', label: 'Both'),
              ],
              selected: side,
              onSelected: (value) =>
                  ref.read(pumpingSideFilterProvider.notifier).state = value,
            ),
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('pumping_logs_empty'),
              emptyMessage:
                  'No pumping logs in this period. Tap + to add one.',
            ),
          ],
        ),
        ),
      ),
    );
  }
}
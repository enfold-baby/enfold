import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'providers/logs_providers.dart';
import 'widgets/log_period_bar.dart';
import 'widgets/paginated_log_list.dart';
import 'widgets/type_filter_chips.dart';
import '../../widgets/sync_refresh.dart';

class FeedLogsScreen extends ConsumerWidget {
  const FeedLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(feedLogsProvider);
    final feedMode = ref.watch(feedModeFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed logs')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_feed_log'),
        onPressed: () => context.push(AppRoutes.logFeedAdd),
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('feed_logs_pull_to_refresh'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              'All feeds',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: feedLogPeriodProvider),
            const SizedBox(height: 20),
            DetailFilterChips<String>(
              label: 'Type',
              options: const [
                DetailFilterOption(value: 'breast', label: 'Breast'),
                DetailFilterOption(value: 'formula', label: 'Formula'),
              ],
              selected: feedMode,
              onSelected: (value) {
                ref.read(feedModeFilterProvider.notifier).state = value;
                if (value != 'breast') {
                  ref.read(feedDeliveryFilterProvider.notifier).state = null;
                }
              },
            ),
            if (feedMode == 'breast') ...[
              const SizedBox(height: 16),
              DetailFilterChips<String>(
                label: 'Breast delivery',
                options: const [
                  DetailFilterOption(value: 'direct', label: 'At breast'),
                  DetailFilterOption(value: 'pumped', label: 'Pumped'),
                ],
                selected: ref.watch(feedDeliveryFilterProvider),
                onSelected: (value) =>
                    ref.read(feedDeliveryFilterProvider.notifier).state = value,
              ),
            ],
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('feed_logs_empty'),
              emptyMessage: 'No feed logs in this period. Tap + to add one.',
            ),
          ],
        ),
        ),
      ),
    );
  }
}
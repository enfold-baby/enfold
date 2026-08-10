import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../logs/widgets/log_period_bar.dart';
import '../logs/widgets/paginated_log_list.dart';
import 'providers/tummy_time_providers.dart';
import '../../widgets/sync_refresh.dart';

class TummyTimeLogsScreen extends ConsumerWidget {
  const TummyTimeLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(tummyLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tummy time')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_tummy_log'),
        onPressed: () => context.push(AppRoutes.logTummyAdd),
        backgroundColor: AppColors.tummyCoral,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SyncRefresh(
          indicatorKey: const Key('tummy_logs_pull_to_refresh'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              'All tummy sessions',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: tummyLogPeriodProvider),
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('tummy_logs_empty'),
              emptyMessage:
                  'No tummy time logs in this period. Tap + to add one.',
            ),
          ],
        ),
        ),
      ),
    );
  }
}
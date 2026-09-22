import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../logs/widgets/log_period_bar.dart';
import '../logs/widgets/paginated_log_list.dart';
import 'providers/tummy_time_providers.dart';
import '../../widgets/sync_refresh.dart';

class TummyTimeLogsScreen extends ConsumerWidget {
  const TummyTimeLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(tummyLogsProvider);
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tummyLogsTitle)),
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
              l10n.tummyLogsAll,
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
              emptyMessage: l10n.tummyLogsEmpty,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
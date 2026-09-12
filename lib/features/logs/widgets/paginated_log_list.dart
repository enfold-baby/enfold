import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/paginated_column.dart';
import '../../../services/auth/auth_providers.dart';
import '../../settings/providers/units_providers.dart';
import '../../today/models/care_log_entry.dart';
import 'log_entry_actions.dart';
import 'log_entry_tile.dart';

class PaginatedLogList extends ConsumerWidget {
  const PaginatedLogList({
    super.key,
    required this.logsAsync,
    this.pageSize = 10,
    this.visibleCountProvider,
    this.emptyMessage = 'No logs in this period.',
    this.emptyKey,
  });

  final AsyncValue<List<CareLogEntry>> logsAsync;
  final int pageSize;
  final StateProvider<int>? visibleCountProvider;
  final String emptyMessage;
  final Key? emptyKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).valueOrNull;
    final isSignedIn = session != null;
    final showAttribution = isSignedIn;
    final useImperial = ref.watch(useImperialUnitsProvider).valueOrNull ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return logsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Text(
        'Could not load logs.',
        style: GoogleFonts.nunito(
          color: AppColors.mutedText(Theme.of(context).brightness),
        ),
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return Container(
            key: emptyKey,
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
              emptyMessage,
              style: GoogleFonts.nunito(
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
          );
        }

        return PaginatedColumn<CareLogEntry>(
          items: logs,
          pageSize: pageSize,
          visibleCountProvider: visibleCountProvider,
          loadMoreKey: const Key('load_more_logs'),
          itemBuilder: (context, entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LogEntryTile(
              entry: entry,
              useImperial: useImperial,
              isSignedIn: isSignedIn,
              showAttribution: showAttribution,
              currentUserId: session?.user.id,
              onTap: () => showLogEntryActions(context, ref, entry),
            ),
          ),
        );
      },
    );
  }
}

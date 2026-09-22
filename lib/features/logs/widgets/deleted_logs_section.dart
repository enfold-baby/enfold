import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/datetime/clock_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/providers/time_format_providers.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/providers/today_log_provider.dart';
import '../providers/logs_providers.dart';
import 'log_entry_actions.dart';

class DeletedLogsSection extends ConsumerWidget {
  const DeletedLogsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedAsync = ref.watch(deletedLogsProvider);
    final use24Hour = ref.watch(use24HourTimeProvider).valueOrNull ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return deletedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        final l10n = AppL10n.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              l10n.deletedLogsTitle,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.accent(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.deletedLogsSubtitle,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.mutedText(Theme.of(context).brightness),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in entries)
              _DeletedLogTile(
                entry: entry,
                isDark: isDark,
                use24Hour: use24Hour,
                onRestore: () async {
                  await ref.read(careLogActionsProvider).restoreLog(entry.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.deletedLogRestored(entry.type.label(l10n)),
                        ),
                      ),
                    );
                },
                onDeleteForever: () async {
                  final confirmed = await _confirmPermanentDelete(context);
                  if (!confirmed) return;
                  final removed = await ref
                      .read(careLogActionsProvider)
                      .permanentDeleteLog(entry.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          removed
                              ? l10n.deletedLogPurged(entry.type.label(l10n))
                              : l10n.deletedLogPurgeFailed,
                        ),
                      ),
                    );
                },
              ),
          ],
        );
      },
    );
  }
}

Future<bool> _confirmPermanentDelete(BuildContext context) async {
  final l10n = AppL10n.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deletedLogPurgeTitle),
          content: Text(l10n.deletedLogPurgeBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bloomDeep,
                foregroundColor: AppColors.cream,
              ),
              child: Text(l10n.deletedLogPurgeConfirm),
            ),
          ],
        ),
      ) ??
      false;
}

class _DeletedLogTile extends StatelessWidget {
  const _DeletedLogTile({
    required this.entry,
    required this.isDark,
    required this.use24Hour,
    required this.onRestore,
    required this.onDeleteForever,
  });

  final CareLogEntry entry;
  final bool isDark;
  final bool use24Hour;
  final VoidCallback onRestore;
  final VoidCallback onDeleteForever;

  @override
  Widget build(BuildContext context) {
    final deletedAt = entry.deletedAt;
    if (deletedAt == null) return const SizedBox.shrink();

    final logged = ClockFormat.formatDateAndTime(
      entry.loggedAt,
      use24Hour: use24Hour,
    );
    final daysLeft = recoveryDaysRemaining(deletedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('deleted_log_${entry.id}'),
        tileColor: isDark ? AppColors.nightElevated : AppColors.creamDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark
                ? AppColors.nightLine
                : AppColors.bark.withValues(alpha: 0.08),
          ),
        ),
        leading: Icon(entry.type.icon, color: AppColors.mutedText(Theme.of(context).brightness)),
        title: Text(
          entry.type.label(AppL10n.of(context)),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '$logged · ${AppL10n.of(context).deletedLogDaysLeft(daysLeft)}',
          style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness), fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('delete_forever_log_${entry.id}'),
              tooltip: AppL10n.of(context).deletedLogPurgeConfirm,
              onPressed: onDeleteForever,
              icon: const Icon(Icons.delete_forever_outlined),
              color: AppColors.bloomDeep,
            ),
            TextButton(
              key: Key('restore_log_${entry.id}'),
              onPressed: onRestore,
              child: Text(AppL10n.of(context).deletedLogRestore),
            ),
          ],
        ),
      ),
    );
  }
}
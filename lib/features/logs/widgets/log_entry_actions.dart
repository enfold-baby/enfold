import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/providers/today_log_provider.dart';
import '../log_retention.dart';

Future<void> showLogEntryActions(
  BuildContext context,
  WidgetRef ref,
  CareLogEntry entry,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = AppL10n.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.type.label(l10n),
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.detailSummary(l10n) ?? l10n.logActionsFallbackTitle,
                style: GoogleFonts.nunito(
                  color: AppColors.mutedText(Theme.of(context).brightness),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: Key('edit_log_${entry.id}'),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.logEdit(entry.type, entry.id));
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.logActionsEdit),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: Key('delete_log_${entry.id}'),
                onPressed: () async {
                  final confirmed = await _confirmDelete(context);
                  if (!confirmed) return;
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  await ref
                      .read(careLogActionsProvider)
                      .softDeleteLog(entry.id);
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.logActionsSoftDeleted(entry.type.label(l10n)),
                        ),
                      ),
                    );
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.logActionsDelete),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.bloomDeep,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> _confirmDelete(BuildContext context) async {
  final l10n = AppL10n.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.logActionsDeleteTitle),
          content: Text(l10n.logActionsDeleteBody(LogRetention.recoveryDays)),
          actions: [
            TextButton(
              key: const Key('delete_log_cancel'),
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              key: const Key('delete_log_confirm'),
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bloomDeep,
                foregroundColor: AppColors.cream,
              ),
              child: Text(l10n.logActionsDelete),
            ),
          ],
        ),
      ) ??
      false;
}

int recoveryDaysRemaining(DateTime deletedAt) {
  final expiresAt = deletedAt.add(
    const Duration(days: LogRetention.recoveryDays),
  );
  final remaining = expiresAt.difference(DateTime.now()).inDays;
  return remaining < 0 ? 0 : remaining;
}

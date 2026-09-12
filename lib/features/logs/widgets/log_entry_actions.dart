import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
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
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entry.type.label,
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.detailSummary() ?? 'Logged entry',
              style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: Key('edit_log_${entry.id}'),
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.logEdit(entry.type, entry.id));
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
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
                await ref.read(careLogActionsProvider).softDeleteLog(entry.id);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        '${entry.type.label} moved to Recently deleted',
                      ),
                    ),
                  );
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.bloomDeep,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> _confirmDelete(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete this log?'),
          content: Text(
            'You can restore it within ${LogRetention.recoveryDays} days '
            'from Logs → Recently deleted. After that it is permanently removed.',
          ),
          actions: [
            TextButton(
              key: const Key('delete_log_cancel'),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('delete_log_confirm'),
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bloomDeep,
                foregroundColor: AppColors.cream,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}

int recoveryDaysRemaining(DateTime deletedAt) {
  final expiresAt =
      deletedAt.add(const Duration(days: LogRetention.recoveryDays));
  final remaining = expiresAt.difference(DateTime.now()).inDays;
  return remaining < 0 ? 0 : remaining;
}
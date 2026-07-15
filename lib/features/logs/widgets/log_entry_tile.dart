import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../today/models/care_log_entry.dart';
import '../../today/models/log_type.dart';

class LogEntryTile extends StatelessWidget {
  const LogEntryTile({
    super.key,
    required this.entry,
    required this.useImperial,
    this.isSignedIn = false,
    this.showAttribution = false,
    this.currentUserId,
    this.onTap,
  });

  final CareLogEntry entry;
  final bool useImperial;
  final bool isSignedIn;
  final bool showAttribution;
  final String? currentUserId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('MMM d · h:mm a');
    final time = timeFormat.format(entry.loggedAt);
    final sync = !entry.pendingSync
        ? 'synced'
        : isSignedIn
            ? 'will sync'
            : 'on device';
    final detail = entry.detailSummary(useImperial: useImperial);
    final loggedBy = entry.loggedByLabel(
      currentUserId: currentUserId,
      showAttribution: showAttribution,
    );
    final parts = <String>[time];
    if (detail != null && detail.isNotEmpty) parts.add(detail);
    if (loggedBy != null) parts.add(loggedBy);
    parts.add(sync);
    final subtitle = parts.join(' · ');
    final title = switch (entry.type) {
      LogType.medication
          when entry.details.medicationName != null &&
              entry.details.medicationName!.isNotEmpty =>
        entry.details.medicationName!,
      LogType.pumping => 'Pumping',
      LogType.tummyTime => 'Tummy time',
      _ => entry.type.label,
    };

    return ListTile(
      key: Key('log_entry_${entry.id}'),
      onTap: onTap,
      tileColor: isDark ? AppColors.nightElevated : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.08),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: entry.type.color,
        child: Icon(entry.type.icon, color: AppColors.cream, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(color: AppColors.barkSoft),
      ),
    );
  }
}
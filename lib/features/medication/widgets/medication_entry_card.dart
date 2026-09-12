import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/datetime/clock_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/database/app_database.dart';
import '../../today/models/care_log_entry.dart';
import '../utils/medication_routine_due.dart';

class MedicationEntryCard extends StatelessWidget {
  const MedicationEntryCard({
    super.key,
    required this.todayLogs,
    required this.routines,
    required this.use24Hour,
    required this.onTap,
    required this.onAdd,
    this.onGive,
  });

  final List<CareLogEntry> todayLogs;
  final List<MedicationRoutine> routines;
  final bool use24Hour;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final ValueChanged<MedicationRoutine>? onGive;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final enabled = [for (final r in routines) if (r.enabled) r];

    return Material(
      color: isDark ? AppColors.nightElevated : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('today_medication_card'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.nightLine
                  : AppColors.bark.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.medicationAmber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meds & vitamins',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (enabled.isEmpty)
                      Text(
                        _fallbackSubtitle(todayLogs),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: AppColors.mutedText(brightness),
                        ),
                      )
                    else
                      for (final routine in enabled)
                        _RoutineLine(
                          routine: routine,
                          todayLogs: todayLogs,
                          use24Hour: use24Hour,
                          onGive: onGive,
                        ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('add_medication_quick'),
                tooltip: 'Log medication',
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.medicationAmber,
              ),
              Icon(Icons.chevron_right, color: AppColors.mutedText(brightness)),
            ],
          ),
        ),
      ),
    );
  }

  static String _fallbackSubtitle(List<CareLogEntry> todayLogs) {
    final count = todayLogs.length;
    final latest = todayLogs.isEmpty ? null : todayLogs.first;
    if (count == 0) {
      return 'Track vitamins, supplements, and medications';
    }
    if (latest?.details.medicationName != null) {
      final name = latest!.details.medicationName!;
      return count == 1
          ? 'Today: $name'
          : 'Today: $count doses · latest $name';
    }
    return count == 1 ? '1 dose logged today' : '$count doses logged today';
  }
}

class _RoutineLine extends StatelessWidget {
  const _RoutineLine({
    required this.routine,
    required this.todayLogs,
    required this.use24Hour,
    this.onGive,
  });

  final MedicationRoutine routine;
  final List<CareLogEntry> todayLogs;
  final bool use24Hour;
  final ValueChanged<MedicationRoutine>? onGive;

  @override
  Widget build(BuildContext context) {
    final loggedAt = latestDoseAt(name: routine.name, todayLogs: todayLogs);
    final timeLabel = loggedAt == null
        ? null
        : ClockFormat.formatTime(loggedAt, use24Hour: use24Hour);
    final line = medicationRoutineTodayLine(
      name: routine.name,
      timeLabel: timeLabel,
    );
    final due = loggedAt == null;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
          ),
          if (due && onGive != null)
            IconButton(
              key: Key('medication_give_${routine.id}'),
              tooltip: 'Log ${routine.name}',
              visualDensity: VisualDensity.compact,
              onPressed: () => onGive!(routine),
              icon: const Icon(Icons.check_circle_outline, size: 22),
              color: AppColors.medicationAmber,
            ),
        ],
      ),
    );
  }
}

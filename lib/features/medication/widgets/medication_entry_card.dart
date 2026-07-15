import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../today/models/care_log_entry.dart';

class MedicationEntryCard extends StatelessWidget {
  const MedicationEntryCard({
    super.key,
    required this.todayLogs,
    required this.onTap,
    required this.onAdd,
  });

  final List<CareLogEntry> todayLogs;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = todayLogs.length;
    final latest = todayLogs.isEmpty ? null : todayLogs.first;

    String subtitle;
    if (count == 0) {
      subtitle = 'Track vitamins, supplements, and medications';
    } else if (latest?.details.medicationName != null) {
      final name = latest!.details.medicationName!;
      subtitle = count == 1
          ? 'Today: $name'
          : 'Today: $count doses · latest $name';
    } else {
      subtitle = count == 1 ? '1 dose logged today' : '$count doses logged today';
    }

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
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.barkSoft,
                      ),
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
              const Icon(Icons.chevron_right, color: AppColors.barkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
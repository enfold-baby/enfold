import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/log_type.dart';
import '../models/today_summary.dart';

class TodaySummaryCards extends StatelessWidget {
  const TodaySummaryCards({
    super.key,
    required this.summary,
  });

  final TodaySummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today so far',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.sage,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                key: const Key('today_summary_feed'),
                type: LogType.feed,
                value: '${summary.feedCount}',
                label: summary.feedCount == 1 ? 'feed' : 'feeds',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                key: const Key('today_summary_diaper'),
                type: LogType.diaper,
                value: '${summary.diaperCount}',
                label: summary.diaperCount == 1 ? 'diaper' : 'diapers',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                key: const Key('today_summary_sleep'),
                type: LogType.sleep,
                value: summary.sleepLabel,
                label: 'sleep',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    super.key,
    required this.type,
    required this.value,
    required this.label,
    required this.isDark,
  });

  final LogType type;
  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(type.icon, color: type.color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.cream : AppColors.bark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.barkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
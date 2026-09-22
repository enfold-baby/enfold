import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/bloom_section_header.dart';
import '../../../widgets/bloom_surface.dart';
import '../models/log_type.dart';
import '../models/today_summary.dart';
import '../../../l10n/generated/app_localizations.dart';

class TodaySummaryCards extends StatelessWidget {
  const TodaySummaryCards({super.key, required this.summary});

  final TodaySummary summary;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BloomSectionHeader(
          title: l10n.todaySoFar,
          subtitle: l10n.todaySoFarSubtitle,
        ),
        const SizedBox(height: 12),
        BloomSurface(
          color: AppColors.softSurface(brightness),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    key: const Key('today_summary_feed'),
                    type: LogType.feed,
                    value: '${summary.feedCount}',
                    label: l10n.todaySummaryFeeds(summary.feedCount),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _SummaryMetric(
                    key: const Key('today_summary_diaper'),
                    type: LogType.diaper,
                    value: '${summary.diaperCount}',
                    label: l10n.todaySummaryDiapers(summary.diaperCount),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _SummaryMetric(
                    key: const Key('today_summary_sleep'),
                    type: LogType.sleep,
                    value: summary.sleepLabel,
                    label: l10n.todaySummarySleep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    super.key,
    required this.type,
    required this.value,
    required this.label,
  });

  final LogType type;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, color: type.color, size: 21),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: theme.textTheme.headlineMedium?.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.mutedText(brightness),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

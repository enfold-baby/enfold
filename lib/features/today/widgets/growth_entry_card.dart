import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/units/growth_units.dart';
import '../../growth/data/milestone_catalog.dart';
import '../../growth/models/growth_measurement_entry.dart';

class GrowthEntryCard extends StatelessWidget {
  const GrowthEntryCard({
    super.key,
    required this.latestMeasurement,
    required this.milestonesAchieved,
    required this.useImperial,
    required this.onTap,
  });

  final GrowthMeasurementEntry? latestMeasurement;
  final int milestonesAchieved;
  final bool useImperial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    String subtitle;
    if (latestMeasurement?.weightKg != null) {
      subtitle =
          'Latest weight ${GrowthUnits.formatWeightKg(latestMeasurement!.weightKg, useImperial: useImperial)} · '
          '$milestonesAchieved/${MilestoneCatalog.totalCount} milestones';
    } else {
      subtitle =
          '$milestonesAchieved/${MilestoneCatalog.totalCount} milestones celebrated';
    }

    return Material(
      color: isDark ? AppColors.nightElevated : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('today_growth_card'),
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
                  color: AppColors.sage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.straighten_outlined,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growth & milestones',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: AppColors.mutedText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.mutedText(brightness)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/datetime/clock_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/units/growth_units.dart';
import '../../settings/providers/time_format_providers.dart';
import '../models/growth_measurement_entry.dart';

class MeasurementTile extends ConsumerWidget {
  const MeasurementTile({
    super.key,
    required this.entry,
    required this.useImperial,
    required this.onDelete,
  });

  final GrowthMeasurementEntry entry;
  final bool useImperial;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final use24Hour = ref.watch(use24HourTimeProvider).valueOrNull ?? false;
    final parts = <String>[];
    if (entry.weightKg != null) {
      parts.add(
        GrowthUnits.formatWeightKg(entry.weightKg, useImperial: useImperial),
      );
    }
    if (entry.lengthCm != null) {
      parts.add(
        'L ${GrowthUnits.formatLengthCm(entry.lengthCm, useImperial: useImperial)}',
      );
    }
    if (entry.headCm != null) {
      parts.add(
        'H ${GrowthUnits.formatLengthCm(entry.headCm, useImperial: useImperial)}',
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.08),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          ClockFormat.formatLongDateAndTime(
            entry.measuredAt,
            use24Hour: use24Hour,
          ),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          parts.isEmpty ? 'Measurement logged' : parts.join(' · '),
          style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: AppColors.bloomDeep,
          onPressed: onDelete,
        ),
      ),
    );
  }
}
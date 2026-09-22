import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/units/growth_units.dart';
import '../models/growth_measurement_entry.dart';

class MeasurementSummaryCard extends StatelessWidget {
  const MeasurementSummaryCard({
    super.key,
    required this.latest,
    required this.useImperial,
  });

  final GrowthMeasurementEntry? latest;
  final bool useImperial;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppL10n.of(context);

    if (latest == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _boxDecoration(isDark),
        child: Text(
          l10n.growthSummaryEmpty,
          style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness), height: 1.45),
        ),
      );
    }

    final dateFormat = DateFormat.yMMMd();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.growthSummaryLatest(dateFormat.format(latest!.measuredAt)),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.accent(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: l10n.growthWeight,
                  value: GrowthUnits.formatWeightKg(
                    latest!.weightKg,
                    useImperial: useImperial,
                  ),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: l10n.growthLength,
                  value: GrowthUnits.formatLengthCm(
                    latest!.lengthCm,
                    useImperial: useImperial,
                  ),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: l10n.growthHead,
                  value: GrowthUnits.formatLengthCm(
                    latest!.headCm,
                    useImperial: useImperial,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.nightElevated : AppColors.creamDeep,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? AppColors.nightLine
            : AppColors.bark.withValues(alpha: 0.08),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 12, color: AppColors.mutedText(Theme.of(context).brightness)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
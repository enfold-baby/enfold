import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/log_period_filter.dart';

typedef PeriodFilterNotifier = StateProvider<LogPeriodFilter>;

class LogPeriodBar extends ConsumerWidget {
  const LogPeriodBar({
    super.key,
    required this.periodProvider,
  });

  final PeriodFilterNotifier periodProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(periodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in LogPeriodPreset.values)
              _PeriodChip(
                label: preset == LogPeriodPreset.custom && period.isCustom
                    ? period.periodLabel()
                    : preset.label,
                selected: period.preset == preset,
                onTap: () async {
                  if (preset == LogPeriodPreset.custom) {
                    await _pickCustomRange(context, ref);
                  } else {
                    ref.read(periodProvider.notifier).state =
                        LogPeriodFilter(preset: preset);
                  }
                },
              ),
          ],
        ),
        if (period.isCustom) ...[
          const SizedBox(height: 8),
          Text(
            'Showing ${period.periodLabel()}',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: isDark ? AppColors.cream : AppColors.barkSoft,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final current = ref.read(periodProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365 * 3)),
      lastDate: now,
      initialDateRange: current.customStart != null && current.customEnd != null
          ? DateTimeRange(start: current.customStart!, end: current.customEnd!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 6)),
              end: now,
            ),
    );
    if (picked == null) return;
    ref.read(periodProvider.notifier).state = LogPeriodFilter(
      preset: LogPeriodPreset.custom,
      customStart: picked.start,
      customEnd: picked.end,
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: GoogleFonts.nunito(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: selected
            ? AppColors.cream
            : (isDark ? AppColors.cream : AppColors.bark),
      ),
      selectedColor: AppColors.sage,
      backgroundColor: isDark ? AppColors.nightElevated : AppColors.creamDeep,
      side: BorderSide(
        color: selected
            ? AppColors.sage
            : (isDark ? AppColors.nightLine : AppColors.bark.withValues(alpha: 0.12)),
      ),
      showCheckmark: false,
    );
  }
}
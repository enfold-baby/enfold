import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/datetime/clock_format.dart';
import '../../../core/datetime/log_date_bounds.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/providers/time_format_providers.dart';

class TimeField extends ConsumerWidget {
  const TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24Hour = ref.watch(use24HourTimeProvider).valueOrNull ?? false;
    final formatted = ClockFormat.formatWeekdayDateAndTime(
      value,
      use24Hour: use24Hour,
    );
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return OutlinedButton(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: LogDateBounds.clampInitial(value),
          firstDate: LogDateBounds.firstDate(),
          lastDate: LogDateBounds.lastDate(),
        );
        if (date == null || !context.mounted) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: use24Hour,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
        if (time == null) return;

        onChanged(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
      },
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.mutedText(brightness),
            ),
          ),
          const SizedBox(height: 4),
          Text(formatted, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

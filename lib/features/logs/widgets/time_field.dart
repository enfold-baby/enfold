import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class TimeField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final format = DateFormat('EEE, MMM d · h:mm a');
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return OutlinedButton(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: value.subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (date == null || !context.mounted) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
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
          Text(format.format(value), style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

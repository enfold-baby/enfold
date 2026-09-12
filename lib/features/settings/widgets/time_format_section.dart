import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/time_format_providers.dart';

class TimeFormatSection extends ConsumerWidget {
  const TimeFormatSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockAsync = ref.watch(use24HourTimeProvider);
    final brightness = Theme.of(context).brightness;

    return clockAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (use24Hour) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              'Time',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'How times appear in logs, pickers, and the visit PDF.',
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              key: const Key('clock_format_selector'),
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('12-hour (AM/PM)'),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('24-hour'),
                ),
              ],
              selected: {use24Hour},
              onSelectionChanged: (selection) {
                ref.read(timeFormatActionsProvider).setUse24Hour(selection.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}

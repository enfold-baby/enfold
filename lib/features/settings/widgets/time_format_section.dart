import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/time_format_providers.dart';
import '../../../widgets/segment_label.dart';

class TimeFormatSection extends ConsumerWidget {
  const TimeFormatSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockAsync = ref.watch(use24HourTimeProvider);
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);

    return clockAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (use24Hour) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              l10n.settingsTimeTitle,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              l10n.settingsTimeSubtitle,
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              key: const Key('clock_format_selector'),
              segments: [
                ButtonSegment(
                  value: false,
                  label: SegmentLabel(l10n.settingsTime12Hour),
                ),
                ButtonSegment(
                  value: true,
                  label: SegmentLabel(l10n.settingsTime24Hour),
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

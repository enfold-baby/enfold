import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/reminders/care_reminder_providers.dart';

class CareRemindersSection extends ConsumerWidget {
  const CareRemindersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final enabled = ref.watch(careRemindersEnabledProvider).valueOrNull ?? false;
    final actions = ref.read(careReminderActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('care_reminders_toggle'),
          title: Text(
            'Evening check-in',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            'A gentle ping if nothing is logged by evening. Off by default. Never a streak, never guilt.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.mutedText(brightness),
            ),
          ),
          value: enabled,
          onChanged: (value) => actions.setEnabled(value),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/awake_time_providers.dart';

class AwakeTimeSection extends ConsumerWidget {
  const AwakeTimeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final enabled = ref.watch(showAwakeTimeProvider).valueOrNull ?? true;

    return SwitchListTile(
      key: const Key('awake_time_toggle'),
      title: Text(
        'Time awake',
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        'Show how long the baby has been awake since the last logged sleep, on the Today screen.',
        style: GoogleFonts.nunito(
          fontSize: 13,
          color: AppColors.mutedText(brightness),
        ),
      ),
      value: enabled,
      onChanged: (value) =>
          ref.read(awakeTimeActionsProvider).setShowAwakeTime(value),
    );
  }
}

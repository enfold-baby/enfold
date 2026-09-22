import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/awake_time_providers.dart';

class AwakeTimeSection extends ConsumerWidget {
  const AwakeTimeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);
    final enabled = ref.watch(showAwakeTimeProvider).valueOrNull ?? true;

    return SwitchListTile(
      key: const Key('awake_time_toggle'),
      title: Text(
        l10n.settingsAwakeTitle,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        l10n.settingsAwakeSubtitle,
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

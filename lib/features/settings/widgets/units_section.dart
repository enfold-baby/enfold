import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/units_providers.dart';
import '../../../widgets/segment_label.dart';

class UnitsSection extends ConsumerWidget {
  const UnitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(useImperialUnitsProvider);

    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);

    return unitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (useImperial) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              l10n.settingsUnitsTitle,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              l10n.settingsUnitsSubtitle,
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              key: const Key('volume_unit_selector'),
              segments: [
                ButtonSegment(
                  value: false,
                  label: SegmentLabel(l10n.settingsUnitsMetric),
                ),
                ButtonSegment(
                  value: true,
                  label: SegmentLabel(l10n.settingsUnitsUs),
                ),
              ],
              selected: {useImperial},
              onSelectionChanged: (selection) {
                ref.read(unitsActionsProvider).setUseImperial(selection.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}
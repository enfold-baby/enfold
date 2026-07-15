import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/units_providers.dart';

class UnitsSection extends ConsumerWidget {
  const UnitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(useImperialUnitsProvider);

    final brightness = Theme.of(context).brightness;

    return unitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (useImperial) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              'Units',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Bottle amounts in logs and PDF export.',
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              key: const Key('volume_unit_selector'),
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Metric (ml)'),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('US (fl oz)'),
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
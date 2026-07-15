import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class ChipOption<T> {
  const ChipOption({required this.value, required this.label});

  final T value;
  final String label;
}

class ChipPicker<T> extends StatelessWidget {
  const ChipPicker({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.allowEmpty = true,
  });

  final String label;
  final List<ChipOption<T>> options;
  final T? selected;
  final ValueChanged<T?> onSelected;
  final bool allowEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.cream : AppColors.bark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option.label),
                selected: selected == option.value,
                onSelected: (value) {
                  if (!value && allowEmpty) {
                    onSelected(null);
                    return;
                  }
                  onSelected(option.value);
                },
                selectedColor: AppColors.sage.withValues(alpha: 0.22),
                labelStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: selected == option.value
                      ? (isDark ? AppColors.cream : AppColors.sageDeep)
                      : AppColors.barkSoft,
                ),
                side: BorderSide(
                  color: selected == option.value
                      ? AppColors.sage
                      : (isDark
                          ? AppColors.nightLine
                          : AppColors.bark.withValues(alpha: 0.12)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
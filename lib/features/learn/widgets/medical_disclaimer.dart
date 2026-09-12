import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightElevated : AppColors.creamDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 12,
          height: 1.5,
          color: AppColors.mutedText(Theme.of(context).brightness),
        ),
      ),
    );
  }
}
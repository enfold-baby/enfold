import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/log_type.dart';

class QuickLogTile extends StatelessWidget {
  const QuickLogTile({
    super.key,
    required this.type,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  final LogType type;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Log ${type.label}',
      child: Material(
        color: isDark ? AppColors.nightElevated : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isDark ? 0 : 1,
        shadowColor: AppColors.bark.withValues(alpha: 0.12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.nightLine : AppColors.bark.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(type.icon, color: AppColors.cream, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  type.label,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.cream : AppColors.bark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
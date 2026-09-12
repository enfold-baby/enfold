import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class BloomBrandMark extends StatelessWidget {
  const BloomBrandMark({super.key, this.size = 96, this.showBackdrop = true});

  final double size;
  final bool showBackdrop;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final image = Image.asset(
      'assets/brand/app_icon.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
    );

    if (!showBackdrop) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: image,
      );
    }

    return Container(
      width: size + 24,
      height: size + 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? AppColors.nightCard
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular((size + 24) * 0.32),
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.nightLine
              : Colors.white,
        ),
        boxShadow: brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: AppColors.bark.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: image,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/bloom_surface.dart';
import '../models/log_type.dart';

class QuickLogTile extends StatelessWidget {
  const QuickLogTile({
    super.key,
    required this.type,
    required this.color,
    required this.onTap,
    this.onLongPress,
    this.supportingText = 'View log · hold to add',
  });

  final LogType type;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = type.label(AppL10n.of(context));
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return BloomSurface(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: '$label. $supportingText',
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 112),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark
                        ? color.withValues(alpha: 0.2)
                        : _softColor(type),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    type.icon,
                    color: AppColors.readableInk(color, brightness),
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: AppColors.mutedText(brightness),
                ),
              ],
            ),
            const Spacer(),
            Text(label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              supportingText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.mutedText(brightness),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _softColor(LogType type) => switch (type) {
    LogType.feed => AppColors.sageMist,
    LogType.diaper => AppColors.bloomMist,
    LogType.sleep => AppColors.sleepMist,
    LogType.medication => AppColors.amberMist,
    LogType.pumping => AppColors.pumpLavender.withValues(alpha: 0.14),
    LogType.tummyTime => AppColors.tummyCoral.withValues(alpha: 0.14),
  };
}

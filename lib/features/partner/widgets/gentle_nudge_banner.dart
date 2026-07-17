import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/partner_nudge.dart';

class GentleNudgeBanner extends StatelessWidget {
  const GentleNudgeBanner({super.key, required this.nudge, this.onDismiss});

  final PartnerNudge nudge;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      key: const Key('partner_gentle_nudge'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: nudge.type.color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: nudge.type.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(nudge.type.icon, color: nudge.type.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gentle reminder',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: nudge.type.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nudge.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.mutedText(brightness),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              key: const Key('dismiss_partner_nudge'),
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.mutedText(brightness),
            ),
        ],
      ),
    );
  }
}

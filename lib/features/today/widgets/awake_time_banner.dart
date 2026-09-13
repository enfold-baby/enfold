import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/datetime/clock_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../logs/providers/logs_providers.dart';
import '../../logs/widgets/active_sleep_banner.dart';
import '../../settings/providers/awake_time_providers.dart';
import '../../settings/providers/time_format_providers.dart';
import '../models/awake_window.dart';

/// "Awake for 1h 20m" after the last logged sleep. Hidden while asleep, when
/// switched off in Settings, or when no recent sleep is on record.
class AwakeTimeBanner extends ConsumerStatefulWidget {
  const AwakeTimeBanner({super.key});

  @override
  ConsumerState<AwakeTimeBanner> createState() => _AwakeTimeBannerState();
}

class _AwakeTimeBannerState extends ConsumerState<AwakeTimeBanner> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(showAwakeTimeProvider).valueOrNull ?? false;
    final sleeps = ref.watch(recentSleepsProvider).valueOrNull ?? const [];
    final use24Hour = ref.watch(use24HourTimeProvider).valueOrNull ?? false;
    final now = DateTime.now();
    final window = enabled ? AwakeWindow.fromSleeps(sleeps, now: now) : null;
    if (window == null) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final ink = AppColors.readableInk(AppColors.medicationAmber, brightness);
    // Amber on its own tint is about 2:1 in light mode, so text uses bark
    // and the icon a deeper amber there.
    final titleInk = isDark ? ink : AppColors.bark;
    final iconInk = isDark
        ? ink
        : Color.lerp(AppColors.medicationAmber, AppColors.bark, 0.45)!;
    final elapsed = formatSleepElapsed(window.wokeAt, now);
    final title = elapsed == 'just now' ? 'Just woke up' : 'Awake for $elapsed';
    final since = ClockFormat.formatTime(window.wokeAt, use24Hour: use24Hour);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        key: const Key('awake_time_banner'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ink.withValues(
            alpha: isDark ? 0.16 : 0.12,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.wb_sunny_outlined, color: iconInk),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      color: titleInk,
                    ),
                  ),
                  Text(
                    'Since $since',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText(brightness),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

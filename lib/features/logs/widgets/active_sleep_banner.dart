import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/datetime/clock_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/providers/time_format_providers.dart';
import '../../today/models/care_log_entry.dart';

class ActiveSleepBanner extends ConsumerWidget {
  const ActiveSleepBanner({
    super.key,
    required this.entry,
    required this.onWakeUp,
    this.onAdjustStart,
  });

  final CareLogEntry entry;
  final VoidCallback onWakeUp;
  final VoidCallback? onAdjustStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final ink = AppColors.readableInk(AppColors.sleepBlue, brightness);
    final start = entry.details.sleepStart ?? entry.loggedAt;
    final use24Hour = ref.watch(use24HourTimeProvider).valueOrNull ?? false;
    final started = ClockFormat.formatTime(start, use24Hour: use24Hour);
    final elapsed = formatSleepElapsed(start, DateTime.now());

    return Material(
      key: const Key('active_sleep_banner'),
      color: ink.withValues(alpha: brightness == Brightness.dark ? 0.16 : 0.14),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onAdjustStart,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ink.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.bedtime, color: ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleeping now',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                    Text(
                      'Since $started · $elapsed',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                key: const Key('wake_up_button'),
                onPressed: onWakeUp,
                style: FilledButton.styleFrom(
                  backgroundColor: ink,
                  foregroundColor: AppColors.cream,
                ),
                child: const Text('Wake up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatSleepElapsed(DateTime start, DateTime now) {
  final minutes = now.difference(start).inMinutes;
  if (minutes < 1) return 'just now';
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (remainder == 0) return '${hours}h';
  return '${hours}h ${remainder}m';
}

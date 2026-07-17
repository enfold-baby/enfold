import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/units/volume_units.dart';
import '../../tummy_time/providers/tummy_time_providers.dart';
import '../models/care_log_entry.dart';

class ActivityEntryCard extends StatelessWidget {
  const ActivityEntryCard({
    super.key,
    required this.tummyLogs,
    required this.pumpingLogs,
    required this.useImperial,
    required this.onTapTummy,
    required this.onTapPumping,
    required this.onAddTummy,
    required this.onAddPumping,
  });

  final List<CareLogEntry> tummyLogs;
  final List<CareLogEntry> pumpingLogs;
  final bool useImperial;
  final VoidCallback onTapTummy;
  final VoidCallback onTapPumping;
  final VoidCallback onAddTummy;
  final VoidCallback onAddPumping;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final tummyMinutes = tummyMinutesToday(tummyLogs);
    final pumpedMl = _pumpedMlToday(pumpingLogs);

    String subtitle;
    final parts = <String>[];
    if (tummyLogs.isEmpty && pumpingLogs.isEmpty) {
      subtitle = 'Track tummy sessions and pumping output';
    } else {
      if (tummyLogs.isNotEmpty) {
        parts.add(
          tummyLogs.length == 1
              ? '${formatTummyMinutes(tummyMinutes)} tummy'
              : '${tummyLogs.length} tummy · ${formatTummyMinutes(tummyMinutes)}',
        );
      }
      if (pumpingLogs.isNotEmpty) {
        parts.add(_pumpedSummary(pumpedMl));
      }
      subtitle = 'Today: ${parts.join(' · ')}';
    }

    return Material(
      color: isDark ? AppColors.nightElevated : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: const Key('today_activity_card'),
        onTap: onTapTummy,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.nightLine
                  : AppColors.bark.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.tummyCoral,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.child_care_outlined,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tummy & pumping',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 13,
                                color: AppColors.mutedText(brightness),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('add_tummy_quick'),
                      onPressed: onAddTummy,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tummy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.tummyCoral,
                        side: const BorderSide(color: AppColors.tummyCoral),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('add_pumping_quick'),
                      onPressed: onAddPumping,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Pump'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.pumpLavender,
                        side: const BorderSide(color: AppColors.pumpLavender),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    key: const Key('open_tummy_logs'),
                    onPressed: onTapTummy,
                    child: const Text('Tummy logs'),
                  ),
                  TextButton(
                    key: const Key('open_pumping_logs'),
                    onPressed: onTapPumping,
                    child: const Text('Pump logs'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _pumpedMlToday(List<CareLogEntry> logs) {
    var total = 0;
    for (final entry in logs) {
      total += entry.details.bottleMl ?? 0;
    }
    return total;
  }

  String _pumpedSummary(int ml) {
    if (ml <= 0) {
      return pumpingLogs.length == 1 ? '1 pump' : '${pumpingLogs.length} pumps';
    }
    return '${VolumeUnits.formatBottleMl(ml, useImperial: useImperial)} pumped';
  }
}

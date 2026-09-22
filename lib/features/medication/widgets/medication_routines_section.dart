import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/datetime/clock_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/database/app_database.dart';
import '../../settings/providers/time_format_providers.dart';
import '../providers/medication_routine_providers.dart';
import '../../../l10n/generated/app_localizations.dart';

class MedicationRoutinesSection extends ConsumerWidget {
  const MedicationRoutinesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(medicationRoutinesProvider);
    final use24Hour = ref.watch(use24HourTimeProvider).valueOrNull ?? false;
    final brightness = Theme.of(context).brightness;
    final routines = routinesAsync.valueOrNull ?? const <MedicationRoutine>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppL10n.of(context).medicationRoutinesTitle,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: AppColors.accent(brightness),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppL10n.of(context).medicationRoutinesSubtitle,
          style: GoogleFonts.nunito(
            fontSize: 14,
            height: 1.4,
            color: AppColors.mutedText(brightness),
          ),
        ),
        const SizedBox(height: 12),
        if (routines.isEmpty)
          Text(
            AppL10n.of(context).medicationRoutinesEmpty,
            style: GoogleFonts.nunito(
              color: AppColors.mutedText(brightness),
            ),
          )
        else
          for (final routine in routines)
            _RoutineTile(
              routine: routine,
              use24Hour: use24Hour,
            ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({
    required this.routine,
    required this.use24Hour,
  });

  final MedicationRoutine routine;
  final bool use24Hour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final sample = DateTime(2026, 1, 1, routine.hour, routine.minute);
    final timeLabel = ClockFormat.formatTime(sample, use24Hour: use24Hour);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('medication_routine_${routine.id}'),
        contentPadding: EdgeInsets.zero,
        title: Text(
          routine.name,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          AppL10n.of(context).medicationRoutineAround(timeLabel),
          style: GoogleFonts.nunito(
            color: AppColors.mutedText(brightness),
          ),
        ),
        onTap: () => _pickTime(context, ref),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              key: Key('medication_routine_enabled_${routine.id}'),
              value: routine.enabled,
              onChanged: (value) => ref
                  .read(medicationRoutineActionsProvider)
                  .setEnabled(routine.id, value),
            ),
            IconButton(
              key: Key('medication_routine_delete_${routine.id}'),
              tooltip: AppL10n.of(context).medicationRoutineRemove,
              onPressed: () => ref
                  .read(medicationRoutineActionsProvider)
                  .deleteRoutine(routine.id),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: routine.hour, minute: routine.minute),
    );
    if (picked == null) return;
    await ref.read(medicationRoutineActionsProvider).setTime(
          routine.id,
          hour: picked.hour,
          minute: picked.minute,
        );
  }
}

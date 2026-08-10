import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../services/database/app_database.dart';
import '../../widgets/sync_refresh.dart';
import 'expecting_date_bounds.dart';
import 'pregnancy_week_calculator.dart';
import 'providers/pregnancy_providers.dart';

class PregnancyScreen extends ConsumerWidget {
  const PregnancyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(pregnancyProfileProvider);
    final appointmentsAsync = ref.watch(pregnancyAppointmentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pregnancy')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Could not load pregnancy profile.',
            style: GoogleFonts.nunito(color: AppColors.barkSoft),
          ),
        ),
        data: (profile) {
          final appointments = appointmentsAsync.valueOrNull ?? [];
          final now = DateTime.now();
          final week = profile.dueDate != null
              ? pregnancyWeekFromDueDate(profile.dueDate!, now)
              : null;
          final daysLeft = profile.dueDate != null
              ? daysUntilDue(profile.dueDate!, now)
              : null;
          final kickCount = _kickCountForToday(profile, now);

          return SyncRefresh(
            indicatorKey: const Key('pregnancy_pull_to_refresh'),
            child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                'Bump to baby',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.barkSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track the journey',
                style: GoogleFonts.fraunces(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.cream : AppColors.bark,
                ),
              ),
              const SizedBox(height: 24),
              _DueDateCard(
                dueDate: profile.dueDate,
                week: week,
                daysLeft: daysLeft,
                onPickDate: () => _pickDueDate(context, ref, profile.dueDate),
                onClear: profile.dueDate == null
                    ? null
                    : () => ref.read(pregnancyActionsProvider).setDueDate(null),
              ),
              const SizedBox(height: 16),
              _KickCounterCard(
                count: kickCount,
                onKick: () async {
                  final count =
                      await ref.read(pregnancyActionsProvider).incrementKick();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('Kick $count logged today'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                },
                onReset: () =>
                    ref.read(pregnancyActionsProvider).resetKicks(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Appointments',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.sage,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    key: const Key('add_appointment'),
                    onPressed: () => _addAppointment(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add note'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (appointments.isEmpty)
                Container(
                  key: const Key('empty_appointments'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.nightElevated : AppColors.creamDeep,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.nightLine
                          : AppColors.bark.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    'Save questions for your next prenatal visit.',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: AppColors.barkSoft,
                    ),
                  ),
                )
              else
                ...appointments.map(
                  (appointment) => _AppointmentTile(
                    appointment: appointment,
                    onDelete: () => ref
                        .read(pregnancyActionsProvider)
                        .deleteAppointment(appointment.id),
                  ),
                ),
            ],
          ),
          );
        },
      ),
    );
  }

  int _kickCountForToday(PregnancyProfile profile, DateTime now) {
    final kickDate = profile.kickCountDate;
    if (kickDate == null) return 0;
    final today = DateTime(now.year, now.month, now.day);
    final stored = DateTime(kickDate.year, kickDate.month, kickDate.day);
    return stored == today ? profile.kickCountToday : 0;
  }

  Future<void> _pickDueDate(
    BuildContext context,
    WidgetRef ref,
    DateTime? current,
  ) async {
    final today = calendarToday();
    // While expecting: do not allow past due dates. Keep a sensible far bound.
    final last = today.add(const Duration(days: 320));
    var initial = clampOnOrAfterToday(
      current ?? today.add(const Duration(days: 120)),
    );
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: last,
      helpText: 'Select due date',
    );
    if (picked == null) return;
    await ref.read(pregnancyActionsProvider).setDueDate(picked);
  }

  Future<void> _addAppointment(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? scheduledAt;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('appointment_title'),
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('appointment_notes'),
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('appointment_pick_date'),
              onPressed: () async {
                final today = calendarToday();
                // Appointments while expecting: today or future only.
                final picked = await showDatePicker(
                  context: context,
                  initialDate: today,
                  firstDate: today,
                  lastDate: today.add(const Duration(days: 365)),
                );
                if (picked != null) scheduledAt = picked;
              },
              child: const Text('Pick date (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('appointment_save'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true || titleController.text.trim().isEmpty) {
      titleController.dispose();
      notesController.dispose();
      return;
    }

    await ref.read(pregnancyActionsProvider).addAppointment(
          title: titleController.text.trim(),
          scheduledAt: scheduledAt,
          notes: notesController.text.trim(),
        );
    titleController.dispose();
    notesController.dispose();
  }
}

class _DueDateCard extends StatelessWidget {
  const _DueDateCard({
    required this.dueDate,
    required this.week,
    required this.daysLeft,
    required this.onPickDate,
    this.onClear,
  });

  final DateTime? dueDate;
  final int? week;
  final int? daysLeft;
  final VoidCallback onPickDate;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat.yMMMMd();

    return Container(
      key: const Key('due_date_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Due date',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(height: 8),
          if (dueDate == null)
            Text(
              'Set your due date to see your current week.',
              style: GoogleFonts.nunito(color: AppColors.barkSoft),
            )
          else ...[
            Text(
              dateFormat.format(dueDate!),
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (week != null)
              Text(
                'Week $week${daysLeft != null && daysLeft! >= 0 ? ' · $daysLeft days to go' : ''}',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.barkSoft,
                ),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                key: const Key('set_due_date'),
                onPressed: onPickDate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bloom,
                  foregroundColor: AppColors.cream,
                ),
                child: Text(dueDate == null ? 'Set due date' : 'Change date'),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  key: const Key('clear_due_date'),
                  onPressed: onClear,
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _KickCounterCard extends StatelessWidget {
  const _KickCounterCard({
    required this.count,
    required this.onKick,
    required this.onReset,
  });

  final int count;
  final VoidCallback onKick;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('kick_counter_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.nightElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kick counter',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap when you feel movement. Count resets each day.',
            style: GoogleFonts.nunito(color: AppColors.barkSoft),
          ),
          const SizedBox(height: 16),
          Text(
            '$count',
            key: const Key('kick_count'),
            style: GoogleFonts.fraunces(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: AppColors.bloom,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                key: const Key('log_kick'),
                onPressed: onKick,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: AppColors.cream,
                ),
                child: const Text('Log kick'),
              ),
              const SizedBox(width: 8),
              if (count > 0)
                TextButton(
                  key: const Key('reset_kicks'),
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({
    required this.appointment,
    required this.onDelete,
  });

  final PregnancyAppointment appointment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat.yMMMd();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('appointment_${appointment.id}'),
        tileColor: isDark ? AppColors.nightElevated : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark
                ? AppColors.nightLine
                : AppColors.bark.withValues(alpha: 0.08),
          ),
        ),
        title: Text(
          appointment.title,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          [
            if (appointment.scheduledAt != null)
              dateFormat.format(appointment.scheduledAt!),
            if (appointment.notes.isNotEmpty) appointment.notes,
          ].join(' · '),
          style: GoogleFonts.nunito(color: AppColors.barkSoft),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
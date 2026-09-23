import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/database/database_provider.dart';
import '../today/models/care_log_details.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'providers/logs_providers.dart';
import 'widgets/time_field.dart';
import '../../widgets/segment_label.dart';

enum _SleepMode { range, now }

class LogSleepScreen extends ConsumerStatefulWidget {
  const LogSleepScreen({super.key, this.logId});

  final String? logId;

  bool get isEditing => logId != null;

  @override
  ConsumerState<LogSleepScreen> createState() => _LogSleepScreenState();
}

class _LogSleepScreenState extends ConsumerState<LogSleepScreen> {
  _SleepMode _mode = _SleepMode.range;
  late DateTime _sleepStart;
  late DateTime _sleepEnd;
  final _noteController = TextEditingController();
  bool _busy = false;
  bool _loading = false;
  bool _stillSleeping = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _sleepStart = now.subtract(const Duration(hours: 1));
    _sleepEnd = now;
    if (widget.logId != null) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEntry());
    }
  }

  Future<void> _loadEntry() async {
    final row =
        await ref.read(databaseProvider).careLogDao.getActiveLog(widget.logId!);
    if (!mounted) return;
    if (row == null) {
      Navigator.of(context).pop();
      return;
    }

    final details = CareLogDetails.fromJsonString(row.detailsJson);
    final inProgress = details.sleepInProgress == true;
    setState(() {
      _loading = false;
      _mode = _SleepMode.range;
      _stillSleeping = inProgress;
      _sleepStart = details.sleepStart ?? row.occurredAt;
      _sleepEnd = inProgress
          ? DateTime.now()
          : (details.sleepEnd ?? row.occurredAt);
      _noteController.text = row.note;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _openEnded =>
      _stillSleeping || (!widget.isEditing && _mode == _SleepMode.now);

  int? get _durationMinutes {
    if (_openEnded) return null;
    if (_sleepEnd.isBefore(_sleepStart)) return null;
    return _sleepEnd.difference(_sleepStart).inMinutes;
  }

  DateTime get _clampedStart {
    final now = DateTime.now();
    return _sleepStart.isAfter(now) ? now : _sleepStart;
  }

  Future<bool> _guardExistingOpenSleep() async {
    final openSleep = ref.read(openSleepProvider).valueOrNull;
    if (openSleep == null) return true;
    if (widget.isEditing && openSleep.id == widget.logId) return true;
    if (!mounted) return false;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppL10n.of(context).sleepAlreadyInProgress)),
    );
    return false;
  }

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    setState(() => _busy = true);
    final note = _noteController.text.trim();
    final actions = ref.read(careLogActionsProvider);
    final start = _clampedStart;

    if (_openEnded) {
      if (!await _guardExistingOpenSleep()) return;
      final details = CareLogDetails(
        sleepStart: start,
        sleepInProgress: true,
      );
      if (widget.isEditing) {
        await actions.updateLogEntry(
          logId: widget.logId!,
          type: LogType.sleep,
          occurredAt: start,
          details: details,
          note: note,
        );
      } else {
        await actions.startSleepAt(start, note: note);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? l10n.sleepUpdated : l10n.sleepStarted,
            ),
          ),
        );
      Navigator.of(context).pop();
      return;
    }

    final duration = _durationMinutes;
    if (duration == null) {
      setState(() => _busy = false);
      return;
    }
    final details = CareLogDetails(
      sleepStart: start,
      sleepEnd: _sleepEnd,
      durationMinutes: duration,
      sleepInProgress: false,
    );

    if (widget.isEditing) {
      await actions.updateLogEntry(
        logId: widget.logId!,
        type: LogType.sleep,
        occurredAt: _sleepEnd,
        details: details,
        note: note,
      );
    } else {
      await actions.saveLog(
        type: LogType.sleep,
        occurredAt: _sleepEnd,
        details: details,
        note: note,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? l10n.sleepUpdated
                : LogType.sleep.confirmation(l10n),
          ),
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _durationMinutes;
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);
    final title =
        widget.isEditing ? l10n.sleepFormTitleEdit : l10n.sleepFormTitleNew;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (!widget.isEditing)
              SegmentedButton<_SleepMode>(
                segments: [
                  ButtonSegment(
                    value: _SleepMode.range,
                    label: SegmentLabel(l10n.sleepModeNap),
                  ),
                  ButtonSegment(
                    value: _SleepMode.now,
                    label: SegmentLabel(l10n.sleepModeNow),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (value) {
                  final next = value.first;
                  setState(() {
                    _mode = next;
                    if (next == _SleepMode.now) {
                      _sleepStart = DateTime.now();
                      _stillSleeping = true;
                    } else {
                      _stillSleeping = false;
                    }
                  });
                },
              ),
            const SizedBox(height: 20),
            Text(
              _openEnded ? l10n.sleepPromptOpenEnded : l10n.sleepPromptRange,
              style: GoogleFonts.nunito(
                color: AppColors.mutedText(brightness),
              ),
            ),
            const SizedBox(height: 16),
            TimeField(
              label: l10n.sleepFellAsleep,
              value: _sleepStart,
              onChanged: (value) => setState(() => _sleepStart = value),
            ),
            if (!_openEnded) ...[
              const SizedBox(height: 12),
              TimeField(
                label: l10n.sleepWokeUp,
                value: _sleepEnd,
                onChanged: (value) => setState(() => _sleepEnd = value),
              ),
            ],
            if (_mode == _SleepMode.range || widget.isEditing) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                key: const Key('sleep_still_sleeping'),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.sleepStillSleeping,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  l10n.sleepStillSleepingSubtitle,
                  style: GoogleFonts.nunito(
                    color: AppColors.mutedText(brightness),
                  ),
                ),
                value: _stillSleeping,
                onChanged: (value) => setState(() => _stillSleeping = value),
              ),
            ],
            if (!_openEnded && duration != null) ...[
              const SizedBox(height: 8),
              Text(
                duration < 60
                    ? l10n.sleepDurationMinutes(duration)
                    : l10n.sleepDurationHoursMinutes(
                        duration ~/ 60,
                        duration % 60,
                      ),
                key: const Key('sleep_duration_preview'),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: AppColors.readableInk(AppColors.sleepBlue, brightness),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              key: const Key('sleep_note'),
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.commonNoteOptional,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: !widget.isEditing && _mode == _SleepMode.now
                  ? const Key('start_sleep_now')
                  : const Key('save_sleep_log'),
              onPressed: _busy || (!_openEnded && duration == null)
                  ? null
                  : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sleepBlue,
                foregroundColor: AppColors.cream,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _busy
                    ? l10n.commonSaving
                    : _openEnded
                        ? l10n.sleepSaveStillSleeping
                        : widget.isEditing
                            ? l10n.commonSaveChanges
                            : l10n.sleepSaveButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

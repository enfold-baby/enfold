import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/database/database_provider.dart';
import '../today/models/care_log_details.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'providers/logs_providers.dart';
import 'widgets/time_field.dart';

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
  bool _inProgress = false;

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
      _inProgress = inProgress;
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

  int? get _durationMinutes {
    if (_sleepEnd.isBefore(_sleepStart)) return null;
    return _sleepEnd.difference(_sleepStart).inMinutes;
  }

  Future<void> _saveRange() async {
    setState(() => _busy = true);
    final duration = _durationMinutes;
    final details = CareLogDetails(
      sleepStart: _sleepStart,
      sleepEnd: _inProgress ? null : _sleepEnd,
      durationMinutes: _inProgress ? null : duration,
      sleepInProgress: _inProgress,
    );
    final note = _noteController.text.trim();
    final actions = ref.read(careLogActionsProvider);

    if (widget.isEditing) {
      await actions.updateLogEntry(
        logId: widget.logId!,
        type: LogType.sleep,
        occurredAt: _inProgress ? _sleepStart : _sleepEnd,
        details: details,
        note: note,
      );
    } else {
      await actions.saveLog(
        type: LogType.sleep,
        occurredAt: _sleepEnd,
        details: CareLogDetails(
          sleepStart: _sleepStart,
          sleepEnd: _sleepEnd,
          durationMinutes: duration,
          sleepInProgress: false,
        ),
        note: note,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Sleep updated' : 'Sleep logged'),
        ),
      );
    Navigator.of(context).pop();
  }

  Future<void> _startNow() async {
    setState(() => _busy = true);
    final openSleep = ref.read(openSleepProvider).valueOrNull;
    if (openSleep != null) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A sleep is already in progress')),
      );
      return;
    }

    await ref.read(careLogActionsProvider).startSleepNow();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Sleep started')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _durationMinutes;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit sleep' : 'Log sleep'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit sleep' : 'Log sleep'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (!widget.isEditing)
              SegmentedButton<_SleepMode>(
                segments: const [
                  ButtonSegment(
                    value: _SleepMode.range,
                    label: Text('Log a nap'),
                  ),
                  ButtonSegment(
                    value: _SleepMode.now,
                    label: Text('Sleeping now'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (value) =>
                    setState(() => _mode = value.first),
              ),
            if (widget.isEditing && _inProgress) ...[
              Text(
                'Still sleeping — update start time or add a note.',
                style: GoogleFonts.nunito(color: AppColors.barkSoft),
              ),
              const SizedBox(height: 16),
            ],
            if (_mode == _SleepMode.range || widget.isEditing) ...[
              if (!widget.isEditing) const SizedBox(height: 20),
              if (!widget.isEditing)
                Text(
                  'From when to when?',
                  style: GoogleFonts.nunito(color: AppColors.barkSoft),
                ),
              if (!widget.isEditing) const SizedBox(height: 16),
              TimeField(
                label: 'Fell asleep',
                value: _sleepStart,
                onChanged: (value) => setState(() => _sleepStart = value),
              ),
              if (!_inProgress) ...[
                const SizedBox(height: 12),
                TimeField(
                  label: 'Woke up',
                  value: _sleepEnd,
                  onChanged: (value) => setState(() => _sleepEnd = value),
                ),
              ],
              if (!_inProgress && duration != null) ...[
                const SizedBox(height: 16),
                Text(
                  duration < 60
                      ? 'Duration: ${duration}min'
                      : 'Duration: ${duration ~/ 60}h ${duration % 60}m',
                  key: const Key('sleep_duration_preview'),
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: AppColors.sleepBlue,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                key: const Key('sleep_note'),
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('save_sleep_log'),
                onPressed: _busy || (!_inProgress && duration == null)
                    ? null
                    : _saveRange,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sleepBlue,
                  foregroundColor: AppColors.cream,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  _busy
                      ? 'Saving…'
                      : widget.isEditing
                          ? 'Save changes'
                          : 'Save sleep',
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Text(
                'Tap below when baby drifts off. Come back and tap Wake up on the Logs screen when they are up.',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.barkSoft,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('start_sleep_now'),
                onPressed: _busy ? null : _startNow,
                icon: const Icon(Icons.bedtime_outlined),
                label: Text(_busy ? 'Starting…' : 'Started sleeping now'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sleepBlue,
                  foregroundColor: AppColors.cream,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
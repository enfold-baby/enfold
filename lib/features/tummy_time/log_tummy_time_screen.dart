import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/database/database_provider.dart';
import '../logs/widgets/time_field.dart';
import '../today/models/care_log_details.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';

class LogTummyTimeScreen extends ConsumerStatefulWidget {
  const LogTummyTimeScreen({super.key, this.logId});

  final String? logId;

  bool get isEditing => logId != null;

  @override
  ConsumerState<LogTummyTimeScreen> createState() => _LogTummyTimeScreenState();
}

class _LogTummyTimeScreenState extends ConsumerState<LogTummyTimeScreen> {
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _occurredAt;
  bool _busy = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _occurredAt = DateTime.now();
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
    setState(() {
      _loading = false;
      _occurredAt = row.occurredAt;
      _noteController.text = row.note;
      if (details.durationMinutes != null) {
        _durationController.text = '${details.durationMinutes}';
      }
    });
  }

  @override
  void dispose() {
    _durationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _applyPreset(int minutes) {
    setState(() => _durationController.text = '$minutes');
  }

  Future<void> _save() async {
    final duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Enter how many minutes')),
        );
      return;
    }

    setState(() => _busy = true);

    final details = CareLogDetails(
      activity: CareLogDetails.tummyTimeActivity,
      durationMinutes: duration,
    );
    final note = _noteController.text.trim();
    final actions = ref.read(careLogActionsProvider);

    if (widget.isEditing) {
      await actions.updateLogEntry(
        logId: widget.logId!,
        type: LogType.tummyTime,
        occurredAt: _occurredAt,
        details: details,
        note: note,
      );
    } else {
      await actions.saveLog(
        type: LogType.tummyTime,
        occurredAt: _occurredAt,
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
            widget.isEditing ? 'Tummy time updated' : 'Tummy time logged',
          ),
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit tummy time' : 'Log tummy time'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit tummy time' : 'Log tummy time'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'How long on tummy?',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.barkSoft,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quick picks',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final minutes in [3, 5, 10, 15])
                  ChoiceChip(
                    key: Key('tummy_preset_$minutes'),
                    label: Text('$minutes min'),
                    selected: _durationController.text == '$minutes',
                    onSelected: (_) => _applyPreset(minutes),
                    selectedColor: AppColors.tummyCoral,
                    labelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: _durationController.text == '$minutes'
                          ? AppColors.cream
                          : AppColors.bark,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('tummy_duration'),
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                hintText: 'e.g. 5',
              ),
            ),
            const SizedBox(height: 16),
            TimeField(
              label: 'Time',
              value: _occurredAt,
              onChanged: (value) => setState(() => _occurredAt = value),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('tummy_note'),
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save_tummy_log'),
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.tummyCoral,
                foregroundColor: AppColors.cream,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _busy
                    ? 'Saving…'
                    : widget.isEditing
                        ? 'Save changes'
                        : 'Save tummy time',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/database/database_provider.dart';
import '../today/models/care_log_details.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'widgets/chip_picker.dart';
import 'widgets/time_field.dart';

class LogDiaperScreen extends ConsumerStatefulWidget {
  const LogDiaperScreen({super.key, this.logId});

  final String? logId;

  bool get isEditing => logId != null;

  @override
  ConsumerState<LogDiaperScreen> createState() => _LogDiaperScreenState();
}

class _LogDiaperScreenState extends ConsumerState<LogDiaperScreen> {
  var _wet = false;
  var _dirty = false;
  String? _stoolConsistency;
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
      _wet = details.wet ?? false;
      _dirty = details.dirty ?? false;
      _stoolConsistency = details.stoolConsistency;
      _occurredAt = row.occurredAt;
      _noteController.text = row.note;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);

    final details = CareLogDetails(
      wet: _wet ? true : null,
      dirty: _dirty ? true : null,
      stoolConsistency: _dirty ? _stoolConsistency : null,
    );
    final note = _noteController.text.trim();
    final actions = ref.read(careLogActionsProvider);

    if (widget.isEditing) {
      await actions.updateLogEntry(
        logId: widget.logId!,
        type: LogType.diaper,
        occurredAt: _occurredAt,
        details: details,
        note: note,
      );
    } else {
      await actions.saveLog(
        type: LogType.diaper,
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
          content: Text(widget.isEditing ? 'Diaper updated' : 'Diaper logged'),
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit diaper' : 'Log diaper'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit diaper' : 'Log diaper'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'What happened?',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              key: const Key('diaper_wet_toggle'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Peed (wet)'),
              value: _wet,
              onChanged: (value) => setState(() => _wet = value),
            ),
            SwitchListTile(
              key: const Key('diaper_dirty_toggle'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Pooped'),
              value: _dirty,
              onChanged: (value) => setState(() {
                _dirty = value;
                if (!value) _stoolConsistency = null;
              }),
            ),
            if (_dirty) ...[
              const SizedBox(height: 12),
              ChipPicker<String>(
                key: const Key('stool_consistency_picker'),
                label: 'Poop consistency',
                options: const [
                  ChipOption(value: 'normal', label: 'Normal'),
                  ChipOption(value: 'soft', label: 'Soft'),
                  ChipOption(value: 'hard', label: 'Hard'),
                  ChipOption(value: 'loose', label: 'Loose'),
                ],
                selected: _stoolConsistency,
                onSelected: (value) => setState(() => _stoolConsistency = value),
              ),
            ],
            const SizedBox(height: 16),
            TimeField(
              label: 'Time',
              value: _occurredAt,
              onChanged: (value) => setState(() => _occurredAt = value),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('diaper_note'),
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save_diaper_log'),
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bloom,
                foregroundColor: AppColors.cream,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _busy
                    ? 'Saving…'
                    : widget.isEditing
                        ? 'Save changes'
                        : 'Save diaper',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
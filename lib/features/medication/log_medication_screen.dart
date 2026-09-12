import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/database/database_provider.dart';
import '../logs/widgets/chip_picker.dart';
import '../logs/widgets/time_field.dart';
import '../today/models/care_log_details.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'data/medication_presets.dart';
import 'providers/medication_routine_providers.dart';

class LogMedicationScreen extends ConsumerStatefulWidget {
  const LogMedicationScreen({super.key, this.logId});

  final String? logId;

  bool get isEditing => logId != null;

  @override
  ConsumerState<LogMedicationScreen> createState() =>
      _LogMedicationScreenState();
}

class _LogMedicationScreenState extends ConsumerState<LogMedicationScreen> {
  String? _category = 'vitamin';
  String? _selectedPreset;
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _occurredAt;
  bool _busy = false;
  bool _loading = false;
  bool _remindDaily = false;

  @override
  void initState() {
    super.initState();
    _occurredAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateReminder());
    if (widget.logId != null) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEntry());
    }
  }

  Future<void> _hydrateReminder({String? name}) async {
    final query = (name ?? _nameController.text).trim();
    if (query.isEmpty) return;
    final db = ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    final existing = await db.medicationRoutineDao.findByName(
      babyId: babyId,
      name: query,
    );
    if (!mounted) return;
    setState(() {
      _remindDaily = existing != null && existing.enabled;
    });
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
    final name = details.medicationName ?? '';
    MedicationPreset? matchingPreset;
    for (final preset in MedicationPresets.presets) {
      if (preset.name == name) {
        matchingPreset = preset;
        break;
      }
    }

    setState(() {
      _loading = false;
      _category = details.medicationCategory ?? 'vitamin';
      _selectedPreset = matchingPreset?.name;
      _nameController.text = name;
      _doseController.text = details.medicationDose ?? '';
      _occurredAt = row.occurredAt;
      _noteController.text = row.note;
    });
    await _hydrateReminder(name: name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _applyPreset(MedicationPreset preset) {
    setState(() {
      _category = preset.category;
      _selectedPreset = preset.name;
      _nameController.text = preset.name;
      if (preset.suggestedDose != null) {
        _doseController.text = preset.suggestedDose!;
      }
    });
    _hydrateReminder(name: preset.name);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Enter a name for this dose')),
        );
      return;
    }

    setState(() => _busy = true);

    final dose = _doseController.text.trim();
    final details = CareLogDetails(
      medicationCategory: _category,
      medicationName: name,
      medicationDose: dose.isEmpty ? null : dose,
    );
    final note = _noteController.text.trim();
    final actions = ref.read(careLogActionsProvider);

    if (widget.isEditing) {
      await actions.updateLogEntry(
        logId: widget.logId!,
        type: LogType.medication,
        occurredAt: _occurredAt,
        details: details,
        note: note,
      );
    } else {
      await actions.saveLog(
        type: LogType.medication,
        occurredAt: _occurredAt,
        details: details,
        note: note,
      );
    }

    await ref.read(medicationRoutineActionsProvider).saveFromLog(
          name: name,
          dose: dose,
          category: _category ?? 'vitamin',
          hour: _occurredAt.hour,
          minute: _occurredAt.minute,
          remindDaily: _remindDaily,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Dose updated' : 'Dose logged',
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
          title: Text(widget.isEditing ? 'Edit dose' : 'Log dose'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final presets = MedicationPresets.forCategory(_category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit dose' : 'Log dose'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'What did baby take?',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 20),
            ChipPicker<String>(
              key: const Key('medication_category_picker'),
              label: 'Category',
              options: [
                for (final (value, label) in MedicationPresets.categories)
                  ChipOption(value: value, label: label),
              ],
              selected: _category,
              onSelected: (value) => setState(() {
                _category = value;
                _selectedPreset = null;
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Common choices',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.accent(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in presets)
                  ChoiceChip(
                    key: Key('medication_preset_${preset.name}'),
                    label: Text(preset.name),
                    selected: _selectedPreset == preset.name,
                    onSelected: (_) => _applyPreset(preset),
                    selectedColor: AppColors.medicationAmber,
                    labelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: _selectedPreset == preset.name
                          ? AppColors.cream
                          : AppColors.mutedText(Theme.of(context).brightness),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('medication_name'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Vitamin D drops',
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                setState(() => _selectedPreset = null);
                _hydrateReminder();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('medication_dose'),
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dose (optional)',
                hintText: 'e.g. 1 drop, 2.5 ml',
              ),
            ),
            const SizedBox(height: 16),
            TimeField(
              label: 'Time',
              value: _occurredAt,
              onChanged: (value) => setState(() => _occurredAt = value),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('medication_daily_reminder_toggle'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Remind me every day',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                'A gentle ping around this time. Off by default, never a streak.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppColors.mutedText(Theme.of(context).brightness),
                ),
              ),
              value: _remindDaily,
              onChanged: (value) => setState(() => _remindDaily = value),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('medication_note'),
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save_medication_log'),
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.medicationAmber,
                foregroundColor: AppColors.cream,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _busy
                    ? 'Saving…'
                    : widget.isEditing
                        ? 'Save changes'
                        : 'Save dose',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
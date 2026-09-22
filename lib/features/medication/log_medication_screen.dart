import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
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

    final l10n = AppL10n.of(context);
    final details = CareLogDetails.fromJsonString(row.detailsJson);
    final name = details.medicationName ?? '';
    // Matches on the current language only: an older log saved under another
    // language just leaves the chips unselected, the name still shows.
    MedicationPreset? matchingPreset;
    for (final preset in MedicationPresets.presets) {
      if (preset.name(l10n) == name) {
        matchingPreset = preset;
        break;
      }
    }

    setState(() {
      _loading = false;
      _category = details.medicationCategory ?? 'vitamin';
      _selectedPreset = matchingPreset?.id;
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
    final l10n = AppL10n.of(context);
    final name = preset.name(l10n);
    setState(() {
      _category = preset.category;
      _selectedPreset = preset.id;
      _nameController.text = name;
      final dose = preset.suggestedDose(l10n);
      if (dose != null) _doseController.text = dose;
    });
    _hydrateReminder(name: name);
  }

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.medicationNameRequired)),
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
            widget.isEditing
                ? l10n.medicationUpdated
                : l10n.medicationLogged,
          ),
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final title = widget.isEditing
        ? l10n.medicationFormTitleEdit
        : l10n.medicationFormTitleNew;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final presets = MedicationPresets.forCategory(_category);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              l10n.medicationWhatTaken,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 20),
            ChipPicker<String>(
              key: const Key('medication_category_picker'),
              label: l10n.medicationCategoryLabel,
              options: [
                for (final value in MedicationPresets.categoryValues)
                  ChipOption(
                    value: value,
                    label: MedicationPresets.categoryLabel(l10n, value),
                  ),
              ],
              selected: _category,
              onSelected: (value) => setState(() {
                _category = value;
                _selectedPreset = null;
              }),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.medicationCommonChoices,
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
                    key: Key('medication_preset_${preset.id}'),
                    label: Text(preset.name(l10n)),
                    selected: _selectedPreset == preset.id,
                    onSelected: (_) => _applyPreset(preset),
                    selectedColor: AppColors.medicationAmber,
                    labelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: _selectedPreset == preset.id
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
              decoration: InputDecoration(
                labelText: l10n.medicationNameLabel,
                hintText: l10n.medicationNameHint,
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
              decoration: InputDecoration(
                labelText: l10n.medicationDoseLabel,
                hintText: l10n.medicationDoseHint,
              ),
            ),
            const SizedBox(height: 16),
            TimeField(
              label: l10n.commonTimeLabel,
              value: _occurredAt,
              onChanged: (value) => setState(() => _occurredAt = value),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('medication_daily_reminder_toggle'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.medicationRemindDaily,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                l10n.medicationRemindDailySubtitle,
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
              decoration: InputDecoration(
                labelText: l10n.commonNoteOptional,
              ),
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
                    ? l10n.commonSaving
                    : widget.isEditing
                        ? l10n.commonSaveChanges
                        : l10n.medicationSaveButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
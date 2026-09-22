import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/units/volume_units.dart';
import '../../services/database/database_provider.dart';
import '../logs/widgets/chip_picker.dart';
import '../logs/widgets/time_field.dart';
import '../settings/providers/units_providers.dart';
import '../today/models/care_log_details.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';

class LogPumpingScreen extends ConsumerStatefulWidget {
  const LogPumpingScreen({super.key, this.logId});

  final String? logId;

  bool get isEditing => logId != null;

  @override
  ConsumerState<LogPumpingScreen> createState() => _LogPumpingScreenState();
}

class _LogPumpingScreenState extends ConsumerState<LogPumpingScreen> {
  String? _side;
  final _amountController = TextEditingController();
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
    final useImperial = ref.read(useImperialUnitsProvider).valueOrNull ?? false;

    setState(() {
      _loading = false;
      _side = details.breastSide;
      _occurredAt = row.occurredAt;
      _noteController.text = row.note;
      if (details.durationMinutes != null) {
        _durationController.text = '${details.durationMinutes}';
      }
      if (details.bottleMl != null) {
        _amountController.text = useImperial
            ? VolumeUnits.flOzFromMl(details.bottleMl!).toStringAsFixed(1)
            : '${details.bottleMl}';
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _durationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? _parseAmountMl(bool useImperial) {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return null;
    if (useImperial) {
      final oz = double.tryParse(amountText);
      if (oz == null) return null;
      return VolumeUnits.mlFromFlOz(oz);
    }
    return int.tryParse(amountText);
  }

  Future<void> _save() async {
    final useImperial = ref.read(useImperialUnitsProvider).valueOrNull ?? false;
    final amountMl = _parseAmountMl(useImperial);
    if (amountMl == null || amountMl <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).pumpingAmountRequired)),
        );
      return;
    }

    setState(() => _busy = true);
    final duration = int.tryParse(_durationController.text.trim());

    final details = CareLogDetails(
      breastSide: _side,
      bottleMl: amountMl,
      durationMinutes: duration,
    );
    final note = _noteController.text.trim();
    final actions = ref.read(careLogActionsProvider);

    if (widget.isEditing) {
      await actions.updateLogEntry(
        logId: widget.logId!,
        type: LogType.pumping,
        occurredAt: _occurredAt,
        details: details,
        note: note,
      );
    } else {
      await actions.saveLog(
        type: LogType.pumping,
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
            widget.isEditing
                ? AppL10n.of(context).pumpingUpdated
                : LogType.pumping.confirmation(AppL10n.of(context)),
          ),
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final useImperial = ref.watch(useImperialUnitsProvider).valueOrNull ?? false;
    final l10n = AppL10n.of(context);
    final title =
        widget.isEditing ? l10n.pumpingFormTitleEdit : l10n.pumpingFormTitleNew;

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
            Text(
              l10n.pumpingHowMuch,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 20),
            ChipPicker<String>(
              key: const Key('pumping_side_picker'),
              label: l10n.pumpingSideLabel,
              options: [
                ChipOption(value: 'left', label: l10n.feedSideLeft),
                ChipOption(value: 'right', label: l10n.feedSideRight),
                ChipOption(value: 'both', label: l10n.feedSideBoth),
              ],
              selected: _side,
              onSelected: (value) => setState(() => _side = value),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('pumping_amount'),
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText:
                    useImperial ? l10n.feedAmountFlOz : l10n.feedAmountMl,
                hintText: useImperial
                    ? l10n.pumpingAmountHintFlOz
                    : l10n.pumpingAmountHintMl,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('pumping_duration'),
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.pumpingDurationLabel,
                hintText: l10n.feedDurationHint,
              ),
            ),
            const SizedBox(height: 16),
            TimeField(
              label: l10n.commonTimeLabel,
              value: _occurredAt,
              onChanged: (value) => setState(() => _occurredAt = value),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('pumping_note'),
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.commonNoteOptional,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save_pumping_log'),
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pumpLavender,
                foregroundColor: AppColors.cream,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _busy
                    ? l10n.commonSaving
                    : widget.isEditing
                        ? l10n.commonSaveChanges
                        : l10n.pumpingSaveButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
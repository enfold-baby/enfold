import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
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
          const SnackBar(content: Text('Add how much you pumped.')),
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
            widget.isEditing ? 'Pumping updated' : 'Pumping logged',
          ),
        ),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final useImperial = ref.watch(useImperialUnitsProvider).valueOrNull ?? false;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit pumping' : 'Log pumping'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit pumping' : 'Log pumping'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'How much did you pump?',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.mutedText(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 20),
            ChipPicker<String>(
              key: const Key('pumping_side_picker'),
              label: 'Side (optional)',
              options: const [
                ChipOption(value: 'left', label: 'Left'),
                ChipOption(value: 'right', label: 'Right'),
                ChipOption(value: 'both', label: 'Both'),
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
                labelText: useImperial ? 'Amount (fl oz)' : 'Amount (ml)',
                hintText: useImperial ? 'e.g. 3.0' : 'e.g. 90',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('pumping_duration'),
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes, optional)',
                hintText: 'e.g. 15',
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
              key: const Key('pumping_note'),
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
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
                    ? 'Saving…'
                    : widget.isEditing
                        ? 'Save changes'
                        : 'Save pumping',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
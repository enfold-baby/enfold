import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/units/volume_units.dart';
import '../settings/providers/units_providers.dart';
import '../../services/database/database_provider.dart';
import '../today/models/care_log_details.dart';
import '../today/models/log_type.dart';
import '../today/providers/today_log_provider.dart';
import 'widgets/chip_picker.dart';
import 'widgets/time_field.dart';

class LogFeedScreen extends ConsumerStatefulWidget {
  const LogFeedScreen({super.key, this.logId});

  final String? logId;

  bool get isEditing => logId != null;

  @override
  ConsumerState<LogFeedScreen> createState() => _LogFeedScreenState();
}

class _LogFeedScreenState extends ConsumerState<LogFeedScreen> {
  String? _feedMode;
  String? _breastSide;
  String? _breastDelivery;
  final _durationController = TextEditingController();
  final _amountController = TextEditingController();
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
    var feedMode = details.feedMode;
    if (feedMode == 'bottle') feedMode = 'formula';

    setState(() {
      _loading = false;
      _feedMode = feedMode;
      _breastSide = details.breastSide;
      _breastDelivery = details.breastDelivery;
      _occurredAt = row.occurredAt;
      _noteController.text = row.note;
      if (details.feedDurationMinutes != null) {
        _durationController.text = '${details.feedDurationMinutes}';
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
    _durationController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _showAmountField {
    if (_feedMode == 'formula') return true;
    if (_feedMode == 'breast' && _breastDelivery == 'pumped') return true;
    return false;
  }

  int? _parseAmountMl(bool useImperial) {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || !_showAmountField) return null;
    if (useImperial) {
      final oz = double.tryParse(amountText);
      if (oz == null) return null;
      return VolumeUnits.mlFromFlOz(oz);
    }
    return int.tryParse(amountText);
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final useImperial = ref.read(useImperialUnitsProvider).valueOrNull ?? false;
    final duration = int.tryParse(_durationController.text.trim());

    final details = CareLogDetails(
      feedMode: _feedMode,
      breastSide: _feedMode == 'breast' ? _breastSide : null,
      breastDelivery: _feedMode == 'breast' ? _breastDelivery : null,
      bottleMl: _parseAmountMl(useImperial),
      feedDurationMinutes: duration,
    );
    final note = _noteController.text.trim();
    final actions = ref.read(careLogActionsProvider);

    if (widget.isEditing) {
      await actions.updateLogEntry(
        logId: widget.logId!,
        type: LogType.feed,
        occurredAt: _occurredAt,
        details: details,
        note: note,
      );
    } else {
      await actions.saveLog(
        type: LogType.feed,
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
          content: Text(widget.isEditing ? 'Feed updated' : 'Feed logged'),
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
          title: Text(widget.isEditing ? 'Edit feed' : 'Log feed'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit feed' : 'Log feed'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'What kind of feed?',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.barkSoft,
              ),
            ),
            const SizedBox(height: 20),
            ChipPicker<String>(
              key: const Key('feed_mode_picker'),
              label: 'Type',
              options: const [
                ChipOption(value: 'breast', label: 'Breast'),
                ChipOption(value: 'formula', label: 'Formula'),
              ],
              selected: _feedMode,
              onSelected: (value) => setState(() {
                _feedMode = value;
                if (value != 'breast') {
                  _breastSide = null;
                  _breastDelivery = null;
                }
                if (value != 'formula' && _breastDelivery != 'pumped') {
                  _amountController.clear();
                }
              }),
            ),
            if (_feedMode == 'breast') ...[
              const SizedBox(height: 20),
              ChipPicker<String>(
                key: const Key('breast_delivery_picker'),
                label: 'How was breast milk given? (optional)',
                options: const [
                  ChipOption(value: 'direct', label: 'At breast'),
                  ChipOption(value: 'pumped', label: 'Pumped · bottle'),
                ],
                selected: _breastDelivery,
                onSelected: (value) => setState(() {
                  _breastDelivery = value;
                  if (value != 'pumped') _amountController.clear();
                }),
              ),
              const SizedBox(height: 20),
              ChipPicker<String>(
                key: const Key('breast_side_picker'),
                label: 'Side (optional)',
                options: const [
                  ChipOption(value: 'left', label: 'Left'),
                  ChipOption(value: 'right', label: 'Right'),
                  ChipOption(value: 'both', label: 'Both'),
                ],
                selected: _breastSide,
                onSelected: (value) => setState(() => _breastSide = value),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              key: const Key('feed_duration'),
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes, optional)',
                hintText: 'e.g. 15',
              ),
            ),
            if (_showAmountField) ...[
              const SizedBox(height: 16),
              TextField(
                key: const Key('feed_amount'),
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: useImperial
                      ? 'Amount (fl oz, optional)'
                      : 'Amount (ml, optional)',
                ),
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
              key: const Key('feed_note'),
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save_feed_log'),
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sage,
                foregroundColor: AppColors.cream,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _busy
                    ? 'Saving…'
                    : widget.isEditing
                        ? 'Save changes'
                        : 'Save feed',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
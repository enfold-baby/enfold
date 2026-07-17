import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/units/volume_units.dart';
import '../../services/database/database_provider.dart';
import '../../widgets/bloom_section_header.dart';
import '../../widgets/bloom_surface.dart';
import '../settings/providers/units_providers.dart';
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
    final row = await ref
        .read(databaseProvider)
        .careLogDao
        .getActiveLog(widget.logId!);
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
    final useImperial =
        ref.watch(useImperialUnitsProvider).valueOrNull ?? false;
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit feed' : 'Log feed'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit feed' : 'Log feed')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _FeedFormHero(isEditing: widget.isEditing),
            const SizedBox(height: 26),
            const BloomSectionHeader(
              title: 'Feed type',
              subtitle: 'Choose what fits this moment.',
            ),
            const SizedBox(height: 12),
            BloomSurface(
              child: ChipPicker<String>(
                key: const Key('feed_mode_picker'),
                label: 'What kind of feed?',
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
            ),
            if (_feedMode == 'breast') ...[
              const SizedBox(height: 14),
              BloomSurface(
                color: AppColors.softSurface(brightness),
                child: Column(
                  children: [
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
                    const SizedBox(height: 22),
                    ChipPicker<String>(
                      key: const Key('breast_side_picker'),
                      label: 'Side (optional)',
                      options: const [
                        ChipOption(value: 'left', label: 'Left'),
                        ChipOption(value: 'right', label: 'Right'),
                        ChipOption(value: 'both', label: 'Both'),
                      ],
                      selected: _breastSide,
                      onSelected: (value) =>
                          setState(() => _breastSide = value),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            const BloomSectionHeader(
              title: 'Details',
              subtitle: 'Optional is genuinely optional.',
            ),
            const SizedBox(height: 12),
            BloomSurface(
              child: Column(
                children: [
                  TextField(
                    key: const Key('feed_duration'),
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      hintText: 'e.g. 15',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                  ),
                  if (_showAmountField) ...[
                    const SizedBox(height: 14),
                    TextField(
                      key: const Key('feed_amount'),
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: useImperial
                            ? 'Amount (fl oz)'
                            : 'Amount (ml)',
                        prefixIcon: const Icon(Icons.water_drop_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TimeField(
                    label: 'Time',
                    value: _occurredAt,
                    onChanged: (value) => setState(() => _occurredAt = value),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('feed_note'),
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      hintText: 'Anything worth remembering?',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: FilledButton.icon(
          key: const Key('save_feed_log'),
          onPressed: _busy ? null : _save,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            _busy
                ? 'Saving…'
                : widget.isEditing
                ? 'Save changes'
                : 'Save feed',
          ),
        ),
      ),
    );
  }
}

class _FeedFormHero extends StatelessWidget {
  const _FeedFormHero({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return BloomSurface(
      color: brightness == Brightness.dark
          ? AppColors.nightCard
          : AppColors.sageMist,
      borderColor: AppColors.sage.withValues(alpha: 0.22),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.sage,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              color: AppColors.cream,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update this feed' : 'A feed, simply logged',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Add only the details you remember. The time is already set.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

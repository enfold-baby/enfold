import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final l10n = AppL10n.of(context);
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
          content: Text(
            widget.isEditing
                ? l10n.feedUpdated
                : LogType.feed.confirmation(l10n),
          ),
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
    final l10n = AppL10n.of(context);
    final title =
        widget.isEditing ? l10n.feedFormTitleEdit : l10n.feedFormTitleNew;

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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _FeedFormHero(isEditing: widget.isEditing),
            const SizedBox(height: 26),
            BloomSectionHeader(
              title: l10n.feedTypeSectionTitle,
              subtitle: l10n.feedTypeSectionSubtitle,
            ),
            const SizedBox(height: 12),
            BloomSurface(
              child: ChipPicker<String>(
                key: const Key('feed_mode_picker'),
                label: l10n.feedModeLabel,
                options: [
                  ChipOption(value: 'breast', label: l10n.feedModeBreast),
                  ChipOption(value: 'formula', label: l10n.feedModeFormula),
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
                      label: l10n.feedDeliveryLabel,
                      options: [
                        ChipOption(
                          value: 'direct',
                          label: l10n.feedDeliveryDirect,
                        ),
                        ChipOption(
                          value: 'pumped',
                          label: l10n.feedDeliveryPumped,
                        ),
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
                      label: l10n.feedSideLabel,
                      options: [
                        ChipOption(value: 'left', label: l10n.feedSideLeft),
                        ChipOption(value: 'right', label: l10n.feedSideRight),
                        ChipOption(value: 'both', label: l10n.feedSideBoth),
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
            BloomSectionHeader(
              title: l10n.formDetailsTitle,
              subtitle: l10n.formDetailsSubtitle,
            ),
            const SizedBox(height: 12),
            BloomSurface(
              child: Column(
                children: [
                  TextField(
                    key: const Key('feed_duration'),
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.feedDurationLabel,
                      hintText: l10n.feedDurationHint,
                      prefixIcon: const Icon(Icons.timer_outlined),
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
                            ? l10n.feedAmountFlOz
                            : l10n.feedAmountMl,
                        prefixIcon: const Icon(Icons.water_drop_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TimeField(
                    label: l10n.commonTimeLabel,
                    value: _occurredAt,
                    onChanged: (value) => setState(() => _occurredAt = value),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const Key('feed_note'),
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: l10n.commonNoteLabel,
                      hintText: l10n.commonNoteHint,
                      prefixIcon: const Icon(Icons.notes_outlined),
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
                ? l10n.commonSaving
                : widget.isEditing
                ? l10n.commonSaveChanges
                : l10n.feedSaveButton,
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
                  isEditing
                      ? AppL10n.of(context).feedFormHeroEdit
                      : AppL10n.of(context).feedFormHeroNew,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  AppL10n.of(context).feedFormHeroSubtitle,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/units/growth_units.dart';
import '../logs/widgets/time_field.dart';
import '../settings/providers/units_providers.dart';
import 'providers/growth_providers.dart';

class AddGrowthMeasurementScreen extends ConsumerStatefulWidget {
  const AddGrowthMeasurementScreen({super.key});

  @override
  ConsumerState<AddGrowthMeasurementScreen> createState() =>
      _AddGrowthMeasurementScreenState();
}

class _AddGrowthMeasurementScreenState
    extends ConsumerState<AddGrowthMeasurementScreen> {
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _headController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _measuredAt;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _measuredAt = DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _headController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final useImperial = ref.read(useImperialUnitsProvider).valueOrNull ?? false;
    final weightKg = GrowthUnits.parseWeightKg(
      _weightController.text,
      useImperial: useImperial,
    );
    final lengthCm = GrowthUnits.parseLengthCm(
      _lengthController.text,
      useImperial: useImperial,
    );
    final headCm = GrowthUnits.parseLengthCm(
      _headController.text,
      useImperial: useImperial,
    );

    if (weightKg == null && lengthCm == null && headCm == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppL10n.of(context).growthAddAtLeastOne),
          ),
        );
      return;
    }

    setState(() => _busy = true);
    await ref.read(growthActionsProvider).saveMeasurement(
          measuredAt: _measuredAt,
          weightKg: weightKg,
          lengthCm: lengthCm,
          headCm: headCm,
          note: _noteController.text.trim(),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).growthSaved)),
      );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final useImperial = ref.watch(useImperialUnitsProvider).valueOrNull ?? false;
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.growthAddTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            TextField(
              key: const Key('growth_weight'),
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: GrowthUnits.weightFieldLabel(
                  l10n,
                  useImperial: useImperial,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('growth_length'),
              controller: _lengthController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: GrowthUnits.lengthFieldLabel(
                  l10n,
                  useImperial: useImperial,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('growth_head'),
              controller: _headController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: GrowthUnits.headFieldLabel(
                  l10n,
                  useImperial: useImperial,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TimeField(
              label: l10n.growthDateTimeLabel,
              value: _measuredAt,
              onChanged: (value) => setState(() => _measuredAt = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.commonNoteOptional,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save_growth_measurement'),
              onPressed: _busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sage,
                foregroundColor: AppColors.cream,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _busy ? l10n.commonSaving : l10n.growthSaveButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
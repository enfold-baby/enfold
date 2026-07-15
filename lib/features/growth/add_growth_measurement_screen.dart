import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
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
          const SnackBar(
            content: Text('Add at least one measurement.'),
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
      ..showSnackBar(const SnackBar(content: Text('Measurement saved')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final useImperial = ref.watch(useImperialUnitsProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Add measurement')),
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
                labelText: GrowthUnits.headFieldLabel(useImperial: useImperial),
              ),
            ),
            const SizedBox(height: 16),
            TimeField(
              label: 'Date & time',
              value: _measuredAt,
              onChanged: (value) => setState(() => _measuredAt = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
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
              child: Text(_busy ? 'Saving…' : 'Save measurement'),
            ),
          ],
        ),
      ),
    );
  }
}
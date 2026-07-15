import 'package:bloomdue_baby/features/today/models/care_log_details.dart';
import 'package:bloomdue_baby/features/today/models/log_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CareLogDetails', () {
    test('round-trips breast feed with pumped delivery', () {
      const details = CareLogDetails(
        feedMode: 'breast',
        breastDelivery: 'pumped',
        breastSide: 'left',
        bottleMl: 90,
        feedDurationMinutes: 12,
      );
      final restored = CareLogDetails.fromJsonString(details.toJsonString());
      expect(restored.breastDelivery, 'pumped');
      expect(
        restored.summarize(LogType.feed),
        'breast · pumped · bottle · left · 90ml · 12min',
      );
    });

    test('summarizes diaper wet and poop with consistency', () {
      const details = CareLogDetails(
        wet: true,
        dirty: true,
        stoolConsistency: 'soft',
      );
      expect(details.summarize(LogType.diaper), 'wet · poop · soft');
    });

    test('summarizes sleep duration and in-progress state', () {
      const details = CareLogDetails(durationMinutes: 45);
      expect(details.summarize(LogType.sleep), '45min');

      const active = CareLogDetails(sleepInProgress: true);
      expect(active.summarize(LogType.sleep), 'sleeping now');
    });

    test('summarizes medication with category, name, and dose', () {
      const details = CareLogDetails(
        medicationCategory: 'vitamin',
        medicationName: 'Vitamin D drops',
        medicationDose: '1 drop',
      );
      expect(
        details.summarize(LogType.medication),
        'vitamin · Vitamin D drops · 1 drop',
      );

      final restored = CareLogDetails.fromJsonString(details.toJsonString());
      expect(restored.medicationName, 'Vitamin D drops');
      expect(restored.medicationDose, '1 drop');
    });

    test('summarizes pumping with side, amount, and duration', () {
      const details = CareLogDetails(
        breastSide: 'left',
        bottleMl: 90,
        durationMinutes: 12,
      );
      expect(
        details.summarize(LogType.pumping),
        'left · 90ml · 12min',
      );
    });

    test('summarizes tummy time duration', () {
      const details = CareLogDetails(
        activity: CareLogDetails.tummyTimeActivity,
        durationMinutes: 5,
      );
      expect(details.summarize(LogType.tummyTime), '5min');

      final restored = CareLogDetails.fromJsonString(details.toJsonString());
      expect(restored.activity, CareLogDetails.tummyTimeActivity);
    });

    test('summarizes bottle volume in imperial units', () {
      const details = CareLogDetails(
        feedMode: 'formula',
        bottleMl: 118,
      );
      expect(
        details.summarize(LogType.feed, useImperial: true),
        'formula · 4 fl oz',
      );
    });
  });
}
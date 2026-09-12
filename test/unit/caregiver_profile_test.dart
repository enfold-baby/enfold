import 'package:enfold/features/settings/widgets/caregiver_profile_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('composeCaregiverDisplayName', () {
    test('role only', () {
      expect(composeCaregiverDisplayName(role: 'Mom'), 'Mom');
    });

    test('role and name', () {
      expect(
        composeCaregiverDisplayName(role: 'Dad', name: 'Raul'),
        'Dad · Raul',
      );
    });

    test('Other uses name only', () {
      expect(
        composeCaregiverDisplayName(role: 'Other', name: 'Auntie'),
        'Auntie',
      );
    });
  });

  group('parseCaregiverDisplayName', () {
    test('round-trips role and name', () {
      final parsed = parseCaregiverDisplayName('Mom · Ana');
      expect(parsed.role, 'Mom');
      expect(parsed.name, 'Ana');
    });

    test('role only', () {
      final parsed = parseCaregiverDisplayName('Dad');
      expect(parsed.role, 'Dad');
      expect(parsed.name, '');
    });
  });
}

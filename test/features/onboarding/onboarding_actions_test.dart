import 'package:enfold/features/onboarding/providers/onboarding_providers.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  test('saveBabyProfile writes the typed name to the default baby', () async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    addTearDown(db.close);

    await container
        .read(onboardingActionsProvider)
        .saveBabyProfile(name: 'Mia', birthDate: null);

    final babyId = await db.careLogDao.ensureDefaultBaby();
    final baby = await db.careLogDao.watchBaby(babyId).first;
    expect(baby.name, 'Mia');
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';

final useImperialUnitsProvider = FutureProvider<bool>((ref) async {
  final db = ref.read(databaseProvider);
  return db.settingsDao.useImperialUnits();
});

final unitsActionsProvider = Provider<UnitsActions>((ref) {
  return UnitsActions(ref);
});

class UnitsActions {
  UnitsActions(this._ref);

  final Ref _ref;

  Future<void> setUseImperial(bool value) async {
    await _ref.read(databaseProvider).settingsDao.setUseImperialUnits(value);
    _ref.invalidate(useImperialUnitsProvider);
  }
}
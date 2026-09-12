import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';

final use24HourTimeProvider = FutureProvider<bool>((ref) async {
  final db = ref.read(databaseProvider);
  return db.settingsDao.use24HourTime();
});

final timeFormatActionsProvider = Provider<TimeFormatActions>((ref) {
  return TimeFormatActions(ref);
});

class TimeFormatActions {
  TimeFormatActions(this._ref);

  final Ref _ref;

  Future<void> setUse24Hour(bool value) async {
    await _ref.read(databaseProvider).settingsDao.setUse24HourTime(value);
    _ref.invalidate(use24HourTimeProvider);
  }
}

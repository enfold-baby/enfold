import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';

final showAwakeTimeProvider = StreamProvider<bool>((ref) {
  final db = ref.read(databaseProvider);
  return db.settingsDao.watchShowAwakeTime();
});

final awakeTimeActionsProvider = Provider<AwakeTimeActions>((ref) {
  return AwakeTimeActions(ref);
});

class AwakeTimeActions {
  AwakeTimeActions(this._ref);

  final Ref _ref;

  Future<void> setShowAwakeTime(bool value) async {
    await _ref.read(databaseProvider).settingsDao.setShowAwakeTime(value);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/app_database.dart';
import '../../../services/database/database_provider.dart';

final activeBabyProvider = StreamProvider<Baby>((ref) async* {
  final db = ref.read(databaseProvider);
  final babyId = await db.careLogDao.ensureDefaultBaby();
  yield* db.careLogDao.watchBaby(babyId);
});

final babyProfileActionsProvider = Provider<BabyProfileActions>((ref) {
  return BabyProfileActions(ref);
});

class BabyProfileActions {
  BabyProfileActions(this._ref);

  final Ref _ref;

  Future<void> updateProfile({
    required String name,
    DateTime? birthDate,
    required bool isPreemie,
  }) async {
    final db = _ref.read(databaseProvider);
    final babyId = await db.careLogDao.ensureDefaultBaby();
    await db.careLogDao.updateBabyProfile(
      babyId: babyId,
      name: name.trim().isEmpty ? 'Baby' : name.trim(),
      birthDate: birthDate,
      isPreemie: isPreemie,
    );
  }
}
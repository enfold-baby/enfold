import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';
import '../../baby/providers/baby_profile_providers.dart';
import '../../pregnancy/providers/pregnancy_providers.dart';

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(onboardingCompletedProvider, (_, __) => refresh.notify());
  return refresh;
});

class RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final db = ref.read(databaseProvider);
  return db.settingsDao.isOnboardingCompleted();
});

final onboardingActionsProvider = Provider<OnboardingActions>((ref) {
  return OnboardingActions(ref);
});

class OnboardingActions {
  OnboardingActions(this._ref);

  final Ref _ref;

  Future<void> complete() async {
    await _ref.read(databaseProvider).settingsDao.setOnboardingCompleted(true);
    _ref.invalidate(onboardingCompletedProvider);
    _ref.read(routerRefreshProvider).notify();
  }

  Future<void> savePregnancyDueDate(DateTime dueDate) async {
    await _ref.read(pregnancyActionsProvider).setDueDate(dueDate);
  }

  Future<void> saveBabyProfile({
    required String name,
    DateTime? birthDate,
  }) async {
    await _ref.read(babyProfileActionsProvider).updateProfile(
          name: name,
          birthDate: birthDate,
          isPreemie: false,
        );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/database/database_provider.dart';

final activeBabyIdProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.careLogDao.ensureDefaultBaby();
});
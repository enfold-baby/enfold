import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learn_card.dart';
import '../services/learn_content_service.dart';

final learnContentServiceProvider = Provider<LearnContentService>(
  (ref) => const LearnContentService(),
);

final learnCardsProvider = FutureProvider<List<LearnCard>>((ref) async {
  final service = ref.watch(learnContentServiceProvider);
  return service.loadAllCards();
});

final learnCardProvider = FutureProvider.family<LearnCard, String>((ref, id) async {
  final service = ref.watch(learnContentServiceProvider);
  return service.loadCard(id);
});
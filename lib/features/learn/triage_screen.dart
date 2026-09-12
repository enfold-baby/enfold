import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'models/learn_card.dart';
import 'providers/learn_content_provider.dart';
import 'widgets/medical_disclaimer.dart';

class TriageScreen extends ConsumerStatefulWidget {
  const TriageScreen({super.key, required this.cardId});

  final String cardId;

  @override
  ConsumerState<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends ConsumerState<TriageScreen> {
  String? _currentNodeId;
  TriageLevel? _outcome;

  void _reset(LearnTriage triage) {
    setState(() {
      _currentNodeId = triage.startId;
      _outcome = null;
    });
  }

  void _answer(TriageChoice choice, LearnTriage triage) {
    setState(() {
      if (choice.outcome != null) {
        _outcome = choice.outcome;
        _currentNodeId = null;
      } else if (choice.goto != null) {
        _currentNodeId = choice.goto;
        _outcome = null;
      }
    });
  }

  Color _colorFor(TriageLevel level) => switch (level) {
        TriageLevel.green => AppColors.sage,
        TriageLevel.yellow => const Color(0xFFC9A227),
        TriageLevel.red => AppColors.bloomDeep,
      };

  @override
  Widget build(BuildContext context) {
    final cardAsync = ref.watch(learnCardProvider(widget.cardId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick triage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go('${AppRoutes.learn}/${widget.cardId}'),
        ),
      ),
      body: cardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Triage not available.',
            style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness)),
          ),
        ),
        data: (card) {
          final triage = card.triage;
          if (triage == null) {
            return Center(
              child: Text(
                'No triage for this topic.',
                style: GoogleFonts.nunito(color: AppColors.mutedText(Theme.of(context).brightness)),
              ),
            );
          }

          final currentNodeId = _currentNodeId ?? triage.startId;

          if (_outcome != null) {
            final result = triage.outcomes[_outcome!]!;
            final color = _colorFor(_outcome!);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Container(
                  key: Key('triage_outcome_${_outcome!.name}'),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.45)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.cream : AppColors.bark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result.body,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? AppColors.cream : AppColors.bark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => _reset(triage),
                  child: const Text('Start over'),
                ),
                const SizedBox(height: 16),
                MedicalDisclaimer(text: card.disclaimer),
              ],
            );
          }

          final node = triage.nodes[currentNodeId]!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                triage.intro,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.mutedText(Theme.of(context).brightness),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                node.question,
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.cream : AppColors.bark,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('triage_yes'),
                onPressed: () => _answer(node.yes, triage),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: AppColors.cream,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Yes'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('triage_no'),
                onPressed: () => _answer(node.no, triage),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('No'),
              ),
              const SizedBox(height: 24),
              MedicalDisclaimer(text: card.disclaimer),
            ],
          );
        },
      ),
    );
  }
}
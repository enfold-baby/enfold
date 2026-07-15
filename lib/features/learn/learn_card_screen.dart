import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'providers/learn_content_provider.dart';
import 'widgets/learn_section.dart';
import 'widgets/medical_disclaimer.dart';

class LearnCardScreen extends ConsumerWidget {
  const LearnCardScreen({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(learnCardProvider(cardId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.learn),
        ),
      ),
      body: cardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Card not found.',
            style: GoogleFonts.nunito(color: AppColors.barkSoft),
          ),
        ),
        data: (card) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              card.title,
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.cream : AppColors.bark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.summary,
              style: GoogleFonts.nunito(
                fontSize: 15,
                height: 1.45,
                color: AppColors.barkSoft,
              ),
            ),
            if (card.triage != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                key: Key('triage_start_${card.id}'),
                onPressed: () =>
                    context.go('${AppRoutes.learn}/${card.id}/triage'),
                icon: const Icon(Icons.help_outline),
                label: const Text('Quick triage'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: AppColors.cream,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            LearnSection(
              label: "What's normal",
              color: AppColors.sage,
              body: card.whatsNormal,
            ),
            const SizedBox(height: 24),
            LearnSection(
              label: 'Watch for',
              color: const Color(0xFFC9A227),
              bullets: card.watchFor,
            ),
            const SizedBox(height: 24),
            LearnSection(
              label: 'Call doctor if',
              color: AppColors.bloomDeep,
              bullets: card.callDoctorIf,
            ),
            const SizedBox(height: 24),
            Text(
              card.reviewer.displayLine,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.barkSoft,
              ),
            ),
            const SizedBox(height: 16),
            MedicalDisclaimer(text: card.disclaimer),
          ],
        ),
      ),
    );
  }
}
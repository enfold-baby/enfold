import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'models/learn_card.dart';
import 'providers/learn_content_provider.dart';
import 'utils/learn_card_filter.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(learnCardsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load learn cards.',
              style: GoogleFonts.nunito(color: AppColors.barkSoft),
            ),
          ),
        ),
        data: (cards) {
          final visible = filterLearnCards(cards, _query);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                'Is this normal?',
                style: GoogleFonts.fraunces(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.cream : AppColors.bark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Doctor-reviewed guidance. Reassurance before panic.',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.barkSoft,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('learn_search'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search topics…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          key: const Key('learn_search_clear'),
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No cards match your search.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: AppColors.barkSoft,
                    ),
                  ),
                )
              else
                ...visible.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LearnCardTile(card: card, isDark: isDark),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LearnCardTile extends StatelessWidget {
  const _LearnCardTile({required this.card, required this.isDark});

  final LearnCard card;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.nightElevated : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key('learn_card_${card.id}'),
        onTap: () => context.go('${AppRoutes.learn}/${card.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.nightLine
                  : AppColors.bark.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.cream : AppColors.bark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.summary,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.barkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              if (card.triage != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Triage',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.sageDeep,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: AppColors.barkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../logs/widgets/log_period_bar.dart';
import '../logs/widgets/paginated_log_list.dart';
import '../logs/widgets/type_filter_chips.dart';
import 'data/medication_presets.dart';
import 'providers/medication_providers.dart';

class MedicationLogsScreen extends ConsumerWidget {
  const MedicationLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(medicationLogsProvider);
    final category = ref.watch(medicationCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meds & vitamins')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_medication_log'),
        onPressed: () => context.push(AppRoutes.logMedicationAdd),
        backgroundColor: AppColors.medicationAmber,
        foregroundColor: AppColors.cream,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
          children: [
            Text(
              'All doses',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            LogPeriodBar(periodProvider: medicationLogPeriodProvider),
            const SizedBox(height: 20),
            DetailFilterChips<String>(
              label: 'Category',
              options: [
                for (final (value, label) in MedicationPresets.categories)
                  DetailFilterOption(value: value, label: label),
              ],
              selected: category,
              onSelected: (value) =>
                  ref.read(medicationCategoryFilterProvider.notifier).state =
                      value,
            ),
            const SizedBox(height: 24),
            PaginatedLogList(
              logsAsync: logsAsync,
              emptyKey: const Key('medication_logs_empty'),
              emptyMessage:
                  'No medication or vitamin logs in this period. Tap + to add one.',
            ),
          ],
        ),
      ),
    );
  }
}
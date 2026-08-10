import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../features/growth/providers/growth_providers.dart';
import '../features/logs/providers/logs_providers.dart';
import '../features/medication/providers/medication_providers.dart';
import '../features/partner/providers/partner_providers.dart';
import '../features/pumping/providers/pumping_providers.dart';
import '../features/settings/widgets/partner_section.dart';
import '../features/today/providers/today_log_provider.dart';
import '../features/tummy_time/providers/tummy_time_providers.dart';
import '../services/auth/auth_providers.dart';
import '../services/sync/sync_providers.dart';

/// Pull-to-refresh that runs partner sync, then lets Drift streams rebuild UI.
class SyncRefresh extends ConsumerWidget {
  const SyncRefresh({
    super.key,
    required this.child,
    this.indicatorKey,
    this.fullHistory = false,
  });

  final Widget child;
  final Key? indicatorKey;

  /// When true, pull beyond the usual 2-day lookback (useful after join).
  final bool fullHistory;

  static Future<void> run(
    WidgetRef ref,
    BuildContext context, {
    bool fullHistory = false,
  }) async {
    final result = await ref
        .read(syncActionsProvider)
        .syncIfSignedIn(fullHistory: fullHistory);

    // Force-refresh stream/future providers that might not rebuild UI.
    ref.invalidate(todayLogProvider);
    ref.invalidate(todayMedicationLogsProvider);
    ref.invalidate(todayTummyLogsProvider);
    ref.invalidate(todayPumpingLogsProvider);
    ref.invalidate(hubLogsProvider);
    ref.invalidate(feedLogsProvider);
    ref.invalidate(diaperLogsProvider);
    ref.invalidate(sleepLogsProvider);
    ref.invalidate(openSleepProvider);
    ref.invalidate(deletedLogsProvider);
    ref.invalidate(medicationLogsProvider);
    ref.invalidate(pumpingLogsProvider);
    ref.invalidate(tummyLogsProvider);
    ref.invalidate(growthMeasurementsProvider);
    ref.invalidate(milestoneStatusesProvider);
    ref.invalidate(partnerNudgeProvider);
    ref.invalidate(hasPartnerProvider);
    ref.invalidate(familyInfoProvider);

    if (!context.mounted) return;
    final signedIn = ref.read(authSessionProvider).valueOrNull != null;
    if (signedIn && !result.ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              result.error == null
                  ? 'Couldn’t sync right now. Your local logs are safe.'
                  : 'Sync failed: ${result.error}',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      key: indicatorKey,
      color: AppColors.sage,
      onRefresh: () => run(ref, context, fullHistory: fullHistory),
      child: child,
    );
  }
}

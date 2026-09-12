import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/learn/learn_card_screen.dart';
import '../../features/learn/learn_screen.dart';
import '../../features/learn/triage_screen.dart';
import '../../features/logs/diaper_logs_screen.dart';
import '../../features/logs/feed_logs_screen.dart';
import '../../features/logs/log_diaper_screen.dart';
import '../../features/logs/log_feed_screen.dart';
import '../../features/logs/log_sleep_screen.dart';
import '../../features/logs/logs_hub_screen.dart';
import '../../features/growth/add_growth_measurement_screen.dart';
import '../../features/growth/growth_screen.dart';
import '../../features/logs/sleep_logs_screen.dart';
import '../../features/medication/log_medication_screen.dart';
import '../../features/medication/medication_logs_screen.dart';
import '../../features/pumping/log_pumping_screen.dart';
import '../../features/pumping/pumping_logs_screen.dart';
import '../../features/tummy_time/log_tummy_time_screen.dart';
import '../../features/tummy_time/tummy_time_logs_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/providers/onboarding_providers.dart';
import '../../features/pregnancy/pregnancy_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/today/models/log_type.dart';
import '../../features/today/today_screen.dart';
import '../../widgets/app_shell.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const today = '/';
  static const logs = '/logs';
  static const logFeed = '/logs/feed';
  static const logFeedAdd = '/logs/feed/add';
  static const logDiaper = '/logs/diaper';
  static const logDiaperAdd = '/logs/diaper/add';
  static const logSleep = '/logs/sleep';
  static const logSleepAdd = '/logs/sleep/add';
  static const logMedication = '/logs/medication';
  static const logMedicationAdd = '/logs/medication/add';
  static const logPumping = '/logs/pumping';
  static const logPumpingAdd = '/logs/pumping/add';
  static const logTummy = '/logs/tummy';
  static const logTummyAdd = '/logs/tummy/add';
  static const learn = '/learn';
  static const pregnancy = '/pregnancy';
  static const settings = '/settings';
  static const growth = '/growth';
  static const growthAdd = '/growth/add';
  static const logsGrowth = '/logs/growth';
  static const logsGrowthAdd = '/logs/growth/add';

  static String learnCard(String id) => '$learn/$id';
  static String learnTriage(String id) => '$learn/$id/triage';

  static String logList(LogType type) => switch (type) {
        LogType.feed => logFeed,
        LogType.diaper => logDiaper,
        LogType.sleep => logSleep,
        LogType.medication => logMedication,
        LogType.pumping => logPumping,
        LogType.tummyTime => logTummy,
      };

  static String logForm(LogType type) => switch (type) {
        LogType.feed => logFeedAdd,
        LogType.diaper => logDiaperAdd,
        LogType.sleep => logSleepAdd,
        LogType.medication => logMedicationAdd,
        LogType.pumping => logPumpingAdd,
        LogType.tummyTime => logTummyAdd,
      };

  static String logEdit(LogType type, String logId) =>
      '${logList(type)}/$logId';

  static String growthAddFrom(String location) {
    if (location.startsWith(logsGrowth)) return logsGrowthAdd;
    return growthAdd;
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.today,
    refreshListenable: ref.read(routerRefreshProvider),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final onboardingAsync = ref.read(onboardingCompletedProvider);

      if (onboardingAsync.isLoading) return null;

      final completed = onboardingAsync.value ?? false;
      if (!completed && location != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      if (completed && location == AppRoutes.onboarding) {
        return AppRoutes.today;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayScreen(),
                routes: [
                  GoRoute(
                    path: 'growth',
                    builder: (context, state) => const GrowthScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) =>
                            const AddGrowthMeasurementScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.logs,
                builder: (context, state) => const LogsHubScreen(),
                routes: [
                  GoRoute(
                    path: 'feed',
                    builder: (context, state) => const FeedLogsScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) => const LogFeedScreen(),
                      ),
                      GoRoute(
                        path: ':logId',
                        builder: (context, state) => LogFeedScreen(
                          logId: state.pathParameters['logId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'diaper',
                    builder: (context, state) => const DiaperLogsScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) => const LogDiaperScreen(),
                      ),
                      GoRoute(
                        path: ':logId',
                        builder: (context, state) => LogDiaperScreen(
                          logId: state.pathParameters['logId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'sleep',
                    builder: (context, state) => const SleepLogsScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) => const LogSleepScreen(),
                      ),
                      GoRoute(
                        path: ':logId',
                        builder: (context, state) => LogSleepScreen(
                          logId: state.pathParameters['logId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'medication',
                    builder: (context, state) => const MedicationLogsScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) =>
                            const LogMedicationScreen(),
                      ),
                      GoRoute(
                        path: ':logId',
                        builder: (context, state) => LogMedicationScreen(
                          logId: state.pathParameters['logId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'pumping',
                    builder: (context, state) => const PumpingLogsScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) => const LogPumpingScreen(),
                      ),
                      GoRoute(
                        path: ':logId',
                        builder: (context, state) => LogPumpingScreen(
                          logId: state.pathParameters['logId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'tummy',
                    builder: (context, state) => const TummyTimeLogsScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) =>
                            const LogTummyTimeScreen(),
                      ),
                      GoRoute(
                        path: ':logId',
                        builder: (context, state) => LogTummyTimeScreen(
                          logId: state.pathParameters['logId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'growth',
                    builder: (context, state) => const GrowthScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) =>
                            const AddGrowthMeasurementScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => LearnCardScreen(
                      cardId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'triage',
                        builder: (context, state) => TriageScreen(
                          cardId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.pregnancy,
        builder: (context, state) => const PregnancyScreen(),
      ),
    ],
  );
}
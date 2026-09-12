import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/theme_providers.dart';
import 'features/settings/providers/time_format_providers.dart';
import 'features/medication/providers/medication_routine_providers.dart';
import 'services/push/push_providers.dart';
import 'services/reminders/care_reminder_providers.dart';

class EnfoldApp extends ConsumerWidget {
  const EnfoldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pushBootstrapProvider);
    ref.watch(careReminderBootstrapProvider);
    ref.watch(medicationRoutineBootstrapProvider);
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final use24Hour =
        ref.watch(use24HourTimeProvider).valueOrNull ?? false;
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Enfold',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: use24Hour,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter(ref);
  ref.onDispose(router.dispose);
  return router;
});
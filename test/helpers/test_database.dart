import 'package:enfold/features/onboarding/providers/onboarding_providers.dart';
import 'package:enfold/features/settings/providers/app_info_provider.dart';
import 'package:enfold/services/auth/auth_providers.dart';
import 'package:enfold/services/auth/auth_session.dart';
import 'package:enfold/services/database/app_database.dart';
import 'package:enfold/services/database/database_provider.dart';
import 'package:enfold/services/push/fcm_token_source.dart';
import 'package:enfold/services/push/push_providers.dart';
import 'package:enfold/features/medication/providers/medication_routine_providers.dart';
import 'package:enfold/services/reminders/care_reminder_providers.dart';
import 'package:enfold/services/reminders/care_reminder_scheduler.dart';
import 'package:enfold/services/reminders/medication_routine_scheduler.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

class _TestAuthNotifier extends AuthSessionNotifier {
  @override
  Future<AuthSession?> build() async => null;

  @override
  Future<String?> requestMagicCode(String email) async => '123456';
}

ProviderContainer createTestContainer({AppDatabase? database}) {
  final db = database ?? createTestDatabase();
  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      authSessionProvider.overrideWith(_TestAuthNotifier.new),
      onboardingCompletedProvider.overrideWith((ref) async => true),
      appPackageInfoProvider.overrideWith(
        (ref) async => const AppPackageInfo(
          version: '0.1.0',
          buildNumber: '1',
          appName: 'Enfold',
        ),
      ),
      fcmTokenSourceProvider.overrideWithValue(const NoOpFcmTokenSource()),
      careReminderSchedulerProvider.overrideWithValue(
        const NoOpCareReminderScheduler(),
      ),
      medicationRoutineSchedulerProvider.overrideWithValue(
        const NoOpMedicationRoutineScheduler(),
      ),
    ],
  );
}
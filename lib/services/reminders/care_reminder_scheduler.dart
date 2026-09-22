import '../../l10n/generated/app_localizations.dart';

abstract class CareReminderScheduler {
  Future<void> sync({
    required AppL10n l10n,
    required bool enabled,
    required String babyName,
    required bool hasLogsToday,
    DateTime? now,
  });
}

class NoOpCareReminderScheduler implements CareReminderScheduler {
  const NoOpCareReminderScheduler();

  @override
  Future<void> sync({
    required AppL10n l10n,
    required bool enabled,
    required String babyName,
    required bool hasLogsToday,
    DateTime? now,
  }) async {}
}

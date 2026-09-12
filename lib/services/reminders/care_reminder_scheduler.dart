abstract class CareReminderScheduler {
  Future<void> sync({
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
    required bool enabled,
    required String babyName,
    required bool hasLogsToday,
    DateTime? now,
  }) async {}
}

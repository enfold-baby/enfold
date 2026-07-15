class MilestoneDefinition {
  const MilestoneDefinition({
    required this.key,
    required this.title,
    required this.ageHint,
    required this.group,
  });

  final String key;
  final String title;
  final String ageHint;
  final String group;
}

class MilestoneStatus {
  const MilestoneStatus({
    required this.definition,
    this.achievedAt,
  });

  final MilestoneDefinition definition;
  final DateTime? achievedAt;

  bool get isAchieved => achievedAt != null;
}
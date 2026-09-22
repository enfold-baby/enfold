import '../../../l10n/generated/app_localizations.dart';

class MilestoneDefinition {
  const MilestoneDefinition({
    required this.key,
    required this.group,
  });

  /// Stable id: stored on achievements and synced, never translated.
  final String key;

  /// Stable group id; [groupLabel] is what the headings show.
  final String group;

  String title(AppL10n l10n) => switch (key) {
        'social_smile' => l10n.milestoneSocialSmile,
        'lifts_head_tummy' => l10n.milestoneLiftsHeadTummy,
        'follows_objects' => l10n.milestoneFollowsObjects,
        'coos' => l10n.milestoneCoos,
        'holds_head_steady' => l10n.milestoneHoldsHeadSteady,
        'laughs' => l10n.milestoneLaughs,
        'pushes_up_tummy' => l10n.milestonePushesUpTummy,
        'rolls_over' => l10n.milestoneRollsOver,
        'sits_with_support' => l10n.milestoneSitsWithSupport,
        'babbles' => l10n.milestoneBabbles,
        'sits_without_support' => l10n.milestoneSitsWithoutSupport,
        'crawls_or_scoots' => l10n.milestoneCrawlsOrScoots,
        _ => l10n.milestonePincerGrasp,
      };

  String ageHint(AppL10n l10n) => switch (key) {
        'social_smile' => l10n.milestoneAgeSocialSmile,
        'lifts_head_tummy' => l10n.milestoneAgeLiftsHeadTummy,
        'follows_objects' => l10n.milestoneAgeFollowsObjects,
        'coos' => l10n.milestoneAgeCoos,
        'holds_head_steady' => l10n.milestoneAgeHoldsHeadSteady,
        'laughs' => l10n.milestoneAgeLaughs,
        'pushes_up_tummy' => l10n.milestoneAgePushesUpTummy,
        'rolls_over' => l10n.milestoneAgeRollsOver,
        'sits_with_support' => l10n.milestoneAgeSitsWithSupport,
        'babbles' => l10n.milestoneAgeBabbles,
        'sits_without_support' => l10n.milestoneAgeSitsWithoutSupport,
        'crawls_or_scoots' => l10n.milestoneAgeCrawlsOrScoots,
        _ => l10n.milestoneAgePincerGrasp,
      };

  String groupLabel(AppL10n l10n) => switch (group) {
        'early_weeks' => l10n.milestoneGroupEarlyWeeks,
        '1_2_months' => l10n.milestoneGroupOneTwoMonths,
        '2_4_months' => l10n.milestoneGroupTwoFourMonths,
        '4_6_months' => l10n.milestoneGroupFourSixMonths,
        _ => l10n.milestoneGroupSixNineMonths,
      };
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

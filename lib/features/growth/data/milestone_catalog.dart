import '../models/milestone_definition.dart';

abstract final class MilestoneCatalog {
  /// Keys and groups are stable ids; the copy lives in the ARB files.
  static const entries = <MilestoneDefinition>[
    MilestoneDefinition(key: 'social_smile', group: 'early_weeks'),
    MilestoneDefinition(key: 'lifts_head_tummy', group: 'early_weeks'),
    MilestoneDefinition(key: 'follows_objects', group: '1_2_months'),
    MilestoneDefinition(key: 'coos', group: '1_2_months'),
    MilestoneDefinition(key: 'holds_head_steady', group: '2_4_months'),
    MilestoneDefinition(key: 'laughs', group: '2_4_months'),
    MilestoneDefinition(key: 'pushes_up_tummy', group: '2_4_months'),
    MilestoneDefinition(key: 'rolls_over', group: '4_6_months'),
    MilestoneDefinition(key: 'sits_with_support', group: '4_6_months'),
    MilestoneDefinition(key: 'babbles', group: '4_6_months'),
    MilestoneDefinition(key: 'sits_without_support', group: '6_9_months'),
    MilestoneDefinition(key: 'crawls_or_scoots', group: '6_9_months'),
    MilestoneDefinition(key: 'pincer_grasp', group: '6_9_months'),
  ];

  static int get totalCount => entries.length;
}

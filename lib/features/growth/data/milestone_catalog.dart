import '../models/milestone_definition.dart';

abstract final class MilestoneCatalog {
  static const entries = <MilestoneDefinition>[
    MilestoneDefinition(
      key: 'social_smile',
      title: 'First social smile',
      ageHint: 'Around 6–8 weeks',
      group: 'Early weeks',
    ),
    MilestoneDefinition(
      key: 'lifts_head_tummy',
      title: 'Lifts head on tummy',
      ageHint: 'Around 1 month',
      group: 'Early weeks',
    ),
    MilestoneDefinition(
      key: 'follows_objects',
      title: 'Follows objects with eyes',
      ageHint: 'Around 2 months',
      group: '1–2 months',
    ),
    MilestoneDefinition(
      key: 'coos',
      title: 'Coos and makes sounds',
      ageHint: 'Around 2 months',
      group: '1–2 months',
    ),
    MilestoneDefinition(
      key: 'holds_head_steady',
      title: 'Holds head steady',
      ageHint: 'Around 3 months',
      group: '2–4 months',
    ),
    MilestoneDefinition(
      key: 'laughs',
      title: 'Laughs out loud',
      ageHint: 'Around 3–4 months',
      group: '2–4 months',
    ),
    MilestoneDefinition(
      key: 'pushes_up_tummy',
      title: 'Pushes up on arms during tummy time',
      ageHint: 'Around 4 months',
      group: '2–4 months',
    ),
    MilestoneDefinition(
      key: 'rolls_over',
      title: 'Rolls over (one way)',
      ageHint: 'Around 4–6 months',
      group: '4–6 months',
    ),
    MilestoneDefinition(
      key: 'sits_with_support',
      title: 'Sits with support',
      ageHint: 'Around 5–6 months',
      group: '4–6 months',
    ),
    MilestoneDefinition(
      key: 'babbles',
      title: 'Babbles consonant sounds',
      ageHint: 'Around 6 months',
      group: '4–6 months',
    ),
    MilestoneDefinition(
      key: 'sits_without_support',
      title: 'Sits without support',
      ageHint: 'Around 6–8 months',
      group: '6–9 months',
    ),
    MilestoneDefinition(
      key: 'crawls_or_scoots',
      title: 'Crawls or scoots',
      ageHint: 'Around 7–9 months',
      group: '6–9 months',
    ),
    MilestoneDefinition(
      key: 'pincer_grasp',
      title: 'Picks up small objects (pincer grasp)',
      ageHint: 'Around 9 months',
      group: '6–9 months',
    ),
  ];

  static int get totalCount => entries.length;
}
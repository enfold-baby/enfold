import '../../../l10n/generated/app_localizations.dart';

class LearnReviewer {
  const LearnReviewer({
    required this.name,
    required this.credentials,
    required this.specialty,
    required this.reviewedAt,
  });

  final String name;
  final String credentials;
  final String specialty;
  final String reviewedAt;

  factory LearnReviewer.fromJson(Map<String, dynamic> json) {
    return LearnReviewer(
      name: json['name'] as String,
      credentials: json['credentials'] as String? ?? '',
      specialty: json['specialty'] as String,
      reviewedAt: json['reviewedAt'] as String,
    );
  }

  /// Only a named clinician with credentials counts as a review; placeholders
  /// such as "Pending physician review" must never read as "Reviewed by".
  bool get isReviewed =>
      credentials.trim().isNotEmpty && !name.toLowerCase().startsWith('pending');

  String displayLine(AppL10n l10n) {
    if (!isReviewed) return l10n.learnDisclaimerUnreviewed;
    return l10n.learnReviewedBy(name, credentials, specialty, reviewedAt);
  }
}

enum TriageLevel { green, yellow, red }

class TriageOutcome {
  const TriageOutcome({required this.title, required this.body});

  final String title;
  final String body;

  factory TriageOutcome.fromJson(Map<String, dynamic> json) {
    return TriageOutcome(
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class TriageChoice {
  const TriageChoice({this.goto, this.outcome});

  final String? goto;
  final TriageLevel? outcome;

  factory TriageChoice.fromJson(Map<String, dynamic> json) {
    return TriageChoice(
      goto: json['goto'] as String?,
      outcome: json['outcome'] != null
          ? TriageLevel.values.byName(json['outcome'] as String)
          : null,
    );
  }
}

class TriageNode {
  const TriageNode({
    required this.question,
    required this.yes,
    required this.no,
  });

  final String question;
  final TriageChoice yes;
  final TriageChoice no;

  factory TriageNode.fromJson(Map<String, dynamic> json) {
    return TriageNode(
      question: json['question'] as String,
      yes: TriageChoice.fromJson(json['yes'] as Map<String, dynamic>),
      no: TriageChoice.fromJson(json['no'] as Map<String, dynamic>),
    );
  }
}

class LearnTriage {
  const LearnTriage({
    required this.intro,
    required this.startId,
    required this.nodes,
    required this.outcomes,
  });

  final String intro;
  final String startId;
  final Map<String, TriageNode> nodes;
  final Map<TriageLevel, TriageOutcome> outcomes;

  factory LearnTriage.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as Map<String, dynamic>;
    final rawOutcomes = json['outcomes'] as Map<String, dynamic>;

    return LearnTriage(
      intro: json['intro'] as String,
      startId: json['startId'] as String,
      nodes: {
        for (final entry in rawNodes.entries)
          entry.key: TriageNode.fromJson(entry.value as Map<String, dynamic>),
      },
      outcomes: {
        for (final entry in rawOutcomes.entries)
          TriageLevel.values.byName(entry.key): TriageOutcome.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      },
    );
  }
}

/// A citation shown under a card, as App Store guideline 1.4.1 requires for
/// medical information: the source name and a link parents can open.
class LearnSource {
  const LearnSource({required this.title, required this.url});

  final String title;
  final String url;

  factory LearnSource.fromJson(Map<String, dynamic> json) {
    return LearnSource(
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}

class LearnCard {
  const LearnCard({
    required this.id,
    required this.title,
    required this.summary,
    required this.whatsNormal,
    required this.watchFor,
    required this.callDoctorIf,
    required this.reviewer,
    required this.disclaimer,
    this.sources = const [],
    this.triage,
  });

  final String id;
  final String title;
  final String summary;
  final String whatsNormal;
  final List<String> watchFor;
  final List<String> callDoctorIf;
  final LearnReviewer reviewer;
  final String disclaimer;
  final List<LearnSource> sources;
  final LearnTriage? triage;

  factory LearnCard.fromJson(Map<String, dynamic> json) {
    return LearnCard(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      whatsNormal: json['whatsNormal'] as String,
      watchFor: (json['watchFor'] as List<dynamic>).cast<String>(),
      callDoctorIf: (json['callDoctorIf'] as List<dynamic>).cast<String>(),
      reviewer: LearnReviewer.fromJson(json['reviewer'] as Map<String, dynamic>),
      disclaimer: json['disclaimer'] as String,
      sources: (json['sources'] as List<dynamic>? ?? const [])
          .map((e) => LearnSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      triage: json['triage'] != null
          ? LearnTriage.fromJson(json['triage'] as Map<String, dynamic>)
          : null,
    );
  }
}
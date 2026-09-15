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

  String get displayLine {
    if (!isReviewed) return 'General educational information, not medical advice';
    return 'Reviewed by $name, $credentials · $specialty · $reviewedAt';
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
      triage: json['triage'] != null
          ? LearnTriage.fromJson(json['triage'] as Map<String, dynamic>)
          : null,
    );
  }
}
class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.email,
    required this.displayName,
  });

  final String id;
  final String email;
  final String displayName;

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
    );
  }
}

class FamilyInfo {
  const FamilyInfo({
    required this.id,
    required this.members,
    this.inviteCode,
  });

  final String id;
  final String? inviteCode;
  final List<FamilyMember> members;

  factory FamilyInfo.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? [];
    return FamilyInfo(
      id: json['id'] as String,
      inviteCode: json['invite_code'] as String?,
      members: [
        for (final item in membersJson)
          FamilyMember.fromJson(item as Map<String, dynamic>),
      ],
    );
  }
}

class FamilyInvite {
  const FamilyInvite({required this.code, this.expiresAt});

  final String code;
  final DateTime? expiresAt;

  factory FamilyInvite.fromJson(Map<String, dynamic> json) {
    return FamilyInvite(
      code: json['code'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );
  }
}

class RemoteCareEvent {
  const RemoteCareEvent({
    required this.id,
    required this.childId,
    required this.type,
    required this.occurredAt,
    required this.details,
    required this.note,
    this.clientUpdatedAt,
    this.createdByUserId,
    this.createdByDisplayName,
  });

  final String id;
  final String childId;
  final String type;
  final DateTime occurredAt;
  final Map<String, dynamic> details;
  final String note;
  final DateTime? clientUpdatedAt;
  final String? createdByUserId;
  final String? createdByDisplayName;

  factory RemoteCareEvent.fromJson(Map<String, dynamic> json) {
    return RemoteCareEvent(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      type: json['type'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String).toLocal(),
      details: Map<String, dynamic>.from(
        json['details'] as Map<String, dynamic>? ?? {},
      ),
      note: json['note'] as String? ?? '',
      clientUpdatedAt: json['client_updated_at'] == null
          ? null
          : DateTime.parse(json['client_updated_at'] as String).toLocal(),
      createdByUserId: json['created_by_user_id'] as String?,
      createdByDisplayName: json['created_by_display_name'] as String?,
    );
  }
}
// Pure-Dart models for the V0.2 local "direction → goal" journey boundary.
// Compatible table names still use identity_* / portrait_*, but product
// semantics here are direction, constraint, domain, goal and milestone.

class JourneyMilestoneInput {
  const JourneyMilestoneInput({
    required this.title,
    required this.evidenceRule,
    required this.window,
  });

  final String title;
  final String evidenceRule;
  final String window;

  Map<String, Object?> toJson() => {
        'title': title,
        'evidence_rule': evidenceRule,
        'window': window,
      };

  static JourneyMilestoneInput fromJson(Map<String, Object?> json) =>
      JourneyMilestoneInput(
        title: json['title'] as String,
        evidenceRule: json['evidence_rule'] as String,
        window: json['window'] as String,
      );
}

class ConfirmJourneyBoundaryCommand {
  const ConfirmJourneyBoundaryCommand({
    required this.ownerId,
    required this.operationId,
    required this.deviceId,
    required this.installationId,
    required this.direction,
    required this.constraint,
    required this.domainCode,
    required this.goalTitle,
    required this.milestone,
    required this.occurredAtUs,
    this.appVersion = '0.2.0+2',
    this.platform = 'test',
    this.subjectKind = 'guest',
  });

  final String ownerId;
  final String operationId;
  final String deviceId;
  final String installationId;
  final String direction;
  final String constraint;
  final String domainCode;
  final String goalTitle;
  final JourneyMilestoneInput milestone;
  final int occurredAtUs;
  final String appVersion;
  final String platform;

  /// V0.2 subjects only allow one active row per kind. Isolation fixtures
  /// may use `local_account` for the second owner.
  final String subjectKind;

  Map<String, Object?> toPayload() => {
        'direction': direction,
        'constraint': constraint,
        'domain_code': domainCode,
        'goal_title': goalTitle,
        'milestone': milestone.toJson(),
      };
}

class ConfirmedJourneyBoundary {
  const ConfirmedJourneyBoundary({
    required this.ownerId,
    required this.operationId,
    required this.draftId,
    required this.portraitVersionId,
    required this.domainId,
    required this.goalId,
    required this.milestoneId,
    required this.direction,
    required this.constraint,
    required this.domainCode,
    required this.goalTitle,
    required this.milestone,
    required this.confirmedAtUs,
  });

  final String ownerId;
  final String operationId;
  final String draftId;
  final String portraitVersionId;
  final String domainId;
  final String goalId;
  final String milestoneId;
  final String direction;
  final String constraint;
  final String domainCode;
  final String goalTitle;
  final JourneyMilestoneInput milestone;
  final int confirmedAtUs;

  Map<String, Object?> toResultJson() => {
        'owner_id': ownerId,
        'operation_id': operationId,
        'draft_id': draftId,
        'portrait_version_id': portraitVersionId,
        'domain_id': domainId,
        'goal_id': goalId,
        'milestone_id': milestoneId,
        'direction': direction,
        'constraint': constraint,
        'domain_code': domainCode,
        'goal_title': goalTitle,
        'milestone': milestone.toJson(),
        'confirmed_at_us': confirmedAtUs,
      };

  static ConfirmedJourneyBoundary fromResultJson(Map<String, Object?> json) =>
      ConfirmedJourneyBoundary(
        ownerId: json['owner_id'] as String,
        operationId: json['operation_id'] as String,
        draftId: json['draft_id'] as String,
        portraitVersionId: json['portrait_version_id'] as String,
        domainId: json['domain_id'] as String,
        goalId: json['goal_id'] as String,
        milestoneId: json['milestone_id'] as String,
        direction: json['direction'] as String,
        constraint: json['constraint'] as String,
        domainCode: json['domain_code'] as String,
        goalTitle: json['goal_title'] as String,
        milestone: JourneyMilestoneInput.fromJson(
          Map<String, Object?>.from(json['milestone'] as Map),
        ),
        confirmedAtUs: json['confirmed_at_us'] as int,
      );
}

class JourneyBoundaryIncomplete implements Exception {
  const JourneyBoundaryIncomplete([
    this.message = 'The local journey boundary is incomplete.',
  ]);

  final String message;

  @override
  String toString() => message;
}

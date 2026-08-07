/// Multi-agent system type definitions.
///
/// Agent roles:
/// - fitness_coach: Physical domain guidance
/// - skill_mentor: Skill domain mentoring
/// - cognitive_trainer: Cognitive domain training
/// - social_advisor: Social domain advice
/// - wellness_guardian: Health bandwidth monitoring
/// - fusion_strategist: Cross-domain connections
/// - identity_guide: Identity evolution observation (does NOT define identity)
/// - safety_officer: Safety enforcement (veto authority)
///
/// All JSON keys follow snake_case (ADR-6). No Flutter dependencies.
library;

import 'package:meta/meta.dart';
import 'package:primeatlas/core/common/owner_id.dart';
import 'package:primeatlas/core/fusion/fusion_types.dart';

/// Agent role enumeration.
enum AgentRole {
  fitnessCoach,
  skillMentor,
  cognitiveTrainer,
  socialAdvisor,
  wellnessGuardian,
  fusionStrategist,
  identityGuide,
  safetyOfficer;

  String get code => switch (this) {
        AgentRole.fitnessCoach => 'fitness_coach',
        AgentRole.skillMentor => 'skill_mentor',
        AgentRole.cognitiveTrainer => 'cognitive_trainer',
        AgentRole.socialAdvisor => 'social_advisor',
        AgentRole.wellnessGuardian => 'wellness_guardian',
        AgentRole.fusionStrategist => 'fusion_strategist',
        AgentRole.identityGuide => 'identity_guide',
        AgentRole.safetyOfficer => 'safety_officer',
      };

  static AgentRole fromCode(String code) => switch (code) {
        'fitness_coach' => AgentRole.fitnessCoach,
        'skill_mentor' => AgentRole.skillMentor,
        'cognitive_trainer' => AgentRole.cognitiveTrainer,
        'social_advisor' => AgentRole.socialAdvisor,
        'wellness_guardian' => AgentRole.wellnessGuardian,
        'fusion_strategist' => AgentRole.fusionStrategist,
        'identity_guide' => AgentRole.identityGuide,
        'safety_officer' => AgentRole.safetyOfficer,
        _ => throw ArgumentError('Unknown AgentRole code: $code'),
      };
}

/// Authority level for agent decisions.
enum AuthorityLevel {
  advisory,
  recommend,
  decide,
  veto;

  String get code => name;

  static AuthorityLevel fromCode(String code) => switch (code) {
        'advisory' => AuthorityLevel.advisory,
        'recommend' => AuthorityLevel.recommend,
        'decide' => AuthorityLevel.decide,
        'veto' => AuthorityLevel.veto,
        _ => throw ArgumentError('Unknown AuthorityLevel code: $code'),
      };
}

/// Message type for inter-agent communication.
enum AgentMessageType {
  consultation,
  recommendation,
  objection,
  information,
  delegation;

  String get code => name;

  static AgentMessageType fromCode(String code) => switch (code) {
        'consultation' => AgentMessageType.consultation,
        'recommendation' => AgentMessageType.recommendation,
        'objection' => AgentMessageType.objection,
        'information' => AgentMessageType.information,
        'delegation' => AgentMessageType.delegation,
        _ => throw ArgumentError('Unknown AgentMessageType code: $code'),
      };
}

/// Safety status surfaced by a multi-agent panel (FAD).
///
/// Mirrors the post-evaluation severity of the safety layer:
/// - [clear]: no safety concern (info-level only).
/// - [advisory]: a warning was raised — advisory, never blocking.
/// - [blockedNonUser]: a block-severity concern was found. Per C-RL1 the user
///   is never hard-blocked; "blocked" here means the system strongly
///   discourages with an alternative path, it does NOT prevent the user's
///   goal or information access.
enum SafetyStatus {
  clear,
  advisory,
  blockedNonUser;

  String get code => switch (this) {
        SafetyStatus.clear => 'clear',
        SafetyStatus.advisory => 'advisory',
        SafetyStatus.blockedNonUser => 'blocked_non_user',
      };

  static SafetyStatus fromCode(String code) => switch (code) {
        'clear' => SafetyStatus.clear,
        'advisory' => SafetyStatus.advisory,
        'blocked_non_user' => SafetyStatus.blockedNonUser,
        _ => throw ArgumentError('Unknown SafetyStatus code: $code'),
      };
}

/// Describes the capabilities and authority of an agent role.
@immutable
class AgentCapability {
  final AgentRole role;
  final List<String> specialties;
  final List<String> decisionTypes;
  final AuthorityLevel authorityLevel;

  const AgentCapability({
    required this.role,
    required this.specialties,
    required this.decisionTypes,
    required this.authorityLevel,
  });

  Map<String, Object?> toJson() => {
        'role': role.code,
        'specialties': specialties,
        'decision_types': decisionTypes,
        'authority_level': authorityLevel.code,
      };

  static AgentCapability fromJson(Map<String, Object?> json) =>
      AgentCapability(
        role: AgentRole.fromCode(json['role'] as String),
        specialties: (json['specialties'] as List).cast<String>(),
        decisionTypes: (json['decision_types'] as List).cast<String>(),
        authorityLevel:
            AuthorityLevel.fromCode(json['authority_level'] as String),
      );
}

/// A decision made by an agent.
@immutable
class AgentDecision {
  final AgentRole agentRole;
  final String decisionType;
  final String recommendation;
  final String reasoning;
  final double confidence;
  final List<String> alternatives;
  final int timestamp;

  const AgentDecision({
    required this.agentRole,
    required this.decisionType,
    required this.recommendation,
    required this.reasoning,
    required this.confidence,
    required this.alternatives,
    required this.timestamp,
  });

  bool get isVeto => agentRole == AgentRole.safetyOfficer &&
      confidence >= 1.0;

  Map<String, Object?> toJson() => {
        'agent_role': agentRole.code,
        'decision_type': decisionType,
        'recommendation': recommendation,
        'reasoning': reasoning,
        'confidence': confidence,
        'alternatives': alternatives,
        'timestamp': timestamp,
      };

  static AgentDecision fromJson(Map<String, Object?> json) => AgentDecision(
        agentRole: AgentRole.fromCode(json['agent_role'] as String),
        decisionType: json['decision_type'] as String,
        recommendation: json['recommendation'] as String,
        reasoning: json['reasoning'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        alternatives: (json['alternatives'] as List).cast<String>(),
        timestamp: json['timestamp'] as int,
      );
}

/// Context passed to agents for evaluation.
@immutable
class AgentContext {
  final OwnerId ownerId;
  final Map<String, Object?> currentState;
  final String? domainFocus;
  final List<AgentDecision> recentDecisions;
  final Map<String, Object?> userPreferences;

  const AgentContext({
    required this.ownerId,
    required this.currentState,
    this.domainFocus,
    required this.recentDecisions,
    required this.userPreferences,
  });
}

/// A proposed action to be evaluated by agents.
@immutable
class ProposedAction {
  final String actionType;
  final String description;
  final Map<String, Object?> parameters;

  const ProposedAction({
    required this.actionType,
    required this.description,
    required this.parameters,
  });
}

/// A message between agents.
@immutable
class AgentMessage {
  final AgentRole fromRole;
  final AgentRole toRole;
  final String content;
  final AgentMessageType messageType;
  final int timestamp;

  const AgentMessage({
    required this.fromRole,
    required this.toRole,
    required this.content,
    required this.messageType,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => {
        'from_role': fromRole.code,
        'to_role': toRole.code,
        'content': content,
        'message_type': messageType.code,
        'timestamp': timestamp,
      };

  static AgentMessage fromJson(Map<String, Object?> json) => AgentMessage(
        fromRole: AgentRole.fromCode(json['from_role'] as String),
        toRole: AgentRole.fromCode(json['to_role'] as String),
        content: json['content'] as String,
        messageType: AgentMessageType.fromCode(json['message_type'] as String),
        timestamp: json['timestamp'] as int,
      );
}

/// Result of running a full multi-agent panel (FAD / Agent V2).
///
/// Aggregates the per-agent decisions, the resolved (winning) decision, the
/// panel-level safety status, and any cross-domain fusion opportunities
/// discovered while evaluating. Pure data — no I/O.
@immutable
class AgentPanelResult {
  final List<AgentDecision> decisions;
  final AgentDecision? resolution;
  final SafetyStatus safetyStatus;
  final List<FusionOpportunity> fusionOpportunities;

  const AgentPanelResult({
    required this.decisions,
    this.resolution,
    required this.safetyStatus,
    this.fusionOpportunities = const [],
  });

  Map<String, Object?> toJson() => {
        'decisions': decisions.map((d) => d.toJson()).toList(),
        'resolution': resolution?.toJson(),
        'safety_status': safetyStatus.code,
        'fusion_opportunities':
            fusionOpportunities.map((o) => o.toJson()).toList(),
      };
}

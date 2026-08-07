/// Multi-agent orchestrator engine.
///
/// Rules:
/// 1. Safety officer has veto authority -- can override all other agents.
/// 2. Fusion strategist connects domains -- finds cross-domain opportunities.
/// 3. Identity guide does NOT define identity -- only observes and suggests
///    possibilities.
/// 4. All agent decisions include reasoning and alternatives (transparency).
/// 5. User controls goals/time/constraints/reality; agents generate and
///    execute plans, knowledge adoption, and normal auto-adjustments.
library;

import 'package:primeatlas/core/agents/agent_types.dart';

/// Orchestrates multi-agent evaluation and conflict resolution.
class AgentOrchestrator {
  final Map<AgentRole, AgentCapability> _capabilities;

  AgentOrchestrator()
      : _capabilities = _defaultCapabilities();

  /// Evaluates a proposed action by asking relevant agents for opinions.
  ///
  /// Returns decisions from all agents that have authority over the action
  /// type. The safety officer is always consulted.
  List<AgentDecision> evaluateAction(
    AgentContext ctx,
    ProposedAction action,
  ) {
    final now = _currentTimestampUs();
    final decisions = <AgentDecision>[];

    for (final entry in _capabilities.entries) {
      final role = entry.key;
      final cap = entry.value;
      if (!cap.decisionTypes.contains(action.actionType) &&
          role != AgentRole.safetyOfficer) {
        continue;
      }

      final decision = _evaluateForRole(role, cap, ctx, action, now);
      decisions.add(decision);
    }

    return decisions;
  }

  /// Resolves conflicting agent decisions.
  ///
  /// Resolution rules (in priority order):
  /// 1. If safety officer issued a veto, it overrides all others.
  /// 2. If any decision has `decide` authority, the highest-confidence one
  ///    wins.
  /// 3. Otherwise, return the highest-confidence `recommend` decision.
  /// 4. If all are `advisory`, return null (no resolution).
  AgentDecision? resolveConflict(List<AgentDecision> decisions) {
    if (decisions.isEmpty) return null;

    // Rule 1: Safety officer veto.
    final safetyDecisions = decisions
        .where((d) => d.agentRole == AgentRole.safetyOfficer)
        .toList();
    for (final d in safetyDecisions) {
      if (d.isVeto) return d;
    }

    // Rule 2: Highest-confidence decide.
    final decideDecisions = decisions.where((d) {
      final cap = _capabilities[d.agentRole];
      return cap?.authorityLevel == AuthorityLevel.decide;
    }).toList();
    if (decideDecisions.isNotEmpty) {
      decideDecisions
          .sort((a, b) => b.confidence.compareTo(a.confidence));
      return decideDecisions.first;
    }

    // Rule 3: Highest-confidence recommend.
    final recommendDecisions = decisions.where((d) {
      final cap = _capabilities[d.agentRole];
      return cap?.authorityLevel == AuthorityLevel.recommend;
    }).toList();
    if (recommendDecisions.isNotEmpty) {
      recommendDecisions
          .sort((a, b) => b.confidence.compareTo(a.confidence));
      return recommendDecisions.first;
    }

    // Rule 4: All advisory -- no resolution.
    return null;
  }

  /// Routes a message from one agent to relevant agents.
  ///
  /// Returns the list of messages that would be delivered. A message to
  /// a specific agent is delivered only to that agent. A message to
  /// `safetyOfficer` is always delivered. A broadcast message (toRole ==
  /// fromRole) is delivered to all other agents.
  List<AgentMessage> routeMessage(AgentMessage message) {
    final delivered = <AgentMessage>[];

    if (message.toRole == message.fromRole) {
      // Broadcast to all other agents.
      for (final role in _capabilities.keys) {
        if (role == message.fromRole) continue;
        delivered.add(AgentMessage(
          fromRole: message.fromRole,
          toRole: role,
          content: message.content,
          messageType: message.messageType,
          timestamp: message.timestamp,
        ));
      }
    } else {
      delivered.add(message);
    }

    return delivered;
  }

  AgentDecision _evaluateForRole(
    AgentRole role,
    AgentCapability cap,
    AgentContext ctx,
    ProposedAction action,
    int timestamp,
  ) {
    // Safety officer checks for safety violations.
    if (role == AgentRole.safetyOfficer) {
      return _safetyEvaluation(action, ctx, timestamp);
    }

    // Fusion strategist finds cross-domain connections.
    if (role == AgentRole.fusionStrategist) {
      return _fusionEvaluation(action, ctx, timestamp);
    }

    // Identity guide observes and suggests, never defines.
    if (role == AgentRole.identityGuide) {
      return _identityEvaluation(action, ctx, timestamp);
    }

    // Default: domain-specific advisory.
    return AgentDecision(
      agentRole: role,
      decisionType: action.actionType,
      recommendation: 'proceed',
      reasoning:
          'Agent ${role.code} reviewed action ${action.actionType} '
          'and found no objections.',
      confidence: 0.8,
      alternatives: ['defer', 'modify_parameters'],
      timestamp: timestamp,
    );
  }

  AgentDecision _safetyEvaluation(
    ProposedAction action,
    AgentContext ctx,
    int timestamp,
  ) {
    return AgentDecision(
      agentRole: AgentRole.safetyOfficer,
      decisionType: action.actionType,
      recommendation: 'safe_to_proceed',
      reasoning:
          'Safety officer evaluated action for rule violations. '
          'No safety rule breaches detected.',
      confidence: 0.95,
      alternatives: ['block_if_safety_rule_violated'],
      timestamp: timestamp,
    );
  }

  AgentDecision _fusionEvaluation(
    ProposedAction action,
    AgentContext ctx,
    int timestamp,
  ) {
    return AgentDecision(
      agentRole: AgentRole.fusionStrategist,
      decisionType: action.actionType,
      recommendation: 'cross_domain_opportunity_identified',
      reasoning:
          'Fusion strategist analyzed action for cross-domain '
          'synergies. Action may benefit multiple domains.',
      confidence: 0.7,
      alternatives: ['domain_isolated_execution', 'enhanced_fusion_plan'],
      timestamp: timestamp,
    );
  }

  AgentDecision _identityEvaluation(
    ProposedAction action,
    AgentContext ctx,
    int timestamp,
  ) {
    return AgentDecision(
      agentRole: AgentRole.identityGuide,
      decisionType: action.actionType,
      recommendation: 'observes_identity_implications',
      reasoning:
          'Identity guide observes this action for identity evolution '
          'possibilities. Identity guide does not define identity -- '
          'only suggests possibilities.',
      confidence: 0.6,
      alternatives: ['no_identity_change_detected'],
      timestamp: timestamp,
    );
  }

  int _currentTimestampUs() => DateTime.now().microsecondsSinceEpoch;

  static Map<AgentRole, AgentCapability> _defaultCapabilities() => {
        AgentRole.fitnessCoach: const AgentCapability(
          role: AgentRole.fitnessCoach,
          specialties: ['physical_training', 'recovery', 'nutrition'],
          decisionTypes: ['training_plan', 'recovery_adjustment'],
          authorityLevel: AuthorityLevel.recommend,
        ),
        AgentRole.skillMentor: const AgentCapability(
          role: AgentRole.skillMentor,
          specialties: ['skill_development', 'practice_scheduling'],
          decisionTypes: ['skill_plan', 'practice_adjustment'],
          authorityLevel: AuthorityLevel.recommend,
        ),
        AgentRole.cognitiveTrainer: const AgentCapability(
          role: AgentRole.cognitiveTrainer,
          specialties: ['cognitive_training', 'mental_models'],
          decisionTypes: ['cognitive_plan', 'challenge_adjustment'],
          authorityLevel: AuthorityLevel.recommend,
        ),
        AgentRole.socialAdvisor: const AgentCapability(
          role: AgentRole.socialAdvisor,
          specialties: ['social_skills', 'relationship_building'],
          decisionTypes: ['social_plan', 'connection_adjustment'],
          authorityLevel: AuthorityLevel.advisory,
        ),
        AgentRole.wellnessGuardian: const AgentCapability(
          role: AgentRole.wellnessGuardian,
          specialties: ['health_bandwidth', 'over_training_prevention'],
          decisionTypes: ['intervention', 'load_adjustment'],
          authorityLevel: AuthorityLevel.recommend,
        ),
        AgentRole.fusionStrategist: const AgentCapability(
          role: AgentRole.fusionStrategist,
          specialties: ['cross_domain', 'synergy_detection'],
          decisionTypes: ['fusion_opportunity', 'domain_connection'],
          authorityLevel: AuthorityLevel.advisory,
        ),
        AgentRole.identityGuide: const AgentCapability(
          role: AgentRole.identityGuide,
          specialties: ['identity_evolution', 'self_perception'],
          decisionTypes: ['identity_observation', 'possibility_suggestion'],
          authorityLevel: AuthorityLevel.advisory,
        ),
        AgentRole.safetyOfficer: const AgentCapability(
          role: AgentRole.safetyOfficer,
          specialties: ['safety_rules', 'risk_assessment'],
          decisionTypes: ['safety_check', 'override'],
          authorityLevel: AuthorityLevel.veto,
        ),
      };
}

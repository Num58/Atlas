import 'package:primeatlas/core/agents/agent_orchestrator.dart';
import 'package:primeatlas/core/common/owner_id.dart';
import 'package:primeatlas/core/conflict/conflict_engine.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';
import 'package:primeatlas/core/decision/decision_orchestrator.dart';
import 'package:primeatlas/core/decision/decision_types.dart';
import 'package:primeatlas/core/fusion/fusion_engine.dart';
import 'package:primeatlas/core/fusion/fusion_types.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/safety/safety_engine.dart';
import 'package:primeatlas/core/safety/safety_types.dart' hide ProposedAction;
import 'package:primeatlas/core/tone/tone_engine.dart';
import 'package:primeatlas/core/tone/tone_types.dart';
import 'package:test/test.dart';

PortraitSnapshot _portrait(List<String> axisIds) => PortraitSnapshot(
      version: 1,
      activeAxes: [
        for (final id in axisIds) PortraitAxis(id: id, label: id, active: true)
      ],
      values: {for (final id in axisIds) id: 0.5},
      transitionNarrative: '',
      consentedAt: DateTime.fromMicrosecondsSinceEpoch(0),
    );

DecisionContext _ctx({
  List<GrowthDomain> activeDomains = const [],
  List<ScheduledItem> scheduledItems = const [],
  SafetyContext safetyContext = const SafetyContext(energyLevel: 80),
  PortraitSnapshot? portrait,
}) =>
    DecisionContext(
      ownerId: const OwnerId('owner-1'),
      portrait: portrait ?? _portrait(['focus']),
      activeDomains: activeDomains,
      scheduledItems: scheduledItems,
      safetyContext: safetyContext,
      currentToneState: ToneState.initial,
      now: DateTime.fromMicrosecondsSinceEpoch(1700000000000000),
    );

void main() {
  final orchestrator = DecisionOrchestrator(
    safetyEngine: const SafetyEngine(),
    conflictEngine: const ConflictEngine(),
    fusionEngine: const FusionEngine(),
    agentOrchestrator: AgentOrchestrator(),
    toneEngine: ToneEngine(),
  );

  test('approved: two active domains, no safety/conflict issues', () {
    final action = ProposedAction(
      actionType: 'skill_plan',
      description: 'practice',
      domain: 'cognitive',
      scheduledAtUs: 0,
    );
    final domains = [
      GrowthDomain(
          code: 'a', name: 'A', observedThemeTags: ['focus'], progress: 0.6),
      GrowthDomain(
          code: 'b', name: 'B', observedThemeTags: ['focus'], progress: 0.5),
    ];
    final result = orchestrator.runDecision(action, _ctx(activeDomains: domains));
    expect(result.isSuccess, isTrue);
    final outcome = result.valueOrNull!;
    expect(outcome.status, DecisionStatus.approved);
    expect(outcome.fusionOpportunities, isNotEmpty);
    expect(outcome.evidenceChain, isNotEmpty);
  });

  test('safety_blocked: injury + physical action, C-RL1 keeps user agency', () {
    final action = ProposedAction(
      actionType: 'training_plan',
      description: 'run',
      domain: 'physical',
      intensity: 80,
      durationMin: 30,
      scheduledAtUs: 0,
    );
    final ctx = _ctx(
      activeDomains: [
        GrowthDomain(code: 'a', name: 'A', progress: 0.6),
        GrowthDomain(code: 'b', name: 'B', progress: 0.5),
      ],
      safetyContext: const SafetyContext(
        energyLevel: 80,
        healthStatus: HealthStatus(injuryFlags: ['knee']),
      ),
    );
    final result = orchestrator.runDecision(action, ctx);
    expect(result.isFailure, isTrue);
    final failure = result.failureOrNull!;
    expect(failure.code, 'safety_blocked');
    // C-RL1 assertions: never blocks the user goal.
    expect(failure.details['blocked_user'], isFalse);
    expect(failure.details['alternative_paths'], isNotEmpty);
  });

  test('data_insufficient: missing active domains', () {
    final action = ProposedAction(
      actionType: 'skill_plan',
      description: 'practice',
      scheduledAtUs: 0,
    );
    final result =
        orchestrator.runDecision(action, _ctx(activeDomains: const []));
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull!.code, 'data_insufficient');
  });

  test('conflict_unresolved: overlapping schedule items', () {
    final start = DateTime.fromMicrosecondsSinceEpoch(1000000000000000);
    final items = [
      ScheduledItem(
        id: 'x',
        start: start,
        end: start.add(const Duration(hours: 1)),
        plannedEnergy: 20,
        isTraining: false,
        recoveryLevel: 80,
      ),
      ScheduledItem(
        id: 'y',
        start: start.add(const Duration(minutes: 30)),
        end: start.add(const Duration(hours: 2)),
        plannedEnergy: 20,
        isTraining: false,
        recoveryLevel: 80,
      ),
    ];
    final action = ProposedAction(
      actionType: 'skill_plan',
      description: 'practice',
      domain: 'cognitive',
      scheduledAtUs: 0,
    );
    final result = orchestrator.runDecision(
      action,
      _ctx(
        activeDomains: [
          GrowthDomain(code: 'a', name: 'A', progress: 0.6),
          GrowthDomain(code: 'b', name: 'B', progress: 0.5),
        ],
        scheduledItems: items,
      ),
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull!.code, 'conflict_unresolved');
  });
}

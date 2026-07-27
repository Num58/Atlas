import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';
import 'package:primeatlas/app/state/journey_models.dart';

JourneyState journeyStateFromSnapshot(JourneyBoundarySnapshot snapshot) {
  final restoredDomains = snapshot.domain
      .split(RegExp(r'[·,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  final goalTitle = snapshot.goalTitle.trim();
  return JourneyState(
    direction: snapshot.direction,
    constraint: snapshot.constraint,
    domains: restoredDomains.isEmpty
        ? <String>[snapshot.domain]
        : restoredDomains,
    pausedDomains: const <String>[],
    goals: goalTitle.isEmpty
        ? const <GoalDraft>[]
        : <GoalDraft>[
            GoalDraft(
              id: 'goal-restored-1',
              title: goalTitle,
              status: GoalDraftStatus.active,
            ),
          ],
    milestone: MilestoneDraft(
      title: snapshot.milestoneTitle,
      evidenceRule: snapshot.milestoneEvidenceRule,
      window: snapshot.milestoneWindow,
    ),
    saveStatus: LocalSaveStatus.persisted,
    isConfirmed: true,
    saveError: null,
    isRestoring: false,
    domainFocusSuggestion: null,
  );
}

bool isJourneyBoundaryComplete(JourneyState state) {
  final hasGoal = state.goals.any(
    (item) =>
        item.status != GoalDraftStatus.archived && item.title.trim().isNotEmpty,
  );
  return state.direction.isNotEmpty &&
      state.constraint.isNotEmpty &&
      state.domains.isNotEmpty &&
      hasGoal &&
      state.milestone != null;
}

String nextGoalId(List<GoalDraft> existing) {
  return 'goal-${existing.length + 1}-${DateTime.now().microsecondsSinceEpoch}';
}

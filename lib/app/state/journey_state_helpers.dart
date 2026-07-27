import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';
import 'package:primeatlas/app/state/journey_models.dart';

JourneyState journeyStateFromSnapshot(JourneyBoundarySnapshot snapshot) {
  final restoredDomains = snapshot.domain
      .split(RegExp(r'[·,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
  return JourneyState(
    direction: snapshot.direction,
    constraint: snapshot.constraint,
    domains: restoredDomains.isEmpty
        ? <String>[snapshot.domain]
        : restoredDomains,
    pausedDomains: const <String>[],
    goal: snapshot.goalTitle,
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
  return state.direction.isNotEmpty &&
      state.constraint.isNotEmpty &&
      state.domains.isNotEmpty &&
      state.goal.isNotEmpty &&
      state.milestone != null;
}

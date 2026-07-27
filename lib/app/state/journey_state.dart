import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/bootstrap/persistence_providers.dart';
import 'package:primeatlas/app/state/journey_models.dart';
import 'package:primeatlas/app/state/journey_state_helpers.dart';
import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';
import 'package:primeatlas/application/journey/domain_lifecycle.dart';

export 'package:primeatlas/app/state/journey_models.dart';

class JourneyController extends Notifier<JourneyState> {
  static const maxActiveDomains = 3;
  static const _lifecycle = DomainLifecycle(maxActive: maxActiveDomains);

  var _restoreStarted = false;

  @override
  JourneyState build() {
    if (!_restoreStarted) {
      _restoreStarted = true;
      Future.microtask(restoreFromLocalStore);
    }
    return const JourneyState.initial();
  }

  Future<void> restoreFromLocalStore() async {
    state = state.copyWith(isRestoring: true, clearSaveError: true);
    try {
      final loader = ref.read(loadLatestJourneyBoundaryProvider);
      final snapshot = await loader();
      if (snapshot == null) {
        state = state.copyWith(isRestoring: false);
        return;
      }
      state = journeyStateFromSnapshot(snapshot);
    } catch (_) {
      state = state.copyWith(
        isRestoring: false,
        saveStatus: state.saveStatus == LocalSaveStatus.persisted
            ? LocalSaveStatus.failed
            : state.saveStatus,
        saveError: '本机恢复失败，请重试确认写入',
      );
    }
  }

  void saveDirection({required String direction, required String constraint}) {
    state = state.copyWith(
      direction: direction.trim(),
      constraint: constraint.trim(),
      saveStatus: LocalSaveStatus.pendingPersistence,
      isConfirmed: false,
      clearSaveError: true,
    );
  }

  DomainSelectionResult selectDomain(String domain) {
    final outcome = _lifecycle.toggleActive(
      active: state.domains,
      paused: state.pausedDomains,
      domain: domain,
    );
    if (!outcome.ok) {
      state = state.copyWith(domainFocusSuggestion: outcome.message);
      return DomainSelectionResult.focusSuggestion(
        outcome.message ?? '请先聚焦现有成长域',
      );
    }
    state = state.copyWith(
      domains: outcome.active,
      pausedDomains: outcome.paused,
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
      clearDomainFocusSuggestion: true,
    );
    return DomainSelectionResult.accepted(outcome.active);
  }

  DomainSelectionResult pauseDomain(String domain) {
    final outcome = _lifecycle.pause(
      active: state.domains,
      paused: state.pausedDomains,
      domain: domain,
    );
    if (!outcome.ok) {
      state = state.copyWith(domainFocusSuggestion: outcome.message);
      return DomainSelectionResult.focusSuggestion(
        outcome.message ?? '无法暂停该成长域',
      );
    }
    state = state.copyWith(
      domains: outcome.active,
      pausedDomains: outcome.paused,
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
      clearDomainFocusSuggestion: true,
    );
    return DomainSelectionResult.accepted(outcome.active);
  }

  DomainSelectionResult resumeDomain(String domain) {
    final outcome = _lifecycle.resume(
      active: state.domains,
      paused: state.pausedDomains,
      domain: domain,
    );
    if (!outcome.ok) {
      state = state.copyWith(domainFocusSuggestion: outcome.message);
      return DomainSelectionResult.focusSuggestion(
        outcome.message ?? '无法恢复该成长域',
      );
    }
    state = state.copyWith(
      domains: outcome.active,
      pausedDomains: outcome.paused,
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
      clearDomainFocusSuggestion: true,
    );
    return DomainSelectionResult.accepted(outcome.active);
  }

  /// Compatibility entry used by simplified GoalPage.
  void saveGoal(String goal) {
    final title = goal.trim();
    if (title.isEmpty) {
      return;
    }
    if (state.goals.isEmpty) {
      addGoal(title);
      return;
    }
    final primary = state.goals.first;
    updateGoal(primary.id, title);
  }

  void addGoal(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return;
    }
    final goals = [
      ...state.goals,
      GoalDraft(
        id: nextGoalId(state.goals),
        title: normalized,
      ),
    ];
    state = state.copyWith(
      goals: List<GoalDraft>.unmodifiable(goals),
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
    );
  }

  void updateGoal(String id, String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return;
    }
    final goals = state.goals
        .map(
          (item) => item.id == id ? item.copyWith(title: normalized) : item,
        )
        .toList(growable: false);
    state = state.copyWith(
      goals: List<GoalDraft>.unmodifiable(goals),
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
    );
  }

  void setGoalStatus(String id, GoalDraftStatus status) {
    final goals = state.goals
        .map((item) => item.id == id ? item.copyWith(status: status) : item)
        .toList(growable: false);
    state = state.copyWith(
      goals: List<GoalDraft>.unmodifiable(goals),
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
    );
  }

  void saveMilestone(MilestoneDraft milestone) {
    state = state.copyWith(
      milestone: milestone,
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
    );
  }

  Future<void> confirmBoundary() async {
    if (!isJourneyBoundaryComplete(state)) {
      throw StateError('The local journey boundary is incomplete.');
    }
    if (state.saveStatus == LocalSaveStatus.saving) {
      return;
    }

    final snapshot = state;
    state = state.copyWith(
      saveStatus: LocalSaveStatus.saving,
      isConfirmed: false,
      clearSaveError: true,
    );

    final useCase = ref.read(confirmJourneyBoundaryProvider);
    try {
      final result = await useCase(
        ConfirmJourneyBoundaryCommand(
          direction: snapshot.direction,
          constraint: snapshot.constraint,
          domain: snapshot.domainsLabel,
          goalTitle: snapshot.goal,
          milestoneTitle: snapshot.milestone!.title,
          milestoneEvidenceRule: snapshot.milestone!.evidenceRule,
          milestoneWindow: snapshot.milestone!.window,
        ),
      );
      if (result.ok) {
        final activated = snapshot.goals
            .map(
              (item) => item.status == GoalDraftStatus.archived
                  ? item
                  : item.copyWith(status: GoalDraftStatus.active),
            )
            .toList(growable: false);
        state = state.copyWith(
          goals: List<GoalDraft>.unmodifiable(activated),
          isConfirmed: true,
          saveStatus: LocalSaveStatus.persisted,
          clearSaveError: true,
          clearDomainFocusSuggestion: true,
        );
        return;
      }
      state = state.copyWith(
        isConfirmed: false,
        saveStatus: LocalSaveStatus.failed,
        saveError: result.message ?? '写入本机失败，请重试',
      );
    } catch (_) {
      state = state.copyWith(
        isConfirmed: false,
        saveStatus: LocalSaveStatus.failed,
        saveError: '写入本机失败，请重试',
      );
    }
  }
}

final journeyControllerProvider =
    NotifierProvider<JourneyController, JourneyState>(JourneyController.new);

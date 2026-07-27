import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/app/bootstrap/persistence_providers.dart';
import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';

enum LocalSaveStatus { pendingPersistence, saving, persisted, failed }

class MilestoneDraft {
  const MilestoneDraft({
    required this.title,
    required this.evidenceRule,
    required this.window,
  });

  final String title;
  final String evidenceRule;
  final String window;
}

class JourneyState {
  const JourneyState({
    required this.direction,
    required this.constraint,
    required this.domain,
    required this.goal,
    required this.milestone,
    required this.saveStatus,
    required this.isConfirmed,
    this.saveError,
    this.isRestoring = false,
  });

  const JourneyState.initial()
      : direction = '',
        constraint = '',
        domain = '',
        goal = '',
        milestone = null,
        saveStatus = LocalSaveStatus.pendingPersistence,
        isConfirmed = false,
        saveError = null,
        isRestoring = false;

  final String direction;
  final String constraint;
  final String domain;
  final String goal;
  final MilestoneDraft? milestone;
  final LocalSaveStatus saveStatus;
  final bool isConfirmed;
  final String? saveError;
  final bool isRestoring;

  JourneyState copyWith({
    String? direction,
    String? constraint,
    String? domain,
    String? goal,
    MilestoneDraft? milestone,
    LocalSaveStatus? saveStatus,
    bool? isConfirmed,
    String? saveError,
    bool? isRestoring,
    bool clearSaveError = false,
  }) {
    return JourneyState(
      direction: direction ?? this.direction,
      constraint: constraint ?? this.constraint,
      domain: domain ?? this.domain,
      goal: goal ?? this.goal,
      milestone: milestone ?? this.milestone,
      saveStatus: saveStatus ?? this.saveStatus,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }
}

class JourneyController extends Notifier<JourneyState> {
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
      state = JourneyState(
        direction: snapshot.direction,
        constraint: snapshot.constraint,
        domain: snapshot.domain,
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
      );
    } catch (_) {
      // Keep session draft if present; mark restore failure without fake save.
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

  void selectDomain(String domain) {
    state = state.copyWith(
      domain: domain,
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
    );
  }

  void saveGoal(String goal) {
    state = state.copyWith(
      goal: goal.trim(),
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
    final complete = state.direction.isNotEmpty &&
        state.constraint.isNotEmpty &&
        state.domain.isNotEmpty &&
        state.goal.isNotEmpty &&
        state.milestone != null;
    if (!complete) {
      throw StateError('The local journey boundary is incomplete.');
    }
    if (state.saveStatus == LocalSaveStatus.saving) {
      return;
    }

    // Keep edit buffer; only claim confirmation after use-case success.
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
          domain: snapshot.domain,
          goalTitle: snapshot.goal,
          milestoneTitle: snapshot.milestone!.title,
          milestoneEvidenceRule: snapshot.milestone!.evidenceRule,
          milestoneWindow: snapshot.milestone!.window,
        ),
      );
      if (result.ok) {
        state = state.copyWith(
          isConfirmed: true,
          saveStatus: LocalSaveStatus.persisted,
          clearSaveError: true,
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

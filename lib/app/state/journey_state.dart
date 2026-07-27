import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  const JourneyState.initial()
      : direction = '',
        constraint = '',
        domain = '',
        goal = '',
        milestone = null,
        saveStatus = LocalSaveStatus.pendingPersistence,
        isConfirmed = false;

  final String direction;
  final String constraint;
  final String domain;
  final String goal;
  final MilestoneDraft? milestone;
  final LocalSaveStatus saveStatus;
  final bool isConfirmed;

  JourneyState copyWith({
    String? direction,
    String? constraint,
    String? domain,
    String? goal,
    MilestoneDraft? milestone,
    LocalSaveStatus? saveStatus,
    bool? isConfirmed,
  }) {
    return JourneyState(
      direction: direction ?? this.direction,
      constraint: constraint ?? this.constraint,
      domain: domain ?? this.domain,
      goal: goal ?? this.goal,
      milestone: milestone ?? this.milestone,
      saveStatus: saveStatus ?? this.saveStatus,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

class JourneyController extends Notifier<JourneyState> {
  @override
  JourneyState build() => const JourneyState.initial();

  void saveDirection({required String direction, required String constraint}) {
    state = state.copyWith(
      direction: direction.trim(),
      constraint: constraint.trim(),
      saveStatus: LocalSaveStatus.pendingPersistence,
      isConfirmed: false,
    );
  }

  void selectDomain(String domain) {
    state = state.copyWith(domain: domain, isConfirmed: false);
  }

  void saveGoal(String goal) {
    state = state.copyWith(goal: goal.trim(), isConfirmed: false);
  }

  void saveMilestone(MilestoneDraft milestone) {
    state = state.copyWith(milestone: milestone, isConfirmed: false);
  }

  void confirmBoundary() {
    final complete = state.direction.isNotEmpty &&
        state.constraint.isNotEmpty &&
        state.domain.isNotEmpty &&
        state.goal.isNotEmpty &&
        state.milestone != null;
    if (!complete) {
      throw StateError('The local journey boundary is incomplete.');
    }
    state = state.copyWith(
      isConfirmed: true,
      saveStatus: LocalSaveStatus.pendingPersistence,
    );
  }
}

final journeyControllerProvider =
    NotifierProvider<JourneyController, JourneyState>(JourneyController.new);

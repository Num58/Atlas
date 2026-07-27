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

class DomainSelectionResult {
  const DomainSelectionResult.accepted(this.domains)
      : focusSuggestion = null,
        accepted = true;

  const DomainSelectionResult.focusSuggestion(this.focusSuggestion)
      : domains = const <String>[],
        accepted = false;

  final bool accepted;
  final List<String> domains;
  final String? focusSuggestion;
}

class JourneyState {
  const JourneyState({
    required this.direction,
    required this.constraint,
    required this.domains,
    required this.goal,
    required this.milestone,
    required this.saveStatus,
    required this.isConfirmed,
    this.saveError,
    this.isRestoring = false,
    this.domainFocusSuggestion,
  });

  const JourneyState.initial()
      : direction = '',
        constraint = '',
        domains = const <String>[],
        goal = '',
        milestone = null,
        saveStatus = LocalSaveStatus.pendingPersistence,
        isConfirmed = false,
        saveError = null,
        isRestoring = false,
        domainFocusSuggestion = null;

  final String direction;
  final String constraint;
  final List<String> domains;
  final String goal;
  final MilestoneDraft? milestone;
  final LocalSaveStatus saveStatus;
  final bool isConfirmed;
  final String? saveError;
  final bool isRestoring;
  final String? domainFocusSuggestion;

  /// Primary domain used by current V0.2 confirm write path.
  String get domain => domains.isEmpty ? '' : domains.first;

  String get domainsLabel {
    if (domains.isEmpty) {
      return '';
    }
    return domains.join(' · ');
  }

  JourneyState copyWith({
    String? direction,
    String? constraint,
    List<String>? domains,
    String? goal,
    MilestoneDraft? milestone,
    LocalSaveStatus? saveStatus,
    bool? isConfirmed,
    String? saveError,
    bool? isRestoring,
    String? domainFocusSuggestion,
    bool clearSaveError = false,
    bool clearDomainFocusSuggestion = false,
  }) {
    return JourneyState(
      direction: direction ?? this.direction,
      constraint: constraint ?? this.constraint,
      domains: domains ?? this.domains,
      goal: goal ?? this.goal,
      milestone: milestone ?? this.milestone,
      saveStatus: saveStatus ?? this.saveStatus,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      isRestoring: isRestoring ?? this.isRestoring,
      domainFocusSuggestion: clearDomainFocusSuggestion
          ? null
          : (domainFocusSuggestion ?? this.domainFocusSuggestion),
    );
  }
}

class JourneyController extends Notifier<JourneyState> {
  static const maxActiveDomains = 3;

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
      final restoredDomains = snapshot.domain
          .split(RegExp(r'[·,]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      state = JourneyState(
        direction: snapshot.direction,
        constraint: snapshot.constraint,
        domains: restoredDomains.isEmpty
            ? <String>[snapshot.domain]
            : restoredDomains,
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

  /// Toggle/select growth domains. At most [maxActiveDomains] active.
  /// Selecting a 4th domain returns focus suggestion and does not write.
  DomainSelectionResult selectDomain(String domain) {
    final normalized = domain.trim();
    if (normalized.isEmpty) {
      return const DomainSelectionResult.focusSuggestion('成长域不能为空');
    }
    final current = [...state.domains];
    if (current.contains(normalized)) {
      current.remove(normalized);
      state = state.copyWith(
        domains: List<String>.unmodifiable(current),
        isConfirmed: false,
        saveStatus: LocalSaveStatus.pendingPersistence,
        clearSaveError: true,
        clearDomainFocusSuggestion: true,
      );
      return DomainSelectionResult.accepted(
        List<String>.unmodifiable(current),
      );
    }
    if (current.length >= maxActiveDomains) {
      final suggestion =
          '已有 $maxActiveDomains 个活跃成长域（${current.join('、')}）。'
          '请先聚焦或调整现有域，而不是继续增加第 ${maxActiveDomains + 1} 个。';
      state = state.copyWith(domainFocusSuggestion: suggestion);
      return DomainSelectionResult.focusSuggestion(suggestion);
    }
    current.add(normalized);
    state = state.copyWith(
      domains: List<String>.unmodifiable(current),
      isConfirmed: false,
      saveStatus: LocalSaveStatus.pendingPersistence,
      clearSaveError: true,
      clearDomainFocusSuggestion: true,
    );
    return DomainSelectionResult.accepted(
      List<String>.unmodifiable(current),
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
        state.domains.isNotEmpty &&
        state.goal.isNotEmpty &&
        state.milestone != null;
    if (!complete) {
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
        state = state.copyWith(
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

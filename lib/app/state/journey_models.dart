enum LocalSaveStatus { pendingPersistence, saving, persisted, failed }

enum GoalDraftStatus { draft, active, paused, archived }

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

class GoalDraft {
  const GoalDraft({
    required this.id,
    required this.title,
    this.status = GoalDraftStatus.draft,
  });

  final String id;
  final String title;
  final GoalDraftStatus status;

  GoalDraft copyWith({
    String? id,
    String? title,
    GoalDraftStatus? status,
  }) {
    return GoalDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
    );
  }
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
    required this.pausedDomains,
    required this.goals,
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
        pausedDomains = const <String>[],
        goals = const <GoalDraft>[],
        milestone = null,
        saveStatus = LocalSaveStatus.pendingPersistence,
        isConfirmed = false,
        saveError = null,
        isRestoring = false,
        domainFocusSuggestion = null;

  final String direction;
  final String constraint;
  final List<String> domains;
  final List<String> pausedDomains;
  final List<GoalDraft> goals;
  final MilestoneDraft? milestone;
  final LocalSaveStatus saveStatus;
  final bool isConfirmed;
  final String? saveError;
  final bool isRestoring;
  final String? domainFocusSuggestion;

  String get domain => domains.isEmpty ? '' : domains.first;

  String get domainsLabel {
    if (domains.isEmpty) {
      return '';
    }
    return domains.join(' · ');
  }

  String get pausedDomainsLabel {
    if (pausedDomains.isEmpty) {
      return '';
    }
    return pausedDomains.join(' · ');
  }

  /// Compatibility primary goal used by current confirm write path.
  String get goal =>
      goals.isEmpty ? '' : goals.firstWhere(
            (item) => item.status != GoalDraftStatus.archived,
            orElse: () => goals.first,
          ).title;

  String get goalsLabel {
    final visible = goals
        .where((item) => item.status != GoalDraftStatus.archived)
        .map((item) => item.title)
        .where((title) => title.trim().isNotEmpty)
        .toList(growable: false);
    if (visible.isEmpty) {
      return '';
    }
    if (visible.length == 1) {
      return visible.first;
    }
    return '${visible.first} 等 ${visible.length} 个目标';
  }

  GoalDraft? goalById(String id) {
    for (final item in goals) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  JourneyState copyWith({
    String? direction,
    String? constraint,
    List<String>? domains,
    List<String>? pausedDomains,
    List<GoalDraft>? goals,
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
      pausedDomains: pausedDomains ?? this.pausedDomains,
      goals: goals ?? this.goals,
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

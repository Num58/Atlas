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
    required this.pausedDomains,
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
        pausedDomains = const <String>[],
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
  final List<String> pausedDomains;
  final String goal;
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

  JourneyState copyWith({
    String? direction,
    String? constraint,
    List<String>? domains,
    List<String>? pausedDomains,
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
      pausedDomains: pausedDomains ?? this.pausedDomains,
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

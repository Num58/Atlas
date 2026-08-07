/// Cross-Domain Fusion type definitions (FAD / Fusion V2).
///
/// The Fusion engine discovers opportunities where growth domains reinforce
/// each other. All suggestions are advisory — the system explains WHY, the
/// user decides.
///
/// **Red-line reconciliation (FAD)**: what used to be `identityDimensions` is
/// now `observedThemeTags` — these are *observations* the user has surfaced,
/// never identity definitions. Likewise `identityReinforcement` is now
/// `themeReinforcement`: it reinforces an observed theme, it does not assign
/// or define an identity for the user.
///
/// All JSON keys are snake_case (ADR-6). No Flutter dependency.
library;

import 'package:meta/meta.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// Connection type enum — how two domains can reinforce each other.
enum ConnectionType {
  skillTransfer,
  resourceSharing,
  temporalSynergy,
  themeReinforcement,
  constraintComplement;

  String get code => switch (this) {
        ConnectionType.skillTransfer => 'skill_transfer',
        ConnectionType.resourceSharing => 'resource_sharing',
        ConnectionType.temporalSynergy => 'temporal_synergy',
        ConnectionType.themeReinforcement => 'theme_reinforcement',
        ConnectionType.constraintComplement => 'constraint_complement',
      };

  static ConnectionType fromCode(String code) => switch (code) {
        'skill_transfer' => ConnectionType.skillTransfer,
        'resource_sharing' => ConnectionType.resourceSharing,
        'temporal_synergy' => ConnectionType.temporalSynergy,
        'theme_reinforcement' => ConnectionType.themeReinforcement,
        'constraint_complement' => ConnectionType.constraintComplement,
        _ => throw ArgumentError('Unknown ConnectionType code: $code'),
      };
}

/// A growth domain snapshot — lightweight input to the fusion engine.
///
/// This is a local type; the full domain model lives elsewhere.
@immutable
class GrowthDomain {
  final String code;
  final String name;
  final double progress;
  final List<String> activeGoalCodes;
  /// Observed theme tags surfaced for this domain.
  ///
  /// **Observation, not identity.** These are themes the user has shown
  /// interest in / exhibited — the system never uses them to *define* who
  /// the user is. They feed cross-domain fusion only.
  final List<String> observedThemeTags;

  const GrowthDomain({
    required this.code,
    required this.name,
    this.progress = 0.0,
    this.activeGoalCodes = const [],
    this.observedThemeTags = const [],
  }) : assert(progress >= 0.0 && progress <= 1.0);

  Map<String, Object?> toJson() => {
        'code': code,
        'name': name,
        'progress': progress,
        'active_goal_codes': activeGoalCodes,
        'observed_theme_tags': observedThemeTags,
      };

  static GrowthDomain fromJson(Map<String, Object?> json) => GrowthDomain(
        code: json['code'] as String,
        name: json['name'] as String,
        progress: (json['progress'] as num).toDouble(),
        activeGoalCodes:
            (json['active_goal_codes'] as List?)?.cast<String>() ?? const [],
        observedThemeTags: (json['observed_theme_tags'] as List?)
                ?.cast<String>() ??
            const [],
      );
}

/// A pair of domains with a compatibility assessment.
@immutable
class DomainPair {
  final String domainA;
  final String domainB;
  final double compatibilityScore;

  const DomainPair({
    required this.domainA,
    required this.domainB,
    required this.compatibilityScore,
  }) : assert(compatibilityScore >= 0.0 && compatibilityScore <= 1.0);

  Map<String, Object?> toJson() => {
        'domain_a': domainA,
        'domain_b': domainB,
        'compatibility_score': compatibilityScore,
      };

  static DomainPair fromJson(Map<String, Object?> json) => DomainPair(
        domainA: json['domain_a'] as String,
        domainB: json['domain_b'] as String,
        compatibilityScore: (json['compatibility_score'] as num).toDouble(),
      );
}

/// A fusion opportunity — a discovered cross-domain connection.
@immutable
class FusionOpportunity {
  final List<String> domainsInvolved;
  final ConnectionType connectionType;
  final double strength;
  final String description;
  final List<String> evidenceRefs;
  /// Observed themes that ground this opportunity (only for
  /// [ConnectionType.themeReinforcement]). Empty for other connection types.
  final List<String> observedThemes;
  /// Advisory tone hint for expressing this opportunity. Null when no tone is
  /// implied. Never forces a tone on the user.
  final ToneId? toneHint;

  const FusionOpportunity({
    required this.domainsInvolved,
    required this.connectionType,
    required this.strength,
    required this.description,
    this.evidenceRefs = const [],
    this.observedThemes = const [],
    this.toneHint,
  })  : assert(strength >= 0.0 && strength <= 1.0),
       assert(domainsInvolved.length >= 2);

  Map<String, Object?> toJson() => {
        'domains_involved': domainsInvolved,
        'connection_type': connectionType.code,
        'strength': strength,
        'description': description,
        'evidence_refs': evidenceRefs,
        'observed_themes': observedThemes,
        'tone_hint': toneHint?.code,
      };

  static FusionOpportunity fromJson(Map<String, Object?> json) =>
      FusionOpportunity(
        domainsInvolved:
            (json['domains_involved'] as List).cast<String>(),
        connectionType:
            ConnectionType.fromCode(json['connection_type'] as String),
        strength: (json['strength'] as num).toDouble(),
        description: json['description'] as String,
        evidenceRefs: (json['evidence_refs'] as List?)
                ?.cast<String>() ??
            const [],
        observedThemes: (json['observed_themes'] as List?)
                ?.cast<String>() ??
            const [],
        toneHint: json['tone_hint'] == null
            ? null
            : ToneId.fromCode(json['tone_hint'] as String),
      );
}

/// A fusion rule — condition pattern to suggestion mapping.
@immutable
class FusionRule {
  final String conditionPattern;
  final String suggestion;
  final int priority;

  const FusionRule({
    required this.conditionPattern,
    required this.suggestion,
    this.priority = 0,
  });

  Map<String, Object?> toJson() => {
        'condition_pattern': conditionPattern,
        'suggestion': suggestion,
        'priority': priority,
      };

  static FusionRule fromJson(Map<String, Object?> json) => FusionRule(
        conditionPattern: json['condition_pattern'] as String,
        suggestion: json['suggestion'] as String,
        priority: json['priority'] as int,
      );
}

/// The result of applying a fusion opportunity.
@immutable
class FusionResult {
  final int opportunitiesFound;
  final int appliedCount;
  final int skippedCount;
  final String reasoning;

  const FusionResult({
    required this.opportunitiesFound,
    required this.appliedCount,
    required this.skippedCount,
    required this.reasoning,
  });

  Map<String, Object?> toJson() => {
        'opportunities_found': opportunitiesFound,
        'applied_count': appliedCount,
        'skipped_count': skippedCount,
        'reasoning': reasoning,
      };

  static FusionResult fromJson(Map<String, Object?> json) => FusionResult(
        opportunitiesFound: json['opportunities_found'] as int,
        appliedCount: json['applied_count'] as int,
        skippedCount: json['skipped_count'] as int,
        reasoning: json['reasoning'] as String,
      );
}

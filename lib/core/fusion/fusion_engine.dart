import 'package:meta/meta.dart';
import 'package:primeatlas/core/fusion/fusion_types.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// Cross-Domain Fusion Engine (FAD / Fusion V2).
///
/// Discovers opportunities where growth domains reinforce each other.
///
/// **Key principle**: Fusion suggestions are advisory. The system explains
/// WHY it suggests, the user decides. No fusion is forced.
///
/// **Evidence source (P-RL1)**: fusion reads the portrait's *active* axes as
/// its evidence source. Axes that are not active (`PortraitAxis.active ==
/// false`) never enter the analysis. When two domains share an *observed*
/// theme, that theme only counts as a reinforcement signal if it is also an
/// active axis — inactive (observed-but-not-rendered) themes are filtered out.
@immutable
class FusionEngine {
  final List<FusionRule> rules;

  const FusionEngine({this.rules = const []});

  /// Discovers cross-domain fusion opportunities.
  ///
  /// [portrait] supplies the evidence source (active axes). [activeDomains]
  /// are the domains currently in play. Pure function — no I/O, no side
  /// effects.
  List<FusionOpportunity> discover(
    PortraitSnapshot portrait,
    List<GrowthDomain> activeDomains,
  ) {
    if (activeDomains.length < 2) return const [];

    // P-RL1: only active axes are eligible evidence.
    final activeAxisIds = portrait.activeAxes
        .where((a) => a.active)
        .map((a) => a.id)
        .toSet();

    final opportunities = <FusionOpportunity>[];
    for (var i = 0; i < activeDomains.length; i++) {
      for (var j = i + 1; j < activeDomains.length; j++) {
        final a = activeDomains[i];
        final b = activeDomains[j];
        final pair = _analyzePair(a, b, activeAxisIds);
        if (pair != null) opportunities.add(pair);
      }
    }

    // Sort by strength descending.
    opportunities.sort((a, b) => b.strength.compareTo(a.strength));
    return opportunities;
  }

  /// Applies a fusion opportunity (advisory only).
  ///
  /// Returns a result indicating the outcome. Application is advisory — it
  /// records the suggestion but does not force any changes.
  FusionResult apply(FusionOpportunity opportunity) {
    final reasoning = _buildReasoning(opportunity);
    return FusionResult(
      opportunitiesFound: 1,
      appliedCount: 1,
      skippedCount: 0,
      reasoning: reasoning,
    );
  }

  // ---- Private helpers ----

  FusionOpportunity? _analyzePair(
    GrowthDomain a,
    GrowthDomain b,
    Set<String> activeAxisIds,
  ) {
    // Theme reinforcement — shared OBSERVED themes that are also active axes.
    // Observation, not identity: we never define who the user is.
    final shared = a.observedThemeTags.toSet()
        .intersection(b.observedThemeTags.toSet());
    final evidenced = shared.intersection(activeAxisIds);

    if (evidenced.isNotEmpty) {
      return FusionOpportunity(
        domainsInvolved: [a.code, b.code],
        connectionType: ConnectionType.themeReinforcement,
        strength: _computeStrength(a.progress, b.progress),
        description:
            'Domains ${a.code} and ${b.code} show overlapping observed '
            'themes: ${evidenced.join(', ')}. These are observations, not '
            'identity definitions — progressing both may reinforce them.',
        evidenceRefs: evidenced.toList(),
        observedThemes: evidenced.toList(),
        toneHint: ToneId.warm,
      );
    }

    // Skill transfer — if one domain is ahead, skill may transfer.
    final progressDiff = (a.progress - b.progress).abs();
    if (progressDiff > 0.3) {
      final ahead = a.progress > b.progress ? a : b;
      final behind = a.progress > b.progress ? b : a;
      return FusionOpportunity(
        domainsInvolved: [a.code, b.code],
        connectionType: ConnectionType.skillTransfer,
        strength: progressDiff * 0.5,
        description:
            'Domain ${ahead.code} is ahead (${ahead.progress.toStringAsFixed(2)}) '
            'of ${behind.code} (${behind.progress.toStringAsFixed(2)}). '
            'Skills and momentum may transfer.',
        evidenceRefs: ['progress_diff:$progressDiff'],
        observedThemes: const [],
        toneHint: ToneId.encouraging,
      );
    }

    // Constraint complement — an early-stage domain can provide focus for an
    // advanced one.
    if (a.progress < 0.3 && b.progress > 0.6) {
      return FusionOpportunity(
        domainsInvolved: [a.code, b.code],
        connectionType: ConnectionType.constraintComplement,
        strength: 0.3,
        description:
            'Domain ${a.code} is in early stage while ${b.code} is advanced. '
            'The constraint of ${a.code} can provide focus for ${b.code}.',
        evidenceRefs: ['progress_a:${a.progress}', 'progress_b:${b.progress}'],
        observedThemes: const [],
        toneHint: ToneId.warm,
      );
    }

    // Resource sharing — domains with overlapping goals.
    final sharedGoals =
        a.activeGoalCodes.toSet().intersection(b.activeGoalCodes.toSet());
    if (sharedGoals.isNotEmpty) {
      return FusionOpportunity(
        domainsInvolved: [a.code, b.code],
        connectionType: ConnectionType.resourceSharing,
        strength: 0.4,
        description:
            'Domains ${a.code} and ${b.code} share goals: '
            '${sharedGoals.join(', ')}. Resources can be shared.',
        evidenceRefs: sharedGoals.toList(),
        observedThemes: const [],
        toneHint: ToneId.professional,
      );
    }

    // Temporal synergy — both domains active at similar progress.
    if (a.progress > 0.3 &&
        b.progress > 0.3 &&
        (a.progress - b.progress).abs() < 0.15) {
      return FusionOpportunity(
        domainsInvolved: [a.code, b.code],
        connectionType: ConnectionType.temporalSynergy,
        strength: 0.35,
        description:
            'Domains ${a.code} and ${b.code} are at similar progress levels. '
            'Practicing them in sequence may create temporal synergy.',
        evidenceRefs: [
          'progress_a:${a.progress}',
          'progress_b:${b.progress}',
        ],
        observedThemes: const [],
        toneHint: ToneId.professional,
      );
    }

    return null;
  }

  double _computeStrength(double progressA, double progressB) {
    // Higher combined progress = stronger reinforcement signal.
    final combined = (progressA + progressB) / 2;
    return (combined * 0.6).clamp(0.0, 1.0);
  }

  String _buildReasoning(FusionOpportunity opp) {
    return 'Fusion suggestion for ${opp.domainsInvolved.join(' + ')}: '
        '${opp.connectionType.code} (strength: '
        '${opp.strength.toStringAsFixed(2)}). ${opp.description}';
  }
}

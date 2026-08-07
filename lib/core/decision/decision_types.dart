/// FAD 决策组合层 —— 类型定义（Route C 三引擎 + safety + fusion + agents 的组合消费）。
///
/// 本文件不依赖 `package:flutter`，可被纯 Dart 单测覆盖。
///
/// **红线重申**：
/// - 身份相关 observe-only：本层只读 `PortraitSnapshot.activeAxes` 作为融合证据源，
///   绝不定义/贴标签用户身份。
/// - C-RL1：`safety_blocked` 是“决策流水闭合”的失败码，但**绝不硬阻断用户目标**——
///   失败详情中始终携带 `blocked_user: false` 与替代路径，用户保留执行自主权。
/// - 字段名与序列化键一律 snake_case（ADR-6）。
library;

import 'package:meta/meta.dart';
import 'package:primeatlas/core/agents/agent_types.dart'
    hide ProposedAction;
import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/common/owner_id.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';
import 'package:primeatlas/core/fusion/fusion_types.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/safety/safety_types.dart' hide ProposedAction;
import 'package:primeatlas/core/tone/tone_types.dart';

/// ===========================================================================
/// 决策失败码（FAD 决策组合层）。
///
/// 与 `DomainFailure.code` 对齐，供 [DecisionOrchestrator.runDecision] 的
/// `Result<DecisionOutcome>` 失败分支使用。
/// ===========================================================================
abstract class DecisionFailures {
  /// 安全硬阻断（C-RL1）：决策流水闭合，但**不阻断用户目标**。
  ///
  /// 详情中始终附带 `blocked_user: false` 与替代路径，用户可自行决定是否执行。
  static DomainFailure safetyBlocked({
    required List<String> warnings,
    required List<String> alternatives,
  }) =>
      DomainFailure(
        code: 'safety_blocked',
        retryable: false,
        messageKey: 'decision.safety_blocked',
        details: <String, Object?>{
          'blocked_user': false,
          'warnings': warnings,
          'alternative_paths': alternatives,
          'max_severity': 'block',
        },
      );

  /// 数据不足：缺少形成决策所需的证据（如无激活域 / 无激活画像轴）。
  static const DomainFailure dataInsufficient = DomainFailure(
    code: 'data_insufficient',
    retryable: false,
    messageKey: 'decision.data_insufficient',
  );

  /// 冲突未决：检测到日程冲突且未经用户仲裁，系统暂不自动批准。
  ///
  /// 注意：依据 C-RL1 冲突本身不硬阻断用户；此处仅表示自动化决策无法给出，
  /// 用户仍可在仲裁后自行执行。
  static DomainFailure conflictUnresolved({List<String> conflictIds = const []}) =>
      DomainFailure(
        code: 'conflict_unresolved',
        retryable: false,
        messageKey: 'decision.conflict_unresolved',
        details: <String, Object?>{'conflict_ids': conflictIds},
      );
}

/// 决策成功路径的状态（失败路径由 [DecisionFailures] 的失败码表达）。
enum DecisionStatus {
  approved,
  caution;

  String get code => name;

  static DecisionStatus fromCode(String code) =>
      code == 'caution' ? DecisionStatus.caution : DecisionStatus.approved;
}

/// 决策依据来源（用于在 UI 中分色展示证据链）。
enum DecisionEvidenceSource {
  safety,
  conflict,
  fusion,
  agents,
  tone;

  String get label => switch (this) {
        DecisionEvidenceSource.safety => '安全',
        DecisionEvidenceSource.conflict => '冲突',
        DecisionEvidenceSource.fusion => '融合',
        DecisionEvidenceSource.agents => '多 Agent',
        DecisionEvidenceSource.tone => '调性',
      };
}

/// 单条决策依据（证据链的最小单元）。
@immutable
class DecisionEvidenceItem {
  final DecisionEvidenceSource source;
  final String label;
  final String detail;

  const DecisionEvidenceItem({
    required this.source,
    required this.label,
    required this.detail,
  });

  Map<String, Object?> toJson() => {
        'source': source.name,
        'label': label,
        'detail': detail,
      };

  static DecisionEvidenceItem fromJson(Map<String, Object?> json) =>
      DecisionEvidenceItem(
        source: DecisionEvidenceSource.values.firstWhere(
          (e) => e.name == json['source'],
          orElse: () => DecisionEvidenceSource.agents,
        ),
        label: json['label'] as String,
        detail: json['detail'] as String,
      );
}

/// 决策组合层的“提案动作”。
///
/// 这是本层对 action 的规范表达，字段足以映射到：
/// - safety 引擎的 [SafetyProposedAction]（domain / intensity / durationMin / scheduledAtUs）；
/// - agents 编排器的 [AgentProposedAction]（actionType / description / parameters）。
@immutable
class ProposedAction {
  final String actionType;
  final String description;
  final String domain;
  final int intensity;
  final int durationMin;
  final int scheduledAtUs;
  final Map<String, Object?> parameters;

  const ProposedAction({
    required this.actionType,
    required this.description,
    this.domain = '',
    this.intensity = 0,
    this.durationMin = 0,
    required this.scheduledAtUs,
    this.parameters = const {},
  }) : assert(intensity >= 0 && intensity <= 100);

  Map<String, Object?> toJson() => {
        'action_type': actionType,
        'description': description,
        'domain': domain,
        'intensity': intensity,
        'duration_min': durationMin,
        'scheduled_at_us': scheduledAtUs,
        'parameters': parameters,
      };

  static ProposedAction fromJson(Map<String, Object?> json) => ProposedAction(
        actionType: json['action_type'] as String,
        description: json['description'] as String? ?? '',
        domain: json['domain'] as String? ?? '',
        intensity: json['intensity'] as int? ?? 0,
        durationMin: json['duration_min'] as int? ?? 0,
        scheduledAtUs: json['scheduled_at_us'] as int,
        parameters:
            (json['parameters'] as Map?)?.cast<String, Object?>() ?? const {},
      );
}

/// 决策上下文：承载各引擎所需的输入证据（不持有任何引擎实例）。
@immutable
class DecisionContext {
  final OwnerId ownerId;
  final PortraitSnapshot portrait;
  final List<GrowthDomain> activeDomains;
  final List<ScheduledItem> scheduledItems;
  final SafetyContext safetyContext;
  final ToneState currentToneState;
  final DateTime now;

  const DecisionContext({
    required this.ownerId,
    required this.portrait,
    required this.activeDomains,
    required this.scheduledItems,
    required this.safetyContext,
    required this.currentToneState,
    required this.now,
  });
}

/// 决策结果：组合消费 safety / conflict / fusion / agents / tone 后的完整依据。
///
/// 始终携带 `evidenceChain`，供 `fusion_evidence_chain.dart` 透明展示“为什么”。
@immutable
class DecisionOutcome {
  final DecisionStatus status;
  final String summary;
  final SafetyStatus safetyStatus;
  final List<String> safetyWarnings;
  final List<String> safetyAlternatives;
  final List<FusionOpportunity> fusionOpportunities;
  final List<AgentDecision> agentDecisions;
  final AgentDecision? agentResolution;
  final ToneId recommendedTone;
  final List<DecisionEvidenceItem> evidenceChain;
  final DateTime decidedAt;

  const DecisionOutcome({
    required this.status,
    required this.summary,
    required this.safetyStatus,
    this.safetyWarnings = const [],
    this.safetyAlternatives = const [],
    this.fusionOpportunities = const [],
    this.agentDecisions = const [],
    this.agentResolution,
    required this.recommendedTone,
    this.evidenceChain = const [],
    required this.decidedAt,
  });

  Map<String, Object?> toJson() => {
        'status': status.code,
        'summary': summary,
        'safety_status': safetyStatus.code,
        'safety_warnings': safetyWarnings,
        'safety_alternatives': safetyAlternatives,
        'fusion_opportunities':
            fusionOpportunities.map((o) => o.toJson()).toList(),
        'agent_decisions': agentDecisions.map((d) => d.toJson()).toList(),
        'agent_resolution': agentResolution?.toJson(),
        'recommended_tone': recommendedTone.code,
        'evidence_chain': evidenceChain.map((e) => e.toJson()).toList(),
        'decided_at': decidedAt.microsecondsSinceEpoch,
      };

  static DecisionOutcome fromJson(Map<String, Object?> json) =>
      DecisionOutcome(
        status: DecisionStatus.fromCode(json['status'] as String? ?? 'approved'),
        summary: json['summary'] as String? ?? '',
        safetyStatus: SafetyStatus.fromCode(
            json['safety_status'] as String? ?? 'clear'),
        safetyWarnings: (json['safety_warnings'] as List?)
                ?.cast<String>() ??
            const [],
        safetyAlternatives: (json['safety_alternatives'] as List?)
                ?.cast<String>() ??
            const [],
        fusionOpportunities: (json['fusion_opportunities'] as List?)
                ?.map((e) =>
                    FusionOpportunity.fromJson(e as Map<String, Object?>))
                .toList() ??
            const [],
        agentDecisions: (json['agent_decisions'] as List?)
                ?.map((e) => AgentDecision.fromJson(e as Map<String, Object?>))
                .toList() ??
            const [],
        agentResolution: json['agent_resolution'] == null
            ? null
            : AgentDecision.fromJson(
                json['agent_resolution'] as Map<String, Object?>),
        recommendedTone:
            ToneId.fromCode(json['recommended_tone'] as String? ?? 'professional'),
        evidenceChain: (json['evidence_chain'] as List?)
                ?.map((e) =>
                    DecisionEvidenceItem.fromJson(e as Map<String, Object?>))
                .toList() ??
            const [],
        decidedAt: DateTime.fromMicrosecondsSinceEpoch(
            json['decided_at'] as int? ?? 0),
      );
}

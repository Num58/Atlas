/// `fusion_opportunity_event` —— 跨域融合机会事件（append-only）。
///
/// 在决策组合层发现融合机会后发出，记录涉及的域、连接类型、强度、观察主题
/// 与建议调性。写入现有 `events` 表（append-only），不新增 SQLite 表。
///
/// **红线**：`observed_themes` 仅为观察信号，绝不用于定义/贴附用户身份标签。
library;

import 'package:primeatlas/core/fusion/fusion_types.dart';
import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// 跨域融合机会事件载体。
class FusionOpportunityEvent implements EventPayload {
  static const String eventType = 'fusion_opportunity_event';

  final String ownerId;
  final List<String> domainCodes;
  final ConnectionType connectionType;
  final double strength;
  final List<String> observedThemes;
  final ToneId? toneHint;
  final String description;
  final int decidedAtUs;

  const FusionOpportunityEvent({
    required this.ownerId,
    required this.domainCodes,
    required this.connectionType,
    required this.strength,
    required this.observedThemes,
    this.toneHint,
    required this.description,
    required this.decidedAtUs,
  }) : assert(strength >= 0.0 && strength <= 1.0);

  @override
  Map<String, Object?> toJson() => {
        'owner_id': ownerId,
        'domain_codes': domainCodes,
        'connection_type': connectionType.code,
        'strength': strength,
        'observed_themes': observedThemes,
        'tone_hint': toneHint?.code,
        'description': description,
        'decided_at_us': decidedAtUs,
      };

  factory FusionOpportunityEvent.fromJson(Map<String, Object?> json) {
    return FusionOpportunityEvent(
      ownerId: json['owner_id'] as String,
      domainCodes: (json['domain_codes'] as List).cast<String>(),
      connectionType:
          ConnectionType.fromCode(json['connection_type'] as String),
      strength: (json['strength'] as num).toDouble(),
      observedThemes: (json['observed_themes'] as List?)?.cast<String>() ??
          const [],
      toneHint: json['tone_hint'] == null
          ? null
          : ToneId.fromCode(json['tone_hint'] as String),
      description: json['description'] as String,
      decidedAtUs: json['decided_at_us'] as int,
    );
  }
}

/// 校验器：保证 `fusion_opportunity_event` 结构合法且枚举受控。
class FusionOpportunityEventValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! FusionOpportunityEvent) {
      return ValidationResult.failed([
        'payload is not a FusionOpportunityEvent (got ${payload.runtimeType})'
      ]);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    checkString(json, errors, 'owner_id');
    checkString(json, errors, 'description');
    checkEnumValue(json, errors, 'connection_type', const [
      'skill_transfer',
      'resource_sharing',
      'temporal_synergy',
      'theme_reinforcement',
      'constraint_complement',
    ]);
    checkNullableString(json, errors, 'tone_hint');
    if (json['domain_codes'] is! List) {
      errors.add('field "domain_codes" must be List');
    }
    if (json['observed_themes'] is! List) {
      errors.add('field "observed_themes" must be List');
    }
    if (json['strength'] is! num) {
      errors.add('field "strength" must be num');
    } else {
      final s = (json['strength'] as num).toDouble();
      if (s < 0.0 || s > 1.0) {
        errors.add('field "strength" must be in [0,1]');
      }
    }
    if (json['decided_at_us'] is! int) {
      errors.add('field "decided_at_us" must be int');
    }
    if (errors.isNotEmpty) return ValidationResult.failed(errors);
    return const ValidationResult.ok();
  }
}

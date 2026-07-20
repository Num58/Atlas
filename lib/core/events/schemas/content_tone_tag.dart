import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

/// Layer at which a content tone tag is applied (T-RL2). */
enum ContentLayer { copy, visual, interaction, push }

class ContentToneTag implements EventPayload {
  static const String eventType = 'content_tone_tag';

  final Tone session_anchor_tone;
  final Tone resolved_tone;
  final ContentLayer layer; // copy | visual | interaction | push
  final bool consistent_with_anchor;

  const ContentToneTag({
    required this.session_anchor_tone,
    required this.resolved_tone,
    required this.layer,
    required this.consistent_with_anchor,
  });

  @override
  Map<String, Object?> toJson() => {
        'session_anchor_tone': session_anchor_tone.name,
        'resolved_tone': resolved_tone.name,
        'layer': layer.name,
        'consistent_with_anchor': consistent_with_anchor,
      };

  factory ContentToneTag.fromJson(Map<String, Object?> json) {
    return ContentToneTag(
      session_anchor_tone:
          Tone.values.byName(json['session_anchor_tone'] as String),
      resolved_tone: Tone.values.byName(json['resolved_tone'] as String),
      layer: ContentLayer.values.byName(json['layer'] as String),
      consistent_with_anchor: json['consistent_with_anchor'] as bool,
    );
  }
}

class ContentToneTagValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! ContentToneTag) {
      return ValidationResult.failed(
          ['payload is not a ContentToneTag (got ${payload.runtimeType})']);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    checkString(json, errors, 'session_anchor_tone');
    checkString(json, errors, 'resolved_tone');
    checkString(json, errors, 'layer');
    checkBool(json, errors, 'consistent_with_anchor');
    checkEnumValue(json, errors, 'session_anchor_tone',
        Tone.values.map((e) => e.name));
    checkEnumValue(
        json, errors, 'resolved_tone', Tone.values.map((e) => e.name));
    checkEnumValue(json, errors, 'layer', ContentLayer.values.map((e) => e.name));
    if (errors.isNotEmpty) return ValidationResult.failed(errors);
    return const ValidationResult.ok();
  }
}

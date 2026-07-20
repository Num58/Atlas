import 'package:primeatlas/core/events/event_payload.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/validator.dart';

/// Track chosen during arbitration (C-RL2).
enum ChosenTrack { oneClickAdopt, iWillDoIt }

extension ChosenTrackX on ChosenTrack {
  String get code => switch (this) {
        ChosenTrack.oneClickAdopt => 'one_click_adopt',
        ChosenTrack.iWillDoIt => 'i_will_do_it',
      };
  static ChosenTrack fromCode(String code) => switch (code) {
        'one_click_adopt' => ChosenTrack.oneClickAdopt,
        'i_will_do_it' => ChosenTrack.iWillDoIt,
        _ => throw FormatException('unknown ChosenTrack code: $code'),
      };
}

/// `arbitration_event` — emitted when the user resolves a conflict (C-RL2).
class ArbitrationEvent implements EventPayload {
  static const String eventType = 'arbitration_event';

  final String conflict_id;
  final ChosenTrack chosen_track;
  final bool rationale_display_complete; // C-RL2 transparency
  final bool retained_override_entry; // C-RL2 keep "I'll do it" entry
  final String? user_initiated_edit; // required when chosen_track == iWillDoIt

  const ArbitrationEvent({
    required this.conflict_id,
    required this.chosen_track,
    required this.rationale_display_complete,
    required this.retained_override_entry,
    this.user_initiated_edit,
  });

  @override
  Map<String, Object?> toJson() => {
        'conflict_id': conflict_id,
        'chosen_track': chosen_track.code,
        'rationale_display_complete': rationale_display_complete,
        'retained_override_entry': retained_override_entry,
        'user_initiated_edit': user_initiated_edit,
      };

  factory ArbitrationEvent.fromJson(Map<String, Object?> json) {
    return ArbitrationEvent(
      conflict_id: json['conflict_id'] as String,
      chosen_track: ChosenTrackX.fromCode(json['chosen_track'] as String),
      rationale_display_complete:
          json['rationale_display_complete'] as bool,
      retained_override_entry: json['retained_override_entry'] as bool,
      user_initiated_edit: json['user_initiated_edit'] as String?,
    );
  }
}

class ArbitrationEventValidator implements Validator {
  @override
  ValidationResult validate(EventPayload payload) {
    if (payload is! ArbitrationEvent) {
      return ValidationResult.failed(
          ['payload is not an ArbitrationEvent (got ${payload.runtimeType})']);
    }
    return validateMap(payload.toJson());
  }

  ValidationResult validateMap(Map<String, Object?> json) {
    final errors = <String>[];
    checkString(json, errors, 'conflict_id');
    checkString(json, errors, 'chosen_track');
    checkBool(json, errors, 'rationale_display_complete');
    checkBool(json, errors, 'retained_override_entry');
    checkNullableString(json, errors, 'user_initiated_edit');
    checkEnumValue(json, errors, 'chosen_track',
        const ['one_click_adopt', 'i_will_do_it']);

    // C-RL2: choosing "I'll do it" must carry an explicit edit.
    if (json['chosen_track'] == 'i_will_do_it') {
      final edit = json['user_initiated_edit'];
      if (edit == null || (edit is String && edit.isEmpty)) {
        errors.add(
            'C-RL2: chosen_track=i_will_do_it requires non-empty user_initiated_edit');
      }
    }
    if (errors.isNotEmpty) return ValidationResult.failed(errors);
    return const ValidationResult.ok();
  }
}

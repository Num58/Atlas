import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/events/schemas/arbitration_event.dart';
import 'package:primeatlas/core/events/schemas/conflict_detected.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/events/schemas/content_tone_tag.dart';
import 'package:primeatlas/core/events/schemas/dimension_data_presence.dart';
import 'package:primeatlas/core/events/schemas/identity_transition_event.dart';
import 'package:primeatlas/core/events/schemas/profile_field_update.dart';
import 'package:primeatlas/core/events/schemas/tone_change_event.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';
import 'package:primeatlas/core/tone/tone_types.dart';

void main() {
  group('Validator 100% rejection', () {
    test('(a) every schema validator rejects a missing required field',
        () {
      final cases = <ValidationResult>[
        ToneChangeEventValidator()
            .validateMap({'to_tone': 'warm', 'trigger': 'user_explicit', 'blocked_by_system': false}),
        ContentToneTagValidator().validateMap({
          'session_anchor_tone': 'professional',
          'resolved_tone': 'warm',
          'layer': 'copy'
        }),
        ConflictDetectedValidator().validateMap({
          'conflict_type': 'goal_goal',
          'is_body_related': false,
          'disposition': {'blocked_user': false},
          'recommended_orchestration': {
            'type': 'defer',
            'rationale': 'r',
            'safety_channel_required': false
          }
        }),
        ArbitrationEventValidator().validateMap({
          'chosen_track': 'one_click_adopt',
          'rationale_display_complete': true,
          'retained_override_entry': true
        }),
        ProfileFieldUpdateValidator().validateMap({
          'confirm_source': 'user_explicit',
          'consent_record_id': 'consent1',
          'portrait_version': 'v1'
        }),
        IdentityTransitionEventValidator().validateMap({
          'from_role': 'initiate',
          'to_role': 'practitioner',
          'has_narratable_change': true,
          'narrative_shown': true
        }),
        DimensionDataPresenceValidator()
            .validateMap({'dimension': 'd', 'is_active': true, 'rendered': true}),
      ];
      for (final r in cases) {
        expect(r.valid, isFalse, reason: 'expected rejection for missing field');
      }
    });

    test('(b) every schema validator rejects a wrong-typed payload', () {
      // Pass a ContentToneTag where each validator expects its own type.
      const wrong = ContentToneTag(
        session_anchor_tone: Tone.professional,
        resolved_tone: Tone.warm,
        layer: ContentLayer.copy,
        consistent_with_anchor: true,
      );
      expect(ToneChangeEventValidator().validate(wrong).valid, isFalse);
      expect(ContentToneTagValidator().validate(wrong).valid, isTrue);
      expect(ConflictDetectedValidator().validate(wrong).valid, isFalse);
      expect(ArbitrationEventValidator().validate(wrong).valid, isFalse);
      expect(ProfileFieldUpdateValidator().validate(wrong).valid, isFalse);
      expect(IdentityTransitionEventValidator().validate(wrong).valid, isFalse);
      expect(DimensionDataPresenceValidator().validate(wrong).valid, isFalse);
    });

    test('(c) ConflictDetected rejected when disposition.blocked_user == true',
        () {
      final json = {
        'conflict_id': 'c1',
        'conflict_type': 'goal_goal',
        'is_body_related': false,
        'disposition': {'blocked_user': true}, // C-RL1 violation
        'recommended_orchestration': {
          'type': 'defer',
          'rationale': 'r',
          'safety_channel_required': false
        }
      };
      final r = ConflictDetectedValidator().validateMap(json);
      expect(r.valid, isFalse);
      expect(r.errors, contains(contains('C-RL1')));
    });

    test('(d) ArbitrationEvent rejected when i_will_do_it without edit', () {
      const typed = ArbitrationEvent(
        conflict_id: 'c1',
        chosen_track: ChosenTrack.iWillDoIt,
        rationale_display_complete: true,
        retained_override_entry: true,
        user_initiated_edit: null,
      );
      expect(ArbitrationEventValidator().validate(typed).valid, isFalse);

      final viaJson = ArbitrationEventValidator().validateMap({
        'conflict_id': 'c1',
        'chosen_track': 'i_will_do_it',
        'rationale_display_complete': true,
        'retained_override_entry': true,
        'user_initiated_edit': ''
      });
      expect(viaJson.valid, isFalse);
    });

    test('valid payloads pass (sanity)', () {
      const c = ConflictDetected(
        conflict_id: 'c1',
        conflict_type: ConflictType.goalGoal,
        is_body_related: false,
        disposition: Disposition(blockedUser: false),
        recommended_orchestration: Orchestration(
          type: OrchestrationType.defer,
          rationale: 'r',
          safetyChannelRequired: false,
        ),
      );
      expect(ConflictDetectedValidator().validate(c).valid, isTrue);
    });
  });
}

// PrimeAtlas — `lib/core` public surface (barrel).
//
// Re-exports everything owned by the event-bus / storage / sync layer (S0,
// TRK-M0-INFRA) plus the engine module contracts owned by sibling teammates
// (T2-1 / C1-1 / P3-1). No `package:flutter` is imported anywhere here; the
// whole barrel compiles and unit-tests under plain Dart.

// ---- Events (TRK-M0-INFRA) ----
export 'events/event_payload.dart';
export 'events/event_receipt.dart';
export 'events/validator.dart';
export 'events/identity_event_bus.dart';
export 'events/dashboard.dart';
export 'events/schemas/tone_change_event.dart';
export 'events/schemas/content_tone_tag.dart';
export 'events/schemas/conflict_detected.dart';
export 'events/schemas/arbitration_event.dart';
export 'events/schemas/profile_field_update.dart';
export 'events/schemas/identity_transition_event.dart';
export 'events/schemas/dimension_data_presence.dart';

// ---- Storage ----
export 'storage/event_log_repository.dart';
export 'storage/portrait_repository.dart';
export 'storage/in_memory_event_log.dart';
export 'storage/in_memory_portrait.dart';
export 'storage/sqlite/sqlite_event_log.dart';
export 'storage/sqlite/sqlite_portrait.dart';

// ---- Sync ----
export 'sync/sync_adapter.dart';

// ---- Engine module contracts (owned by sibling teammates) ----
export 'tone/tone_types.dart';
export 'tone/tone_engine.dart';
export 'tone/tone_state_machine.dart';
export 'conflict/conflict_types.dart';
export 'conflict/conflict_engine.dart';
export 'portrait/portrait_types.dart';
export 'portrait/portrait_engine.dart';

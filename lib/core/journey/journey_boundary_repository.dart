import 'journey_boundary.dart';

/// Owner-scoped persistence contract for journey boundary confirmation.
/// Implementations must keep direction/constraint in answers_json/snapshot_json
/// and must never encode role/persona identity labels.
abstract interface class JourneyBoundaryRepository {
  /// Atomically confirms a complete journey boundary for [command.ownerId].
  /// Same operation_id + same payload must replay the stored result.
  ConfirmedJourneyBoundary confirm(ConfirmJourneyBoundaryCommand command);

  /// Returns the latest active confirmed boundary for [ownerId], or null.
  ConfirmedJourneyBoundary? loadLatestConfirmed(String ownerId);
}

import 'package:primeatlas/core/events/event_receipt.dart';
import 'event_log_repository.dart';

/// Default in-memory [EventLogRepository] used by tests and the default bus.
/// No native dependencies — fully unit-testable without Flutter/sqlite.
class InMemoryEventLogRepository implements EventLogRepository {
  final List<EventRecord> _records = [];

  @override
  void append(EventRecord record) => _records.add(record);

  @override
  List<EventRecord> query(QuerySpec spec) {
    final matched = _records.where((r) {
      if (spec.eventTypes.isNotEmpty &&
          !spec.eventTypes.contains(r.eventType)) {
        return false;
      }
      if (spec.from != null && r.createdAt < spec.from!) return false;
      if (spec.to != null && r.createdAt > spec.to!) return false;
      if (spec.sessionId != null && r.sessionId != spec.sessionId) {
        return false;
      }
      return true;
    }).toList();

    // Deterministic ordering by createdAt, then id.
    matched.sort((a, b) {
      final c = a.createdAt.compareTo(b.createdAt);
      if (c != 0) return c;
      return a.id.compareTo(b.id);
    });

    if (spec.limit != null && spec.limit! < matched.length) {
      return matched.sublist(0, spec.limit!);
    }
    return matched;
  }
}

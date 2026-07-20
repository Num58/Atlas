import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/storage/in_memory_event_log.dart';

EventRecord _rec(String id, String type, int createdAt, {String? sessionId}) =>
    EventRecord(
      id: id,
      eventType: type,
      payload: {'id': id},
      createdAt: createdAt,
      sessionId: sessionId,
    );

void main() {
  group('InMemoryEventLogRepository', () {
    late InMemoryEventLogRepository repo;

    setUp(() {
      repo = InMemoryEventLogRepository();
      repo.append(_rec('a', 'tone_change_event', 1000, sessionId: 's1'));
      repo.append(_rec('b', 'conflict_detected', 2000, sessionId: 's1'));
      repo.append(_rec('c', 'tone_change_event', 3000, sessionId: 's2'));
    });

    test('append + query all', () {
      expect(repo.query(const QuerySpec()), hasLength(3));
    });

    test('filter by eventTypes', () {
      final r = repo.query(const QuerySpec(eventTypes: ['tone_change_event']));
      expect(r, hasLength(2));
      expect(r.every((e) => e.eventType == 'tone_change_event'), isTrue);
    });

    test('filter by from/to time window', () {
      final r = repo.query(const QuerySpec(from: 2000, to: 2000));
      expect(r, hasLength(1));
      expect(r.first.id, 'b');
    });

    test('filter by sessionId', () {
      final r = repo.query(const QuerySpec(sessionId: 's1'));
      expect(r, hasLength(2));
    });

    test('limit caps results and preserves order', () {
      final r = repo.query(const QuerySpec(limit: 1));
      expect(r, hasLength(1));
      expect(r.first.id, 'a');
    });
  });
}

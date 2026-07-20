import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/events/event_receipt.dart';
import 'package:primeatlas/core/sync/sync_adapter.dart';

void main() {
  group('NoopSyncAdapter', () {
    final adapter = NoopSyncAdapter();

    test('isEnabled is false (local-only)', () {
      expect(adapter.isEnabled, isFalse);
    });

    test('pushEvents is a no-op and completes', () async {
      const rec = EventRecord(
        id: 'e1',
        eventType: 'tone_change_event',
        payload: {},
        createdAt: 1,
      );
      await expectLater(adapter.pushEvents([rec]), completes);
    });

    test('pull returns an empty list', () async {
      final pulled = await adapter.pull();
      expect(pulled, isEmpty);
    });
  });
}

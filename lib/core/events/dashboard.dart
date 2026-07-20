import 'event_receipt.dart';

/// Local dashboard aggregation layer over an event-record list (per §3.3).
///
/// Pure Dart, no `package:flutter`, no external state — feeds the 9 red-line
/// dashboard signals and the V1/V2/V3 anti-vanity metrics.
class Dashboard {
  final List<EventRecord> records;

  const Dashboard(this.records);

  /// Count of events per event type. Supports T-RL / C-RL / P-RL coverage.
  Map<String, int> redlineCoverage() {
    final counts = <String, int>{};
    for (final r in records) {
      counts[r.eventType] = (counts[r.eventType] ?? 0) + 1;
    }
    return counts;
  }

  /// Count of [eventType] events per time bucket of [bucket] duration.
  /// The map key is the bucket's start epoch-ms (floor of createdAt).
  Map<int, int> timeSeries(String eventType, Duration bucket) {
    final bucketMs = bucket.inMilliseconds;
    if (bucketMs <= 0) return {};
    final buckets = <int, int>{};
    for (final r in records) {
      if (r.eventType != eventType) continue;
      final start = (r.createdAt ~/ bucketMs) * bucketMs;
      buckets[start] = (buckets[start] ?? 0) + 1;
    }
    return buckets;
  }
}

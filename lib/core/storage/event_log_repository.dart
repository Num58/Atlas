import 'package:primeatlas/core/events/event_receipt.dart';

/// Persistence contract for the event log (§7.2).
abstract class EventLogRepository {
  void append(EventRecord record);
  List<EventRecord> query(QuerySpec spec);
}

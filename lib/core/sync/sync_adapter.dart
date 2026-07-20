import 'package:primeatlas/core/events/event_receipt.dart';

/// Cloud-sync seam (§7.3). Phase1 ships the local-first [NoopSyncAdapter];
/// a real adapter (Supabase/self-hosted) is swapped in only when the product
/// decides to connect to the cloud. Guarantees "no network, data stays local".
abstract class SyncAdapter {
  /// Push locally-persisted events to the cloud.
  Future<void> pushEvents(List<EventRecord> records);

  /// Pull events from the cloud.
  Future<List<EventRecord>> pull();

  /// Whether cloud sync is active.
  bool get isEnabled;
}

/// Default placeholder: pure-local, never touches the network.
class NoopSyncAdapter implements SyncAdapter {
  @override
  Future<void> pushEvents(List<EventRecord> records) async {}

  @override
  Future<List<EventRecord>> pull() async => const [];

  @override
  bool get isEnabled => false;
}

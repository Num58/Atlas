import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:primeatlas/app/state/app_providers.dart';
import 'package:primeatlas/core/ports/local_persistence_repository.dart';

/// Local-first data status surfaced in the "我的" area.
///
/// [syncLabel] is always `'savedLocal'` — PrimeAtlas V0.2 never reports a
/// cloud sync state, because there is no cloud.
@immutable
class LocalDataStatus {
  const LocalDataStatus({
    required this.schemaState,
    required this.integrityOk,
    required this.syncLabel,
  });

  final SchemaState schemaState;
  final bool integrityOk;
  final String syncLabel;

  int get schemaVersionCount => schemaState.entries.length;

  String get syncLabelText {
    switch (syncLabel) {
      case 'savedLocal':
        return '已保存在本机';
      default:
        return '已保存在本机';
    }
  }
}

/// Loads schema + integrity state from the local persistence repository.
final class LocalDataStatusNotifier extends AsyncNotifier<LocalDataStatus> {
  @override
  Future<LocalDataStatus> build() async {
    final repo = ref.watch(localPersistenceRepositoryProvider);
    final schemaState = repo.schemaState();
    return LocalDataStatus(
      schemaState: schemaState,
      integrityOk: schemaState.integrityOk,
      syncLabel: 'savedLocal',
    );
  }
}

final localDataStatusProvider =
    AsyncNotifierProvider<LocalDataStatusNotifier, LocalDataStatus>(
  LocalDataStatusNotifier.new,
);

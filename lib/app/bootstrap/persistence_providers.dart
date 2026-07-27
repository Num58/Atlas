import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/baseline_migration.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/journey_boundary_repository.dart';
import 'package:primeatlas/infrastructure/storage/sqlite/prime_atlas_database.dart';

/// Stable guest ids for V0.2 single-device local runtime.
const localGuestOwnerId = '00000000-0000-7000-a000-000000000001';
const localGuestDeviceId = '00000000-0000-7000-a000-0000000000d1';
const localGuestInstallationId = '00000000-0000-7000-a000-0000000000i1';

/// Optional override for tests/integration (must be a writable file path).
final localDatabasePathProvider = Provider<String?>((ref) => null);

String resolveDefaultLocalDatabasePath() {
  final home = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      Directory.systemTemp.path;
  final dir = Directory(
    [
      home,
      '.primeatlas',
      'v0.2',
    ].join(Platform.pathSeparator),
  );
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return '${dir.path}${Platform.pathSeparator}primeatlas.db';
}

/// Composition-root wiring for local persistence use-cases.
///
/// This file only assembles dependencies. Pages must continue calling the
/// application Port and must not import Repository classes.
final primeAtlasDatabaseProvider = Provider<PrimeAtlasDatabase>((ref) {
  final overridePath = ref.watch(localDatabasePathProvider);
  final path = (overridePath == null || overridePath.trim().isEmpty)
      ? resolveDefaultLocalDatabasePath()
      : overridePath;
  final database = PrimeAtlasDatabase.open(
    path,
    [loadBaselineMigration()],
    appVersion: '0.2.0+2',
    appliedAtUs: DateTime.now().toUtc().microsecondsSinceEpoch,
  );
  ref.onDispose(database.close);
  return database;
});

final journeyBoundaryRepositoryProvider =
    Provider<SqliteJourneyBoundaryRepository>((ref) {
  final database = ref.watch(primeAtlasDatabaseProvider);
  return SqliteJourneyBoundaryRepository(database.connection);
});

final confirmJourneyBoundaryExecutorProvider =
    Provider<ConfirmJourneyBoundaryExecutor>((ref) {
  final repository = ref.watch(journeyBoundaryRepositoryProvider);
  return ConfirmJourneyBoundaryExecutor(repository);
});

final confirmJourneyBoundaryProvider = Provider<ConfirmJourneyBoundary>((ref) {
  final executor = ref.watch(confirmJourneyBoundaryExecutorProvider);
  return LocalConfirmJourneyBoundary(
    executor,
    ownerId: localGuestOwnerId,
    deviceId: localGuestDeviceId,
    installationId: localGuestInstallationId,
  );
});

final loadLatestJourneyBoundaryProvider =
    Provider<LoadLatestJourneyBoundary>((ref) {
  final executor = ref.watch(confirmJourneyBoundaryExecutorProvider);
  return LocalLoadLatestJourneyBoundary(
    executor,
    ownerId: localGuestOwnerId,
  );
});

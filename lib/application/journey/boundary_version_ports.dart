import 'package:primeatlas/application/journey/confirm_journey_boundary.dart';
import 'package:primeatlas/core/journey/journey_boundary.dart' as core;

/// UI Port for listing target-boundary versions.
abstract class ListBoundaryVersions {
  Future<List<core.BoundaryVersionSummary>> call();
}

/// UI Port for restoring a historical boundary version.
abstract class RestoreBoundaryVersion {
  Future<ConfirmJourneyBoundaryResult> call(String versionId);
}

class LocalListBoundaryVersions implements ListBoundaryVersions {
  LocalListBoundaryVersions(
    this.executor, {
    required this.ownerId,
  });

  final ConfirmJourneyBoundaryExecutor executor;
  final String ownerId;

  @override
  Future<List<core.BoundaryVersionSummary>> call() async {
    return executor.listBoundaryVersions(ownerId);
  }
}

class LocalRestoreBoundaryVersion implements RestoreBoundaryVersion {
  LocalRestoreBoundaryVersion(
    this.executor, {
    required this.ownerId,
    required this.deviceId,
    required this.installationId,
    this.nowUs,
    this.operationIdBuilder,
  });

  final ConfirmJourneyBoundaryExecutor executor;
  final String ownerId;
  final String deviceId;
  final String installationId;
  final int Function()? nowUs;
  final String Function(String versionId)? operationIdBuilder;

  @override
  Future<ConfirmJourneyBoundaryResult> call(String versionId) async {
    try {
      final operationId = operationIdBuilder?.call(versionId) ??
          'restore-${DateTime.now().microsecondsSinceEpoch}';
      executor.restoreVersion(
        core.RestoreBoundaryVersionCommand(
          ownerId: ownerId,
          operationId: operationId,
          deviceId: deviceId,
          installationId: installationId,
          versionId: versionId,
          occurredAtUs: nowUs?.call() ?? DateTime.now().microsecondsSinceEpoch,
        ),
      );
      return const ConfirmJourneyBoundaryResult.success();
    } on core.JourneyBoundaryIncomplete catch (error) {
      return ConfirmJourneyBoundaryResult.failure(
        code: 'boundary_incomplete',
        message: error.message,
      );
    } catch (_) {
      return const ConfirmJourneyBoundaryResult.failure(
        code: 'storage_failed',
        message: '恢复目标边界失败，请重试',
      );
    }
  }
}

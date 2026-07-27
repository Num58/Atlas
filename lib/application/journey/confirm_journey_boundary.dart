import 'package:primeatlas/core/journey/journey_boundary.dart' as core;
import 'package:primeatlas/core/journey/journey_boundary_repository.dart';

/// UI-facing command. Pages and Riverpod only depend on these fields.
class ConfirmJourneyBoundaryCommand {
  const ConfirmJourneyBoundaryCommand({
    required this.direction,
    required this.constraint,
    required this.domain,
    required this.goalTitle,
    required this.milestoneTitle,
    required this.milestoneEvidenceRule,
    required this.milestoneWindow,
  });

  final String direction;
  final String constraint;
  final String domain;
  final String goalTitle;
  final String milestoneTitle;
  final String milestoneEvidenceRule;
  final String milestoneWindow;
}

class ConfirmJourneyBoundaryResult {
  const ConfirmJourneyBoundaryResult.success()
      : ok = true,
        code = null,
        message = null;

  const ConfirmJourneyBoundaryResult.failure({
    required this.code,
    required this.message,
  }) : ok = false;

  final bool ok;
  final String? code;
  final String? message;
}

/// Async Port consumed by UI. Implementations live outside presentation.
abstract class ConfirmJourneyBoundary {
  Future<ConfirmJourneyBoundaryResult> call(
    ConfirmJourneyBoundaryCommand command,
  );
}

/// UI restore model for the latest confirmed boundary.
class JourneyBoundarySnapshot {
  const JourneyBoundarySnapshot({
    required this.direction,
    required this.constraint,
    required this.domain,
    required this.goalTitle,
    required this.milestoneTitle,
    required this.milestoneEvidenceRule,
    required this.milestoneWindow,
  });

  final String direction;
  final String constraint;
  final String domain;
  final String goalTitle;
  final String milestoneTitle;
  final String milestoneEvidenceRule;
  final String milestoneWindow;

  factory JourneyBoundarySnapshot.fromConfirmed(
    core.ConfirmedJourneyBoundary confirmed,
  ) {
    return JourneyBoundarySnapshot(
      direction: confirmed.direction,
      constraint: confirmed.constraint,
      domain: confirmed.domainCode,
      goalTitle: confirmed.goalTitle,
      milestoneTitle: confirmed.milestone.title,
      milestoneEvidenceRule: confirmed.milestone.evidenceRule,
      milestoneWindow: confirmed.milestone.window,
    );
  }
}

/// Loads the latest confirmed boundary for restart recovery.
abstract class LoadLatestJourneyBoundary {
  Future<JourneyBoundarySnapshot?> call();
}

/// Temporary honest failure until composition root injects SQLite wiring.
class UnwiredConfirmJourneyBoundary implements ConfirmJourneyBoundary {
  const UnwiredConfirmJourneyBoundary();

  @override
  Future<ConfirmJourneyBoundaryResult> call(
    ConfirmJourneyBoundaryCommand command,
  ) async {
    return const ConfirmJourneyBoundaryResult.failure(
      code: 'local_persistence_not_wired',
      message: '本机写入能力尚未接入',
    );
  }
}

/// Default load Port when persistence is not wired.
class UnwiredLoadLatestJourneyBoundary implements LoadLatestJourneyBoundary {
  const UnwiredLoadLatestJourneyBoundary();

  @override
  Future<JourneyBoundarySnapshot?> call() async => null;
}

/// Sync orchestration around [JourneyBoundaryRepository].
/// Used by infrastructure tests and the SQLite UI adapter.
class ConfirmJourneyBoundaryExecutor {
  const ConfirmJourneyBoundaryExecutor(this.repository);

  final JourneyBoundaryRepository repository;

  core.ConfirmedJourneyBoundary execute(
    core.ConfirmJourneyBoundaryCommand command,
  ) {
    _requireComplete(command);
    _rejectIdentityLabels(command);
    return repository.confirm(command);
  }

  core.ConfirmedJourneyBoundary? loadLatestConfirmed(String ownerId) {
    return repository.loadLatestConfirmed(ownerId);
  }

  List<core.BoundaryVersionSummary> listBoundaryVersions(String ownerId) {
    return repository.listBoundaryVersions(ownerId);
  }

  core.ConfirmedJourneyBoundary restoreVersion(
    core.RestoreBoundaryVersionCommand command,
  ) {
    return repository.restoreVersion(command);
  }

  static void _requireComplete(core.ConfirmJourneyBoundaryCommand command) {
    final incomplete = command.direction.trim().isEmpty ||
        command.constraint.trim().isEmpty ||
        command.domainCode.trim().isEmpty ||
        command.goalTitle.trim().isEmpty ||
        command.milestone.title.trim().isEmpty ||
        command.milestone.evidenceRule.trim().isEmpty ||
        command.milestone.window.trim().isEmpty ||
        command.ownerId.trim().isEmpty ||
        command.operationId.trim().isEmpty ||
        command.deviceId.trim().isEmpty ||
        command.installationId.trim().isEmpty;
    if (incomplete) {
      throw const core.JourneyBoundaryIncomplete();
    }
  }

  static void _rejectIdentityLabels(
    core.ConfirmJourneyBoundaryCommand command,
  ) {
    final text = [
      command.direction,
      command.constraint,
      command.goalTitle,
      command.milestone.title,
    ].join('\n');
    if (text.contains('我想成为') || text.contains('我现在是')) {
      throw const core.JourneyBoundaryIncomplete(
        'Journey boundary may not define user identity or roles.',
      );
    }
  }
}

/// Maps UI confirmation fields onto the core SQLite repository path.
class LocalConfirmJourneyBoundary implements ConfirmJourneyBoundary {
  LocalConfirmJourneyBoundary(
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
  final String Function(ConfirmJourneyBoundaryCommand command)?
      operationIdBuilder;

  @override
  Future<ConfirmJourneyBoundaryResult> call(
    ConfirmJourneyBoundaryCommand command,
  ) async {
    try {
      final operationId = operationIdBuilder?.call(command) ??
          'op-${DateTime.now().microsecondsSinceEpoch}';
      executor.execute(
        core.ConfirmJourneyBoundaryCommand(
          ownerId: ownerId,
          operationId: operationId,
          deviceId: deviceId,
          installationId: installationId,
          direction: command.direction.trim(),
          constraint: command.constraint.trim(),
          domainCode: command.domain.trim(),
          goalTitle: command.goalTitle.trim(),
          milestone: core.JourneyMilestoneInput(
            title: command.milestoneTitle.trim(),
            evidenceRule: command.milestoneEvidenceRule.trim(),
            window: command.milestoneWindow.trim(),
          ),
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
        message: '写入本机失败，请重试',
      );
    }
  }
}

/// Maps repository loadLatestConfirmed onto the UI restore Port.
class LocalLoadLatestJourneyBoundary implements LoadLatestJourneyBoundary {
  LocalLoadLatestJourneyBoundary(
    this.executor, {
    required this.ownerId,
  });

  final ConfirmJourneyBoundaryExecutor executor;
  final String ownerId;

  @override
  Future<JourneyBoundarySnapshot?> call() async {
    final confirmed = executor.loadLatestConfirmed(ownerId);
    if (confirmed == null) {
      return null;
    }
    return JourneyBoundarySnapshot.fromConfirmed(confirmed);
  }
}

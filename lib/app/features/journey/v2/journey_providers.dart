import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:primeatlas/app/state/app_providers.dart';
import 'package:primeatlas/application/domains/activate_domain.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/application/goals/create_goal_candidate.dart';
import 'package:primeatlas/core/common/domain_failure.dart';
import 'package:primeatlas/core/ports/domain_repository.dart';
import 'package:primeatlas/core/ports/goal_repository.dart';

/// Throws the [DomainFailure] of a failed [Result], surfacing it to
/// async notifier error states; otherwise returns the success value.
T _require<T>(Result<T> result) {
  final failure = result.failureOrNull;
  if (failure != null) {
    throw failure;
  }
  return result.valueOrNull as T;
}

/// Active (focused) domains for the current owner.
final class ActiveDomainsNotifier extends AsyncNotifier<List<Domain>> {
  @override
  Future<List<Domain>> build() async {
    final ownerId = ref.watch(ownerIdProvider);
    return ref.watch(domainRepositoryProvider).listActive(ownerId);
  }
}

final activeDomainsProvider =
    AsyncNotifierProvider<ActiveDomainsNotifier, List<Domain>>(
  ActiveDomainsNotifier.new,
);

/// Arguments for a single journey-overview page (keyset pagination).
@immutable
class JourneyOverviewArgs {
  const JourneyOverviewArgs({this.cursor, this.limit = 20});

  final JourneyOverviewCursor? cursor;
  final int limit;

  bool _cursorEquals(JourneyOverviewCursor? other) {
    if (cursor == null && other == null) return true;
    if (cursor == null || other == null) return false;
    return cursor!.updatedAtUs == other.updatedAtUs && cursor!.id == other.id;
  }

  @override
  bool operator ==(Object other) =>
      other is JourneyOverviewArgs &&
      other.limit == limit &&
      _cursorEquals(other.cursor);

  @override
  int get hashCode => Object.hash(cursor?.updatedAtUs, cursor?.id, limit);
}

/// One page of the journey overview, keyed by [JourneyOverviewArgs].
final class JourneyOverviewNotifier
    extends FamilyAsyncNotifier<JourneyOverviewResult, JourneyOverviewArgs> {
  @override
  Future<JourneyOverviewResult> build(JourneyOverviewArgs args) async {
    final ownerId = ref.watch(ownerIdProvider);
    return ref.watch(goalRepositoryProvider).getJourneyOverview(
          ownerId,
          cursor: args.cursor,
          limit: args.limit,
        );
  }
}

final journeyOverviewProvider = AsyncNotifierProviderFamily<
    JourneyOverviewNotifier, JourneyOverviewResult, JourneyOverviewArgs>(
  JourneyOverviewNotifier.new,
);

/// Goal detail including milestones, keyed by goal id.
final class GoalDetailNotifier
    extends FamilyAsyncNotifier<GoalDetail, String> {
  @override
  Future<GoalDetail> build(String goalId) async {
    final ownerId = ref.watch(ownerIdProvider);
    return _require(
      ref.watch(goalRepositoryProvider).getGoalDetail(ownerId, goalId),
    );
  }
}

final goalDetailProvider =
    AsyncNotifierProviderFamily<GoalDetailNotifier, GoalDetail, String>(
  GoalDetailNotifier.new,
);

/// UI-side state for domain lifecycle actions.
@immutable
class DomainActionState {
  const DomainActionState({
    this.busy = false,
    this.error,
    this.lastArchivedId,
  });

  final bool busy;
  final DomainFailure? error;
  final String? lastArchivedId;

  DomainActionState copyWith({
    bool? busy,
    DomainFailure? error,
    String? lastArchivedId,
    bool clearError = false,
  }) {
    return DomainActionState(
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      lastArchivedId: lastArchivedId ?? this.lastArchivedId,
    );
  }
}

/// Activates and archives domains, refreshing dependent providers.
final class DomainActionsNotifier extends Notifier<DomainActionState> {
  @override
  DomainActionState build() => const DomainActionState();

  Future<void> activate(ActivateDomainCommand command) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      final result = ActivateDomain(repo)(command);
      if (result.isFailure) {
        state = state.copyWith(busy: false, error: result.failureOrNull);
        return;
      }
      ref.invalidate(activeDomainsProvider);
      state = state.copyWith(busy: false);
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: DomainFailure.unexpectedExternalCall,
      );
    }
  }

  Future<void> archive(ArchiveDomainCommand command) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final repo = ref.read(domainRepositoryProvider);
      final result = repo.archiveWithImpact(command);
      if (result.isFailure) {
        state = state.copyWith(busy: false, error: result.failureOrNull);
        return;
      }
      ref.invalidate(activeDomainsProvider);
      state = state.copyWith(busy: false, lastArchivedId: command.domainId);
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: DomainFailure.unexpectedExternalCall,
      );
    }
  }
}

final domainActionsProvider =
    NotifierProvider<DomainActionsNotifier, DomainActionState>(
  DomainActionsNotifier.new,
);

/// UI-side state for goal lifecycle actions.
@immutable
class GoalActionState {
  const GoalActionState({
    this.busy = false,
    this.error,
    this.lastActionGoalId,
    this.lastAction,
  });

  final bool busy;
  final DomainFailure? error;
  final String? lastActionGoalId;
  final String? lastAction;

  GoalActionState copyWith({
    bool? busy,
    DomainFailure? error,
    String? lastActionGoalId,
    String? lastAction,
    bool clearError = false,
  }) {
    return GoalActionState(
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      lastActionGoalId: lastActionGoalId ?? this.lastActionGoalId,
      lastAction: lastAction ?? this.lastAction,
    );
  }
}

/// Creates draft goals and transitions goal status via the repository.
final class GoalActionsNotifier extends Notifier<GoalActionState> {
  @override
  GoalActionState build() => const GoalActionState();

  Future<void> createDraft(CreateGoalCandidateCommand command) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final repo = ref.read(goalRepositoryProvider);
      final result = CreateGoalCandidate(repo)(command);
      if (result.isFailure) {
        state = state.copyWith(busy: false, error: result.failureOrNull);
        return;
      }
      final goal = result.valueOrNull;
      if (goal != null) {
        ref.invalidate(goalDetailProvider(goal.id));
        ref.invalidate(journeyOverviewProvider(const JourneyOverviewArgs()));
      }
      state = state.copyWith(
        busy: false,
        lastActionGoalId: goal?.id,
        lastAction: 'create',
      );
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: DomainFailure.unexpectedExternalCall,
      );
    }
  }

  Future<void> confirm(String goalId) => _transition(goalId, 'active');
  Future<void> pause(String goalId) => _transition(goalId, 'paused');
  Future<void> archive(String goalId) => _transition(goalId, 'archived');

  Future<void> _transition(String goalId, String status) async {
    state = state.copyWith(busy: true, clearError: true);
    try {
      final ownerId = ref.read(ownerIdProvider);
      final repo = ref.read(goalRepositoryProvider);
      final existing = repo.getGoal(ownerId, goalId);
      if (existing == null) {
        state = state.copyWith(busy: false, error: DomainFailure.notFound);
        return;
      }
      final nowUs = DateTime.now().microsecondsSinceEpoch;
      final updated = Goal(
        id: existing.id,
        ownerId: existing.ownerId,
        domainId: existing.domainId,
        status: status,
        version: existing.version + 1,
        title: existing.title,
        description: existing.description,
        identityGap: existing.identityGap,
        dataSufficiency: existing.dataSufficiency,
        sourceType: existing.sourceType,
        sourcePortraitVersionId: existing.sourcePortraitVersionId,
        targetAtUs: existing.targetAtUs,
        pausedAtUs: status == 'paused' ? nowUs : existing.pausedAtUs,
        completedAtUs: existing.completedAtUs,
        archivedAtUs: status == 'archived' ? nowUs : existing.archivedAtUs,
        createdAtUs: existing.createdAtUs,
        updatedAtUs: nowUs,
      );
      final result = repo.saveGoalVersion(
        SaveGoalCommand(
          ownerId: ownerId,
          goal: updated,
          expectedVersion: existing.version,
        ),
      );
      if (result.isFailure) {
        state = state.copyWith(busy: false, error: result.failureOrNull);
        return;
      }
      ref.invalidate(goalDetailProvider(goalId));
      ref.invalidate(journeyOverviewProvider(const JourneyOverviewArgs()));
      state = state.copyWith(busy: false, lastActionGoalId: goalId);
    } catch (_) {
      state = state.copyWith(
        busy: false,
        error: DomainFailure.unexpectedExternalCall,
      );
    }
  }
}

final goalActionsProvider =
    NotifierProvider<GoalActionsNotifier, GoalActionState>(
  GoalActionsNotifier.new,
);

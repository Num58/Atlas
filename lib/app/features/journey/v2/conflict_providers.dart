import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/core/conflict/conflict_engine.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';

/// 活跃冲突列表提供者（内存态，无 DB 表）。
///
/// 暴露当前未裁决的冲突；`resolve` 执行双轨裁决后从列表移除该冲突。
final conflictProvider =
    StateNotifierProvider<ConflictNotifier, List<Conflict>>((ref) {
  return ConflictNotifier(const ConflictEngine());
});

/// 冲突状态持有者：维护内存中的活跃冲突并执行裁决。
class ConflictNotifier extends StateNotifier<List<Conflict>> {
  ConflictNotifier(this._engine) : super(const <Conflict>[]);

  final ConflictEngine _engine;

  /// 用最新日程项重新检测冲突（覆盖式刷新）。
  void scan(Iterable<ScheduledItem> items) {
    state = _engine.detect(items).toList(growable: false);
  }

  /// 双轨裁决：adopt=true 采纳建议，否则用户自行处理。
  ///
  /// 引擎 `propose` 含 C-RL1 断言（blockedUser 恒为 false），
  /// 裁决后从活跃列表移除该冲突。
  void resolve(Conflict conflict, bool adopt) {
    _engine.propose(conflict, userAdopt: adopt);
    state = state
        .where((c) => c.id != conflict.id)
        .toList(growable: false);
  }

  /// 清除所有活跃冲突（如日程大幅变更后）。
  void clear() => state = const <Conflict>[];
}

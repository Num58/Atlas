import 'package:primeatlas/core/conflict/conflict_types.dart';

/// 冲突检测器抽象契约（C1-1）。
abstract class ConflictDetector {
  /// 检测一次冲突并返回结果。
  ConflictDetectionResult detect(ConflictDetectionRequest req);
}

/// S0 基础冲突检测器。
///
/// 契约保证：
/// - **C-RL1**：结果 `disposition.blockedUser` 恒为 `false`（非阻断）。
/// - **C-RL3**：若 `isBodyRelated == true`，必须携带非空的
///   `bodyReasonTraceableId`，否则直接抛错（fail loudly），保证身体冲突可追溯。
class BasicConflictDetector implements ConflictDetector {
  const BasicConflictDetector();

  @override
  ConflictDetectionResult detect(ConflictDetectionRequest req) {
    if (req.isBodyRelated &&
        (req.bodyReasonTraceableId == null ||
            req.bodyReasonTraceableId!.isEmpty)) {
      throw ArgumentError(
          'C-RL3 violation: body-related conflict (${req.conflictId}) '
          'requires non-empty body_reason_traceable_id');
    }

    const disposition = Disposition(blockedUser: false);

    return ConflictDetectionResult(
      conflictId: req.conflictId,
      conflictType: req.conflictType,
      isBodyRelated: req.isBodyRelated,
      bodyReason: req.bodyReason,
      bodyReasonTraceableId: req.bodyReasonTraceableId,
      disposition: disposition,
      recommendedOrchestration: req.recommendedOrchestration,
    );
  }
}

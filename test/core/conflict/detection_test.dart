import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/conflict/conflict_engine.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';

void main() {
  group('BasicConflictDetector.detect', () {
    test('返回结果 disposition.blockedUser 恒为 false (C-RL1)', () {
      const detector = BasicConflictDetector();
      const req = ConflictDetectionRequest(
        conflictId: 'c1',
        conflictType: ConflictType.goalGoal,
        isBodyRelated: false,
        recommendedOrchestration: Orchestration(
          type: OrchestrationType.oneClickAdopt,
          rationale: 'r',
          safetyChannelRequired: false,
        ),
      );
      final res = detector.detect(req);
      expect(res.disposition.blockedUser, isFalse);
      expect(res.conflictId, 'c1');
      expect(res.conflictType, ConflictType.goalGoal);
    });

    test('身体相关冲突携带 bodyReasonTraceableId (C-RL3)', () {
      const detector = BasicConflictDetector();
      const req = ConflictDetectionRequest(
        conflictId: 'c2',
        conflictType: ConflictType.goalBody,
        isBodyRelated: true,
        bodyReason: 'knee pain',
        bodyReasonTraceableId: 'trace-1',
        recommendedOrchestration: Orchestration(
          type: OrchestrationType.oneClickAdopt,
          rationale: 'r',
          safetyChannelRequired: true,
        ),
      );
      final res = detector.detect(req);
      expect(res.isBodyRelated, isTrue);
      expect(res.bodyReasonTraceableId, 'trace-1');
      expect(res.recommendedOrchestration.safetyChannelRequired, isTrue);
    });

    test('身体相关冲突缺 traceableId 时抛错 (C-RL3 fail loudly)', () {
      const detector = BasicConflictDetector();
      const req = ConflictDetectionRequest(
        conflictId: 'c3',
        conflictType: ConflictType.goalBody,
        isBodyRelated: true,
        recommendedOrchestration: Orchestration(
          type: OrchestrationType.oneClickAdopt,
          rationale: 'r',
          safetyChannelRequired: true,
        ),
      );
      expect(() => detector.detect(req), throwsArgumentError);
    });
  });
}

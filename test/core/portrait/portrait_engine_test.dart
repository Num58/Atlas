import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primeatlas/core/portrait/portrait_engine.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';

void main() {
  // mocktail 注册兜底值，遵循本项目测试约定（便于后续为引擎依赖注入替身）。
  setUpAll(() {
    registerFallbackValue(PortraitSnapshot(
      version: 0,
      activeAxes: [],
      values: {},
      transitionNarrative: '',
      consentedAt: DateTime(2020),
    ));
  });

  const endurance = PortraitAxis(id: 'endurance', label: '耐力', active: true);
  const social = PortraitAxis(id: 'social', label: '社交', active: true);
  const hidden = PortraitAxis(id: 'hidden', label: '隐藏维度', active: false);
  final now = DateTime(2024, 1, 1);

  final engine = PortraitEngine();

  group('createSnapshot 授权与版本化', () {
    test('consent == false 返回 consent_required 失败且不建快照', () {
      final r = engine.createSnapshot(
        axes: [endurance, social],
        rawValues: {'endurance': 0.5, 'social': 0.3},
        consent: false,
        now: now,
        prevVersion: null,
      );
      expect(r.isFailure, isTrue);
      expect(r.failureOrNull?.code, 'consent_required');
      expect(r.valueOrNull, isNull);
    });

    test('首个版本 prevVersion==null 时 version=1 且叙事为空', () {
      final r = engine.createSnapshot(
        axes: [endurance, social],
        rawValues: {'endurance': 0.5, 'social': 0.3},
        consent: true,
        now: now,
        prevVersion: null,
      );
      expect(r.isSuccess, isTrue);
      final snap = r.valueOrNull!;
      expect(snap.version, 1);
      expect(snap.transitionNarrative, '');
      expect(snap.consentedAt, now);
    });

    test('version 在 prevVersion 基础上自增', () {
      final prev = PortraitSnapshot(
        version: 2,
        activeAxes: [endurance, social],
        values: {'endurance': 0.3, 'social': 0.6},
        transitionNarrative: '',
        consentedAt: DateTime(2023),
      );
      final r = engine.createSnapshot(
        axes: [endurance, social],
        rawValues: {'endurance': 0.7, 'social': 0.6},
        consent: true,
        now: now,
        prevVersion: prev.version,
        prev: prev,
      );
      expect(r.valueOrNull!.version, 3);
    });
  });

  group('P-RL1 未激活维度不渲染不存储', () {
    test('未激活维度既不进入 activeAxes 也不进入 values', () {
      final r = engine.createSnapshot(
        axes: [endurance, social, hidden],
        rawValues: {'endurance': 0.8, 'social': 0.4},
        consent: true,
        now: now,
        prevVersion: null,
      );
      expect(r.isSuccess, isTrue);
      final snap = r.valueOrNull!;
      expect(snap.activeAxes.length, 2);
      expect(snap.activeAxes.every((a) => a.active), isTrue);
      expect(snap.values.keys, containsAll(['endurance', 'social']));
      expect(snap.values.containsKey('hidden'), isFalse);
      // 不变量：values 键恰好等于 activeAxes 的 id
      expect(
        snap.values.keys.toSet(),
        snap.activeAxes.map((a) => a.id).toSet(),
      );
    });

    test('rawValues 携带未激活维度键时直接拒绝 (inactive_axis_value)', () {
      final r = engine.createSnapshot(
        axes: [endurance, hidden],
        rawValues: {'endurance': 0.8, 'hidden': 0.9},
        consent: true,
        now: now,
        prevVersion: null,
      );
      expect(r.isFailure, isTrue);
      expect(r.failureOrNull?.code, 'inactive_axis_value');
    });
  });

  group('activeOnly', () {
    test('仅保留激活维度', () {
      final active = engine.activeOnly([endurance, social, hidden]);
      expect(active.length, 2);
      expect(active.every((a) => a.active), isTrue);
    });
  });

  group('deriveTransition 过渡态叙事', () {
    final prev = PortraitSnapshot(
      version: 1,
      activeAxes: [endurance, social],
      values: {'endurance': 0.3, 'social': 0.6},
      transitionNarrative: '',
      consentedAt: DateTime(2023),
    );

    test('首个版本（prev 为 null）返回空串', () {
      final next = PortraitSnapshot(
        version: 2,
        activeAxes: [endurance],
        values: {'endurance': 0.7},
        transitionNarrative: '',
        consentedAt: DateTime(2024),
      );
      expect(engine.deriveTransition(null, next), '');
    });

    test('维度增减与取值变化均生成叙事', () {
      final next = PortraitSnapshot(
        version: 2,
        activeAxes: [endurance],
        values: {'endurance': 0.7},
        transitionNarrative: '',
        consentedAt: DateTime(2024),
      );
      final narrative = engine.deriveTransition(prev, next);
      expect(narrative, isNotEmpty);
      expect(narrative, contains('耐力'));
      expect(narrative, contains('社交'));
    });
  });
}

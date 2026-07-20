import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/portrait/portrait_engine.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';

void main() {
  group('InMemoryPortraitVersioner', () {
    test('createVersion 要求非空 consent (P-RL2)', () {
      final v = InMemoryPortraitVersioner();
      const snap = ProfileSnapshot(
        fields: {},
        activeDimensions: [],
        inactiveDimensions: [],
      );
      expect(() => v.createVersion(snap, ''), throwsArgumentError);
    });

    test('diff 计算正确的 FieldChange 列表与 hasNarratableChange', () {
      final v = InMemoryPortraitVersioner();
      final a = v.createVersion(
        const ProfileSnapshot(
          fields: {'name': 'A', 'age': 1},
          activeDimensions: ['name', 'age'],
          inactiveDimensions: [],
        ),
        'consent-1',
      );
      final b = v.createVersion(
        const ProfileSnapshot(
          fields: {'name': 'B', 'age': 1},
          activeDimensions: ['name', 'age'],
          inactiveDimensions: [],
        ),
        'consent-2',
      );
      final d = v.diff(a.versionId, b.versionId);
      expect(d.changes.length, 1);
      expect(d.changes.first.fieldName, 'name');
      expect(d.changes.first.oldValue, 'A');
      expect(d.changes.first.newValue, 'B');
      expect(d.hasNarratableChange, isTrue);
    });

    test('未激活维度不渲染也不占存储 (P-RL1)', () {
      final v = InMemoryPortraitVersioner();
      v.createVersion(
        const ProfileSnapshot(
          fields: {'x': 1},
          activeDimensions: ['x'],
          inactiveDimensions: ['y'],
        ),
        'consent-1',
      );
      final y = v.getDimensionStatus('y');
      expect(y.isActive, isFalse);
      expect(y.rendered, isFalse);
      expect(y.occupiedStorage, isFalse);

      final x = v.getDimensionStatus('x');
      expect(x.isActive, isTrue);
      expect(x.rendered, isTrue);
      expect(x.occupiedStorage, isTrue);
    });
  });
}

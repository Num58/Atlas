import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/portrait/portrait_engine.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';

void main() {
  group('getDimensionStatus 不变量 (P-RL1)', () {
    test('rendered==isActive 且 !isActive=>!occupiedStorage', () {
      final v = InMemoryPortraitVersioner();
      v.createVersion(
        const ProfileSnapshot(
          fields: {},
          activeDimensions: ['a'],
          inactiveDimensions: ['b'],
        ),
        'consent-1',
      );

      final active = v.getDimensionStatus('a');
      expect(active.rendered == active.isActive, isTrue);

      final inactive = v.getDimensionStatus('b');
      expect(inactive.rendered == inactive.isActive, isTrue);
      expect(!inactive.isActive && !inactive.occupiedStorage, isTrue);

      // 未知维度按未激活处理
      final unknown = v.getDimensionStatus('zzz');
      expect(unknown.isActive, isFalse);
      expect(unknown.rendered, isFalse);
      expect(unknown.occupiedStorage, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/conflict/conflict_types.dart';

void main() {
  group('Disposition.blockedUser 不变量 (C-RL1)', () {
    test('blockedUser: true 在类型层抛断言', () {
      expect(() => Disposition(blockedUser: true),
          throwsA(isA<AssertionError>()));
    });

    test('blockedUser: false 合法', () {
      const d = Disposition(blockedUser: false);
      expect(d.blockedUser, isFalse);
      expect(d.toJson()['blocked_user'], isFalse);
    });
  });
}

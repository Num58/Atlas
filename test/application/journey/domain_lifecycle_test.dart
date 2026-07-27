import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/application/journey/domain_lifecycle.dart';

void main() {
  const lifecycle = DomainLifecycle(maxActive: 3);

  test('accepts up to three active domains', () {
    var active = const <String>[];
    var paused = const <String>[];

    for (final domain in ['体能', '语言', '创作']) {
      final outcome = lifecycle.toggleActive(
        active: active,
        paused: paused,
        domain: domain,
      );
      expect(outcome.ok, isTrue);
      active = outcome.active;
      paused = outcome.paused;
    }

    expect(active, ['体能', '语言', '创作']);
    final fourth = lifecycle.toggleActive(
      active: active,
      paused: paused,
      domain: '认知',
    );
    expect(fourth.ok, isFalse);
    expect(fourth.message, contains('聚焦'));
  });

  test('pause moves domain out of active set', () {
    final outcome = lifecycle.pause(
      active: const ['体能', '语言'],
      paused: const <String>[],
      domain: '体能',
    );
    expect(outcome.ok, isTrue);
    expect(outcome.active, ['语言']);
    expect(outcome.paused, ['体能']);
  });

  test('resume restores paused domain when capacity allows', () {
    final outcome = lifecycle.resume(
      active: const ['语言'],
      paused: const ['体能'],
      domain: '体能',
    );
    expect(outcome.ok, isTrue);
    expect(outcome.active, ['语言', '体能']);
    expect(outcome.paused, isEmpty);
  });

  test('resume rejects when active set is full', () {
    final outcome = lifecycle.resume(
      active: const ['体能', '语言', '创作'],
      paused: const ['认知'],
      domain: '认知',
    );
    expect(outcome.ok, isFalse);
    expect(outcome.message, contains('已满'));
  });
}

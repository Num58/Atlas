/// Pure domain lifecycle helpers for V0.2 (max 3 active domains).
class DomainLifecycle {
  const DomainLifecycle({this.maxActive = 3});

  final int maxActive;

  List<String> normalize(Iterable<String> items) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in items) {
      final value = raw.trim();
      if (value.isEmpty || seen.contains(value)) {
        continue;
      }
      seen.add(value);
      result.add(value);
    }
    return List<String>.unmodifiable(result);
  }

  DomainLifecycleOutcome toggleActive({
    required List<String> active,
    required List<String> paused,
    required String domain,
  }) {
    final name = domain.trim();
    if (name.isEmpty) {
      return DomainLifecycleOutcome.rejected('成长域不能为空');
    }
    final nextActive = [...active];
    final nextPaused = [...paused]..remove(name);

    if (nextActive.contains(name)) {
      nextActive.remove(name);
      return DomainLifecycleOutcome.changed(
        active: normalize(nextActive),
        paused: normalize(nextPaused),
      );
    }

    if (nextActive.length >= maxActive) {
      return DomainLifecycleOutcome.rejected(
        '已有 $maxActive 个活跃成长域（${nextActive.join('、')}）。'
        '请先聚焦、暂停或调整现有域，而不是继续增加第 ${maxActive + 1} 个。',
      );
    }

    nextActive.add(name);
    return DomainLifecycleOutcome.changed(
      active: normalize(nextActive),
      paused: normalize(nextPaused),
    );
  }

  DomainLifecycleOutcome pause({
    required List<String> active,
    required List<String> paused,
    required String domain,
  }) {
    final name = domain.trim();
    if (!active.contains(name)) {
      return DomainLifecycleOutcome.rejected('只能暂停当前活跃成长域');
    }
    final nextActive = [...active]..remove(name);
    final nextPaused = [...paused, name];
    return DomainLifecycleOutcome.changed(
      active: normalize(nextActive),
      paused: normalize(nextPaused),
    );
  }

  DomainLifecycleOutcome resume({
    required List<String> active,
    required List<String> paused,
    required String domain,
  }) {
    final name = domain.trim();
    if (!paused.contains(name)) {
      return DomainLifecycleOutcome.rejected('只能恢复已暂停的成长域');
    }
    if (active.length >= maxActive) {
      return DomainLifecycleOutcome.rejected(
        '活跃成长域已满（$maxActive 个）。请先暂停其中一个，再恢复「$name」。',
      );
    }
    final nextPaused = [...paused]..remove(name);
    final nextActive = [...active, name];
    return DomainLifecycleOutcome.changed(
      active: normalize(nextActive),
      paused: normalize(nextPaused),
    );
  }
}

class DomainLifecycleOutcome {
  const DomainLifecycleOutcome._({
    required this.ok,
    required this.active,
    required this.paused,
    this.message,
  });

  factory DomainLifecycleOutcome.changed({
    required List<String> active,
    required List<String> paused,
  }) {
    return DomainLifecycleOutcome._(
      ok: true,
      active: active,
      paused: paused,
    );
  }

  factory DomainLifecycleOutcome.rejected(String message) {
    return DomainLifecycleOutcome._(
      ok: false,
      active: const <String>[],
      paused: const <String>[],
      message: message,
    );
  }

  final bool ok;
  final List<String> active;
  final List<String> paused;
  final String? message;
}

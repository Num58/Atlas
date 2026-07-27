import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

void main() {
  const uuid = Uuid();
  const zeros = <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  String at(int milliseconds, int randomTail) {
    final random = [...zeros]
      ..[8] = randomTail >> 8
      ..[9] = randomTail & 0xff;
    return uuid.v7(config: V7Options(milliseconds, random));
  }

  test('emits canonical lowercase RFC 9562 version 7 values', () {
    final value = at(1700000000000, 1);
    expect(
      value,
      matches(RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      )),
    );
  });

  test('same millisecond values remain unique with distinct random bytes', () {
    final values = {for (var index = 0; index < 256; index++) at(1, index)};
    expect(values, hasLength(256));
  });

  test('package CSPRNG produces unique values in one fixed millisecond', () {
    final values = {
      for (var index = 0; index < 4096; index++)
        uuid.v7(config: const V7Options(1, null)),
    };
    expect(values, hasLength(4096));
  });

  test('clock rollback is visible and must not be treated as monotonic', () {
    expect(at(999, 0).compareTo(at(1000, 0)), lessThan(0));
    expect(at(1000, 0).compareTo(at(999, 0)), greaterThan(0));
  });

  test('SQLite TEXT order follows UUIDv7 time prefix across milliseconds', () {
    final database = sqlite3.openInMemory();
    addTearDown(database.dispose);
    database.execute('CREATE TABLE ids(id TEXT PRIMARY KEY)');
    database.execute('INSERT INTO ids(id) VALUES (?), (?), (?)', [
      at(1002, 0),
      at(1000, 0),
      at(1001, 0),
    ]);
    final ordered = database.select('SELECT id FROM ids ORDER BY id');
    expect(ordered.map((row) => row['id']), [
      at(1000, 0),
      at(1001, 0),
      at(1002, 0),
    ]);
  });
}

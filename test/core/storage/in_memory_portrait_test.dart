import 'package:flutter_test/flutter_test.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'package:primeatlas/core/storage/in_memory_portrait.dart';

PortraitVersion _v(String id, int createdAt) => PortraitVersion(
      versionId: id,
      createdAt: createdAt,
      snapshot: ProfileSnapshot(
        fields: {'name': id},
        activeDimensions: ['goal'],
        inactiveDimensions: ['sleep'],
      ),
      changeSummary: 'summary-$id',
      consentRecordId: 'consent-1',
    );

void main() {
  group('InMemoryPortraitRepository', () {
    late InMemoryPortraitRepository repo;

    setUp(() {
      repo = InMemoryPortraitRepository();
      repo.save(_v('v1', 1000));
      repo.save(_v('v2', 2000));
      repo.save(_v('v3', 3000));
    });

    test('get returns the saved version', () {
      final v = repo.get('v2');
      expect(v, isNotNull);
      expect(v!.versionId, 'v2');
      expect(v.consentRecordId, 'consent-1');
    });

    test('get returns null for unknown id', () {
      expect(repo.get('nope'), isNull);
    });

    test('list returns newest first', () {
      final all = repo.list();
      expect(all.map((v) => v.versionId).toList(),
          ['v3', 'v2', 'v1']);
    });

    test('list honors limit', () {
      expect(repo.list(limit: 2).map((v) => v.versionId).toList(),
          ['v3', 'v2']);
    });
  });
}

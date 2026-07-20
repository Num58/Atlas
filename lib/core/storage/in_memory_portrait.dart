import 'package:primeatlas/core/portrait/portrait_types.dart';
import 'portrait_repository.dart';

/// Default in-memory [PortraitRepository] used by tests and the default bus.
class InMemoryPortraitRepository implements PortraitRepository {
  final Map<String, PortraitVersion> _store = {};

  @override
  void save(PortraitVersion version) => _store[version.versionId] = version;

  @override
  PortraitVersion? get(String versionId) => _store[versionId];

  @override
  List<PortraitVersion> list({int? limit}) {
    final all = _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (limit != null && limit < all.length) return all.sublist(0, limit);
    return all;
  }
}

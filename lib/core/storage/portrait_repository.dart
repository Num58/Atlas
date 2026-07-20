import 'package:primeatlas/core/portrait/portrait_types.dart';

/// Persistence contract for portrait versions (§7.2).
abstract class PortraitRepository {
  void save(PortraitVersion version);
  PortraitVersion? get(String versionId);
  List<PortraitVersion> list({int? limit});
}

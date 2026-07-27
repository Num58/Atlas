import 'dart:convert';

import 'package:crypto/crypto.dart';

String journeySha256Hex(String input) =>
    sha256.convert(utf8.encode(input)).toString();

String journeyCanonicalJson(Object? value) => jsonEncode(value);

/// Deterministic UUIDv7-shaped TEXT id derived from owner/kind/operation.
String journeyStableId(String ownerId, String kind, String operationId) {
  final digest = journeySha256Hex('$ownerId|$kind|$operationId');
  return [
    digest.substring(0, 8),
    digest.substring(8, 12),
    '7${digest.substring(13, 16)}',
    'a${digest.substring(17, 20)}',
    digest.substring(20, 32),
  ].join('-');
}

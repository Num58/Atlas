# ADR-003: UUIDv7 作为稳定全局 ID

## Status
Accepted (2026-07-21)

## Context
稳定 ID 必须可离线生成、全局唯一并适合 SQLite TEXT 主键。候选为 UUIDv4、UUIDv7、ULID。

## Decision
唯一推荐 UUIDv7，规范表示为小写带连字符文本。RFC 9562 定义其 48 位 Unix 毫秒前缀与 74 位随机/可选单调数据；比 UUIDv4 有更好索引局部性，比 ULID 有 IETF 标准与当前 Dart `uuid` v7 支持。所有真实业务时间仍以 `*_at_us` 为准，不解析 ID 作业务时间。

## Consequences
ID 暴露粗粒度生成时间；不能作授权令牌。SQLite 列保持 `TEXT`。生成依赖已精确锁定为 `uuid 4.6.0`。时钟回退时生成值不保证单调；排序收益仅指跨毫秒的时间前缀局部性，同毫秒内不得依赖 ID 顺序表达业务先后。

## Verification
`uuid 4.6.0` 已精确写入 pubspec/lockfile；标准：<https://www.rfc-editor.org/rfc/rfc9562.html>。`test/architecture/uuid_v7_verification_test.dart` 在 Flutter `3.44.2`/Dart `3.12.2` 通过：规范格式、固定时间/随机字节、同毫秒 4096 次 CSPRNG 唯一、时钟回退显式非单调、SQLite TEXT 跨毫秒排序。命令：`flutter test test/architecture`。

## Related ADRs
ADR-004、ADR-006

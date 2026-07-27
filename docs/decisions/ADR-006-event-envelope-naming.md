# ADR-006: snake_case 与事件 Envelope v1

## Status
Accepted (2026-07-21)

## Context
现有简化事件记录不足以支持 owner 隔离、聚合版本、因果追踪、重放和兼容读取。

## Decision
SQLite 表/列使用 snake_case、复数表名。`domain_events` 使用固定 Envelope：ID、owner、event/schema/aggregate、operation/causation/correlation、actor/source/device sequence、occurred/recorded/timezone、canonical payload 与 SHA-256 hash。writer 只写 `schema_version=1`；reader 忽略未知可选字段并拒绝未知必需字段。

## Consequences
事件记录变大，但审计和兼容边界明确。枚举新增不是自动兼容，必须 reader 分支与迁移。

## Verification
序列化 golden、payload hash、未知可选/必需字段、未知枚举、device sequence、时区/时钟回退 fixture；事件与 ADR-004 同事务。

## Related ADRs
ADR-003、ADR-004、ADR-005

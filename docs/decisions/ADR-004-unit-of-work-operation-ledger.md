# ADR-004: 共享 UnitOfWork 与 operation ledger

## Status
Accepted (2026-07-21)

## Context
身份确认等写操作必须把聚合、事件、审计和幂等结果原子提交，并支持崩溃后的确定性重放。

## Decision
全部 SQLite Repository 共享 `PrimeAtlasDatabase`/Connection 与 UnitOfWork。纳入独立 `operation_ledger`，以 `(owner_id,operation_id)` 唯一，存 `payload_hash/result_json/state/error_code`，与业务写、事件、审计在同一事务落盘。

`operation_ledger` 仅表达本地 `committed/rejected`；不是同步 outbox，禁止 pending/syncing/synced、worker、cursor、push/pull，也不含 tombstone operation。

## Consequences
重试可返回原结果，不重复事件；账本占用少量本地空间。所有写用例必须通过 UoW，Repository 不自行开启互不相干的连接。

## Verification
同 operation 同 hash 单副作用；不同 hash 返回 `idempotency_key_reused`；在每个写点注入 `SQLITE_FULL/BUSY` 均整笔回滚；进程重启后重放结果一致。

## Related ADRs
ADR-002、ADR-005、ADR-006、ADR-011

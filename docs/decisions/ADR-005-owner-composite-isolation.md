# ADR-005: owner_id 复合外键与 Repository 隔离

## Status
Accepted (2026-07-21)

## Context
即使 V0.2 只有本地 guest，也不能允许跨主体读取或把一个 owner 的子对象关联到另一个 owner。

## Decision
每个用户数据表含 `owner_id` 与 `UNIQUE(owner_id,id)`；子表通过 `(owner_id,parent_id)` 复合外键关联。所有 Repository 方法首参为 `OwnerId`，SQL 首要谓词包含 owner。禁止先按 id 查询再在 Dart 层比对 owner。

## Consequences
Schema 与查询略长，但隔离可由 SQLite 强制；未来主体迁移无需重写所有边界。

## Verification
开启 `PRAGMA foreign_keys=ON`；对每个 Repository 跑 owner A/B 读、写、更新、复合 FK 正反测试；越权返回确定性 `account_ownership_mismatch` 且双方 checksum 不变。

## Related ADRs
ADR-003、ADR-004、ADR-006

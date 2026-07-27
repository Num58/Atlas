# ADR-011: V0.2 排除 Tombstone，retention N/A

## Status
Accepted (2026-07-21)

## Context
V0.2 没有删除 UI、备份导入/恢复或远端删除传播。归档和画像历史恢复都保留对象，不构成删除。

## Decision
V0.2 baseline 不创建 `tombstones`，Repository 不执行 tombstone 排除查询，不定义防复活错误、清理 job 或 `retain_until_us`。`DATA-TS-01=不纳入`；依赖它的 `DATA-RET-01=N/A`。`operation_ledger.operation_type` 不含 tombstone。

## Consequences
避免无用表、虚假保留政策和未来同步语义。若后续 Release 增加删除或旧备份恢复，必须先写新 ADR、forward migration、治理政策和防复活 fixture。

## Verification
baseline/schema snapshot 无 tombstone 表；路由和 Use-case 无删除/恢复入口；源码无 retention 常量/清理任务；operation ledger 枚举无 tombstone。

## Related ADRs
ADR-004、ADR-005

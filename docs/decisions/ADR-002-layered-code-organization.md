# ADR-002: 分层目录、依赖方向与文件组织

## Status
Accepted (2026-07-21)

## Context
本地 Flutter MVP 仍需阻止页面直连 SQLite、领域依赖 Flutter 和巨型入口文件。

## Decision
采用 `lib/app -> lib/application -> lib/core`，`lib/infrastructure` 实现 core Port 并由入口装配。页面不写 SQL；Repository 不含业务决策；跨功能经 Use-case/Port。每个源文件一个主职责且不超过 300 行，入口只装配，按功能/资源分包。

## Consequences
边界更可测，事务由 application/UoW 编排；会增加少量接口文件，但不引入服务拆分或代码生成框架。

## Verification
静态依赖扫描、文件行数检查；架构测试拒绝 core 导入 Flutter/SQLite、app 直连 Repository/SQL。

## Related ADRs
ADR-001、ADR-004、ADR-005

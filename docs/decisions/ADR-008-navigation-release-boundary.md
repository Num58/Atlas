# ADR-008: V0.2 两入口与终局四入口兼容

## Status
Accepted (2026-07-21)

## Context
V0.2 只覆盖身份—目标闭环，而终局信息架构为“今日/旅程/成长域/我的”。复制原型六 Tab 会扩大 Release。

## Decision
V0.2 一级入口仅“旅程”和“我的”。后续扩为四入口时保留两者 route ID、对象 ID 与返回语义。Today、训练、Pulse、知识、PR、连接与权限页面不注册路由、导航或 feature。

## Consequences
界面范围可控且不会形成第二套数据真源；未来增加两入口需单独 Release 决策。

## Verification
导出 route/feature registry、semantics tree 与 SQLite 表计数：范围外入口、文案和对象为 0；未知深链确定性拒绝。

## Related ADRs
ADR-001、ADR-007、ADR-009

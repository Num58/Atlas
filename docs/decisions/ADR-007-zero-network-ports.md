# ADR-007: N/A Port、ThrowOnCall 与零网络门

## Status
Accepted (2026-07-21)

## Context
静默 no-op adapter 只能说明调用没有效果，不能证明纯本地 Release 没有发起范围外调用。

## Decision
生产可用显式 disabled adapter；测试默认注入 `ThrowOnCall` 实现，任何 Auth/CloudSync/RemoteDiscovery/Health/Calendar/Location/Content 调用立即抛出 `UnexpectedExternalCall` 并记录 adapter/method。CI 同时扫描禁用网络依赖与 import。

## Consequences
范围扩张会立即使测试失败；测试装配必须显式。V0.2 不提供 HTTP client/server。

## Verification
核心 E2E 断网通过；所有 ThrowOnCall 计数为 0；lockfile 与源码网络依赖/调用为 0；Android/iOS 测试代理业务请求为 0。

## Related ADRs
ADR-001、ADR-008

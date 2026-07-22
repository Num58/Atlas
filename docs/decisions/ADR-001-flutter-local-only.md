# ADR-001: Flutter 本地优先 V0.2 与 HTTP/OpenAPI N/A

## Status
Accepted (2026-07-21)

## Context
V0.2 只交付设备内“身份—目标”闭环。仓库为 Flutter 应用，当前 Release 无服务端、认证、远程同步或 HTTP 边界。

## Decision
使用 Flutter 本地应用 + SQLite；锚定 Flutter `3.44.2`、Dart `3.12.2`。HTTP、REST 与 `openapi.yaml` 对 V0.2 为 N/A。契约为 Dart Use-case、Repository Port 与 SQLite schema。

## Consequences
无需服务器和网络依赖；断网必须完整可用。未来引入 HTTP 时另建 `/api/v1/` 与 OpenAPI，不把本地签名伪装成 REST。

## Verification
保存 SDK machine manifest；lockfile/源码禁用 HTTP client/server；断网 E2E 与抓包业务请求均为 0。

## Related ADRs
ADR-002、ADR-007、ADR-008

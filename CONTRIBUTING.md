# Contributing to PrimeAtlas

## Branch strategy（强制）

为避免多 feature 分支并发合并冲突，本仓库采用**单线集成**：

| 分支 | 用途 | 规则 |
|---|---|---|
| `main` | 受保护发布线 | 仅 PR 合入；禁止 force push |
| `develop` | V0.2 唯一日更集成线 | 所有进行中的开发只落这里 |
| 短期修复分支 | 仅在需要隔离审查时使用 | 命名 `fix/<topic>`，当天合回 `develop` 后删除 |

**禁止：**
- 并行拉一堆 `feature/*` 长期分支
- 直接在 `main` 上提交
- force push `main` / `develop` 已共享历史

**允许：**
- 在 `develop` 上连续小步提交（检查点）
- 文档、代码、测试在同一条集成线上演进

## 提交规范

```
type: short summary in English or Chinese
```

推荐 type：
- `feat` 功能
- `fix` 缺陷
- `docs` 文档
- `test` 测试
- `chore` 工程卫生
- `refactor` 重构（不改行为）

一次提交只做一类事。检查点提交可以有，但**不得**自称 Dev Ready。

## 质量门禁（递进）

| 级别 | 何时 | 最低要求 |
|---|---|---|
| Checkpoint | 推到 `develop` | `dart analyze` 相关文件 + 相关单测/smoke 可复现 |
| Feature complete | 需求验收 | unit/integration 对应该需求绿 |
| Dev Ready | 申请合 `main` | `T-V02` 合同门禁 + 零网络 + 设备/无障碍证据 |

未过门禁不得合 `main`，不得改 README 为“可发布”。

## 工作区卫生

- 不把 SDK、AVD、日志、agent 临时 txt 提交进仓
- 临时证据写到仓库外 `F:/AIPM/Atlas/deliverables/` 或 `.workbuddy/`
- 大型工具链使用 `.gitignore` 中的隔离目录

## 冲突预防

1. 一天只维护一条集成线：`develop`
2. 大改前先拉最新 `develop`
3. 优先小 PR / 小提交，而不是长期分叉
4. Schema / 路由 / Token 变更先改合同文档再改代码

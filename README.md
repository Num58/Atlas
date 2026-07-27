# PrimeAtlas

> 不是“今天做了吗”，而是“离目标近了吗”。
> Flutter · Android / iOS · 本地优先 · V0.2 纯本闭环

PrimeAtlas 管理用户的成长方向与目标证据，而不是简单的待办清单。

```text
方向 / 现实约束
  → 成长域
  → 目标与里程碑
  → 旅程总览与本机版本
  → （后续）执行反馈与重校准
```

---

## 当前状态（诚实）

| 项 | 状态 |
|---|---|
| 产品 / V6 原型 | 用户已批准为体验基线 |
| 规格与研发合同 | V0.2 已锁定 |
| 工程集成线 | `develop`（唯一日更线） |
| 最新检查点 | 见 `develop` 最新 commit |
| Dev Ready | **否** |
| 合入 `main` 发布 | **否** |

当前阶段：**M2 Journey 真持久化闭环（检查点）→ 准备 M3 业务完整化**

---

## 仓库运营约定

- **不拉长期 feature 分支丛**，避免合并冲突雪崩
- 日常开发只在 **`develop`**
- **`main` 受保护**，仅通过 PR 在门禁通过后合入
- 检查点可以推送；**完成/发布必须有测试证据**

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

---

## 本地开发

```bash
# 建议 Flutter 3.44.x / Dart 3.12.x（以 pubspec 与 lock 为准）
flutter pub get
dart analyze
flutter test test/app
flutter test test/infrastructure/storage/sqlite
```

V0.2 范围说明：纯本地闭环；无 HTTP 业务、无云同步、无登录注册、无第三方模型。

---

## 目录

```text
lib/
  app/                 UI、路由、Riverpod 装配
  application/         用例 / Port
  core/                纯 Dart 领域
  infrastructure/      SQLite 等实现
docs/
  spec/                V0.2 合同与追踪
  qa/                  门禁基线
  status/              进度与运营状态
  decisions/           ADR
  prototype/           V6 等批准原型
test/                  单元 / 集成候选
```

---

## 真源优先级

1. 用户已批准的 V6 体验基线与产品红线
2. `docs/spec/v0.2-development-contract-v1.0.md`
3. `docs/spec/v0.2-test-traceability-v1.0.md`
4. `docs/qa/v0.2-dev-gate-baseline-2026-07-27.md`
5. `docs/status/` 进度文档
6. 代码实现（不得反向覆盖合同）

---

## 产品红线

- 不替用户定义身份 / 角色
- 功能图标仅 Lucide SVG allowlist（禁止 emoji 作图标）
- 禁止紫粉渐变与空洞 AI 模板文案
- 未成功写入不得显示“已保存到本机”

---

## 进度

- 阶段进度：`docs/status/development-progress.md`
- 工作区交付看板（仓库外）：`F:/AIPM/Atlas/deliverables/`

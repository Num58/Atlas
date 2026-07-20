# PrimeAtlas Phase1 · 开发规格说明书（Dev Specification）

> **文档性质**：开发执行规格（Step 2 / 5，重建 `Num58/Atlas` → PrimeAtlas）
> **状态**：Draft for review（供架构师与开发 Agent 评审）
> **日期**：2026-07-17
> **作者**：许清楚（PM / 产品负责人代表）
> **基于（绝对路径）**：
> - 交接包（需求 truth source）：`F:\AIPM\Atlas\deliverables\dev-handoff\handoff-dev-phase1-s0-2026-07-17.md`
> - 任务卡清单：`F:\AIPM\atlas-repo\docs\product\task-cards-phase1-gaps-2026-07-17.md`（44 卡）
> - 三缺口 PRD：`F:\AIPM\atlas-repo\docs\product\prd-blueprint-gaps-2026-07-17.md`（9 红线 / Non-goals / M0）
> - 完整蓝图：`F:\AIPM\atlas-repo\docs\product\PrimeAtlas_完整需求蓝图_Final.md`
> - 蓝图缺口分析：`F:\AIPM\atlas-repo\docs\product\analysis-primeatlas-blueprint-2026-07-17.md`
> - 融合可见 PRD（背景）：`F:\AIPM\atlas-repo\docs\product\prd-fusion-visible-phase1-2026-07-17.md`
>
> **一句话目的**：将三大硬缺口（调性 / 冲突检测 / 画像动态更新）补完 Phase1 的 44 张开发就绪任务卡，转化为**以 Flutter/Dart + local-first 为唯一技术表达**的开发目标、验收目标与范围声明，供架构师与开发 Agent 落地。

---

## 〇、技术栈 Reconciliation（M0 冻结决策，覆盖交接包 §6）

> **产品负责人（胜总）M0 冻结决策——本文件唯一技术基准，覆盖交接包 §6 的 Node/TS/Fastify 推荐。**

| 交接包 §6 表达（已废弃） | 本文件权威表达（Flutter / local-first） |
|--------------------------|------------------------------------------|
| 后端 Node + TypeScript + Fastify | **本地优先纯 Dart 核心层 `lib/core`，无服务端、零外部依赖** |
| `identity_event_bus` 内存 + 可选 SQLite | **本地事件总线 `IdentityEventBus`（Dart Stream + 持久化）**，持久化用本地 DB（如 drift/Isar/SQLite），预留 cloud-sync hook |
| 看板查询 API（REST） | **本地查询层**：对本地持久化事件日志（local event log）做按类型/时间的查询 |
| 前端 vanilla HTML / 框架 | **Flutter UI 层 `lib/app`**，复用原型 `primeatlas-prototype-v6.html` 的 `--tone-*` CSS 语义变量引擎映射为 Flutter `Theme`/设计 Token |
| 埋点校验器 + 最简查询 API | **`lib/core/events`**：schema 定义 + 运行时校验器（非法 payload 拒绝率 100%）+ 本地看板底座 |

**关键约束（贯穿全文）**：
- 所有"后端"= `lib/core` 纯 Dart，无网络、无服务器；"看板 API"= 本地查询方法；"前端"= `lib/app`。
- 9 条红线、44 张任务卡、事件 schema、M0 决策、Non-goals **100% 沿用**，仅技术表达由 Node/Web 改写为 Flutter/Dart/local-first。
- 架构建议目录：`lib/core/events`（bus + schema + validator）、`lib/core/tone`、`lib/core/conflict`、`lib/core/portrait`、`lib/app`（UI）、`lib/data`（本地持久化）。
- 测试：采用 `flutter_test` + `mocktail`，P0 卡覆盖率门槛 ≥ 80%（原 Vitest 对应物）。

---

## 一、文档元信息

| 字段 | 内容 |
|------|------|
| 标题 | PrimeAtlas Phase1 三大硬缺口 · 开发规格说明书 |
| 项目 | PrimeAtlas「个人成长操作系统」，定位「陪你成为」，刻意脱离健身 App 归类 |
| 日期 | 2026-07-17 |
| 基于 | 交接包 handoff-dev-phase1-s0 + 5 份产品文档（见页首） |
| 状态 | Draft for review（待架构师/开发 Agent 评审与产品负责人终审） |
| 目的 | 以 Flutter/Dart/local-first 为唯一技术表达，定义三大硬缺口 Phase1 的开发目标、可测验收目标与范围边界，作为 S0→S10 工程执行基准 |

---

## 二、开发目标（Development Goals）

> 三大硬缺口 + 事件总线，共四组目标。每张卡 ID 与红线可追溯到 §三、§五。

### 2.1 调性系统 Tone（对应卡 T2-1 / T2-2 / T2-3 / T2-4 + T1/T3/T4/T5/TRK-T*）

**目标陈述**：用一套 **4 调性 × CSS 语义变量引擎**（单一真源，防换皮）让四种调性（热血 / 专业 / 陪伴 / 严厉）在文案、视觉、交互、推送四层全层一致生效；强化身份认同、规避"健身 App"归类；切换受健康带宽约束、同会话守恒、严厉调性不可引发焦虑。

- **4 调性命名（M0 冻结）**：展示名（中文）= 专业 / 陪伴 / 热血 / 严厉；**代码枚举（Dart `Tone`，架构 §5.1 为权威真源）= `professional` / `warm` / `encouraging` / `strict`**（即 专业=`professional`、陪伴=`warm`、热血=`encouraging`、严厉=`strict`）；**默认主调 = `professional`（专业）**；Phase1 锁主调、渐进解锁。
  > ✅ 口径已对齐（架构 §5.1 / ADR）：M0 中文四名与代码枚举的唯一映射已由架构师在 `Tone` 枚举定稿——展示层用中文四名，代码层用 `professional | warm | encouraging | strict`。早期任务卡 T2-1 的 `warm/encouraging` 字面（温和/激励）为过渡表述，最终以本映射为准，详见 §六 项 3（已闭环）。
- **CSS 语义变量引擎**：以 `--tone-primary / --tone-radius / --tone-font / --tone-ease` 等语义变量切根（单一真源），Flutter 侧映射为 `ThemeExtension`/设计 Token，`lib/app` 全层消费统一 Token，非多套 UI。
- **T2-1（契约）**：`ToneState` 状态机覆盖 4 身份阶段（启程者/践行者/进阶者/掌控者）× 调性合法状态空间；`ToneSwitchRequest/Response` 含 `health_bandwidth` 剩余量与 `intervention`；`HealthBandwidthConfig` 完整。
- **T2-2（算法）**：状态机核心 + 健康带宽检测 + 切换干预（gentle_nudge / cooldown），非阻断。
- **T2-3（集成）**：将调性引擎封装为 `lib/core/tone` 暴露给 `lib/app` 的 Dart API（`switchTone` / `getToneState` / `getHealthBandwidth`），切换时触发 `tone_change_event`。
- **T2-4（测试）**：状态机全路径 + 健康带宽边界 + 并发切换单测/压测，覆盖率 ≥ 80%。
- **关联 UI**：T1 默认调性设定（约束 B 默认开「聚焦卖点」）、T3 内容评审（焦虑量表）、T4 预览、T5 切换提示；埋点 TRK-T1/T2/T3/V3。

### 2.2 冲突检测 Conflict（对应卡 C1-1 / C1-2 / C1-3 / C1-4 + C2/C3/C4/C5/TRK-C*）

**目标陈述**：冲突一律以「权衡提示 + 透明双轨裁决（一键采纳 / 我自己来）」呈现，**绝不硬阻断**用户；身体相关冲突走专用安全通道，给出可追溯理由；保留覆盖权。

- **C1-1（契约）**：`ConflictDetectionResult` 含 `conflict_type / is_body_related / body_reason / body_reason_traceable_id / disposition`；契约层固化 **`disposition.blocked_user` 恒为 `false`**；`conflict_type` 枚举完整（goal_goal / goal_body / goal_resource / goal_identity）；`Orchestration` 含 `type / rationale / safety_channel_required`。
- **C1-2（算法）**：目标冲突识别 + 身体冲突判定 + 理由追溯链生成 + 仲裁编排推荐；非阻断设计。
- **C1-3（集成）**：封装为 `lib/core/conflict` Dart API（`detect` / `getConflict`），触发 `conflict_detected`。
- **C1-4（测试）**：全冲突类型 + 身体理由追溯 + 并发检测单测/压测。
- **tradeoff-not-block**：冲突呈"权衡非禁止"（C-RL1）；**dual-track arbitration**：双轨透明展示依据 + 保留"我自己来"覆盖入口（C-RL2）；**body-safety channel**：身体冲突自动路由安全通道，理由 `body_reason_traceable_id` 可追溯（C-RL3）。
- **关联 UI**：C2 仲裁界面、C3 展示卡片、C4 身体冲突安全通道（Phase1 即接入，需 consent + 合规）、C5 覆盖保留；埋点 TRK-C1/C2/V1/V2。

### 2.3 画像动态更新 Portrait（对应卡 P3-1 / P3-2 / P3-3 / P3-4 + P1/P2/P4/P5/TRK-P*）

**目标陈述**：画像以「版本化 + 动态轴雷达（仅活跃维度）+ 过渡态叙事」让身份进度飞轮闭环；未用维度不占位、系统绝不自动改画像。

- **P3-1（契约）**：`PortraitVersion`（version_id / snapshot / change_summary / consent_record_id）、`VersionDiff`（changes[] / has_narratable_change）、`ProfileSnapshot`（active/inactive_dimensions 区分）。
- **P3-2（算法）**：版本快照生成 + 版本差异计算 + 维度激活/停用管理 + 回溯；`inactive_dimensions` 的 `occupied_storage=false`（P-RL1）。
- **P3-3（集成）**：封装为 `lib/core/portrait` Dart API（createVersion / diff / rollback / getDimensionStatus），身份角色变化时触发 `identity_transition_event`。
- **P3-4（测试）**：单测/压测，覆盖率 ≥ 80%。
- **versioning**：每次画像变更生成新 `portrait_version`，`confirm_source` 仅可为 user_explicit / user_override（P-RL2）。
- **dynamic-axis radar**：雷达仅渲染已激活维度（P-RL1），新轴生长动画；身份角色命名 启程者→践行者→进阶者→掌控者。
- **transition narrative**：仅 `identity_transition_event` 有可讲述变化才显叙事（P-RL3）。
- **关联 UI**：P1 字段管理、P2 身份叙事渲染、P4 维度管理、P5 确认流程；埋点 TRK-P1/P2/P3。

### 2.4 身份事件总线 identity_event_bus（对应卡 TRK-M0-INFRA + 全部 TRK-*）

**目标陈述**：作为全局数据前置与单点底座，提供 **publish / subscribe / validate + 持久化 + 看板底座**，使 9 条红线均可经事件流获得可测信号。

- **TRK-M0-INFRA（S0 关键路径，全局单点）**：`IdentityEventBus`
  - `publish(eventType, payload) → EventReceipt`
  - `validate(eventType, payload) → ValidationResult`
  - 支持发布/订阅/持久化（本地 DB）；6 事件 schema 含字段类型 + 必填校验；校验器非法 payload 拒绝率 = 100%；看板底座支持按事件类型/时间查询。
  - 6 事件 schema：`tone_change_event` / `content_tone_tag` / `conflict_detected` / `arbitration_event` / `profile_field_update` / `identity_transition_event`（另含 `dimension_data_presence`，共 7 类 payload，详见任务卡 §一）。
- **全部 TRK-* 卡（12 张）**均依赖 TRK-M0-INFRA：TRK-T1/T2/T3/V3（调性）、TRK-C1/C2/V1/V2（冲突）、TRK-P1/P2/P3（画像），每张对应一条/一组红线的看板信号。
- **看板底座（dashboard base）**：本地查询层，按事件类型/时间维度聚合，供 9 条红线告警（见 §七）。

> ⚠️ **TRK-M0-INFRA 是全局单点故障**：S0 不完成，M1–M3 全部红线验收阻塞。必须最先落地。

---

## 三、验收目标（Acceptance Goals）

> 将 9 条验收红线（handoff §3）翻译为**可测、可量化**的验收目标。每条含：红线原文、可度量断言、校验方法。所有信号须经 `identity_event_bus` + 看板底座可查（详见 §七）。

### 3.1 调性 Tone

| 红线 | 红线原文（handoff §3） | 可度量断言（Acceptance Criteria） | 校验方法 |
|------|------------------------|-----------------------------------|----------|
| **T-RL1** 切换健康带宽 | 周切换 1–2 次且系统不阻拦；禁止把切换标为罪感 | ① `tone_change_event.blocked_by_system == false` 占比 = 100%；② 将切换标记为"罪感"的提示文案计数 = 0（词表静态扫描 + 内容评审）；③ 健康带宽内（remaining>0）切换占比可查，周切换分布落在 1–2 次健康区间 | 看板查询（TRK-T1）+ 单测（T2-2 健康带宽算法）+ 词表扫描单测 |
| **T-RL2** 同会话守恒 | 同会话调性一致、跨会话渐进解锁；会话内无故漂移即不合格 | ① `content_tone_tag.consistent_with_anchor == true` 占比 ≥ 95%；② 同会话内 `session_anchor_tone` 不变（无故漂移计数 = 0）；③ `ToneState` 状态机拒绝非法转换率 = 100% | 看板查询（TRK-T2）+ 状态机单测（T2-2/T2-4） |
| **T-RL3** 严厉不焦虑 | 严厉主调无罪感/威胁/羞辱词，呈"陪你成为"；焦虑触发词或量表显著升即不合格 | ① 严厉模式下所有文案/视觉/交互/推送命中 guilt/anxiety/shame 词表 = 0；② `anxiety_measure.score` 在严厉上下文无显著上升（阈值由数析定）；③ `threat_word_hit == false` 占比 = 100% | 内容评审（T3）+ 焦虑量表埋点（TRK-T3）+ 词表扫描单测 |

### 3.2 冲突 Conflict

| 红线 | 红线原文（handoff §3） | 可度量断言（Acceptance Criteria） | 校验方法 |
|------|------------------------|-----------------------------------|----------|
| **C-RL1** 不硬阻断 | 冲突呈权衡/提示可继续；禁止/阻断拦截即不合格 | ① `conflict_detected.disposition.blocked_user == false` **100%**（恒 false）；② 无"禁止/阻断拦截"UI 路径 | 看板查询（TRK-C1）+ 断言单测（C1-3/C1-4） |
| **C-RL2** 透明 + 保留覆盖 | 裁决双轨透明展示依据且保留"我自己来"；强制默认、无覆盖入口即不合格 | ① `arbitration_event.rationale_display_complete == true` 占比 = 100%；② `retained_override_entry == true` 可点（"我自己来"入口存在率 = 100%）；③ 无强制默认勾选 | 看板查询（TRK-C2）+ UI 验收（C2） |
| **C-RL3** 身体理由可查 | 身体冲突给可追溯理由；理由缺失即不合格 | ① 当 `is_body_related == true` 时，`body_reason_traceable_id` **存在率 = 100%**；② 理由缺失事件数 = 0；③ 安全通道内容经合规审核 | 看板查询（TRK-C1）+ 断言单测（C1-3）+ 合规检查（C4） |

### 3.3 画像 Portrait

| 红线 | 红线原文（handoff §3） | 可度量断言（Acceptance Criteria） | 校验方法 |
|------|------------------------|-----------------------------------|----------|
| **P-RL1** 未用维度不占位 | 未激活维度不占界面/存储；一致率须 100% | ① `dimension_data_presence.rendered == is_active` 一致率 = **100%**；② `is_active == false` 时 `occupied_storage == false` 一致率 = **100%** | 看板查询（TRK-P3）+ UI 验收（P4） |
| **P-RL2** 不自动改画像 | 变更需用户确认；系统自动改写即告警 | ① `profile_field_update.confirm_source == system_auto` 占比 = **0**（>0 即告警）；② 全部变更经 consent_record_id 关联 | 看板查询（TRK-P1）+ 告警（占比>0 即触发） |
| **P-RL3** 叙事按变化显隐 | 仅 `identity_transition_event` 有可讲述变化才显；一致率须 100% | ① `identity_transition_event.narrative_shown == has_narratable_change` 一致率 = **100%**；② 无变化却显示叙事事件数 = 0 | 看板查询（TRK-P2）+ 断言单测（P2/P3-3） |

### 3.4 防虚荣副指标（数析口径，须一并验收）

| 指标 | 定义 | 健康区间 | 校验方法 |
|------|------|----------|----------|
| V3 调性防虚荣 | 有效切换率 = `health_bandwidth.remaining>0` 的切换 / 总切换（cooldown 期不计入） | 趋势可查，非最大化 | 看板（TRK-V3）消费 `tone_change_event` |
| V1 冲突防虚荣 | 有效冲突率 = 用户产生交互的冲突 / 检出冲突总数 | 趋势可查 | 看板（TRK-V1）消费 `conflict_detected`+`arbitration_event` |
| V2 仲裁防虚荣 | 有效仲裁率 =（one_click_adopt 有后续行为 + i_will_do_it 有 user_initiated_edit）/ 总仲裁 | 趋势可查 | 看板（TRK-V2）消费 `arbitration_event` |

> **通用校验基线（TRK-M0-INFRA）**：校验器对非法 payload 拒绝率 = **100%**（单测覆盖）；看板底座按事件类型/时间查询可用（演示通过）；数析契约 sign-off 通过。

---

## 四、范围声明（Scope）

### 4.1 Non-goals（M0 冻结，逐字沿用 handoff §2，100% 权威）

- ❌ **不自动改写用户画像**：任何画像变更需用户显式确认（P-RL2）。
- ❌ **不以禁止/阻断方式处理冲突**：冲突一律呈权衡提示（C-RL1）。
- ❌ **不为未激活维度保留占位卡/灰块**：未用维度完全不出现（P-RL1）。
- ❌ **不做多套独立 UI 换皮**：调性统一用 CSS 语义变量引擎，单一真源（防换皮、防漂移）。
- ❌ **三大模块指标不进北极星**：均为 Process/Guardrail，身份进度指数动态权重不变。
- ❌ **不引入社交/排行榜/好友机制**：避免归类回健身 App 与焦虑源。
- ❌ **不在同会话内漂移调性**：同会话守恒（T-RL2）。

### 4.2 M0 已冻结决策（5 项，handoff §2 表，不可再议除非产品负责人显式推翻）

| # | 决策 | 内容（Phase1 约束） |
|---|------|----------------------|
| 1 | 需求池口径 | 采明细口径：P0=9 / P1=6 / P2=3，模块 79 人日 + ~6 缓冲 = 85 人日；44 卡 / P0 硬门槛 34 张 / 77.5 人日 |
| 2 | 调性命名 + 默认主调 | 热血 / 专业 / 陪伴 / 严厉；**默认主调 = 专业**；Phase1 锁主调、渐进解锁 |
| 3 | 约束 B | 默认开启「聚焦卖点」提示（C6），用户可手动切换 |
| 4 | 身份角色命名 | 启程者 → 践行者 → 进阶者 → 掌控者（用于动态雷达轴命名 + 过渡态锚定） |
| 5 | 生理数据接入 | Phase1 **即接入** C4 身体冲突安全通道，需显式 consent + 合规；权限拒绝优雅降级，不阻断核心 |

> 注：M0 决策门已完全冻结，路线 C（补三大硬缺口）解锁，可转入工程执行。所有红线、任务卡、事件 schema 沿用，仅技术表达按 §〇 改写为 Flutter/Dart/local-first。

---

## 五、Sprint 映射（S0–S10）

> 44 张卡按双周 Sprint 排期。三条硬依赖链须严格按序。**S0 = 本轮交付物 = TRK-M0-INFRA + T2-1 + C1-1 + P3-1。**

### 5.1 全量卡 → Sprint 映射表

| Sprint | 周 | 阶段 | 卡 ID（44 张） | 小计 |
|--------|----|------|----------------|------|
| **S0** | W1–2 | M0 地基 | **TRK-M0-INFRA、T2-1、C1-1、P3-1** | 4（9.5 人日）|
| S1–S2 | W3–6 | M1 调性 | T1、T2-2、T2-3、T2-4、T3、T4、T5、TRK-T1、TRK-T2、TRK-T3、TRK-V3 | 11（26 人日）|
| S3 | W7–8 | M1→M2 过渡 | T6、C1-2 | 2（4 人日）|
| S4–S5 | W9–12 | M2 冲突 | C1-3、C1-4、C2、C3、C4、C5、TRK-C1、TRK-C2、TRK-V1、TRK-V2 | 10（28 人日）|
| S6 | W13–14 | M2→M3 过渡 | C6、P3-2 | 2（2.5 人日）|
| S7–S8 | W15–18 | M3 画像 | P3-3、P3-4、P1、P2、P4、P5、TRK-P1、TRK-P2、TRK-P3 | 9（22 人日）|
| S9 | W19–20 | 联调对账 | P6、INT-1、INT-2 | 3（4 人日）|
| S10 | W21–22 | 缺陷清零+灰度 | INT-3、INT-4、INT-5 | 3（3 人日）|

**合计**：44 张（模块 27 + 埋点 12 + 集成 5）；P0 硬门槛 34 张 / 77.5 人日。

### 5.2 三条硬依赖链（务必按顺序）

```
引擎链（契约 → 算法 → 集成 → 测试）：
  S0 T2-1(契约) → S1 T2-2(算法) → S2 T2-3(集成) → S2 T2-4(测试)
  S0 C1-1(契约) → S3 C1-2(算法) → S4 C1-3(集成) → S5 C1-4(测试)
  S0 P3-1(契约) → S6 P3-2(算法) → S7 P3-3(集成) → S8 P3-4(测试)

埋点基建链（critical path 单点故障）：
  S0 TRK-M0-INFRA → 全部 TRK-*（schema + bus 依赖）
  TRK-T1 → TRK-V3（消费 tone_change_event）
  TRK-C1 + TRK-C2 → TRK-V1, TRK-V2（消费冲突+仲裁事件）

集成收口链：
  全部 P0 模块卡 + 全部 TRK 卡 → S9 INT-1(联调) → INT-2(对账) → S10 INT-4(缺陷清零) → INT-5(灰度)
```

### 5.3 S0 本轮交付物（已确认范围，共 4 张卡 / 9.5 人日）

| 卡 ID | 内容 | 验收基线 |
|-------|------|----------|
| **TRK-M0-INFRA** | `identity_event_bus` 基建 + 6 事件 schema + 校验器 + 看板底座（local-first Dart） | bus 发布/订阅/持久化；校验器拒绝率 100%；看板可查询；数析 sign-off |
| **T2-1** | 调性引擎接口契约（`ToneState`/`ToneSwitchRequest/Response`/`HealthBandwidthConfig`） | 状态机覆盖 4 阶段×调性；设计 sign-off；接口文档入库 |
| **C1-1** | 冲突检测引擎接口契约（`ConflictDetectionResult`/`Orchestration`，`blocked_user` 恒 false） | 枚举完整；设计 sign-off |
| **P3-1** | 画像版本化引擎接口契约（`PortraitVersion`/`VersionDiff`/`ProfileSnapshot`） | active/inactive 区分；设计 sign-off |

> S0 形成可运行的本地事件总线 + 三引擎接口契约类型（Dart），作为 S1 起算法/集成/UI 卡的基准。TRK-M0-INFRA 为全局单点，须最先落地。

---

## 六、待确认口径差异（Open Items）

> 以下差异**不阻塞 S0**，但须记入台账，待产品负责人终审。

| # | 差异 | 现状 | 处理建议 | 阻塞？ |
|---|------|------|----------|--------|
| 1 | **模块人日口径**：逐项加总 = 69 人日，PRD 总括 = 79 人日（差 10 人日） | 疑似模块级设计规范/集成 overhead 未逐项列出 | 以逐项 69 为基准，差额 10 人日纳入 Sprint 级缓冲统筹 | 否 |
| 2 | **埋点卡数量**：数析原提 13 张，实际落卡 12 张（差 1 张） | 因 `identity_event_bus` 基建合并入 TRK-M0-INFRA 的 S0-01，逻辑自洽 | 与数析确认无遗漏即可 | 否 |
| 3 | **调性命名差异（已闭环）**：M0 文案"热血/专业/陪伴/严厉" vs 任务卡 T2-1 枚举 `professional\|warm\|encouraging\|strict`（专业/温和/激励/严厉） | 四调性展示名与枚举字面不一致 | ✅ **已解决**：架构 §5.1 定稿唯一映射 = 专业=`professional`、陪伴=`warm`、热血=`encouraging`、严厉=`strict`；展示名用 M0 四名，代码枚举用四英文键。dev-spec §2.1 已同步 | 否（已闭环） |

> 差异 1、2 源自交接包 §7；差异 3（调性命名）**已闭环**——架构 §5.1 定稿唯一中英文映射，dev-spec §2.1 已同步，S0 契约落库以该映射为准。

---

## 七、验收看板要求（Dashboard / Acceptance Instrumentation）

> 依据 handoff §3 头部要求：**9 条红线每条都须有可经事件总线 + 看板底座查询的可测信号**。

| 红线 | 信号事件（经 `identity_event_bus`） | 看板指标 | 告警阈值 |
|------|--------------------------------------|----------|----------|
| T-RL1 | `tone_change_event`（TRK-T1） | 切换频率/分布/cooldown 触发率/健康带宽非零占比 | blocked_by_system 出现即告警 |
| T-RL2 | `content_tone_tag`（TRK-T2） | consistent_with_anchor 占比/偏离分布/层拆分 | < 95% 即告警 |
| T-RL3 | `content_tone_tag` + `anxiety_measure`（TRK-T3） | 威胁词命中率/量表分布/调性上下文关联 | threat_word_hit>0 或量表显著升即告警 |
| C-RL1 | `conflict_detected`（TRK-C1） | 冲突检出率/类型分布/非阻断率 | disposition.blocked_user==true 即告警（须恒 false）|
| C-RL2 | `arbitration_event`（TRK-C2） | 采纳率/主动编辑率/rationale 展示完整率/覆盖保留率 | rationale_display_complete<100% 即告警 |
| C-RL3 | `conflict_detected`（TRK-C1） | 身体冲突占比/理由追溯率/安全通道触发率 | body_reason_traceable_id 缺失即告警 |
| P-RL1 | `dimension_data_presence`（TRK-P3） | 维度激活分布/渲染一致率/存储占用合规率 | rendered≠is_active 或 is_active=false 时 occupied_storage≠false 即告警 |
| P-RL2 | `profile_field_update`（TRK-P1） | 字段变更分布/确认来源分布/system_auto 占比 | confirm_source=system_auto 占比 >0 即告警 |
| P-RL3 | `identity_transition_event`（TRK-P2） | 角色转换分布/叙事展示率/显隐一致率 | narrative_shown≠has_narratable_change 即告警 |

**实现要求（local-first）**：
- 看板底座 = `lib/core/events` 之上的**本地查询层**，对持久化事件日志按事件类型/时间聚合，无服务端。
- 每条红线在看板底座须配置硬性告警（见上表阈值），由数析 sign-off。
- 防虚荣副指标 V1/V2/V3 须一并接入看板，防止"空转"通过红线。
- TRK-M0-INFRA 校验器对非法 payload 拒绝率 = 100% 为全局前置闸门。

---

## 八、交付与评审约定

- 本文件为 **Draft for review**，架构师（高见远）据此产出全量架构设计，开发 Agent 据 §二/§三/§五 落地 S0 起各卡。
- 任何范围外需求记入 §四 Non-goals；任何决策须有契约/数据支撑。
- 红线验收随 S0→S10 滚动 sign-off（埋点契约驱动），INT-2 数析最终 sign-off 为闸门。
- 9 条红线 + 防虚荣 V1/V2/V3 须在灰度（INT-5）期间持续处于阈值内，方可 100% 放量。

---

> 本文档由 PM（许清楚）整理，2026-07-17。重要决策以产品负责人（胜总）最终审定为准。技术表达已按 M0 冻结决策统一为 Flutter/Dart/local-first，覆盖交接包 §6。

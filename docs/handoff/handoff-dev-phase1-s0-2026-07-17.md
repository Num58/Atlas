# PrimeAtlas Phase1 开发续接上下文（Handoff Prompt）

> 本文档为「产品战略团队 → 开发专家团」的交接包。目标：让开发专家团在**不重读完整对话**的前提下，直接接管 PrimeAtlas 三大硬缺口补完 Phase1 的工程执行，从 **S0 全量地基**起步。
> 使用方式：将「第二部分起」整段粘贴给开发专家团作为首轮 prompt 即可；文件路径部分请按实际工作区调整。

---

## 〇、给开发专家团的一行定位

你/你们是开发领域专家（全栈 + 系统架构 + 工程实践）。基于以下上下文，将 PrimeAtlas 三大硬缺口 Phase1 的 44 张开发就绪任务卡逐步落地为**完整、可运行、带测试**的代码。工作铁律：**先明确目标与范围、识别风险与依赖，再给务实可落地的方案与代码；遇到不确定处主动提问而非猜测。**

---

## 一、项目背景与进展时间线（必读）

**PrimeAtlas** = 个人成长操作系统，定位「陪你成为」，刻意脱离健身 App 归类。当前专项：补完蓝图四维度评估中标注的**三大硬性缺失**——

1. **调性系统**（Tone）：4 调性 × CSS 语义变量引擎，全层一致
2. **冲突检测**（Conflict）：权衡非禁止 + 双轨裁决 + 身体安全通道
3. **画像动态更新**（Portrait）：版本化 + 动态轴雷达 + 过渡态叙事

**已完成的产品侧工作（全链路闭环）：**

| 阶段 | 产出 | 交付物（绝对路径） |
|------|------|------------------|
| 蓝图四维度评估 | 13 核心场景覆盖率≈42%，三大缺口定性 | `F:\AIPM\Atlas\deliverables\product-strategy\analysis-primeatlas-blueprint-2026-07-17.md` |
| 融合可见 Phase1 PRD | 10 节 17 条需求，验收红线 | `F:\AIPM\Atlas\deliverables\product-strategy\prd-fusion-visible-phase1-2026-07-17.md` |
| 三大缺口 Phase1 PRD | 18 条需求（P0=9/P1=6/P2=3），9 条验收红线 | `F:\AIPM\Atlas\deliverables\product-strategy\prd-blueprint-gaps-2026-07-17.md` |
| M0 设计冻结 | 5 项高管拍板，闸门完全冻结 | 同上 §10 决策记录 |
| **开发就绪任务卡清单** | **44 张卡（模块27+埋点12+集成5），S0–S10 排期** | `F:\AIPM\Atlas\deliverables\product-strategy\task-cards-phase1-gaps-2026-07-17.md` |

**现有代码资产：** `F:\AIPM\Atlas\primeatlas-prototype-v6.html`（v6 单页原型，纯 HTML + CSS 变量设计系统，含暗/亮双主题；是 T2 调性「CSS 语义变量引擎」的天然基座）。**工作区目前零后端脚手架**（无 package.json / src / node_modules）。

---

## 二、M0 已冻结决策（不可再议，除非产品负责人显式推翻）

| # | 决策 | 内容 |
|---|------|------|
| 1 | 需求池口径 | 采明细口径：P0=9 / P1=6 / P2=3，模块 79 人日 + ~6 缓冲 = 85 人日 |
| 2 | 调性命名 + 默认主调 | 热血 / 专业 / 陪伴 / 严厉；**默认主调 = 专业**；Phase1 锁主调、渐进解锁 |
| 3 | 约束 B | 默认开启「聚焦卖点」提示（C6），用户可手动切换 |
| 4 | 身份角色命名 | 启程者 → 践行者 → 进阶者 → 掌控者（用于动态雷达轴命名 + 过渡态锚定） |
| 5 | 生理数据接入 | Phase1 **即接入** C4 身体冲突安全通道，需显式 consent + 合规；权限拒绝优雅降级，不阻断核心 |

**Non-goals（明确不做什么）：** 不自动改写画像 / 不硬阻断冲突 / 不为未激活维度保留占位 / 不做多套独立 UI 换皮（单一 CSS 变量真源）/ 三模块指标不进北极星 / 不引入社交排行榜 / 不同会话内漂移调性。

---

## 三、9 条验收红线（硬性，埋点看板须配告警）

**调性 T**
- **T-RL1 切换健康带宽**：周切换 1–2 次且系统不阻拦；禁止把切换标为罪感
- **T-RL2 同会话守恒**：同会话调性一致、跨会话渐进解锁；会话内无故漂移即不合格
- **T-RL3 严厉不焦虑**：严厉主调无罪感/威胁/羞辱词，呈「陪你成为」；焦虑触发词或量表显著升即不合格

**冲突 C**
- **C-RL1 不硬阻断**：冲突呈权衡/提示可继续；禁止/阻断拦截即不合格
- **C-RL2 透明 + 保留覆盖**：裁决双轨透明展示依据且保留「我自己来」；强制默认、无覆盖入口即不合格
- **C-RL3 身体理由可查**：身体冲突给可追溯理由（body_reason_traceable_id）；理由缺失即不合格

**画像 P**
- **P-RL1 未用维度不占位**：未激活维度不占界面/存储（rendered==is_active；is_active=false 时 occupied_storage==false）；一致率须 100%
- **P-RL2 不自动改画像**：变更需用户确认（confirm_source=system_auto 占比须 = 0）；>0 即告警
- **P-RL3 叙事按变化显隐**：仅 identity_transition_event 有可讲述变化才显（narrative_shown == has_narratable_change）；一致率须 100%

> 防虚荣副指标（数析定义）：调性切换率×健康带宽非零 / 冲突检出率×有效冲突率 / 仲裁采纳率×主动编辑率。

---

## 四、任务卡全景与关键路径

**总量：** 44 张 = 模块开发 27 + 数据埋点 12（TRK-*）+ 集成收口 5（INT-*）。**P0 硬门槛 34 张 / 77.5 人日**，必须全交付才能进红线验收。

**Sprint 排期（双周）：** S0(W1–2) → S1–S2(W3–6, 调性) → S3(W7–8) → S4–S5(W9–12, 冲突) → S6(W13–14) → S7–S8(W15–18, 画像) → S9(W19–20, 联调对账) → S10(W21–22, 缺陷清零+灰度)。

**三条硬依赖链（务必按顺序）：**

```
引擎链：
  S0 T2-1(契约) → S1 T2-2(算法) → S2 T2-3(集成) → S2 T2-4(测试)
  S0 C1-1(契约) → S3 C1-2(算法) → S4 C1-3(集成) → S5 C1-4(测试)
  S0 P3-1(契约) → S6 P3-2(算法) → S7 P3-3(集成) → S8 P3-4(测试)

埋点基建链（critical path 单点故障）：
  S0 TRK-M0-INFRA → 全部 TRK-*（schema + bus 依赖）

集成收口链：
  全部 P0 模块卡 + 全部 TRK 卡 → S9 INT-1(联调) → INT-2(对账) → S10 INT-4(缺陷清零) → INT-5(灰度)
```

> ⚠️ **TRK-M0-INFRA 是全局单点故障**：S0 不完成，M1–M3 全部红线验收阻塞。必须最先落地。

---

## 五、本轮起点：S0 全量地基（已确认范围）

产品负责人确认 S0 一次性交付「埋点基建 + 三引擎接口契约」，形成可运行的事件总线 + 全部接口契约类型。共 4 张卡 / 9.5 人日。

### 5.1 【TRK-M0-INFRA】埋点基建（6 人日 / P0 / critical path）
- **描述**：`identity_event_bus` 基建 + 6 事件 schema + 校验器 + 看板底座。
- **验收标准**：① bus 支持发布/订阅/持久化；② 6 schema 定义完成且含字段类型+必填校验；③ 校验器非法 payload 拒绝率=100%；④ 看板底座支持按事件类型/时间查询；⑤ 数析契约 sign-off。
- **接口契约**：
  ```
  identity_event_bus.publish(event_type, payload) → EventReceipt
  identity_event_bus.validate(event_type, payload) → ValidationResult
  ```
- **6 个事件 schema（字段须完整定义类型与必填）：**
  | 事件类型 | 关键 payload 字段 |
  |---------|------------------|
  | `tone_change_event` | from_tone, to_tone, trigger, blocked_by_system, unlock_path |
  | `content_tone_tag` | session_anchor_tone, resolved_tone, layer(copy\|visual\|interaction\|push), consistent_with_anchor |
  | `conflict_detected` | conflict_type, is_body_related, body_reason, body_reason_traceable_id, disposition{blocked_user:false}, recommended_orchestration |
  | `arbitration_event` | conflict_id, chosen_track(one_click_adopt\|i_will_do_it), rationale_display_complete, retained_override_entry, user_initiated_edit |
  | `profile_field_update` | field_name, old_value, new_value, confirm_source(user_explicit\|user_override\|system_auto), consent_record_id, portrait_version |
  | `identity_transition_event` | transition_id, from_role, to_role, has_narratable_change, narrative_shown, change_summary |
  | `dimension_data_presence` | dimension, is_active, rendered, occupied_storage |
- **DoD(P0)**：数析 sign-off✓ + 校验器单测✓ + 看板底座演示✓

### 5.2 【T2-1】调性引擎接口契约（1 人日 / P0）
- **验收**：① ToneState 状态机覆盖 4 身份阶段 × 3 调性的合法状态空间；② ToneSwitchRequest/Response 含 health_bandwidth 剩余量与 intervention；③ HealthBandwidthConfig 参数完整；④ 设计 sign-off。
- **接口契约（TS 类型）**：
  ```typescript
  type Tone = 'professional' | 'warm' | 'encouraging' | 'strict'; // 专业/陪伴/激励/严厉
  type IdentityStage = 'initiate' | 'practitioner' | 'advanced' | 'master'; // 启程者/践行者/进阶者/掌控者
  interface ToneState { current_tone: Tone; session_anchor_tone: Tone; switch_count: number; last_switch_at: number; }
  interface ToneSwitchRequest { target_tone: Tone; trigger: 'user_explicit' | 'system_suggested' | 'context_adaptive'; context?: Record<string, unknown>; }
  interface ToneSwitchResponse { accepted: boolean; new_tone: Tone; health_bandwidth: { remaining: number; threshold: number }; intervention: 'none' | 'gentle_nudge' | 'cooldown'; }
  interface HealthBandwidthConfig { max_switches_per_session: number; cooldown_duration_ms: number; warning_threshold_pct: number; }
  ```
- **DoD(P0)**：设计 sign-off✓ + 接口文档入库✓ + 状态机图评审✓

### 5.3 【C1-1】冲突检测引擎接口契约（1.5 人日 / P0）
- **验收**：① ConflictDetectionResult 含 conflict_type/is_body_related/body_reason/body_reason_traceable_id/disposition；② disposition.blocked_user 恒 false 写入契约；③ conflict_type 枚举完整（goal_goal/goal_body/goal_resource/goal_identity）；④ Orchestration 模型含 type/rationale/safety_channel_required；⑤ 设计 sign-off。
- **接口契约（TS 类型）**：
  ```typescript
  type ConflictType = 'goal_goal' | 'goal_body' | 'goal_resource' | 'goal_identity';
  interface ConflictDetectionResult {
    conflict_id: string; conflict_type: ConflictType; is_body_related: boolean;
    body_reason?: string; body_reason_traceable_id?: string;
    disposition: { blocked_user: false; recommended_orchestration: Orchestration };
  }
  interface Orchestration { type: 'one_click_adopt' | 'i_will_do_it' | 'defer'; rationale: string; safety_channel_required: boolean; }
  ```
- **DoD(P0)**：设计 sign-off✓ + 接口文档入库✓ + 冲突分类树评审✓

### 5.4 【P3-1】画像版本化引擎接口契约（1 人日 / P0）
- **验收**：① PortraitVersion 含 version_id/snapshot/change_summary/consent_record_id；② VersionDiff 含 changes[]/has_narratable_change；③ ProfileSnapshot 区分 active/inactive_dimensions；④ 设计 sign-off。
- **接口契约（TS 类型）**：
  ```typescript
  interface PortraitVersion { version_id: string; created_at: number; snapshot: ProfileSnapshot; change_summary: string; consent_record_id: string; }
  interface VersionDiff { from_version: string; to_version: string; changes: FieldChange[]; has_narratable_change: boolean; }
  interface ProfileSnapshot { fields: Record<string, unknown>; active_dimensions: string[]; inactive_dimensions: string[]; }
  ```
- **DoD(P0)**：设计 sign-off✓ + 接口文档入库✓ + 版本流转图评审✓

---

## 六、技术栈决策（待开发团确认，附推荐与现状）

**现状：** 工作区零后端脚手架；原型为 vanilla HTML + CSS 变量；运行环境有 Node 22（managed）与 Python 3.13（managed）。

**推荐栈（供开发团评估采纳）：**
- **后端**：Node + TypeScript + Fastify；`identity_event_bus` 先用内存实现 + 可选 SQLite 持久化；单仓库 `npm run dev` 即可跑通，含埋点校验器与最简看板查询 API。零外部依赖，契合超级个体快速迭代。
- **前端**：原型已是 CSS 变量设计系统，T2 调性引擎直接复用 `--tone-*` 语义变量切根（单一真源，防换皮）。是否迁移到框架（React/Vue）或保持 vanilla + 模块化，请开发团据 S1 起 UI 卡（T1/C2/C3/P1/P2）复杂度评估后定。
- **测试**：Vitest（单测/压测），覆盖率门槛 ≥80%（P0 卡硬性要求）。
- **目录约定建议**：`src/events/`（bus + schema + validator）、`src/tone/`、`src/conflict/`、`src/portrait/`、`src/api/`、`tests/`。

**若开发团认为需要 Redis/NATS 等真消息中间件**，请先说明本地运行门槛与收益，再决定（不推荐 Phase1 起就引入重依赖）。

---

## 七、两个待产品负责人确认的口径差异（不阻塞 S0，但需记入账）

1. **模块人日口径**：逐项加总 = 69 人日，PRD 总括 = 79 人日（差 10 人日，疑似模块级设计规范/集成 overhead 未逐项列出）。建议以逐项 69 为基准，差额纳入 Sprint 级缓冲。
2. **埋点卡数量**：数析原提 13 张，实际落卡 12 张（差 1 张因 `identity_event_bus` 基建合并入 TRK-M0-INFRA 的 S0-01）。逻辑自洽，建议与数析确认无遗漏。

---

## 八、关键文件索引（绝对路径，开发团按需读取）

| 文件 | 用途 |
|------|------|
| `F:\AIPM\Atlas\deliverables\product-strategy\task-cards-phase1-gaps-2026-07-17.md` | **主交付物**：44 张任务卡全文（验收标准/接口契约/依赖/估点/Sprint），S0 之后每张卡的规格都在此 |
| `F:\AIPM\Atlas\deliverables\product-strategy\prd-blueprint-gaps-2026-07-17.md` | 三大缺口 PRD（9 条红线正式版、Non-goals、M0 决策记录 §10） |
| `F:\AIPM\Atlas\PrimeAtlas_完整需求蓝图_Final.md` | 完整需求蓝图（设计系统 7.2 火焰模型等底层定义） |
| `F:\AIPM\Atlas\primeatlas-prototype-v6.html` | v6 原型（CSS 变量设计系统，T2 调性引擎基座） |
| `F:\AIPM\Atlas\deliverables\product-strategy\prd-fusion-visible-phase1-2026-07-17.md` | 融合可见 PRD（路线 B，跨域派生语言流等，Phase1 暂不主做但背景相关） |

---

## 九、给开发专家团的首批执行指令（S0）

1. **搭建后端骨架**：按第六节推荐栈初始化 TypeScript + Fastify 单仓库，配置 Vitest，确保 `npm run dev` / `npm test` 可跑。
2. **实现 TRK-M0-INFRA**：`identity_event_bus`（publish/subscribe/validate + 持久化），6 个事件 schema 的 TS 类型 + 运行时校验器（非法 payload 拒绝率=100%），最简看板查询 API（按事件类型/时间维度）。
3. **落地三引擎契约**：将 T2-1 / C1-1 / P3-1 的 TS 接口类型写入 `src/tone/` `src/conflict/` `src/portrait/`（即第五节 5.2–5.4 的代码块），作为后续算法/集成卡的基准。
4. **最小可运行 demo**：启动 bus → 发布一条 `tone_change_event` → 校验器拦截一个非法 payload → 看板 API 能查到该事件。附单测（校验器边界 + bus 发布订阅）。
5. **落盘与汇报**：代码进 `src/`；S0 完成报告写入 `F:\AIPM\Atlas\deliverables\dev-handoff\s0-baseline-2026-07-17.md`，含 TL;DR / 已实现清单 / 测试用例 / 数析+设计 sign-off 状态 / 下一步（S1 调性模块 T2-2 算法）。

---

## 十、若开发团采用多 agent 协作的纪律（可选）

- 跨 agent 信息流须经主理人/你中转，禁止 agent 间直连；
- 任何专业产出（架构方案/接口定义/测试结果）由对应 agent 产出后你再汇编，不自代写；
- 每个决策留数据/契约支撑，范围外需求记入 Non-goals。

---

> 交接包由产品战略团队主理人（方向明/Fang）整理，2026-07-17。重要决策仍以产品负责人（胜总）最终审定为准。

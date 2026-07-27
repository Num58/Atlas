# Spec - PrimeAtlas v1.0

> 版本：v1.0 Draft for Freeze  
> 生成日期：2026-07-20  
> 基于：产品理解 v1.1 Accepted + 全量 PRD v1.1 Accepted + 追踪矩阵 v1.1 Accepted + 产品决策确认单 v1.0 Approved  
> 输入：Architecture Input v1.0 + Design Input v1.0 + QA Input v1.0  
> 状态：**Spec Draft / NOT SPEC READY / NOT DEV READY**  
> 当前门禁：已确认合同可用于冻结；本文标记为 `Spec Blocked` 的参数归零、低保真 IA 验证和独立 QA 审查完成前，禁止架构实现、任务拆分和开发

---

## 0. 状态与约束级别

| 状态 | 含义 |
|---|---|
| `Accepted Product Rule` | 产品负责人已确认，Spec 不得反向修改 |
| `Frozen` | 已形成唯一、可测试合同，可供后续架构与开发引用 |
| `Candidate` | 当前主验证方向，尚未完成证据门禁 |
| `Required` | 已纳入对应版本范围，但其页面、接口、状态或证据合同仍须分别达到 Frozen；不等于开发准入 |
| `Spec Blocked` | 缺字段、阈值、状态、合规或体验证据，禁止开发 |
| `Won't Have` | 明确不进入对应版本 |

本文不以模糊默认值填补 `Spec Blocked`。开发只能引用 `Frozen` 合同和明确纳入版本的 Requirement ID。

### 0.1 规范性文档层级

以下九份文件共同构成本 Spec 的规范性合同，不是参考材料：

1. `primeatlas-spec-v1.0.md`：范围、状态与跨域裁决的最高真源；
2. `primeatlas-spec-architecture-input-v1.0.md`：字段级 Schema、精确状态机、全量事件、Repository、同步、可见性与 fail-closed 的规范性附录；
3. `primeatlas-spec-design-input-v1.0.md`：页面对象归属、逐页状态、低保真任务、Token、等效入口与设计反模式的规范性附录；
4. `primeatlas-spec-qa-input-v1.0.md`：A–K、Agent、全局 GWT、测试分层与门禁的规范性附录；
5. `v0.2-eligibility-expiry-page-contract.md`：Eligibility `expired/superseded` 页面行为的规范性合同，仅适用于未来首个包含普通精细训练能力的 Release，不扩大 V0.2；
6. `v0.2-ia-lowfi-validation-pack.md`：LF-IA-01～18、14项任务、D3/D4证据与最终 IA 裁决的执行合同；
7. `v0.2-assisted-discovery-data-contract.md`：V0.2 A1 本地优先身份发现、第一方辅助白名单、Consent/Manifest、第三方 Hard Disabled 与失败接管合同；
8. `v0.2-dependency-degradation-matrix.md`：V0.2 实际依赖、错误恢复、TTL/新鲜度、N/A 零调用与故障注入合同；
9. `v0.2-test-traceability-v1.0.md`：V0.2 Requirement、状态、事件、Use-case、Repository、页面状态、Test ID、夹具和剩余 Gap 的双向追踪合同。

发生冲突时按“已 Accepted 产品规则 → 主 Spec 明示裁决 → 对应专业附录”的顺序处理；不得选择较宽松规则。主 Spec 未复写的附录条款仍具约束力；标记为 `BLOCKED/Spec Blocked` 的内容不得因被附录描述而视为 Frozen。

---

## 1. 产品定义

- **一句话描述**：PrimeAtlas 是围绕用户目标、现实约束与证据持续编排成长行动的个人成长操作系统；系统帮助用户把想提升的方向转成目标与里程碑，并根据时间、场景、反馈、恢复和成果持续生成与调整计划。
- **目标用户**：18 岁以上普通健康成年人；同时经营 1–3 个活跃成长域，现实时间、场景和能量波动明显，并重视专业性、解释性和数据主权。
- **核心问题**：现有单点工具无法把用户目标、专业知识、身体状态、有限时间和现实变化组织成连续、可信、可执行且可重校准的成长路径。
- **北极星叙事**：聚焦“目标是否更接近、下一步为何这样安排”。PrimeAtlas 只引导目标，不定义用户的角色、身份、人格或“应该成为谁”。

### 1.1 不是什么

- 不是健身、习惯打卡、streak、To-do、通用日历或 OKR 产品；
- 不是通用聊天机器人或 12 个 Agent 聊天入口；
- 不是医疗诊断、治疗、康复处方或心理评估产品；
- 不做社区、排行榜、好友竞争、红点压力或失败羞辱。

---

## 2. 产品范围与版本策略

### 2.1 终局范围

终局范围覆盖 A–K、12 类专业职责和全局数据/安全/离线能力：方向、目标、计划、执行、成果、能量、Prime Pulse、调性、数据洞察、基础能力和交叉融合。

### 2.2 首个开发版本建议：V0.2 方向—目标闭环

> 该版本只有在本文相关合同 Frozen 后才能转为 Dev Ready。V0.2 的既有本地对象名和物理 Schema 保持不变；以下修正只收敛产品语义，不新增 API、Repository、表或字段。

| 优先级 | 功能 | Requirement | 验收摘要 |
|---|---|---|---|
| P0 | 提升方向自由表达与渐进追问 | A1 | 形成可编辑的用户原话、目标方向与约束草案；系统不得生成身份称谓或要求身份确认 |
| P0 | 方向草案确认和版本化 | A4 | 用户只确认目标、时间、场景和现实约束；`system_auto` 仅可生成可修改的目标候选，不得定义用户身份 |
| P0 | 活跃成长域管理 | A2/B4 | 同时最多 3 个活跃域；未激活域零展示、零占位、零权重 |
| P0 | 域内多个目标与来源解释 | B1/B4 | 每个目标关联用户原话、基线、约束和证据；超限只建议聚焦 |
| P0 | 里程碑 | B2 | 有起点、目标状态、周期、证据和完成规则 |
| P0 | 旅程总览与目标关联 | X2 | 在旅程/目标详情展示方向→域→目标→里程碑关系；V0.2 不创建无上游目标来源的“今日行动” |
| P0 | 本地优先与基础审计钩子 | J5/X1 | 草案、确认和编辑本地可靠保存；事件具备幂等、版本和来源 |
| P1 | 目标进度的阶段/趋势/证据视图 | A3 | 数据不足显示学习态；公式未 Frozen 前不显示精确百分比 |

### 2.3 V0.2 设计范围（Candidate 页面合同）

V0.2 最小闭环固定为：

`价值预览/游客继续 → 提升方向与现实约束表达 → 方向草案编辑 → 目标边界确认 → 活跃成长域选择 → 目标候选/编辑/确认 → 里程碑确认 → 旅程总览/目标详情 → 版本历史与本地保存`

| 页面/能力 | V0.2 状态 | 核心对象/事件 | 边界 |
|---|---|---|---|
| 价值预览/游客继续 | Candidate | 只读示例；`preview_opened` | 展示真实方向→目标→证据结构，不使用抽象 Hero |
| 目标方向发现 | Required | 复用 `IdentityDraft` 存储；`draft_created/discovery_answered` | 只记录用户原话、目标、时间、场景与约束；可随时停止；禁止“我现在是/我想成为”、身份差距与画像确认 |
| 方向草案与目标边界确认 | Required | 复用 `IdentityDraft/PortraitVersion`；`portrait_confirmed` 为兼容事件名 | 确认对象是目标边界而非角色身份；系统推断不得写成用户事实 |
| 成长域选择 | Required | `ActiveDomain`；`domain_activated/paused` | 最多3活跃域，未激活域不占位 |
| 目标候选/编辑/确认 | Required | `Goal`；`goal_proposed/confirmed` | 来源用户原话、基线、约束与证据可见，域内允许多个目标 |
| 里程碑确认 | Required | `Milestone`；`milestone_created/updated` | 有证据、周期和完成规则 |
| 旅程总览与目标详情 | Required | 复用 `PortraitVersion/Goal/Milestone` | 是 V0.2 闭环终点和唯一正式编辑真源；不展示身份称谓或画像差距 |
| 版本历史/本地保存状态 | Required | 复用 `PortraitVersion/AuditRecord/OperationLedger` | 展示已保存本机、保存失败和历史目标边界版本；不暗示云同步 |
| 今日 | Won't Have for V0.2 | 无 `PlanAction/ExecutionRecord` | 不出现行动、完成、Pulse 或训练入口；最终 Tab 归属仍受 IA 低保真门禁 |

具体 URL、页面数量和 Tab 归属仍为 `Candidate`；不得依据本表提前冻结四 Tab。

### 2.4 V0.2 Won't Have

- 专业训练方案生成与完整训练执行；
- 恢复、准备度、Prime Pulse 完整计算；
- 知识注入和跨域融合生成；
- 四类 PR、隐藏进步和预测；
- 第三方模型敏感数据发送；
- 云端正式同步服务、成果分享和社区能力；
- 第三方模型调用：V0.2 `Hard Disabled`，用户 Consent 不得覆盖；
- PrimeAtlas 第一方远程辅助仅作为后续版本研究候选，在 recipient/service identity、Consent 文案/有效期、保留删除 SLA 和测试证据冻结前保持 `Spec Blocked`；V0.2 固定为纯本地模板模式，禁止远程 Port、网络调用或半入口；
- 任何未完成安全、Consent 或数据合同的隐藏入口。

这些能力保留在终局蓝图中，按后续 V0.3–V1.0 进入各自 Spec/Release Scope，不得在 V0.2 留半成品按钮。

---

## 3. 已冻结的全局产品规则

1. 目标、方向、行动、约束和证据是最高产品主轴；系统只引导目标，不定义用户角色、身份或人格标签，不设置身份确认作为目标前置条件。
2. 用户控制目标、时间、场景、现实约束及是否发起知识注入；这些上游输入可随时修改并影响后续编排。
3. Atlas 自主决定知识内容是否采纳及如何编排，生成计划并执行普通调整；每次决定必须展示触发来源、依据、前后差异、影响和版本，不把解释变成逐项审批。
4. 最多 3 个活跃成长域，每域可有多个目标；超过上限只建议聚焦。
5. 未激活域不展示、不建业务占位、不进 Agent 上下文和指标分母。
6. 普通时间/场景/优先级冲突由 Atlas 按用户上游约束自主编排并说明代价；用户通过修改约束影响后续版本，不逐项采纳或审批计划建议。
7. 安全规则是独立、不可覆盖的决策层；安全否决不可被用户普通偏好、调性、编排器、模型或其他 Agent 覆盖。
8. 训练方案前适用范围确认必须主动且默认未选；命中、拒绝或无法确认均不生成普通精细训练方案；确认不替代持续安全审查。
9. Pulse 可绕过、不是训练解锁条件；长期目标势能、今日准备度和启动仪式相互独立；产品建议 500ms，并提供等效入口。
10. 指标默认阶段、趋势、证据和数据充分度；条件不足不显示伪精确。
11. 第三方模型仅获最小必要、默认去标识化数据，需独立 Consent，默认不用于训练通用模型；用户拒绝知识注入或撤回相关授权均无惩罚。
12. 12 Agent 是职责、权限和审查角色，不等于 12 个模型或真人；调性只改变表达，不改变事实、权限、Atlas 决策责任或安全规则。

---

## 4. 技术架构合同

| 层 | Frozen 合同 |
|---|---|
| 客户端 | Flutter 单一 Dart 代码库，原生 Android/iOS |
| 状态管理 | Riverpod；状态不可变；复杂异步流程使用 Notifier/AsyncNotifier |
| 导航 | GoRouter；最终路由树待 IA 低保真验证后 Frozen |
| 本地存储 | sqlite3；本地优先；迁移策略在详细架构阶段冻结 |
| 分层 | `lib/core` 纯 Dart，禁止依赖 Flutter；`lib/app` 承载 UI、平台集成和应用编排 |
| 同步 | `SyncAdapter` 抽象；本地事实先落库；NoopSyncAdapter 作为无云同步默认实现 |
| 序列化 | 数据字段与 JSON 键使用 `snake_case` |
| 时间 | 跨设备业务时间使用 UTC 微秒 `*_at_us`，另存 `timezone_id` 和 `timezone_offset_min` |
| 图标 | Lucide 16/20/24px |
| 字体 | Inter + Noto Sans SC；规则、版本、时间与标识使用 JetBrains Mono |
| 主题 | 浅色优先；深色通过同一语义 Token 覆盖 |

### 4.1 全局数据规则

- 跨设备实体使用稳定、不可复用的全局唯一 `id`；具体 UUID 版本 `Spec Blocked` 至详细架构裁决。
- 可修改聚合具有 `version`；离线操作具有 `operation_id`、`event_id`、`device_id`、`device_seq`。
- 所有推断/生成值具有 `source_type`：`user_declared | device_observed | imported | system_inferred | model_generated | professional_content | local_rule`；V0.2 `Goal.source_type` 使用同一枚举并明确允许 `local_rule`。
- 数据充分度使用 `insufficient | partial | sufficient`。
- 执行、安全、Consent 和审计采用追加事实或不可覆盖版本语义。

---

## 5. 核心数据对象清单

> 完整字段级 Schema 以 `primeatlas-spec-architecture-input-v1.0.md` 为输入。下表锁定对象职责；物理拆表、索引和迁移仍由详细架构冻结。

| 对象 | 核心字段/职责 | 关键索引/关联 |
|---|---|---|
| `Subject` | 游客/注册主体、账号状态 | account_id、status |
| `Device` | 平台、版本、device_seq | owner_id、last_seen_at_us |
| `AppSession` | 会话与 tone_version | owner_id、started_at_us |
| `IdentityDraft` | 兼容对象名；用户原话、目标方向、现实约束与追问状态 | owner_id、status、version |
| `ActiveDomain` | 域代码、优先级、激活状态 | owner_id + status；最多3活跃 |
| `PortraitCandidate` | 兼容对象名；系统/规则产生的方向与目标边界变化候选、证据、并发状态 | owner_id、status、base_portrait_version_id |
| `PortraitVersion` | 兼容对象名；用户确认的目标边界版本与证据摘要 | owner_id、version、confirmation_source |
| `EvidenceLink` | 方向、目标、里程碑和候选的来源证据关联 | subject_type/id、evidence_type/id、validity |
| `Goal` | 域内目标、用户原话/基线/约束来源、生命周期 | domain_id、status、version |
| `Milestone` | 起点/目标、证据、周期、完成规则；status=`not_started/in_progress/achieved/not_achieved/superseded` | goal_id、status |
| `Plan` / `PlanVersion` | 计划聚合根、版本、审核、安全状态 | goal_ids、status、version |
| `PlanAction` | 时间、域、动作、来源 | **plan_version_id**、scheduled_at_us |
| `ExecutionRecord/Event` | 开始/暂停/完成等追加事实 | action_id、operation_id、occurred_at_us |
| `FeedbackRecord` | RPE、疼痛、质量及来源 | execution_id、source_type |
| `EligibilityDeclaration` | 五类适用范围回答、展示版本、有效期 | owner_id、status、policy_version |
| `ConsentReceipt` | 目的、范围、接收方、有效期、撤回 | owner_id、purpose_code、status |
| `SafetyEvent/Decision` | 规则命中、证据、否决、替代、复评；`user_overridable=false` | owner_id、plan/action、state |
| `ConflictRecord` | **仅普通**方向/时间/能量/域优先级冲突、影响与仲裁；`blocked_user=false` | conflict_type、state |
| `ContextObservation` | 用户声明/设备/导入的场景与有效期 | owner_id、observation_type、valid_until_at_us |
| `VisibilityPolicy/Manifest` | 目的型字段白名单、接收方与转换 | purpose_code、recipient_id、policy_version |
| `AgentRun/RoleDecision` | 职责、输入清单、规则版本、结构化结论 | job_id、role_code、state |
| `KnowledgeSource/Suggestion` / `DerivedContent` | 来源、评估、采纳状态、派生溯源 | target_goal_id、state、parent_id |
| `PRCandidate/Insight` | 规则、样本、证据、确认/撤销 | owner_id、rule_version |
| `SyncOperation/Conflict` | 幂等、版本、重试、冲突解决 | operation_id、entity_id、state |
| `Tombstone` | 删除传播、旧设备防复活、保留窗口 | owner_id、entity_id、deleted_at_us |
| `AuditRecord` | 关键动作、前后状态、来源和版本 | owner_id、event_type、occurred_at_us |

---

## 6. 状态机合同（精确枚举与转换 Frozen）

Architecture Input §2 的九类状态机是本节的规范性完整定义。每次转换必须校验 `owner_id`、当前状态、`base_version` 与权限，记录触发事件、actor、`operation_id`、前后版本和审计记录；未列出的转换均非法并返回 `invalid_state_transition`。

### 6.1 目标方向草案（兼容聚合名 `IdentityDraft`）

| 当前状态 | 触发 | 下一状态 |
|---|---|---|
| `draft` | `submit` | `pending_confirmation` |
| `draft` | `discard` | `discarded` |
| `draft` | `assisted_update` | `draft`（新版本） |
| `pending_confirmation` | `user_confirm` | `confirmed` |
| `pending_confirmation` | `user_edit` | `draft` |
| `pending_confirmation` | `user_reject` | `discarded` |
| `pending_confirmation` | `concurrent_new_draft` | `superseded` |
| `confirmed` | `newer_confirmed_identity` | `superseded` |

只有 `user_confirm` 可进入 `confirmed`；这里确认的是用户填写的目标、时间、场景和现实约束边界，不是角色身份或人格画像。模型完成、轮数阈值和 `system_auto` 均不得代替用户确认这些上游输入。审计事件继续使用兼容名 `identity_draft_*` 与 `portrait_version_activated`。

### 6.2 目标

| 当前状态 | 触发 | 下一状态 |
|---|---|---|
| `draft` | `submit` | `pending_confirmation` |
| `draft` | `discard` | `archived` |
| `pending_confirmation` | `user_confirm` | `active` |
| `pending_confirmation` | `user_reject` | `archived` |
| `active` | `pause` | `paused` |
| `active` | `major_change` | `recalibrating` |
| `active` | `evidence_complete` | `completed` |
| `paused` | `resume_request` | `recalibrating` |
| `recalibrating` | `user_confirm + required_reviews_passed` | `active` |
| `active/paused/completed` | `archive` | `archived` |

恢复或重大变化必须重跑受影响的专业、安全和时间冲突评审；`completed` 只能产生方向/目标边界候选，不得把结果升级为角色身份或人格画像。

### 6.3 计划

| 当前状态 | 触发 | 下一状态 |
|---|---|---|
| `generating` | `partial_or_data_insufficient` | `draft` |
| `generating` | `generated` | `pending_review` |
| `generating` | `timeout_non_safety` | `draft`（标记 degraded） |
| `generating` | `eligibility_or_safety_fail` | `safety_blocked` |
| `pending_review` | `safety_fail` | `safety_blocked` |
| `pending_review` | `professional_fail` | `draft` |
| `pending_review` | `minor_reversible + all_required_reviews_passed` | `active`（新版本并通知） |
| `pending_review` | `major + all_required_reviews_passed` | `active`（新版本并解释影响；不得逐项审批） |
| `pending_confirmation` | `migration_of_legacy_record + all_required_reviews_passed` | `active`（仅兼容旧记录，不得作为新计划流程） |
| `pending_confirmation` | `upstream_constraints_changed` | `draft`（按新目标/时间/场景/约束重生成） |
| `pending_confirmation` | `legacy_record_archived` | `archived` |
| `active` | `end_of_validity` | `expired` |
| `active` | `new_active_version` | `superseded` |
| `active` | `safety_trigger` | `safety_blocked` |
| `active` | `minor_reversible_adjustment` | `active`（新 PlanVersion） |
| `safety_blocked` | `reassessment_passed` | `pending_review` |
| `safety_blocked` | `safe_alternative_reviewed` | `pending_confirmation`，或仅在“小幅可逆且全部审核通过”时进入 `active` 的 conservative 新版本 |

安全超时、依赖不可用、规则不可用或关键数据过期时，计划不得转为通过；对应 `SafetyEvent` 必须保持 `precautionary_paused` 或进入 `blocked`。`conservative` 不是失败后的默认降级状态，只能是独立生成、独立规则版本、有效适用范围和必要安全检查全部通过的新 `PlanVersion`。`safety_status != passed` 的普通精细方案禁止进入 `active/ready`。除独立的安全/隐私授权外，计划生成、重大或普通调整均由 Atlas 按用户目标、时间、场景和约束自主执行；用户不逐项审批计划版本，但系统必须保留版本并解释依据、差异与影响。

### 6.4 执行

| 当前状态 | 触发 | 下一状态 |
|---|---|---|
| `not_started` | `start` | `in_progress` |
| `not_started` | `skip` | `skipped` |
| `in_progress` | `pause/complete/process_loss` | `paused/completed/interrupted` |
| `in_progress` | `safety_trigger` | `paused`，并追加 `SafetyEvent.precautionary_paused` |
| `paused/interrupted` | `resume_if_safe/skip/complete_with_evidence` | `in_progress/skipped/completed` |
| `completed/skipped` | `user_revert` | `reverted` |
| `reverted` | `start_again_as_new_attempt` | 新 `ExecutionRecord.not_started` |

安全阻断时不得从 `not_started` 进入执行态。每次转换追加 `execution_event`；同一 `operation_id` 幂等。`completed` 不等于质量通过；跳过 RPE 必须保存 `missing`。

### 6.5 Consent

`not_requested → pending`；`pending → granted | denied`；未完成可停留 `pending` 或回到 `not_requested`，不得推定同意；`granted → revoked | expired | superseded`；`denied/revoked/expired/superseded → pending` 仅由新的显式请求触发。

目的、范围、接收方或政策变化必须使旧授权 `superseded` 并新建 `pending`；撤回立即停止新采集和新发送。审计事件为 `consent_requested/granted/denied/revoked/expired/superseded`。

### 6.6 训练适用范围

`not_presented → presented`；`presented → eligible_confirmed | ineligible | rejected | unavailable | incomplete`；`eligible_confirmed → expired | superseded`。

只有“全部项目已回答 + 成年 + 无排除项 + 显式确认”可进入 `eligible_confirmed`。所有项默认 `unanswered`；离开、超时或部分填写必须为 `incomplete`。`incomplete/ineligible/rejected/unavailable/expired/superseded` 均禁止普通精细训练方案；身份、健康、疼痛或规则版本变化触发 `superseded` 并重新展示。

### 6.7 安全

`detected → precautionary_paused → evaluating`；`evaluating → blocked | alternative_available | awaiting_reassessment | resolved`；超时/依赖失败必须保持 `precautionary_paused` 或进入 `blocked`；`blocked → alternative_available | awaiting_reassessment`；`alternative_available` 只能导向新的、已审核 PlanVersion 或 `awaiting_reassessment`；`awaiting_reassessment → resolved` 仅限新复评通过。

`SafetyEvent.user_overridable` 恒为 `false`。不得使用含糊且可执行的 `caution` 状态；任何角色、调性或模型均不能覆盖 `blocked`。安全阻止危险具体方案，但不删除目标；离线新疼痛必须本地即时 `precautionary_paused`。

### 6.8 方向候选与目标边界版本（兼容对象名）

`candidate → pending_confirmation`；`pending_confirmation → accepted | rejected | withdrawn | conflicted`；`conflicted → accepted | rejected | withdrawn` 仅由用户解决；激活新正式版本使旧 active 版本 `superseded`；恢复旧版本必须创建新 active 版本，以 `kind=restored` 与 `restored_from_version_id` 表达来源。

所有用户显式确认与恢复产生的新目标边界版本统一写 `confirmation_source=user_explicit`；该字段只记录用户对目标、时间、场景和现实约束的确认。`system_auto` 只能产生可修改候选；并发候选或版本不可自动字段合并为用户事实，更不得形成角色身份或人格画像。

### 6.9 同步

`local_pending → syncing`；`syncing → synced | retry_pending | conflict | failed_action_required | rejected`；`retry_pending → syncing`；`conflict` 由确定性政策自动解决后进入 `synced`，否则保持待用户处理；`failed_action_required` 修正后创建新的 `local_pending` 操作。

`account_mismatch` 必须 `rejected`；同一 `operation_id` + 同 payload 重放返回原结果，同 key 不同 payload 返回 `idempotency_key_reused`。同步失败不阻断本地可用能力，但必须展示待同步、冲突或需处理状态。

---

## 7. 领域事件、API 与 Repository 合同

> Use-case 语义和事件 Envelope Frozen；最终 Dart/HTTP 签名、事务边界与版本兼容仍为 `Spec Blocked`。所有变更命令携带 `operation_id`；跨端聚合更新携带 `base_version`。

### 7.1 统一事件 Envelope（Frozen）

`event_id, event_type, schema_version, owner_id, aggregate_type, aggregate_id, aggregate_version, operation_id, causation_id?, correlation_id?, source_type, actor_type, actor_ref_id?, device_id, device_seq, occurred_at_us, timezone_id, timezone_offset_min, recorded_at_us, payload, payload_hash`

- event_id 唯一；operation_id 表达一次业务意图；causation/correlation 串联方向→目标→计划→执行→证据/版本因果链。
- payload 不记录健康原文、完整笔记或完整角色/人格叙事。

### 7.2 V0.2 事件目录（Frozen）

核心业务事件：`identity_draft_created/updated/submitted/confirmed/discarded`、`domain_activated/paused/archived`、`portrait_candidate_created/accepted/rejected/withdrawn`、`portrait_version_activated/restored`、`goal_proposed/confirmed/updated/paused/recalibration_started/recalibrated/completed/archived`、`milestone_created/started/achieved/superseded`、`domain_limit_focus_suggested`、`sync_operation_enqueued/succeeded/conflict_detected/conflict_resolved/operation_rejected`、`source_data_corrected`、`tombstone_created`。

A1 身份发现与依赖降级事件：`identity_discovery_answer_recorded`、`assisted_discovery_requested/completed/degraded/timed_out`、`assisted_discovery_result_rejected/discarded`、`visibility_payload_blocked`、`dependency_failure_observed`、`local_save_failed`、`local_transaction_rolled_back`、`local_store_integrity_failed`、`local_migration_failed`、`local_write_conflict_detected`、`local_template_degraded/locale_fallback/item_rejected`、`sync_operation_deduplicated`、`device_clock_anomaly_detected/timezone_changed/time_context_degraded`。

以上事件的 payload 禁止身份原文、完整问答和账号直接标识；字段、来源和验收以三份 V0.2 新合同为准。全量后续事件目录以 Architecture Input §3.2 为规范性附录。

### 7.3 Use-case 语义

| 领域 | 核心接口 | 状态 |
|---|---|---|
| Goal Direction（兼容 Identity 命名） | `create/update/submit/confirm/discard_identity_draft`、`record_identity_discovery_answer`、`request/apply_assisted_discovery`、`continue_with_local_discovery`、`list/restore_portrait_version` | V0.2 只使用纯本地 Dart 路径；对象/命令名仅为兼容，不表达角色身份；远程辅助只属于后续版本研究候选 |
| Domain/Goal/Journey | `activate/pause/archive_domain`、`create_goal_candidate`、`confirm/update/pause/archive_goal`、`request/confirm_goal_recalibration`、`upsert_milestone`、`get_journey_overview/get_goal_detail` | 状态与产品语义 Frozen；UC-010/013/019 请求、结果、错误与事务/读取语义已冻结；V0.2 物理 Schema/FK/索引已由 `0001_baseline.sql` 固化，迁移 runner/UoW 集成仍待实现 |
| Eligibility/Consent | `present/submit_eligibility`、`grant/deny/revoke_consent`、`get_visibility_manifest` | 后续版本；签名 Blocked |
| Plan/Safety | `request_plan_generation`、`get_plan_job`、`generate_plan_version`、`apply_plan_adjustment`、`record_constraint_change`、`request_safety_reassessment` | 后续版本；签名 Blocked。计划生成/普通调整由 Atlas 决策执行，不提供逐项审批命令；安全/隐私授权独立 |
| Execution/Feedback | `start/pause/resume/complete/skip_execution`、`revert_execution`、`record/skip_rpe`、`record_pain/quality`、`correct_feedback` | 后续版本；状态语义 Frozen |
| Goal Direction/Fusion | 复用旧 `Portrait` 命名只作 V0.2 存储兼容；后续 `evaluate_knowledge_source`、`apply_knowledge_decision` | V0.2 不新增接口；后续知识评估由 Atlas自主采纳/拒绝并解释，用户只控制是否发起知识注入 |
| Sync | `enqueue/get_sync_status`、本地测试适配器 `ack/retry/resolve_sync_conflict` | V0.2本地 outbox/Noop 语义；正式云 pull/push 为 Won't Have |

### 7.4 Repository 合同

所有 V0.2 Repository 以 owner_id 隔离；审计查询可读取历史版本。V0.2 不含 tombstone，因此不存在 tombstone 默认过滤。

V0.2 必须冻结：
- `SubjectRepository`: current/bind_guest/switch_subject；
- `IdentityRepository`: get/save draft、active portrait、versions、append candidate、activate version；Repository/方法名仅为兼容，应用层语义为方向/约束草案、方向候选与目标边界版本；
- `DomainRepository`: list active、save domain version；
- `GoalRepository`: get/list/save goal version、list milestones；
- `EvidenceRepository`: link/invalidate/list evidence；
- `AuditRepository`: append/list by object；
- `OperationLedgerRepository`: find by owner+operation、record committed/rejected、replay exact result；必须参与共享 UoW；
- `LocalPersistenceRepository`: SQLite transaction、版本 CAS、冲突快照、存储故障原子回滚与重启恢复。

`SyncRepository` 与 `TombstoneRepository` 不属于 V0.2；不得在 baseline、生产路由或 Repository 装配中出现。

后续版本 Repository 以 Architecture Input §4.3 为规范性附录。

### 7.4.1 V0.2 UC-010 / UC-013 / UC-019 唯一合同（Frozen）

- `UC-010 archiveDomain(ownerId,operationId,domainId,baseVersion,confirmedImpact) -> ArchivedDomainResult`：仅 `active/paused` domain 可归档。`confirmedImpact` 必须等于当前影响摘要的 SHA-256 hash，否则返回 `impact_confirmation_required`。同一 SQLite Unit of Work 内将 domain 置为 `archived`、关联 `active` goals 置为 `paused`，并原子追加 domain/goal event、audit 与 `operation_ledger.committed`。归档不是删除，不创建 tombstone，不传播删除。确定性错误为 `account_ownership_mismatch, not_found, impact_confirmation_required, version_conflict, invalid_state_transition, idempotency_key_reused` 及 §7.6 本地存储错误；owner 不匹配优先返回 `account_ownership_mismatch`，不得降格为 `not_found`。存储失败整笔回滚且不得写 `rejected` ledger。
- `UC-013 updateGoal(ownerId,operationId,goalId,baseVersion,patch) -> GoalUpdateResult`：`title/description/non_core_evidence_note` 为小改，保持当前状态并将 version 加一；`domain_id/identity_linkage/deadline/core_evidence_rule` 为重大改动，服务端确定性分类并将 `active/paused` goal 转入 `recalibrating`。patch 同时含未识别字段或无法唯一分类的变更时返回 `change_classification_required`，不得写入。成功时在同一 SQLite Unit of Work 原子写 Goal、event、audit 与 `operation_ledger.committed`。确定性错误为 `account_ownership_mismatch, not_found, change_classification_required, version_conflict, invalid_state_transition, idempotency_key_reused` 及 §7.6 本地存储错误；owner 不匹配优先。存储失败整笔回滚且不得写 `rejected` ledger。
- `UC-019a getJourneyOverview(ownerId,cursor?,limit=20,max100) -> JourneyOverviewPage`；`UC-019b getGoalDetail(ownerId,goalId) -> GoalDetail`：均为 owner-scoped 一致 SQLite 只读事务，不接收 `operationId`，不读写 operation ledger。overview 使用 `(updated_at_us,id)` keyset cursor 并按两列 `DESC` 排序；非法 cursor 或 `limit<1/limit>100` 返回 `validation_failed`。详情在 id 存在但 owner 不匹配时优先返回 `account_ownership_mismatch`，同 owner 下不存在才返回 `not_found`，以该显式口径保证三份 V0.2 合同一致。SQLite 读取故障统一映射 §7.6 本地存储错误。

### 7.5 V0.2 原子事务与依赖边界

- 目标边界确认必须在单一 sqlite3 事务内原子写入 `IdentityDraft.confirmed + PortraitVersion.active + DomainEvent + AuditRecord + OperationLedger.committed`；兼容对象名不改变确认语义。任何一步失败全部回滚，不得出现半版本或无 ledger 的“成功”。存储故障不得另写 `rejected` ledger。
- V0.2 实际依赖仅包括 sqlite3、设备端本地规则/模板、禁用的外部 Port、系统时钟/时区；`operation_ledger` 不是同步 outbox，正式同步适配器不进入 Release。
- 云同步、第三方模型、认证供应商、健康平台、日历、位置、第三方内容、通知和媒体权限均为 `Won't Have/N/A`；必须通过零调用或 throw-on-call 测试证明无隐藏依赖和半入口。
- 依赖错误码、TTL/新鲜度、重试、替代、审计与 `FX-DB/AI/TPL/SYNC/TIME/NA` 夹具以 `v0.2-dependency-degradation-matrix.md` 为 Frozen Candidate 合同。

### 7.6 统一错误码最小集

`eligibility_required`、`eligibility_not_supported`、`consent_required`、`consent_revoked`、`safety_blocked`、`safety_review_unavailable`、`professional_review_incomplete`、`data_insufficient`、`version_conflict`、`idempotency_key_reused`、`invalid_state_transition`、`validation_failed`、`account_ownership_mismatch`、`offline_pending`、`third_party_payload_blocked`、`dependency_unavailable`、`content_unavailable`、`not_found`、`domain_focus_required`、`impact_confirmation_required`、`change_classification_required`、`local_store_full`、`local_store_busy`、`local_store_corrupt`、`local_store_readonly`、`local_migration_failed`、`local_transaction_failed`。

第 4 个成长域固定返回 `domain_focus_required`，并携带无写入的确定性 `FocusSuggestion` 失败对象；不得使用通用校验错误替代。V0.2 已冻结 `archive_domain`、`update_goal`、Journey read 的逐 Use-case 恢复合同；13 表物理 Schema/FK/索引与可执行 baseline 已落盘并通过机械 Schema 测试，但 migration runner、备份/只读恢复、共享 UoW 与 Repository 集成尚未实现，V0.2 因此仍非 Dev Ready。

---

## 8. 页面与信息架构合同

### 8.1 主验证 Candidate

方案 A：**今日 / 旅程 / 成长域 / 我的**。

- 今日：把方向和目标带入现实行动；
- 旅程：目标方向与现实约束 → 目标/里程碑、成果证据与重校准；
- 成长域：最多 3 个活跃域的专业工作空间；早期以体能深扎；
- 我的：目标边界版本、授权、数据、调性、同步、导出删除和账号治理。

### 8.2 Candidate 对象唯一归属

| 对象/能力 | 主归属候选 | 交叉入口 | 禁止重复 |
|---|---|---|---|
| 目标方向与现实约束 | 旅程 | 今日作用说明、成长域关联 | 不藏在“我的” |
| 目标和里程碑 | 旅程 | 成长域按域筛选、未来今日回链 | 不创建两套可编辑目标详情 |
| 专业计划 | 成长域 | 今日当日切片、旅程目标关联 | 不增加通用计划第五 Tab |
| 今日行动和执行 | 今日 | 成长域计划进入行动 | 不形成多个执行状态真源 |
| 身体状态与体能洞察 | 成长域→体能 | 今日仅显示影响当日摘要 | 不固定为所有用户的一级身体 Tab |
| 知识与派生内容 | 对应成长域/目标 | 来源芯片与证据回链 | 不做脱离目标的内容产品 |
| 成果、PR、周期回顾 | 旅程 | 今日提示、域历史链接 | 不做排行榜/streak中心 |
| 目标边界版本、权限、账号 | 我的 | 旅程提供兼容版本入口 | “我的”不承担定义用户角色/人格的叙事 |
| 安全决定 | 相关计划/执行上下文 | 今日、成长域、通知深链 | 不藏到设置或 Agent 日志 |

以上为 Candidate 归属合同，冻结前验证交叉入口；无论最终 IA 如何，同一业务对象只能有一个正式可编辑真源。

### 8.3 IA 低保真冻结门禁

方案 A 在完成 Design Input §9.2 的 **LF-IA-01～LF-IA-18 共18项验证主题** 和下列 **14项最小任务**前不得标记 `Frozen`。下方10个组合条目只是18项的阅读分组，关闭门禁时必须按18个ID逐项提供证据：

- 一级 Tab 名称、数量、顺序；“旅程”和“成长域”的用户心智；
- 今日首屏在正常日、休息日、安全日、离线日、无计划日的优先级；
- Prime Pulse 位置及“不操作仍可达、不会误认为解锁”；
- 成长域二级导航；旅程与成长域交叉入口；
- 单/双/三域且每域多目标的密度；
- 路由、返回栈、Tab 再次点击、来源/通知深链和安全页退出；
- 适用范围正常/拒绝/无法确认/过期；安全否决；普通冲突双轨；
- 权限/Consent 渐进触发与撤回；离线执行与同步冲突；
- 指标数据不足；知识注入四类普通结论与安全否决；
- v6 高频能力迁移；屏幕阅读器、键盘和 reduced motion 完整任务。

最小可点击任务：

1. 愿望表达→方向与现实约束草案→单/多域→目标→里程碑确认；
2. 单域用户完成体能行动并提交/跳过 RPE；
3. 不操作 Pulse 仍能开始行动；
4. 双域多目标并处理普通时间冲突；
5. 三域每域多目标找到指定目标和专业计划；
6. 从训练卡派生内容回溯父节点；
7. 知识评估处理采纳/改造采纳/暂缓/不采纳与安全否决；
8. 查看成果与周期回顾及方向候选；Atlas 依据有效上游约束自主编排后续版本，不设置逐项审批；
9. 急性疼痛下理解安全否决、替代和复评；
10. 拒绝/无法确认适用范围后找到非训练能力；
11. 拒绝健康/日历/第三方模型权限后继续最低体验；
12. 离线执行、重连同步和处理冲突；
13. 查看数据不足、内容失效、服务超时和已撤回；
14. 用屏幕阅读器、键盘、reduced motion 完成 Pulse、执行、反馈、安全替代和 Consent。

冻结证据至少包含：任务成功率、首次理解准确率、错误入口次数、返回迷失率、关键路径步数、状态误解率、辅助技术完成率。具体原型分层、主持脚本、指标、证据分级和裁决卡以 `v0.2-ia-lowfi-validation-pack.md` 为规范性执行合同。D0–D2 不得替代 D3 真实目标用户证据；核心辅助技术旅程需要 D4 或 QA 明确接受的等价真实证据。不得用主观视觉偏好、团队走查或 AI 模拟替代 IA 判断。

### 8.4 页面状态类别（Frozen）与逐页行为（Spec Blocked）

Frozen 状态类别包括：首次、空、加载、错误、离线、拒权、Consent 未授权/撤回、数据不足、数据过期、来源冲突、普通冲突、安全否决、适用范围未完成/拒绝/无法确认、长任务、超时降级、内容失效、同步待处理、同步冲突、已撤回、已归档、成功。

每个纳入版本的页面必须另行冻结状态映射：触发条件、页面表达、主/次动作、离线行为、读屏播报和禁止行为。在逐页映射完成前，页面保持 `Spec Blocked`。完整规范性矩阵见 `primeatlas-spec-design-input-v1.0.md` §4.2。

V0.2 至少覆盖：身份模型超时/稍后继续、离线草稿、确认中、版本冲突、3 域上限、探索目标/数据不足、里程碑依赖缺失、本地已保存/待同步/同步冲突。

未来首个包含普通精细训练能力的 Release 还必须采用 `v0.2-eligibility-expiry-page-contract.md` 中的 `eligibility_expired` / `eligibility_superseded` 合同：旧回答不得预选或沿用，离线不得产生 `eligible_confirmed`，重新确认创建新记录并只进入持续安全评审。该合同不在 V0.2 创建 Eligibility 页面或记录。

---

## 9. Design Token（Frozen 基础）

### 9.1 设计系统

- Token 分层：Foundation → Semantic → Component；组件不得直接引用 Foundation 色值。
- 浅色优先；深色是同一语义 Token 覆盖层。
- 组件颜色禁止硬编码；调性不得覆盖安全、危险、成功、警告、焦点等事实语义。

### 9.2 Foundation 与 Semantic Color

| Token | 值/引用 | 用途 |
|---|---|---|
| `neutral-0/50/100/200/300` | `#FFFFFF/#F7F9FB/#EEF2F5/#DEE5EA/#C7D0D8` | 表面、背景、边框 |
| `neutral-500/600/700/800/900` | `#697785/#4E5D6B/#344351/#23313D/#15232E` | 辅助至主文字，避免纯黑 |
| `atlas-blue-50/600/700` | `#EFF6FA/#3A6787/#2E5673` | 品牌弱底、信息、主操作 |
| `teal-600` | `#237D78` | 融合/来源关系，不替代成功 |
| `green-600` | `#23845B` | 成功/通过 |
| `amber-600` | `#A86A10` | 警告/待确认/过期 |
| `red-600/700` | `#B8473B/#96372F` | 错误/危险/安全否决 |
| `color-bg-app` | `neutral-50` | 应用背景 |
| `color-bg-surface` | `neutral-0` | 卡片/Sheet |
| `color-text-primary/secondary/muted` | `neutral-900/600/500` | 文本层级 |
| `color-border-default/strong` | `neutral-200/300` | 边界层级 |
| `color-action-primary` | `atlas-blue-700` | 主操作 |
| `color-focus-ring` | `atlas-blue-700` | focus-visible |
| `color-status-success/warning/danger/info` | `green-600/amber-600/red-700/atlas-blue-600` | 状态语义 |
| `color-relation-fusion` | `teal-600` | 融合关系，必须配文字/图标 |

### 9.3 Typography、Spacing、Shape 与 Motion

- 字体：Inter / Noto Sans SC / JetBrains Mono；
- 字号/行高：caption 12/16、label 14/20、body 16/24、title-sm 18/24、title-md 20/28、title-lg 24/32、display-sm 32/40、display-lg 40/48；
- 间距：4px 网格，允许 4/8/12/16/20/24/32/40/48/64/80；
- 圆角：4/8/12/16；pill 只用于标签和状态；
- 阴影：`shadow-xs/sm/md/lg`，低透明克制；最终参数在视觉细化冻结，禁止发光；
- 动效：0/150/250/400ms；标准缓动 `cubic-bezier(0.4, 0, 0.2, 1)`；禁止弹跳/弹性/随机粒子；
- 图标：Lucide 16/20/24px，功能图标有可访问名称。

### 9.4 调性覆盖边界

调性只可覆盖 `tone-accent`、`tone-accent-subtle`、`tone-surface-tint`、文案风格和受 reduced-motion 限制的动效强调。不得覆盖状态色、安全否决、权限、Consent、数据充分度、功能入口、计划和 Agent 事实。

### 9.5 组件最低状态

Button、Input、Card、Tab、Chip、Dropdown、Disclosure、Action Control 必须定义 Default、Hover（适用平台）、Focus-visible、Active、Disabled、Loading、Error、Empty、Success；高风险组件增加 Offline、Permission denied、Insufficient data、Safety veto、Revoked、Stale、Conflict。

---

## 10. 无障碍与等效入口（Frozen 最低合同）

### 10.1 基线

- WCAG 2.2 AA；iOS 触控目标≥44×44pt，Android≥48×48dp；正文对比度≥4.5:1；
- 支持屏幕阅读器、外接键盘、200% 动态字体、窄屏/横屏和 reduced motion；
- 页面有可预测标题、返回名称、焦点顺序、错误摘要和必要 live region；
- 平台/版本测试矩阵仍为 `Spec Blocked`，但核心等效操作不得延后。

### 10.2 等效入口矩阵

| 原交互/信息 | 必须提供的等效入口 |
|---|---|
| Pulse 长按500ms | 明确按钮、读屏自定义动作，结果完全一致 |
| 滑动完成 | 显式完成按钮、Enter/Space、撤销 |
| 拖拽时间槽 | 提前/延后/移到时段菜单、键盘移动、位置播报 |
| 长按笔记评估 | 可见按钮或菜单项 |
| 图表/雷达/趋势 | 同内容结构化列表/表格，包含阶段、证据、窗口、更新时间 |
| 颜色状态 | 图标+文本+必要说明 |
| 发音音频 | 文本术语、音标/拼读、重播和速度 |
| 动作视频 | 字幕、转录、关键帧、文本步骤、播放控制和失效替代 |
| 触觉 | 同步视觉和文本反馈 |
| 势能/庆祝动画 | 静态状态、趋势、证据和可跳过摘要 |
| Bottom Sheet | 焦点陷阱、关闭按钮、返回关闭、关闭后回焦 |

适用范围与 Consent 默认未选；无法通过辅助技术完成确认时进入 `eligibility_unavailable`，不得记录为同意。

---

## 11. 设计反模式门禁

- 禁止紫色/粉紫渐变、emoji功能图标、默认系统字体、硬编码组件色、纯黑大面积表面、发光/玻璃/AI光球、弹跳缓动；
- 禁止抽象口号 Hero、三列同构功能卡、卡片墙和今日完成百分比主视觉；
- 禁止 streak、排行榜、红点、断签、补签、落后压力和伪精确数字；
- 禁止 Pulse 解锁、融合任务中心、同时多任务、身份称谓/身份差距/画像确认流程、把系统推断写成用户事实；知识进入计划必须展示 Atlas 的采纳或不采纳理由、依据、影响和版本，但不得要求用户逐项批准；
- 禁止 12 Agent 头像聊天化、模型名代替解释、私有推理链展示；
- 禁止普通冲突冒充安全、危险方案继续入口、权限/Consent 拒绝惩罚；
- 禁止羞辱、罪感、恐吓、空洞 Lorem/Welcome 文案和不可验收承诺；
- 单域用户不得被表现为缺失或低等级。

---

## 12. 第三方模型与数据可见合同

### 12.1 三层可见

1. 仅设备可见；
2. PrimeAtlas 服务端可见；
3. 第三方模型可见。

第三方模型默认不可见：健康/伤病原文、完整笔记/书摘、完整角色/人格叙事、目标边界版本历史全集、Consent 回执全文、Audit 日志和 Agent 私有推理链。

### 12.2 字段级可见矩阵

| 数据 | 仅设备 | PrimeAtlas服务端 | 第三方模型默认 | 独立Consent | 规则 |
|---|---:|---:|---:|---:|---|
| 账号直接标识/联系方式 | 是 | 认证必要时 | 否 | 不适用 | 模型只用去标识主体ID |
| 已确认目标边界最小摘要 | 是 | 同步启用时 | 条件可见 | 是 | 仅当前任务必要摘要，不发完整叙事 |
| 健康/伤病/睡眠原文 | 是 | 功能必要且授权时 | 否 | 是 | 优先发送结构化约束码，不发原文 |
| 原始笔记/书摘 | 是 | 同步/处理授权时 | 否 | 是 | 仅发送用户明确选择片段 |
| 目标/里程碑 | 是 | 同步启用时 | 条件可见 | 按目的 | 仅当前任务目标片段 |
| 当前计划片段 | 是 | 云评审启用时 | 条件可见 | 是 | 不发无关计划历史 |
| `safety_constraint_codes` | 是 | 是 | 条件可见 | 是 | 结构化且不能让模型绕过规则 |
| 方向候选/目标边界版本历史全集 | 是 | 同步启用时 | 否 | 否 | 只发当前任务需要的最小摘要 |
| Consent/Audit全文 | 是 | 审计必要时 | 否 | 否 | 模型只接收能力门控 |
| 私有推理链 | 不应持久化 | 不记录 | 否 | 否 | 只保存结构化结论/证据/版本 |

### 12.3 Input Manifest（第三方调用必填）

每次调用必须记录：`purpose_code, recipient_id, field_paths_sent, transform_applied, source_record_ids, policy_version, model_id, payload_hash, general_model_training_allowed=false, created_at_us`。

- 当前任务确有必要且有独立 Consent；
- 字段白名单校验不通过返回 `third_party_payload_blocked`；
- 默认去标识化；接收方/目的/范围变化重新授权；
- 字段具体白名单、保留与删除时限未 Frozen 前，第三方敏感数据发送保持 Won't Have / Spec Blocked。

### 12.4 模型输出

- 模型输出标记 `model_generated`；安全规则不可被模型绕过；
- 只保留结构化结论、证据、规则和版本，不展示或持久化私有思维链。

---

## 13. 离线、同步与冲突合同

### 13.1 离线可用

- 已确认目标边界版本、目标、里程碑和缓存计划查看；
- 今日摘要、执行开始/暂停/恢复/完成/跳过/取消/撤销；
- RPE、疼痛、质量、能量记录；
- 草案编辑、Consent 撤回和本地安全暂停；
- 已下载内容。

### 13.2 离线不得伪装可用

- 新目标开放式 AI 推导；
- 完整计划和多职责评审；
- 新知识提取与注入评估；
- 第三方模型调用；
- 依赖最新云端数据的风险放行。

这些请求只能排队或显示待处理，不能伪造最终结论。

### 13.3 冲突优先级

1. **账号所有权**：不同 owner_id / account_mismatch 必须拒绝自动合并；登出/切号不得串写；
2. **安全**：新安全限制、疼痛和规则版本优先于旧缓存；
3. **Consent 撤回**：立即停止新处理，取更严格值；
4. **Eligibility**：incomplete/ineligible/rejected/unavailable/expired/superseded 优先于旧 eligible 回执；
5. **执行事实**：已发生事实不可被新计划覆盖；
6. **用户上游控制**：用户对目标、时间、场景、现实约束与是否知识注入的最新显式修改优先；
7. **Atlas 编排**：知识采纳、计划生成与普通调整由 Atlas 基于有效上游约束自主决定；计划版本并存并建立 supersedes，展示依据、差异和影响，不新增逐项审批；
8. **删除传播**：tombstone 阻止旧设备/备份把已删除对象复活；保留期仍 Spec Blocked；
9. 跨设备核心冲突不得只按时间戳最后写入覆盖。

---

## 14. SLO 与降级合同

| 场景 | P95 目标 | 失败时仍可用 | 禁止输出 | Fail-closed |
|---|---:|---|---|---:|
| 本地今日摘要首屏 | `<2s` 候选，设备基线待冻结 | 最近有效摘要和同步状态 | 空白等待云 Agent | 否 |
| Pulse 首次触觉/视觉反馈 | `<100ms` 候选；完成阈值500ms | 等效按钮/静态反馈 | 把延迟误认为未触发或锁训练 | 否 |
| 调性适配 | `≤5s` | 最近有效调性 | 局部漂移或安全变化 | 否 |
| 方向/目标引导单轮 | `≤10s` | 保留输入、手动编辑 | 伪装形成角色身份或人格画像 | 否 |
| 日内小幅调整 | `≤20s` | 最近有效安全计划、待处理 | 清空今日、伪称已审核 | 涉及安全时是 |
| 有界语言评测 | `≤30s` | 估计/未完成 | 正式权威等级 | 否 |
| 睡眠/营养非紧急建议 | `≤30s` | 一般建议、数据不足态 | 诊断/精确健康结论 | 否 |
| 安全/康复触发 | 立即暂停；完整理由 `≤30s` | 短理由、保守替代、等待复评 | 继续原危险方案 | 是 |
| 知识评估 | `≤60s` | 保存来源、待评估 | 自动注入或无来源结论 | 安全子评审是 |
| 完整计划与多职责评审 | `≤90s` | 进度、后台、保守部分 | 不完整方案标为 ready | 是 |
| PR/隐藏进步/趋势 | 非阻塞，在相关回顾出现 | 延后到下次回顾 | 小样本惊喜、伪预测 | 否 |
| 正常同步 | `<5s` 候选 | 本地继续、待同步 | 覆盖本地事实/旧安全状态 | 安全/撤回传播是 |

设备档位、网络条件、数据量、P95/P99 窗口和后台/取消细则仍为 `Spec Blocked`。

---

## 15. 验收标准（锁定产品语义）

| 编号 | Given | When | Then |
|---|---|---|---|
| AC-01 | 用户表达想提升的方向 | 保存、拒绝或取消目标引导 | 只记录用户原话、目标、时间、场景与约束；不生成身份称谓，不要求先确认身份；输入可恢复且无惩罚 |
| AC-02 | 系统形成方向草案 | 用户确认目标边界 | 复用兼容字段保存新版本，`confirmation_source=user_explicit` 仅表示用户确认目标/约束，不表示接受系统定义的角色身份；历史版本保留 |
| AC-03 | 用户已激活 3 个成长域 | 尝试激活第 4 个域 | 提供聚焦建议，不静默删除已有域或目标 |
| AC-04 | 成长域未激活 | 查看页面、存储和指标 | 不展示、不建占位、不进入权重和 Agent 上下文 |
| AC-05 | 用户跳过 RPE | 保存本次反馈 | `rpe_state=missing`，不得复用历史值 |
| AC-06 | 用户执行 Pulse 或完全跳过 | 进入安全可执行计划 | 两种路径均可继续；Pulse 不改变准备度和安全状态 |
| AC-07 | 普通目标/时间/场景冲突 | Atlas 生成或调整计划 | 按用户上游约束自主编排，不删除目标；展示受影响目标、依据、前后差异、代价和版本，不出现逐项“采纳/拒绝”审批 |
| AC-08 | 安全规则命中 | 用户请求继续原危险方案或普通偏好与安全冲突 | 安全规则独立且不可覆盖；无继续原方案入口；显示依据、替代、暂缓和复评条件 |
| AC-09 | 适用范围项目默认未选 | 用户未完成、拒绝或无法确认 | 不生成普通精细训练方案；保留无关能力和可访问重试 |
| AC-10 | 命中未成年人/孕期/急性疼痛/明确疾病/术后康复 | 请求生成或继续训练 | 安全否决，转保守提示/专业转介；不可覆盖 |
| AC-11 | 用户已通过适用范围确认 | 后续出现疼痛、异常恢复或重大变化 | 重新安全评审；旧确认不作为安全通过证据 |
| AC-12 | 用户撤回 Consent | 系统拟继续采集/外发 | 立即停止新处理，记录传播/删除状态 |
| AC-13 | 第三方模型需要数据 | 无独立 Consent 或超出白名单 | 不发送，提供本地/手动降级 |
| AC-14 | 设备离线 | 用户执行、记录疼痛或撤销 | 本地立即追加事实；重连幂等同步；不重复 PR |
| AC-15 | 云端计划更新 | 本地已有执行事实 | 不覆盖事实；版本并存并解释后续影响 |
| AC-16 | 指标数据不足 | 用户查看方向、恢复或融合 | 显示阶段、证据和充分度，不显示伪精确百分比 |
| AC-17 | 模型/安全依赖超时 | 请求安全相关放行 | 保持 `precautionary_paused/blocked`，不默认通过；仅独立审核通过的新安全替代版本可执行 |
| AC-18 | 用户选择发起知识注入 | Atlas 完成评估与编排 | Atlas 自主决定采纳、改造采纳、暂缓或不采纳，并展示各项决定的理由、依据、影响与版本；用户不逐条审批内容 |
| AC-19 | 用户修改目标、时间、场景或现实约束 | Atlas 生成后续计划版本或普通调整 | Atlas 自主执行并解释触发来源、前后差异和影响；旧版本可追溯，不设置逐项审批流 |
| AC-20 | 用户使用读屏或动态字体 | 完成核心路径 | 功能等价，无手势唯一入口和颜色唯一信息；Q06 保持 V6 既有动效，不新增 reduced-motion 范围 |

完整 A–K/Agent/全局 GWT 以 `primeatlas-spec-qa-input-v1.0.md` 为验收附录。

---

## 16. QA 门禁

### 16.1 Spec Ready

- 12 项产品 P0 均有唯一合同；
- Requirement 字段完整率 100%；
- P0 状态机均有合法/非法转换；
- API、事件、错误码、幂等和版本兼容可测试；
- 外部依赖四类降级可注入验证；
- 公式均有样本、窗口、误差、金标和禁止显示条件；
- IA 完成低保真证据并 Frozen；
- P0 未决项和 P0 缺陷均为 0。

### 16.2 Dev Ready

只有纳入某个 Release 的 Requirement 全部 `Spec Ready`，且测试 ID、CI 门禁、测试数据隔离、开发自检命令明确后，才可进入开发。

**当前判定：NOT SPEC READY / NOT DEV READY。** V0.2 测试追踪合同已定义10个Requirement、55个Test ID、22个夹具、18个故障注入和8项低保真证据；100%静态映射不代表实现、自动化或D3/D4真实验证通过。

---

## 17. Spec Blocked 清单

以下为必须继续冻结、不得由开发自行猜测的主要参数：

1. 首发地区、平台、受监管专业称谓；
2. 方案 A/B/C 的低保真验证与最终 IA/路由/返回栈；验证包已完成，但 LF-IA-01～18 的 D3/D4 真实证据、量化汇总和最终裁决仍未产生；
3. 适用范围字段文案、版本、有效期、重确认条件和转介内容；
4. 疼痛、负荷、禁忌阈值、证据优先级、替代与复评；
5. V0.2 的13表物理 Schema、复合 FK、索引和 baseline 已固化；migration runner、备份/只读恢复、N-1升级、共享 UoW/Repository 集成仍须实现和验收。后续版本的业务删除、tombstone、防复活与保留政策不得回写 V0.2 baseline；
6. API/事件最终签名、错误码、幂等、事务和版本兼容；
7. Consent 目的代码、字段范围、接收方、有效期、撤回和衍生数据处理；
8. 第三方模型字段级白名单、接收方、保留和删除时限；
9. 离线矩阵、队列、重试、同步合并、tombstone 和旧设备防复活；
10. 身份进度、目标健康度、准备度、ACWR、完成质量、势能、融合、PR 和预测公式；
11. 场景来源、数据有效期和误检纠正；
12. 小幅/重大调整完整分类和回退时限；
13. 各专业域强制检查与内容来源/版权；
14. 12 Agent 输入字段、写权限、否决权、失败接管；
15. SLO 设备/网络基线、计时、P95/P99 和后台/取消；
16. 无障碍平台矩阵、动态字体上限和验收数据；
17. 组件级视觉 Token 最终参数（Component Token 映射、各层阴影参数、深色覆盖、逐组件密度与视觉验收基线），须在 Release UI Spec 冻结；
18. 登录方式、游客合并、注销、导出和删除 SLA；
19. 通知类型、频率和安全例外；
20. 成果分享是否首发及其白名单/TTL/撤回。

以上20项为主文合并组；详尽清单以 Architecture Input 第8节与 QA Input 第9节的27类逐项门禁为准。关闭 Spec Ready 时必须提供“20个合并组 → QA 27类”的映射和逐项关闭证据，不能以合并项通过代替子类通过。

---

## 18. 下一步冻结计划

1. 制作方案 A 主原型及 B/C 必要对照的低保真任务流，完成 §8.3 的 18 项验证主题与 14 项最小任务；
2. `UC-010 archive_domain`、`UC-013 update_goal`、`UC-019 journey read` 的请求/响应、错误恢复及事务/读取语义已冻结；V0.2 的13表物理 Schema/FK/索引、baseline snapshot 与机械约束测试已落盘，下一步实现 migration runner、备份/只读恢复、共享 UoW/Repository 集成；仍未达到 Dev Ready；
3. 冻结 tombstone 保留/防复活窗口与确定性拒绝码；若保留第一方远程辅助，冻结 recipient/service identity、Consent 文案/有效期和保留删除 SLA，否则明确 V0.2 仅本地模式；
4. QA 已建立 V0.2 55个Test ID和故障注入合同；下一步冻结低保真样本/阈值、CI命令、测试隔离与覆盖率门禁，并将新增架构合同更新进追踪矩阵；
5. 交付总监执行 Spec 一致性门禁，把 V0.2 对应条目从 `Spec Blocked` 转为 `Frozen`；仅 V0.2 达到 Dev Ready 后启动开发。

---

## 19. 变更记录

| 日期 | 变更内容 | 原因 | 影响范围 |
|---|---|---|---|
| 2026-07-20 | 创建 Spec v1.0 Draft for Freeze | 产品 PRD 已 Accepted，三路 Spec 输入齐备 | 进入 Phase 1.5 冻结，不授权开发 |
| 2026-07-20 | 修复设计审查6项P0与架构审查7类P0 | 补齐V0.2页面闭环、对象归属、IA门禁、状态/Token/无障碍、精确状态机、事件/Repository、账号/Eligibility冲突和字段级数据可见 | 继续复审，仍NOT DEV READY |
| 2026-07-20 | 设计第二轮复审通过并吸收P1 | 6项设计P0归零；将组件级视觉Token最终参数加入Release UI Spec门禁 | 允许进入低保真冻结工作，不授权开发 |
| 2026-07-20 | QA独立准入复审完成 | 架构/设计结构P0归零；识别5项readiness blocker，并明确NOT SPEC READY / NOT DEV READY、Required语义、LF-IA-01～18和27类门禁映射 | 继续Phase 1.5冻结工作，禁止开发 |
| 2026-07-20 | Eligibility页面合同与IA低保真验证包完成 | 补齐expired/superseded页面行为；建立LF-IA-01～18、14项任务和D3/D4证据执行合同 | P0-02合同关闭；P0-04由“缺验证方案”转为“等待真实证据” |
| 2026-07-20 | V0.2数据边界、依赖降级与测试追踪合同完成 | 第三方Hard Disabled、本地完整最低体验、第一方白名单/Manifest、原子事务、N/A零调用、10 Requirement/55 Test/22 Fixture/18 Injection | P0-01合同关闭；P0-03静态追踪关闭；P0-05依赖矩阵关闭，剩余自动化/Release冻结证据 |
| 2026-07-21 | 按 V6 已锁定裁决修正目标主权与 Atlas 决策合同 | 删除“成为谁/身份差距/画像确认前置目标”语义；锁定用户上游控制、Atlas 自主知识采纳/计划编排/普通调整及解释义务，安全规则独立不可覆盖 | 只改 Spec 语义；V0.2 纯本地边界、Dart Use-case、SQLite Schema、API/DB 数量均不扩大 |

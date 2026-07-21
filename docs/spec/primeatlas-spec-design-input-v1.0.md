# PrimeAtlas Spec 设计输入

> 版本：v1.0 Candidate Design Input  
> 日期：2026-07-20  
> 作者：颜好看（设计总监）  
> 阶段：Phase 1.5 / Spec 设计输入  
> 状态：供 Spec 汇编与低保真验证；不是高保真稿、不是前端实现说明、不是 Frozen IA  
> 产品基线：PrimeAtlas 产品决策确认单 v1.0 Approved、产品理解 v1.1 Accepted、全量功能 PRD v1.1 Accepted、需求追踪矩阵 v1.1 Accepted  
> 主验证候选：方案 A「今日 / 旅程 / 成长域 / 我的」  
> 体验参考：`primeatlas-prototype-v6.html`，仅继承已验证交互品质，不继承六 Tab、硬编码指标、emoji 图标和演示数据

---

## 0. 文档用途、状态和边界

### 0.1 本文回答什么

本文把已接受产品规则转换为可供 Spec 使用的设计合同输入，覆盖：

1. 页面树与路由候选；
2. 页面核心组件及其产品对象、逻辑 API、领域事件；
3. 页面和组件必须覆盖的完整状态；
4. 单域、双域、三域及域内多目标关键路径；
5. Design Token、图标、字体、动效和组件状态建议；
6. 无障碍等效入口；
7. 设计反模式门禁；
8. 可在 Spec 锁定的项目与仍需低保真验证的项目。

### 0.2 本文不做什么

- 不制作高保真视觉稿；
- 不提供 Flutter、Web 或原生前端代码；
- 不新增 PRD 外功能；
- 不把 12 类 Agent 表现为 12 个聊天机器人、真人专家或独立模型；
- 不冻结未经验证的一级导航、具体路由路径、Tab 文案和页面数量；
- 不用页面设计替代状态机、API、数据、同步、安全和验收合同；
- 不复用旧 `UIUX-S1.md` 中的习惯 CRUD、连续天数、今日微步、泛陪伴式首页作为当前产品范围。

### 0.3 状态词

| 状态 | 含义 |
|---|---|
| `Accepted Product Rule` | 产品原则已经确认，设计不得改写 |
| `Spec-lock Recommended` | 设计建议可在本轮 Spec 中锁定，不依赖 IA 偏好验证 |
| `Candidate` | 当前推荐验证方向，尚未冻结 |
| `Low-fi Required` | 必须用低保真任务验证后才能冻结 |
| `Blocked` | 缺产品、规则、数据或体验证据，不得进入实现 |
| `Frozen` | 仅在 Spec 审查通过后使用，本文不宣称任何 IA 项已 Frozen |

### 0.4 已接受、不可被设计改写的产品边界

- 身份迁移是唯一最高层主轴；
- 早期为体能单域深扎，同时让融合来源与证据可发现；
- 最多同时主动编排 3 个活跃成长域，每域可以有多个目标；
- 未激活域不展示、不占位、不存储无意义数据、不进入权重；
- 普通冲突保留“一键采纳 / 我自己来”；
- 安全否决后不得继续原危险方案，只能选择安全替代、暂缓或复评；
- 首发训练方案仅面向完成主动适用范围确认的 18 岁以上普通健康成年人；命中、拒绝或无法确认时禁止普通精细训练方案；
- Prime Pulse 可绕过，不是训练解锁条件；长期目标势能、今日准备度、启动仪式相互独立；
- 指标默认展示阶段、趋势、证据和数据充分度，条件不足不显示精确百分比；
- 融合数据采集和内容生成可分别关闭或撤回，且无惩罚；
- 第三方模型处理需要独立 Consent，只获得当前任务最小必要、默认去标识化数据；
- 核心今日查看、执行、RPE、疼痛、能量记录和已缓存说明离线可用。

---

## 1. 产品类型与设计语言边界

### 1.1 产品类型

PrimeAtlas 是 AI 原生个人成长操作系统，而不是健身 App、习惯 App、通用任务管理器或聊天机器人。设计必须同时满足：

- 身份迁移的长期叙事；
- 体能专业空间的高信息密度和可信度；
- 多域编排的结构清晰；
- 健康与安全场景的审慎表达；
- 数据主权、可解释性和默认私密；
- 移动端单手可达与离线连续性。

### 1.2 对标品牌与取舍

| 对标 | 采用 | 不采用 |
|---|---|---|
| Linear | 克制密度、细边框层级、明确状态、精确排版 | 任务至上的压迫感、过冷的开发者工具语气 |
| Notion | 对象层级、渐进展开、来源可回溯 | 无边界自由画布、依赖用户自行搭系统 |
| Apple HIG / Fitness | 移动可达性、动态字体、非评判反馈、健康信息谨慎表达 | 完成圆环压力、红色未达标、手势唯一入口 |
| Stripe | 可信数据表达、解释层级、异常和空状态质量 | 面向桌面数据后台的过高首屏密度 |

### 1.3 先冻结的基础系统

以下不依赖方案 A/B/C 的偏好验证，建议直接作为 `Spec-lock Recommended`：

- 图标：仅 Lucide，16 / 20 / 24px；
- 字体：Inter + Noto Sans SC；规则、版本、时间和标识使用 JetBrains Mono；
- 浅色优先，深色作为同一语义 Token 的覆盖层；
- 颜色只能通过 Foundation → Semantic → Component Token 使用；
- 4px 间距网格；
- 标准缓动 `cubic-bezier(0.4, 0, 0.2, 1)`；
- 所有交互支持 focus-visible、键盘/辅助技术、动态字体和 reduced motion；
- 状态、风险、域和数据充分度不得只靠颜色区分。

---

## 2. 页面树候选：方案 A

> 本节是主验证候选，不是最终页面或路由合同。页面拆分粒度、Tab 文案、Tab 顺序、二级导航形式、返回栈和深链规则均须在 Spec 与低保真验证后冻结。

### 2.1 总体页面树

```text
应用前置
├─ 价值预览（游客可见）
├─ 账号进入 / 游客继续
├─ 身份定义
│  ├─ 自由表达与渐进追问
│  ├─ 当前身份 / 目标身份草案
│  ├─ 活跃成长域候选（最多 3 个活跃域）
│  ├─ 域内目标候选
│  └─ 里程碑确认
└─ 必要时的目的型授权 / Consent

主框架：方案 A 候选
├─ 今日
│  ├─ 今日摘要：今天为什么这样安排
│  ├─ 今日状态：能量、准备度、数据充分度、安全提示
│  ├─ 可选 Prime Pulse
│  ├─ 今日行动列表与主行动
│  ├─ 行动详情 / 动作学习 / 安全理由
│  ├─ 执行：开始、暂停、恢复、完成、跳过、撤销
│  ├─ RPE / 疼痛 / 完成质量反馈
│  ├─ 调整说明与前后差异
│  └─ 今日身份证据 / 有证据时的融合回流
│
├─ 旅程
│  ├─ 当前身份 → 目标身份
│  ├─ 身份差距与活跃成长域概览
│  ├─ 域内多个目标与里程碑
│  ├─ 目标详情、证据、风险与调整记录
│  ├─ 成果 / PR / 隐藏进步
│  ├─ 周期回顾
│  ├─ 身份或目标重校准候选
│  └─ 画像版本历史与恢复
│
├─ 成长域
│  ├─ 仅已激活域的域切换器
│  ├─ 域概览与身份 / 目标关联
│  ├─ 域内目标列表
│  ├─ 专业计划与执行历史
│  ├─ 域数据、洞察与安全
│  ├─ 知识、笔记、派生内容与来源
│  └─ 知识适用性评估与渐进融入
│
└─ 我的
   ├─ 已确认画像摘要与治理入口
   ├─ 数据来源与权限
   ├─ 第三方模型 Consent
   ├─ 融合采集 / 生成控制
   ├─ 调性与通知
   ├─ 离线 / 同步 / 冲突处理
   ├─ 账号、游客合并与会话
   └─ 导出、更正、撤回与删除

跨页面高优先级通道
├─ 安全否决：理由 / 证据 / 安全替代 / 复评条件
├─ 适用范围确认：默认未选、逐项主动动作
├─ 普通冲突：一键采纳 / 我自己来
├─ 权限与 Consent：按目的触发，不做总授权墙
├─ 待处理任务：计划生成、知识评估、同步
└─ 来源回溯：训练、目标、计划、笔记、书摘、回顾
```

### 2.2 概念路由候选

| Route ID | 概念路径候选 | 页面职责 | 状态 |
|---|---|---|---|
| R-00 | `/preview` | 免登录价值预览，展示真实身份—目标—今日行动关系，不使用抽象 Hero | `Candidate` |
| R-01 | `/account/entry` | 游客继续、登录、注册和数据合并入口 | `Candidate` |
| R-02 | `/identity/discovery` | 自由表达、渐进追问、可跳过或停止 | `Candidate` |
| R-03 | `/identity/draft` | 编辑并确认当前身份、目标身份和约束草案 | `Candidate` |
| R-04 | `/identity/domains` | 确认活跃成长域；最多 3 个，未激活域不占位 | `Candidate` |
| R-05 | `/identity/goals` | 查看、编辑、拒绝域内目标候选 | `Candidate` |
| R-06 | `/identity/milestones` | 确认目标里程碑、证据和依赖 | `Candidate` |
| R-10 | `/today` | 今日摘要、状态、行动、证据的 Tab 根页 | `Low-fi Required` |
| R-11 | `/today/pulse` | Prime Pulse 启动仪式；也可作为今日页内嵌组件 | `Low-fi Required` |
| R-12 | `/today/action/:actionId` | 行动详情、目标关联、调整理由、安全信息 | `Candidate` |
| R-13 | `/today/action/:actionId/execute` | 执行态，支持暂停、恢复、完成和离线 | `Candidate` |
| R-14 | `/today/action/:actionId/feedback` | RPE、疼痛、质量、原因；缺失保持 missing | `Candidate` |
| R-15 | `/today/adjustment/:adjustmentId` | 展示调整前后、来源、影响、确认或回退 | `Candidate` |
| R-16 | `/today/evidence/:evidenceId` | 今日身份证据或融合证据的来源详情 | `Candidate` |
| R-20 | `/journey` | 身份迁移总览的 Tab 根页 | `Low-fi Required` |
| R-21 | `/journey/goals/:goalId` | 目标、里程碑、证据、风险、计划关联 | `Candidate` |
| R-22 | `/journey/milestones/:milestoneId` | 里程碑证据和完成规则 | `Candidate` |
| R-23 | `/journey/reviews/:reviewId` | 周期回顾、成果故事线和下一步 | `Candidate` |
| R-24 | `/journey/portrait-candidates/:candidateId` | 对比画像候选，确认、拒绝或稍后处理 | `Candidate` |
| R-25 | `/journey/portrait-versions` | 已确认画像版本历史与恢复 | `Candidate` |
| R-30 | `/domains` | 成长域 Tab 根页；默认进入上次使用域 | `Low-fi Required` |
| R-31 | `/domains/:domainId` | 域概览、域内目标和专业状态 | `Low-fi Required` |
| R-32 | `/domains/:domainId/plan` | 专业计划和版本 | `Candidate` |
| R-33 | `/domains/:domainId/status` | 域数据、准备度、风险、来源和充分度 | `Candidate` |
| R-34 | `/domains/:domainId/history` | 执行历史和可解释趋势 | `Candidate` |
| R-35 | `/domains/:domainId/knowledge` | 知识、笔记、派生内容和来源 | `Candidate` |
| R-36 | `/domains/:domainId/knowledge/:itemId` | 知识详情、版权、来源、关联目标 | `Candidate` |
| R-37 | `/domains/:domainId/knowledge/:itemId/review` | 适用性评估、理由和四类决策 | `Candidate` |
| R-40 | `/me` | 个人治理 Tab 根页 | `Candidate` |
| R-41 | `/me/data-permissions` | 数据来源、权限、Consent 和可见范围 | `Candidate` |
| R-42 | `/me/fusion-controls` | 融合采集、生成和撤回控制 | `Candidate` |
| R-43 | `/me/tone` | 四调性预览与选择，默认专业 | `Candidate` |
| R-44 | `/me/notifications` | 分类型通知、免打扰和安全分级 | `Candidate` |
| R-45 | `/me/offline-sync` | 待同步、失败、冲突、缓存新鲜度 | `Candidate` |
| R-46 | `/me/account` | 游客、登录、合并、切换、登出和注销 | `Candidate` |
| R-47 | `/me/export-delete` | 导出、删除、范围和处理进度 | `Candidate` |
| R-50 | `/eligibility/training` | 训练适用范围确认，不可默认勾选 | `Spec-lock Required` |
| R-51 | `/safety/decision/:decisionId` | 安全否决、替代、暂缓、复评；无继续原方案入口 | `Spec-lock Required` |
| R-52 | `/consent/:purpose` | 目的型授权、接收方、范围、保留和拒绝后的体验 | `Spec-lock Required` |
| R-53 | `/conflicts/:conflictId` | 普通冲突的影响和双轨选择 | `Spec-lock Required` |

### 2.3 路由和返回规则候选

以下规则必须进入低保真与 Spec 验证，本文不宣称已冻结：

1. 四个 Tab 各保留独立返回栈；切换 Tab 后返回不应跳到另一 Tab 的随机中间页。
2. 来自今日行动的目标、域、知识来源深链，关闭或返回时优先回到原行动上下文，而不是重置到目标 Tab 根页。
3. 安全否决、适用范围确认、Consent 和普通冲突是业务状态页面，不应仅用一次性 Toast 或不可恢复弹窗承载。
4. 安全否决页退出后，原危险行动保持不可启动；返回今日时展示安全替代或暂停状态。
5. 身份、目标和画像的编辑结果只有确认后才能进入正式版本；取消返回时保留草稿或明确询问是否丢弃。
6. 从通知或外部深链进入时，若对象已撤回、过期、归档或无权限，应进入对应解释状态，不静默重定向到首页。
7. 旅程和成长域之间的同一目标只存在一个正式详情对象；另一个入口使用上下文链接，不复制编辑页面和状态。
8. Tab 再次点击是回根页、滚动到顶还是保持位置，须通过可用性测试选择，不能由开发默认决定。

### 2.4 页面归属原则

| 对象/能力 | 主归属候选 | 交叉入口 | 禁止重复 |
|---|---|---|---|
| 当前身份 → 目标身份 | 旅程 | 今日顶部作用说明、成长域关联 | 不把核心身份迁移藏在“我的” |
| 目标和里程碑 | 旅程 | 成长域内按域筛选、今日行动回链 | 不创建两套可编辑目标详情 |
| 专业计划 | 成长域 | 今日显示当日切片、旅程显示目标关联 | 不把通用计划做成第五个 Tab |
| 今日行动和执行 | 今日 | 成长域计划进入具体行动 | 不在多个入口形成不同执行状态 |
| 身体状态和体能洞察 | 成长域 → 体能 | 今日只显示影响当日的摘要 | 不固定为所有用户可见的一级“身体”Tab |
| 知识和派生内容 | 对应成长域/目标上下文 | 今日证据与训练卡来源芯片 | 不做脱离目标的独立内容产品 |
| 成果、PR、周期回顾 | 旅程 | 今日完成后提示、域历史链接 | 不做社交排行榜或连续天数中心 |
| 画像治理、权限、账号 | 我的 | 旅程提供画像版本内容入口 | 不让“我的”承担身份迁移主叙事 |
| 安全决定 | 相关计划/执行路径直接可达 | 今日、成长域、通知深链 | 不藏到设置或 Agent 日志 |

---

## 3. 页面核心组件与产品对象 / API / 事件映射

> API 名称是设计侧逻辑能力候选，不是最终 endpoint 或方法签名。架构 Spec 必须统一命名、请求响应、错误码、幂等键和权限。领域事件优先沿用追踪矩阵已有名称。

### 3.1 应用前置与身份建立

| Page / Component | 核心职责 | 产品对象 | 逻辑 API 候选 | 领域事件 | 关键状态 |
|---|---|---|---|---|---|
| 价值预览 `ProductLoopPreview` | 用真实产品结构解释身份→目标→今日行动→证据 | 只读示例，不写用户对象 | `getValuePreview()` | `preview_opened` | 加载、离线内置示例、内容失效 |
| 渐进追问 `IdentityDiscoveryFlow` | 自由表达、3–6 轮建议但可随时停止 | `IdentityDraft`、`IdentityField` | `createIdentityDraft()`、`continueIdentityDiscovery()` | `draft_created`、`discovery_answered` | 首次、保存中、模型超时、稍后继续 |
| 身份草案 `IdentityDraftEditor` | 编辑当前身份、目标身份、约束和来源 | `IdentityDraft`、`GapEvidence` | `getIdentityDraft()`、`updateIdentityDraft()` | `draft_updated`、`draft_discarded` | 数据不足、字段冲突、离线草稿 |
| 身份确认 `IdentityConfirmation` | 只有主动确认才形成正式画像 | `PortraitVersion` | `confirmIdentityDraft()` | `portrait_confirmed`、`version_activated` | 待确认、确认中、并发版本冲突 |
| 成长域选择 `ActiveDomainSelector` | 激活 1–3 个成长域，未激活域不占位 | `ActiveDomain` | `listDomainCandidates()`、`setActiveDomains()` | `domain_activated`、`domain_paused` | 0 域草稿、3 域上限、超限聚焦建议 |
| 目标候选 `GoalProposalList` | 展示目标来源身份差距、基线和证据 | `GoalDraft`、`GapEvidence` | `generateGoalProposals()`、`updateGoalDraft()` | `goal_proposed`、`goal_confirmed` | 生成中、探索目标、候选不合适 |
| 里程碑确认 `MilestoneReview` | 确认起点、状态、周期、证据、依赖 | `Milestone`、`EvidenceRule` | `generateMilestones()`、`confirmMilestones()` | `milestone_changed` | 无法量化、依赖缺失、待确认 |

### 3.2 今日

| Page / Component | 核心职责 | 产品对象 | 逻辑 API 候选 | 领域事件 | 关键状态 |
|---|---|---|---|---|---|
| 今日摘要 `TodaySummary` | 第一眼解释今天为何这样安排、目标关联和变化 | `TodaySummary`、`DailyPlan` | `getTodaySummary(date, timezone)` | `today_opened` | 首次、休息日、无计划、离线、过期 |
| 安排理由 `PlanReasonPanel` | 展示来源、变化、参与职责、充分度 | `PlanVersion`、`RoleDecision`、`EvidenceLink` | `getPlanExplanation(planVersionId)` | `explanation_opened` | 部分结果、Agent 超时、依据已撤回 |
| 今日状态 `DailyStateStrip` | 分开表达能量、准备度、安全状态 | `EnergyLog`、`ReadinessSnapshot`、`RiskFlag` | `getDailyState()`、`recordEnergy()` | `energy_logged` | 拒权、数据不足、来源冲突、数据过期 |
| Prime Pulse `PulseControl` | 可选启动仪式，不解锁训练 | `PulseEvent` | `completePulse()`、`skipPulse()` | `pulse_started`、`pulse_completed`、`pulse_skipped` | 默认、按下、提前松手、切后台、重复、已完成 |
| 今日行动 `ActionCard/List` | 展示目标、时间、调整、安全和离线可用性 | `ActionUnit`、`TimeSlot`、`Goal` | `listTodayActions()` | `action_viewed` | 无行动、替代行动、暂停、已撤销 |
| 行动执行 `ExecutionController` | 开始、暂停、恢复、完成、跳过、撤销 | `ExecutionRecord`、`ExecutionEvent` | `startExecution()`、`pauseExecution()`、`completeExecution()`、`revertExecution()` | `started`、`paused`、`completed`、`reverted` | 杀进程恢复、重复点击、跨日、计划被替代 |
| 动作学习 `ActionLearningPanel` | 3 秒检查、30 秒预习、完整教学入口 | `ContentAsset`、`ExerciseVersion` | `getActionInstruction()` | `content_viewed` | 视频失效、离线文本替代、版权撤回 |
| 反馈 `FeedbackSheet/Page` | RPE、疼痛、质量和原因，不伪造缺失值 | `FeedbackRecord`、`PainEvent` | `recordFeedback()`、`markFeedbackMissing()` | `feedback_recorded`、`feedback_missing` | 跳过、异常值、疼痛、安全暂停 |
| 调整说明 `AdjustmentDiff` | 展示前后差异、来源、影响和回退 | `AdjustmentProposal`、`SceneEvent` | `getAdjustment()`、`acceptAdjustment()`、`revertAdjustment()` | `adjustment_applied`、`adjustment_reverted` | 小调已执行通知、大调待确认、回退失败 |
| 今日证据 `TodayEvidence` | 解释形成了什么身份证据；有证据时显示融合链 | `CompletionEvidence`、`FusionLink` | `listTodayEvidence()` | `evidence_viewed` | 数据不足隐藏、来源撤回、单域无融合模块 |

### 3.3 旅程

| Page / Component | 核心职责 | 产品对象 | 逻辑 API 候选 | 领域事件 | 关键状态 |
|---|---|---|---|---|---|
| 身份迁移头部 `IdentityTransitionHeader` | 固定表达当前身份→目标身份与证据边界 | `PortraitVersion`、`TransitionCandidate` | `getActivePortrait()` | `journey_opened` | 尚未确认身份、候选待处理、历史恢复中 |
| 活跃域概览 `ActiveDomainOverview` | 展示 1–3 个活跃域如何服务身份目标 | `ActiveDomain`、`Goal` | `listActiveDomainsWithGoals()` | `domain_overview_viewed` | 单域、双域、三域、暂停域 |
| 目标卡 `GoalCard` | 展示状态、阶段、趋势、证据和充分度 | `Goal`、`MetricSnapshot`、`RiskFlag` | `listGoals()`、`getGoal()` | `goal_viewed` | 草稿、活跃、暂停、调整中、完成、归档 |
| 里程碑线 `MilestoneTimeline` | 展示里程碑、证据和依赖，不只靠时间轴图形 | `Milestone`、`EvidenceRule` | `listMilestones(goalId)` | `milestone_viewed`、`milestone_achieved` | 未开始、进行中、达成、未达成、被替代 |
| 成果证据 `AchievementEvidence` | PR、隐藏进步、里程碑型证据与纠错 | `PRCandidate`、`PRRecord`、`Insight` | `listAchievementEvidence()`、`correctEvidence()` | `pr_detected`、`pr_confirmed`、`pr_revoked` | 候选、待确认、误报、已撤回、数据不足 |
| 周期回顾 `GrowthReviewStory` | 用故事线组织目标、成果、恢复、场景和下一步 | `GrowthReview` | `getGrowthReview(period)` | `review_opened` | 生成中、部分数据、无足够证据、离线缓存 |
| 画像候选对比 `PortraitCandidateDiff` | 比较当前版本与候选，用户确认才生效 | `TransitionCandidate`、`PortraitVersion` | `getPortraitCandidate()`、`confirmPortraitCandidate()`、`rejectPortraitCandidate()` | `candidate_created`、`version_activated`、`candidate_rejected` | 待确认、被拒、源数据更正、并发修改 |
| 画像版本 `PortraitVersionHistory` | 查看、比较和恢复历史版本 | `PortraitVersion` | `listPortraitVersions()`、`restorePortraitVersion()` | `portrait_restored` | 空历史、恢复确认、影响分析中 |

### 3.4 成长域

| Page / Component | 核心职责 | 产品对象 | 逻辑 API 候选 | 领域事件 | 关键状态 |
|---|---|---|---|---|---|
| 域切换器 `DomainSwitcher` | 只显示活跃域，支持 1–3 域稳定扩展 | `ActiveDomain` | `listActiveDomains()` | `domain_switched` | 单域隐藏切换器、双域、三域、域暂停 |
| 域概览 `DomainOverview` | 展示域目标、专业状态、计划和证据 | `ActiveDomain`、`Goal`、`PlanVersion` | `getDomainOverview(domainId)` | `domain_opened` | 首次、无有效计划、计划待审、安全否决 |
| 专业计划 `ProfessionalPlan` | 结构、版本、审查、变更与安全状态 | `PlanVersion`、`ProfessionalChecklist`、`SafetyReview` | `getPlan()`、`generatePlan()`、`reviewPlan()` | `plan_generated`、`plan_reviewed`、`plan_gate_passed`、`plan_gate_failed` | 生成中、草稿、待审、待确认、有效、过期、被替代 |
| 域状态 `DomainStatus` | 数据来源、趋势、准备度、负荷、风险 | `MetricSnapshot`、`HealthObservation`、`RiskFlag` | `getDomainMetrics()` | `metric_recomputed` | 数据不足、来源冲突、权限拒绝、过期 |
| 执行历史 `ExecutionHistory` | 按目标和计划版本查看事实与反馈 | `ExecutionRecord`、`FeedbackRecord` | `listExecutionHistory()` | `history_viewed` | 空、离线缓存、同步中、冲突 |
| 知识库 `KnowledgeList` | 域/目标绑定的知识、笔记和派生内容 | `ContentAsset`、`KnowledgeSuggestion`、`DerivedContent` | `listDomainKnowledge()`、`importKnowledge()` | `knowledge_imported` | 无内容、导入中、来源失效、授权撤回 |
| 来源芯片 `SourceChip` | 回到训练、目标、计划、笔记、书摘或回顾父节点 | `FusionLink`、`EvidenceLink` | `resolveSourceLink()` | `source_opened` | 父节点删除、已撤回、无权限、离线未缓存 |
| 知识评估 `KnowledgeReview` | 提取→评估→理由→用户四类决策 | `KnowledgeSuggestion`、`AgentReview` | `evaluateKnowledge()`、`decideKnowledgeSuggestion()` | `knowledge_evaluated`、`knowledge_confirmed`、`knowledge_applied` | 提取中、评估中、超时、采纳、改造采纳、暂缓、不采纳 |
| 专家理由卡 `DecisionReasonCard` | 结构化展示结论、职责、证据、充分度和下一步 | `RoleDecision`、`EvidenceLink` | `getDecisionExplanation()` | `decision_explanation_opened` | 可加入、改造后可加入、不建议、安全否决、证据不足 |

### 3.5 我的与跨页面通道

| Page / Component | 核心职责 | 产品对象 | 逻辑 API 候选 | 领域事件 | 关键状态 |
|---|---|---|---|---|---|
| 权限与 Consent `DataPermissionCenter` | 按目的展示数据、接收方、保留和撤回 | `ConsentReceipt`、`VisibilityPolicy` | `listConsents()`、`grantConsent()`、`revokeConsent()` | `consent_granted`、`consent_revoked` | 未授权、已授权、已撤回、部分撤回、处理传播中 |
| 训练适用范围 `EligibilityDeclarationForm` | 默认未选、逐项主动确认适用范围 | `EligibilityDeclaration` | `submitEligibilityDeclaration()` | `eligibility_presented`、`eligibility_confirmed`、`eligibility_rejected`、`eligibility_unavailable` | 未完成、拒绝、无法确认、命中不支持范围、历史过期 |
| 融合控制 `FusionControlCenter` | 分别控制数据采集、内容生成和既有内容处理 | `ConsentReceipt`、`FusionLink` | `updateFusionControls()` | `fusion_disabled`、`fusion_enabled` | 已开启、采集关闭、生成关闭、已撤回、传播中 |
| 调性选择 `ToneSelector` | 四调性预览和确认；只改表达 | `ToneState`、`ToneVersion` | `getTone()`、`switchTone()` | `tone_switched` | 默认专业、预览、应用中、离线、切换失败 |
| 同步中心 `SyncStatusCenter` | 待同步、失败、冲突和重试影响 | `SyncEvent`、`ConflictVersion`、`Tombstone` | `getSyncStatus()`、`retrySync()`、`resolveSyncConflict()` | `sync_started`、`sync_succeeded`、`sync_conflicted` | 离线、待同步、同步中、成功、冲突、失败待处理 |
| 导出删除 `DataRightsCenter` | 导出、更正、删除的范围、进度和失败补偿 | `ExportJob`、`DeletionRequest` | `createExport()`、`requestDeletion()` | `export_requested`、`deletion_requested` | 排队、处理中、完成、部分失败、已取消 |
| 安全否决 `SafetyDecisionPage` | 原因、证据、安全替代、暂缓和复评条件 | `SafetyEvent`、`RuleHit`、`AlternativePlan` | `getSafetyDecision()`、`selectSafeAlternative()`、`requestReassessment()` | `safety_vetoed`、`alternative_offered`、`safety_resolved` | 立即阻断、理由生成中、替代可用、复评中、仍不满足 |
| 普通冲突 `ConflictDecisionPage` | 展示代价，提供一键采纳和我自己来 | `ConflictRecord`、`ArbitrationEvent` | `getConflict()`、`acceptRecommendation()`、`submitManualPlan()` | `conflict_detected`、`user_overrode` | 有推荐、无可行解、用户保留全部目标、待重排 |

---

## 4. 完整状态设计合同

### 4.1 全局状态原则

1. 状态必须在页面主体中解释，不只依赖 Toast、颜色或转瞬即逝动画。
2. 任何高风险流程都必须同时回答：发生了什么、依据是什么、现在还能做什么、什么不能做、如何恢复。
3. 离线、权限拒绝和 Consent 撤回不得被表现为“系统错误”；它们是用户可预期的业务状态。
4. 数据不足不等于零，不等于安全，也不等于没有进步。
5. 安全否决与普通建议拒绝不能复用同一视觉、文案或状态码。
6. 已撤回对象必须保留必要审计解释，但不得继续作为有效内容、指标或计划依据。
7. 加载超过场景 SLO 后必须转为明确的待处理/降级状态，不能无限 spinner。
8. 所有状态均需定义主要动作、次要动作、无障碍播报和离线行为。

### 4.2 必须覆盖的页面状态矩阵

| 状态 | 触发 | 页面表达 | 用户可做 | 禁止做法 |
|---|---|---|---|---|
| 首次 `first-use` | 无身份、无目标或首次进入某能力 | 解释此页服务哪段身份迁移；给单一下一步；不显示伪造仪表盘 | 开始、稍后、了解数据用途 | “Welcome to”大 Hero、虚构百分比、一次索取全部权限 |
| 空 `empty` | 确实无对象，如无目标、无知识、无历史 | 说明为何为空、是否正常、如何创建或返回上游 | 创建、导入、返回旅程 | 用失败语气；为空时仍展示 0 分或空图表 |
| 加载 `loading` | 本地或远端读取中 | 优先骨架化真实布局；明确当前步骤；长任务允许离开 | 取消、后台等待、查看最近有效内容 | 无限 spinner；首屏等待 Agent 才显示 |
| 错误 `error` | 请求、解析、存储或未知错误 | 人话说明影响范围；保留用户输入；提供重试与替代 | 重试、保存草稿、使用缓存、反馈问题 | 清空输入；把安全失败当普通错误后放行 |
| 离线 `offline` | 无网络或服务不可达 | 顶部持续但克制的离线状态；标注可用与待处理能力 | 查看缓存、执行、记录反馈、稍后同步 | 阻断全部 App；伪装云端评审已完成 |
| 拒权 `permission-denied` | 健康、日历、位置、文件、通知等权限拒绝 | 说明缺少何种数据及最低体验；提供手动输入 | 继续手动、本地使用、重新授权 | 强制去系统设置；阻断无关身份/目标能力 |
| Consent 未授权 `consent-not-granted` | 第三方模型或特定数据目的未同意 | 明确接收方、目的、字段和拒绝后的本地/手动能力 | 同意、拒绝、继续降级体验 | 将 Consent 捆绑到账户条款；默认开启 |
| Consent 已撤回 `consent-revoked` | 用户撤回数据采集/发送 | 显示停止新采集/发送的时间、既有和衍生数据处理进度 | 查看影响、重新授权、申请删除 | 撤回后继续发送；以降权或红点惩罚用户 |
| 数据不足 `insufficient-data` | 样本、窗口、来源或可信度不足 | 显示“学习中/尚不足以判断”、缺口和更新时间 | 手动补录、纠错、继续保守方案 | 显示 0、87%、预计日期；“未发现风险=安全” |
| 数据过期 `stale-data` | 超过有效期或来源失联 | 标明最后更新时间、过期影响和当前保守规则 | 刷新、手动确认、继续保守体验 | 无标识继续展示旧精确结论 |
| 来源冲突 `source-conflict` | 主观输入与设备、多个设备或版本冲突 | 并列来源、时间、可信度和系统当前采用规则 | 选择/纠错、保留未知 | 静默选择一个来源并冒充事实 |
| 安全否决 `safety-veto` | 适用范围或持续安全规则命中 | 高优先级但不恐吓；原因、证据、规则版本、替代、复评条件 | 选安全替代、暂缓、复评、管理目标 | 提供继续原危险方案；允许其他 Agent/调性覆盖 |
| 适用范围未完成 `eligibility-incomplete` | 未逐项完成主动确认 | 明确普通精细训练尚不可生成，其他功能仍可用 | 继续确认、稍后、返回目标管理 | 历史自动代填；用通用协议替代 |
| 适用范围拒绝 `eligibility-rejected` | 用户主动拒绝 | 不推断为符合范围；提供保守提示与非训练入口 | 重看说明、稍后重试、返回其他能力 | 诱导、惩罚、继续生成普通精细方案 |
| 无法确认 `eligibility-unavailable` | 辅助技术、网络、设备或理解问题导致无法完成 | 区分技术失败与主动拒绝；提供可访问重试 | 使用等效控件、稍后、获得说明 | 把技术失败记录为同意或拒绝 |
| 普通冲突 `ordinary-conflict` | 时间、方向、能量和优先级冲突 | 展示受影响目标、代价、建议和依据 | 一键采纳、我自己来、暂缓 | 自动删除目标；借“安全”名义强制普通偏好 |
| 生成中 `long-running` | 完整计划、知识评估、回顾生成 | 显示已完成阶段、预计范围而非虚假精确倒计时；可离开 | 取消、后台等待、查看草稿/缓存 | 必须盯屏；未过审结果标为 ready |
| 超时/降级 `timeout-degraded` | 模型或职责超时 | 标注缺失环节、当前可用部分、后续处理和安全边界 | 重试、使用已审核保守模板、稍后通知 | 安全审查超时自动通过 |
| 内容失效 `content-unavailable` | 视频、书摘、规则或来源失效/撤权 | 标注失效原因和时间；提供文本/图片/已审核替代 | 使用替代、返回、报告 | 继续作为有效专业证据 |
| 同步待处理 `sync-pending` | 离线事实尚未上传 | 在相关记录上显示非阻断状态和时间 | 手动重试、继续本地执行 | 用红点制造压力；阻断执行 |
| 同步冲突 `sync-conflict` | 多端画像/计划/编辑冲突 | 并列版本、来源、时间和影响；安全/撤回使用更严格更新值 | 选择普通版本、保留候选、查看差异 | 静默覆盖实际执行事实或新安全状态 |
| 已撤回 `revoked` | PR、证据、建议、分享或来源被撤回 | 标注撤回者/原因/时间及关联重算状态 | 查看审计、纠正源数据、返回 | 继续计入指标、画像或计划；完全删除因果说明 |
| 已归档 `archived` | 目标、画像版本或内容归档 | 只读状态，明确与删除的区别 | 恢复、查看历史、导出 | 伪装为活跃对象；归档即删除历史 |
| 成功 `success` | 确认、保存、同步、撤回等完成 | 就地反馈；高价值成果可进入可跳过庆祝 | 继续、查看影响、撤销（若允许） | 强制全屏庆祝；用连续天数强化成功 |

### 4.3 今日页状态优先级候选

今日页不是卡片堆叠仪表盘。首屏信息按以下优先级候选组织：

1. 安全否决或必须处理的适用范围状态；
2. 今天为什么这样安排，以及与哪个身份/目标相关；
3. 可执行主行动或安全替代；
4. 影响当日的能量、准备度和数据充分度摘要；
5. 可选 Prime Pulse；
6. 其他行动；
7. 已形成的身份证据与真实融合回流。

需要低保真验证的变量：Prime Pulse 在主行动前还是后、状态条的信息量、今日融合是否首屏常驻或有证据时出现、休息日首屏结构。

### 4.4 计划和执行状态的界面区分

| 计划/执行状态 | 视觉和交互要求 |
|---|---|
| 计划生成中 | 显示当前评审阶段；不可开始执行 |
| 计划草稿 | 明确“尚未完成必要审查”；允许查看和补信息，不作为专业方案执行 |
| 待审 | 显示正在等待的职责/规则；可离开页面 |
| 安全否决 | 危险行动不可开始；替代、暂缓、复评可用 |
| 待确认 | 展示影响和前后差异；用户确认后才生效 |
| 有效 | 展示版本、更新时间和适用条件 |
| 过期 | 不默认继续精细执行；说明需刷新/复评和可用保守内容 |
| 被替代 | 只读；返回当前有效版本；保留与实际执行的因果链 |
| 执行进行中 | 核心控制大且稳定；离线可用；离开后可恢复 |
| 执行跳过 | 记录原因可选但不羞辱；不自动安排补偿任务 |
| 执行撤销 | 明确撤销影响；幂等，避免重复记录和 PR |

---

## 5. 单域、双域、三域与多目标关键路径

### 5.1 单域：首次建立身份并进入体能专业计划

```text
价值预览
→ 自由表达“我想成为谁”
→ 渐进追问，可随时停止
→ 当前身份 / 目标身份草案
→ 只激活体能域
→ 体能域内一个或多个目标候选
→ 里程碑确认
→ 请求生成训练计划
→ 适用范围确认（默认未选、逐项主动）
→ 专业设计与安全审查
→ 计划预览 / 解释 / 用户确认
→ 进入旅程总览或体能成长域
```

异常分支：

- 用户未完成、拒绝或无法确认：不生成普通精细训练方案；保留身份、目标、里程碑管理，提供保守提示与专业转介。
- 数据不足：生成探索目标或保守草稿，禁止伪精确终点和 ready 状态。
- 无网络：保存身份/目标草稿；计划生成进入待处理，不伪造 Agent 审查。
- 单域用户：旅程和成长域不展示其他域占位；不显示融合 0 分。

低保真验证指标：首次理解准确率、完成身份确认的错误入口次数、从目标确认到计划状态理解率、适用范围拒绝后能否找到非训练能力。

### 5.2 单域：一次完整今日执行

```text
今日
→ 查看“为何这样安排”与安全/数据充分度
→ 可跳过或完成 Prime Pulse
→ 打开体能行动
→ 查看动作说明、安全信息和目标关联
→ 开始 / 暂停 / 恢复 / 完成
→ 提交 RPE、疼痛、质量；也可明确跳过
→ 本地保存执行事实
→ 查看形成的身份证据与调整候选
→ 返回今日或体能执行历史
```

异常分支：

- 离线：完整执行和反馈可写入；显示待同步，不阻断下一行动。
- 跳过 RPE：保存 missing，绝不复用上次值。
- 报告急性疼痛：立即本地暂停危险动作，进入安全否决页；不得因离线或超时放行。
- 计划在执行中被云端替代：保留本地已发生事实，后续行动按 Spec 冲突规则处理。

低保真验证指标：不做 Pulse 时的可达性、执行中断恢复、疼痛入口发现率、滑动与按钮等效路径成功率。

### 5.3 双域：同一身份下的多目标与时间冲突

示例仅用于结构压力测试，不固定产品内容：体能域含两个目标，语言域含一个目标。

```text
旅程
→ 当前身份 → 目标身份
→ 查看体能域和语言域各自贡献
→ 进入目标详情或周期计划
→ 系统发现两个域争抢同一时间/能量
→ 普通冲突页展示受影响目标、代价和依据
→ 用户选择“一键采纳”或“我自己来”
→ 形成单域时间槽，不同时执行两个域
→ 今日展示最终行动及调整理由
```

普通冲突规则：

- 不删除任何目标；
- 用户可保留全部目标；
- 调整不能伪装为安全否决；
- 手动编排需提供非拖拽等效操作；
- 场景来自用户声明或已授权数据，拒权时可手动设置。

低保真验证指标：用户能否理解“旅程”与“成长域”分工、跨域目标归属错误率、普通冲突双轨选择理解率、返回迷失率。

### 5.4 双域：融合来源回溯与知识注入

```text
体能行动或训练回顾
→ 看到真实执行派生的领域术语/素材
→ 来源芯片回溯到训练父节点
→ 进入对应成长域知识项
→ 发起适用性评估
→ 查看结论、职责、理由、证据和充分度
→ 用户选择采纳 / 改造采纳 / 暂缓 / 不采纳
→ 仅确认项渐进进入相关计划
→ 后续真实应用形成融合证据
```

边界：

- 生成、点击和导入数量不作为成长成果；
- 无真实来源或低置信内容不展示；
- 用户关闭融合生成后停止新增，无惩罚；
- 第三方模型无独立 Consent 时不发送原始笔记、健康原文或完整身份叙事；
- 同一时段仍只执行一个领域任务，不暗示边练边学。

低保真验证指标：来源回溯成功率、知识评估入口发现率、四类结论理解率、撤回后影响理解率。

### 5.5 三域：每域多目标的容量与导航压力测试

```text
旅程根页
→ 当前身份 → 目标身份
→ 三个活跃成长域概览
→ 每域展示最相关的少量目标摘要，完整目标在域/目标页展开
→ 切换成长域查看专业空间
→ 查看跨域时间和能量影响
→ 普通冲突进入双轨选择
→ 重大跨域优先级变化进入事前确认
→ 今日只显示现实可执行的单域时间槽
```

必须验证：

- 旅程首屏不能因 3 域 × 多目标退化成卡片墙；
- 域切换器在动态字体、小屏、长域名下仍稳定；
- 今日不按域平均分配卡片，不惩罚单域或低活跃域；
- 每域多个目标的创建、暂停、归档、恢复和调整状态可理解；
- 新增第 4 个活跃域时，只提供聚焦建议，不静默删除、替换或归档原域；
- 第 4 个域可以保留为未激活候选/历史对象的具体状态需架构 Spec 冻结，设计不得擅自定义存储语义。

低保真验证指标：首屏理解准确率、找到指定目标的步数、域切换错误率、返回迷失率、长文本/大字号溢出率。

### 5.6 安全否决关键路径

```text
用户在准入、计划生成、调整或执行中触发安全规则
→ 立即阻止危险具体方案
→ 安全否决页显示原因、证据来源、规则/版本和数据充分度
→ 提供安全替代 / 暂缓 / 复评条件
→ 用户选择安全路径
→ 计划与今日同步为替代或暂停状态
→ 满足复评条件后生成新的安全版本
```

红线：没有“我仍要继续原方案”、隐藏式返回绕过、调性弱化风险、Agent 投票覆盖安全结论或离线默认放行。

---

## 6. Design Token 建议

### 6.1 三层 Token 架构

```text
Foundation Token
  neutral-900 / atlas-blue-700 / green-600 / amber-600 / red-600
      ↓
Semantic Token
  color-text-primary / color-action-primary / color-status-danger
      ↓
Component Token
  button-primary-bg / safety-banner-border / tab-active-icon
```

规则：组件不得直接引用 Foundation 色值；调性只覆盖表达型 Semantic Token，不覆盖成功、警告、危险、安全否决和焦点可访问性语义。

### 6.2 Foundation Color Token 候选

| Token | 值 | 用途边界 |
|---|---:|---|
| `neutral-0` | `#FFFFFF` | 浅色表面 |
| `neutral-50` | `#F7F9FB` | 应用背景 |
| `neutral-100` | `#EEF2F5` | 次级表面 |
| `neutral-200` | `#DEE5EA` | 默认边框 |
| `neutral-300` | `#C7D0D8` | 强边框、禁用描边 |
| `neutral-400` | `#929EAA` | 占位、次要图标 |
| `neutral-500` | `#697785` | 辅助文本 |
| `neutral-600` | `#4E5D6B` | 次级正文 |
| `neutral-700` | `#344351` | 强调正文 |
| `neutral-800` | `#23313D` | 标题 |
| `neutral-900` | `#15232E` | 主文字，非纯黑 |
| `atlas-blue-50` | `#EFF6FA` | 品牌淡底 |
| `atlas-blue-100` | `#DCEAF2` | 选中背景 |
| `atlas-blue-500` | `#4B7897` | 次级品牌色 |
| `atlas-blue-600` | `#3A6787` | 默认品牌主色 |
| `atlas-blue-700` | `#2E5673` | 主按钮与深色文字链接 |
| `teal-600` | `#237D78` | 融合/来源关系；不得替代成功色 |
| `green-600` | `#23845B` | 成功、已通过 |
| `amber-600` | `#A86A10` | 警告、待确认、数据过期 |
| `red-600` | `#B8473B` | 错误和危险 |
| `red-700` | `#96372F` | 安全否决高对比文本/边框 |

说明：不得使用紫色渐变作为主视觉；页面不直接使用上述值，只能通过 Semantic / Component Token 引用。

### 6.3 浅色 Semantic Token 候选

| Token | Foundation 引用 | 用途 |
|---|---|---|
| `color-bg-app` | `neutral-50` | 应用背景 |
| `color-bg-surface` | `neutral-0` | 卡片、Sheet |
| `color-bg-subtle` | `neutral-100` | 嵌套区、骨架背景 |
| `color-text-primary` | `neutral-900` | 主文字 |
| `color-text-secondary` | `neutral-600` | 次级正文 |
| `color-text-muted` | `neutral-500` | 辅助说明，需验证对比度 |
| `color-border-default` | `neutral-200` | 默认边框 |
| `color-border-strong` | `neutral-300` | 分组和强调边界 |
| `color-action-primary` | `atlas-blue-700` | 主操作 |
| `color-action-primary-hover` | `atlas-blue-600` | hover |
| `color-action-primary-subtle` | `atlas-blue-50` | 选中、弱高亮 |
| `color-focus-ring` | `atlas-blue-700` | focus-visible |
| `color-link` | `atlas-blue-700` | 文本链接 |
| `color-status-success` | `green-600` | 成功、已通过 |
| `color-status-warning` | `amber-600` | 提醒、待确认、过期 |
| `color-status-danger` | `red-700` | 错误、安全否决 |
| `color-status-info` | `atlas-blue-600` | 一般信息 |
| `color-relation-fusion` | `teal-600` | 融合来源和关系；配合文字/图标 |
| `color-overlay-scrim` | 由 `neutral-900` 透明度派生 | 模态遮罩 |

### 6.4 调性 Token 边界

四调性为专业、陪伴、热血、严厉；默认专业。建议仅允许覆盖：

- `tone-accent`；
- `tone-accent-subtle`；
- `tone-surface-tint`；
- `tone-copy-style`（内容规则，不是颜色值）；
- `tone-motion-emphasis`（仍受 reduced motion 和 400ms 上限约束）。

禁止调性覆盖：

- `color-status-danger`、`color-status-warning`、`color-status-success`；
- 安全否决的阻断强度；
- 权限、Consent、数据充分度、专业结论；
- 功能入口、按钮数量和可达性；
- 计划、指标或 Agent 决策事实。

### 6.5 字体 Token

```text
font-display: Inter, Noto Sans SC, sans-serif
font-body: Inter, Noto Sans SC, sans-serif
font-mono: JetBrains Mono, Noto Sans SC, monospace
```

| Token | Size / Line height | Weight | 用途 |
|---|---|---:|---|
| `type-caption` | 12 / 16 | 400–500 | 来源、时间、辅助标签 |
| `type-label` | 14 / 20 | 500–600 | 按钮、Tab、字段标签 |
| `type-body` | 16 / 24 | 400 | 正文、表单 |
| `type-body-strong` | 16 / 24 | 600 | 结论和关键说明 |
| `type-title-sm` | 18 / 24 | 600 | 卡片标题 |
| `type-title-md` | 20 / 28 | 600 | 二级页标题 |
| `type-title-lg` | 24 / 32 | 600–700 | 页面主标题 |
| `type-display-sm` | 32 / 40 | 700 | 身份迁移关键叙事，谨慎使用 |
| `type-display-lg` | 40 / 48 | 700 | 仅价值预览或重大成果，不用于普通页面 |
| `type-mono-sm` | 12 / 16 | 500 | 版本、ID、更新时间 |
| `type-mono-md` | 14 / 20 | 500 | 时间槽、规则编号、指标窗口 |

禁止：用超大数字制造伪精确感；把 JetBrains Mono 用于大段中文正文；仅通过字号区分可点击和不可点击文本。

### 6.6 间距 Token

只允许：`4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48 / 64 / 80`。

| Token | 值 | 用途 |
|---|---:|---|
| `space-1` | 4 | 图标与短标签 |
| `space-2` | 8 | 紧凑组件内部 |
| `space-3` | 12 | 列表项内部 |
| `space-4` | 16 | 页面小屏水平边距、表单间距 |
| `space-5` | 20 | 标准卡片内边距 |
| `space-6` | 24 | 大卡片 / Sheet 内边距 |
| `space-8` | 32 | 页面区块间距 |
| `space-10` | 40 | 页面主要分段 |
| `space-12` | 48 | 空状态上下空间 |
| `space-16` | 64 | 大段落间距 |
| `space-20` | 80 | 价值预览章节间距 |

### 6.7 圆角、边框与阴影

| Token | 值 | 用途 |
|---|---:|---|
| `radius-sm` | 4 | 状态标签、来源芯片 |
| `radius-md` | 8 | 输入、按钮、列表项 |
| `radius-lg` | 12 | 卡片、内嵌面板 |
| `radius-xl` | 16 | Sheet、关键决策容器 |
| `radius-pill` | 999 | 仅药丸标签和状态，不用于所有卡片 |
| `border-width-default` | 1 | 默认边框 |
| `border-width-focus` | 2 | focus-visible |
| `shadow-xs` | 低透明、单层柔影 Token | 输入和轻浮层 |
| `shadow-sm` | 低透明、双层柔影 Token | 可点击卡片 |
| `shadow-md` | 克制浮层 Token | 下拉、Sheet |
| `shadow-lg` | 模态 Token | 高层决策页；安全页优先使用边框和结构而非发光 |

阴影值由视觉 Spec 最终冻结；组件只引用 shadow Token。禁止发光边框、玻璃拟态和紫色光晕。

### 6.8 动效 Token

| Token | 值 | 用途 |
|---|---:|---|
| `duration-instant` | 0ms | reduced motion 或立即状态切换 |
| `duration-fast` | 150ms | 按钮、焦点、折叠 |
| `duration-normal` | 250ms | 页面内层级变化 |
| `duration-slow` | 400ms | 调性表面色过渡、成果叙事 |
| `easing-standard` | `cubic-bezier(0.4, 0, 0.2, 1)` | 通用 |
| `easing-exit` | `cubic-bezier(0.4, 0, 1, 1)` | 离开 |
| `easing-enter` | `cubic-bezier(0, 0, 0.2, 1)` | 进入 |

规则：

- 不使用弹跳、弹性、随机粒子或持续呼吸来吸引操作；
- Pulse 长按首反馈目标小于 100ms，但完成阈值产品建议为 500ms；
- reduced motion 下取消位移、缩放、火焰和庆祝动画，保留即时状态、文本和必要透明度变化；
- 动效不是状态唯一证据，完成后必须有持久文本/图标反馈。

### 6.9 图标系统

- 唯一图标库：Lucide；
- 行内 16px、按钮 20px、独立图标 24px；
- 描边粗细在全产品保持一致；
- 图标颜色引用语义 Token；
- 功能图标必须有可访问名称；装饰图标从可访问树隐藏。

一级 Tab 候选图标仅供低保真验证：

| Tab | Lucide 候选 | 备注 |
|---|---|---|
| 今日 | `Sun` 或 `CalendarDays` | 不能让用户误解为通用日历 |
| 旅程 | `Route` | 需验证是否准确表达身份迁移而非旅行 |
| 成长域 | `Layers3` 或 `LayoutGrid` | 需验证是否表达有限工作空间而非工具目录 |
| 我的 | `UserRound` | 治理入口，不承载核心身份迁移 |

状态图标候选：安全 `ShieldAlert`、数据不足 `CircleHelp`、离线 `CloudOff`、待同步 `CloudUpload`、来源 `GitBranch`、证据 `FileCheck2`、历史 `History`。禁止用 emoji 代替。

### 6.10 组件九态最低要求

所有 Button、Input、Card、Tab、Chip、Dropdown、Disclosure、Action Control 至少定义：

- Default；
- Hover（支持 hover 的平台）；
- Focus-visible；
- Active / Pressed；
- Disabled；
- Loading；
- Error；
- Empty（容器型组件）；
- Success。

高风险组件另加：Offline、Permission denied、Insufficient data、Safety veto、Revoked、Stale、Conflict。

---

## 7. 无障碍与等效入口

### 7.1 基线

- WCAG 2.2 AA；
- iOS 触控目标不小于 44×44pt；Android 建议不小于 48×48dp；
- 正文对比度不低于 4.5:1；大文本和非文本组件按标准验证；
- 支持屏幕阅读器、动态字体、外接键盘、横屏/窄屏和 reduced motion；
- 200% 字体放大时，核心操作不得截断、重叠或只能横向滚动；
- 所有页面有可预测标题、返回名称、焦点顺序和错误摘要；
- 数据刷新、执行完成、安全暂停和同步冲突使用可控 live region 播报，避免重复轰炸。

### 7.2 手势与感官等效矩阵

| 原交互/信息 | 必须提供的等效入口 |
|---|---|
| Prime Pulse 长按 500ms | 明确的“开始今日状态”按钮；屏幕阅读器自定义动作；结果与长按完全一致 |
| 滑动完成行动 | 显式“完成”按钮；键盘 Enter/Space；撤销入口 |
| 拖拽调整时间槽 | “提前 / 延后 / 移到其他时段”按钮或菜单；键盘移动；变更后朗读位置 |
| 长按笔记发起评估 | 可见的“评估这条笔记”菜单项/按钮；不得只靠长按 |
| 图表、雷达、趋势线 | 同内容的结构化列表或表格；包含阶段、趋势、证据、窗口、更新时间 |
| 颜色状态 | 图标 + 文本标签 + 必要说明；成功/警告/危险不只依赖绿/黄/红 |
| 发音音频 | 文本术语、音标/拼读提示、重播和速度；静音时功能仍可理解 |
| 动作视频 | 字幕、转录、关键帧、文本步骤、播放控制；视频失效有替代 |
| 震动/触觉 | 同步视觉和文本反馈；关闭触觉不损失信息 |
| 火焰/势能动画 | 静态状态名、趋势和证据；reduced motion 下完全可用 |
| PR 庆祝 | 可跳过；静态成果摘要；不开动画也能查看证据和下一步 |
| 底部 Sheet | 正确焦点陷阱、关闭按钮、返回键关闭、关闭后焦点回触发点 |

### 7.3 表单和错误

- 适用范围和 Consent 控件默认未选，不得以视觉弱化拒绝选项；
- 错误与字段关联，同时在页首提供错误摘要；
- 不用“有问题”“无效”等模糊信息，需说明如何修正；
- 对健康、疼痛和身份信息使用直接、尊重且非诊断性的文案；
- 无法通过辅助技术完成确认时，进入 `eligibility-unavailable`，不得记录为同意；
- 一次性验证码、时间、单位和范围需按阅读顺序播报；
- 自动保存应有非打扰式、可读的“已保存到本机 / 待同步”状态。

### 7.4 导航

- Tab 名称与图标均有可访问标签，不能只朗读图标名；
- 深链进入后，读屏先播页面标题和当前对象状态；
- 从来源芯片跳转后，返回能回到原证据位置；
- 安全页不能通过焦点顺序暴露不可用的“继续原方案”控件；
- 单域用户隐藏域切换器后，焦点顺序不能留下空节点；
- 动态字体下底部四 Tab 文案不得被只剩图标替代，除非平台可访问名称和低保真验证证明可理解。

---

## 8. 反模式门禁

### 8.1 视觉红线

- 不使用紫色、粉紫色渐变主视觉；
- 不使用 emoji 作为功能图标；
- 不使用默认系统字体直出；
- 组件颜色不得硬编码，全部引用 Token；
- 不使用纯黑、纯灰作为大面积正文或表面色；
- 不使用发光描边、玻璃拟态、过度模糊和 AI 光球；
- 不使用弹跳/弹性缓动；
- 不以三列同构功能卡或“图标 + 标题 + 一句话”代替真实产品内容；
- 价值预览必须展示身份、目标、计划、执行或证据的真实结构，不做口号 + 抽象 3D 图形 Hero。

### 8.2 产品红线

- 不出现连续天数、排行榜、红点、断签、补签和“落后了”压力；
- 不用“完成百分比”作为今日主视觉；
- 不把活跃域数量、点击、导入、生成卡或 Agent 通过率包装为成长成果；
- 不把 Prime Pulse 做成训练解锁、签到或准备度测量；
- 不把长期势能、今日准备度和启动仪式合并成一个数字；
- 不把融合做成独立任务中心、每日待办或同时多任务；
- 不把知识静默加入计划；
- 不把画像候选自动写成用户事实；
- 不把 12 Agent 画成 12 个头像常驻聊天；
- 不直接展示模型名称代替专业解释，不展示私有原始推理链；
- 不把普通冲突包装为不可覆盖的安全结论；
- 不给安全否决提供继续原危险方案的入口；
- 不因用户拒绝权限或撤回 Consent 而惩罚、降权、制造红点或阻断无关能力；
- 不在数据不足时显示 0 分、精确百分比、精确预计日期或“安全”；
- 不把单域用户呈现为缺失、未完成或较低等级。

### 8.3 文案红线

- 不使用 Lorem ipsum、空洞占位和“Welcome to PrimeAtlas”；
- 不使用“偷懒、找借口、失败、终于、落后、补回来”等羞辱或罪感表达；
- 严厉调性仍不得威胁、羞辱或扩大提醒频率；
- 安全页不使用恐吓性诊断措辞，也不淡化风险；
- 不承诺“永不断档、无条件信赖、自动理解一切、精准预测”；
- 不把 AI/Agent 称作真人医生、康复师、营养师或执业专家，除非真实服务和合规范围支持；
- 操作按钮使用具体结果，如“采用安全替代”“保持现有目标并手动安排”，避免泛化“确定 / 好的”。

### 8.4 提交门禁清单

- [ ] 所有页面都能指出它在身份迁移主循环中的位置；
- [ ] 方案 A 仍明确标记 `Candidate`，未偷写成最终 Frozen；
- [ ] 单域、双域、三域和每域多目标均有状态与路径；
- [ ] 未激活域不展示、不占位、不计权；
- [ ] 今日、旅程、成长域和我的对象归属无重复编辑真源；
- [ ] 安全否决无继续原方案入口；
- [ ] 训练适用范围确认默认未选，拒绝/无法确认有降级路径；
- [ ] Pulse 可绕过且有按钮等效入口；
- [ ] 滑动、长按、拖拽、图表、音视频和触觉都有等效路径；
- [ ] 离线、拒权、数据不足、已撤回和同步冲突不是补充说明，而是正式状态；
- [ ] 所有指标展示数据充分度和更新时间；
- [ ] 颜色全部通过 Token，图标全部 Lucide，字体明确；
- [ ] 无紫色渐变、emoji 功能图标、Lorem、抽象 Hero、连续天数和红点压力；
- [ ] 动画不超过 400ms，并支持 reduced motion；
- [ ] 正文对比度、触控尺寸、动态字体和读屏顺序可验收。

---

## 9. Spec 锁定建议与低保真验证清单

### 9.1 可直接进入 Spec 锁定的设计边界

| ID | 项目 | 建议 | 理由 |
|---|---|---|---|
| LOCK-D-01 | 图标系统 | 锁定 Lucide 16/20/24px | 已有产品和设计基线，不依赖 IA 偏好 |
| LOCK-D-02 | 字体系统 | 锁定 Inter + Noto Sans SC + JetBrains Mono | 已有产品和设计基线，避免系统字体直出 |
| LOCK-D-03 | Token 架构 | 锁定 Foundation → Semantic → Component 三层 | 支持浅/深色、调性和状态一致性 |
| LOCK-D-04 | 浅色优先 | 锁定浅色为首发基准，深色为同 Token 覆盖 | 健康、数据、长文本和移动阅读优先 |
| LOCK-D-05 | 间距/圆角/动效 | 锁定 4px 网格、4/8/12/16 圆角、150/250/400ms | 可访问、克制、跨平台稳定 |
| LOCK-D-06 | 状态语义 | 锁定普通冲突、安全否决、拒权、撤回、数据不足不可混用 | 已接受产品红线 |
| LOCK-D-07 | 无障碍等效 | 锁定长按、滑动、拖拽、图表、音视频等效入口 | WCAG 与产品 P0 |
| LOCK-D-08 | 安全页内容 | 锁定原因、证据、替代、暂缓、复评；禁止继续原方案 | 产品 P0 已接受 |
| LOCK-D-09 | 指标表达 | 锁定阶段 + 趋势 + 证据 + 数据充分度 + 更新时间 | 产品 P0 已接受 |
| LOCK-D-10 | 单域零负担 | 锁定未激活域不渲染、不占位、不显示 0 分 | 产品 P0 已接受 |
| LOCK-D-11 | Pulse 边界 | 锁定可绕过、500ms 产品建议、按钮/辅助技术等效、三语义分离 | 产品 P0 已接受；容差和状态机由 Spec 补齐 |
| LOCK-D-12 | 调性边界 | 锁定默认专业、只改表达、不改事实/安全/权限/功能 | 产品 P0 已接受 |
| LOCK-D-13 | 页面状态最低集 | 锁定首次、空、加载、错误、离线、拒权、数据不足、安全否决、已撤回 | 工程和 QA 必须可测试 |

### 9.2 必须在 Spec 锁定、但需要先有低保真证据的项目

| ID | 待锁定项目 | 低保真验证任务 | 冻结前证据 |
|---|---|---|---|
| LF-IA-01 | 一级 Tab 名称、数量、顺序 | 比较 A 与必要的 B/C 对照；完成 8 类关键任务 | 首次理解准确率、任务成功率、关键步数 |
| LF-IA-02 | “旅程”的用户心智 | 找目标、看长期迁移、确认画像变化 | 是否被误解为纯回顾/时间线 |
| LF-IA-03 | “成长域”的用户心智 | 进入体能专业计划、找知识、看域内多目标 | 是否退化为工具目录或大杂烩 |
| LF-IA-04 | 今日首屏信息优先级 | 正常日、休息日、安全日、离线日、无计划日 | 首屏理解、行动发现率、信息过载评分 |
| LF-IA-05 | Prime Pulse 位置 | 对照页面内嵌、独立轻页或弱入口 | 未执行 Pulse 时计划可达率、误认解锁率 |
| LF-IA-06 | 成长域二级导航 | 压测体能的状态/计划/历史/知识/安全 | 到达步数、返回迷失率、大字号稳定性 |
| LF-IA-07 | 旅程与成长域交叉入口 | 从目标到域计划、从域计划回目标证据 | 重复编辑误解率、返回上下文保持率 |
| LF-IA-08 | 单/双/三域密度 | 同一内容分别放入 1、2、3 域及每域多个目标 | 卡片墙风险、目标定位时间、溢出率 |
| LF-IA-09 | 路由与返回栈 | Tab 切换、来源深链、通知深链、关闭安全页 | 返回迷失率、错误退出率 |
| LF-IA-10 | 适用范围确认体验 | 正常确认、拒绝、无法确认、过期重确认 | 默认未选可见性、拒绝后非训练路径发现率 |
| LF-IA-11 | 安全否决体验 | 疼痛、孕期、术后、规则超时和离线 | 用户能否理解目标仍保留但危险方案被阻止 |
| LF-IA-12 | 普通冲突双轨 | 一键采纳、手动编排、无可行解 | 普通建议与安全否决区分准确率 |
| LF-IA-13 | 权限/Consent 渐进触发 | 健康、日历、知识、第三方模型分别拒绝/撤回 | 最低体验发现率、是否感到被强迫 |
| LF-IA-14 | 离线与同步 | 离线执行、待同步、冲突、旧安全状态保护 | 状态理解、重复操作、恢复成功率 |
| LF-IA-15 | 指标数据不足表达 | 身份、准备度、融合、PR、预测冷启动 | 是否被理解为 0、失败或安全 |
| LF-IA-16 | 知识注入四结论 | 采纳、改造采纳、暂缓、不采纳、安全否决 | 结论理解率、下一步选择正确率 |
| LF-IA-17 | v6 高频能力迁移 | 今日、身体状态、训练、目标、知识、我的旧入口映射 | 关键任务步数与可发现性不显著退化 |
| LF-IA-18 | Tab 再次点击行为 | 回根、滚顶、保持位置三种对照 | 错误返回率和用户预期一致率 |

### 9.3 仍被规则/数据合同阻塞，设计不得自行冻结

| ID | 阻塞项 | 设计影响 |
|---|---|---|
| BLOCK-D-01 | 身份进度、目标邻近度、准备度、ACWR、融合、PR、预测公式与金标 | 只能设计阶段/趋势/证据/充分度框架，不能设计具体百分比 |
| BLOCK-D-02 | 训练适用范围的地区、声明字段、有效期和专业转介规则 | 不能冻结最终表单字段和地区文案 |
| BLOCK-D-03 | 小幅/重大调整分类、子场景阈值和回退时限 | 不能冻结哪些变更自动生效的完整列表 |
| BLOCK-D-04 | 第三方模型字段级最小可见清单、接收方、保留和删除时限 | 不能冻结最终 Consent 明细 |
| BLOCK-D-05 | 同步实体/字段合并、tombstone、时区和账号合并规则 | 不能冻结冲突页的最终选项和影响文案 |
| BLOCK-D-06 | Agent 规则/模型/内容/人工属性、写权限和失败接管 | 不能冻结职责可见层级和高级审计范围 |
| BLOCK-D-07 | 动作视频、书摘、发音、专业内容来源、版权和失效替代 | 不能冻结最终内容入口和可用承诺 |
| BLOCK-D-08 | 首发平台/地区、登录方式和成果分享是否首发 | 不能冻结账号入口、分享路由和平台特定模式 |
| BLOCK-D-09 | 计划、知识评估、同步等 SLO 的起止点和部分结果合同 | 不能冻结加载文案、超时点和进度粒度 |
| BLOCK-D-10 | 各对象 API 错误码、幂等键、版本冲突响应 | 不能冻结最终错误恢复操作 |

### 9.4 低保真原型最小任务集

在方案 A 被写为最终 IA 前，至少完成以下可点击低保真任务：

1. 新用户从愿望表达走到身份、单域/多域、目标和里程碑确认；
2. 单域用户完成一次体能行动并提交/跳过 RPE；
3. 用户不操作 Pulse 仍能开始行动；
4. 双域用户查看同一身份下的多个目标并处理普通时间冲突；
5. 三域、每域多目标用户找到指定目标和专业计划；
6. 用户从训练卡派生内容回溯父节点；
7. 用户发起知识评估并处理四类普通结论和安全否决；
8. 用户查看成果和周期回顾，并确认或拒绝画像候选变化；
9. 用户在急性疼痛场景理解安全否决、替代和复评；
10. 用户拒绝/无法完成适用范围确认后，找到非训练能力和保守提示；
11. 用户拒绝健康/日历/第三方模型权限，继续最低体验；
12. 用户离线执行、重连同步并处理冲突；
13. 用户查看数据不足、内容失效、服务超时和已撤回状态；
14. 使用屏幕阅读器、键盘和 reduced motion 完成 Pulse、执行、反馈、安全替代和 Consent。

建议比较指标：任务成功率、首次理解准确率、错误入口次数、返回迷失率、关键路径步数、状态误解率、辅助技术完成率。不得用“更喜欢哪套视觉”替代 IA 判断。

---

## 10. 对 Spec 汇编的交付结论

1. 方案 A「今日 / 旅程 / 成长域 / 我的」是当前主验证候选，能够较完整承载日循环、周期循环、体能深扎、多域扩展和个人治理。
2. 方案 A 仍不是 Frozen IA。四 Tab 名称/顺序、旅程心智、成长域二级 IA、今日密度、返回栈和多域压力必须经低保真验证。
3. 图标、字体、Token 架构、浅色优先、无障碍等效、安全语义、数据不足表达和反压力门禁可以独立于 IA 锁定。
4. 页面必须以产品对象和状态组织，而不是按 v6 六 Tab 逐页翻译；目标、计划、执行、证据、Consent、安全和同步应各有唯一对象真源。
5. 首次、空、加载、错误、离线、拒权、数据不足、安全否决、已撤回不是补充状态，而是 Spec 页面合同的组成部分。
6. 任何页面若不能说明其如何支持“当前身份走向目标身份”，或只能产生点击、打卡和内容数量，不应进入主版本。
7. 任何低保真、高保真或开发稿若将 Candidate 写成 Frozen、显示无依据精确数字、允许继续危险方案、用 emoji 作功能图标、引入 streak/红点/排行榜或把 12 Agent 画成聊天列表，应直接退回。

---

## 11. 输入来源与追踪

主要依据：

- `deliverables/product-strategy/primeatlas-product-decision-confirmation-2026-07-20.md`
- `deliverables/product-strategy/primeatlas-product-understanding-review-2026-07-20.md`
- `deliverables/product-strategy/primeatlas-full-prd-review-2026-07-17.md`
- `deliverables/product-strategy/primeatlas-blueprint-prototype-prd-traceability-2026-07-17.md`
- `deliverables/product-strategy/primeatlas-information-architecture-options-2026-07-20.md`
- `deliverables/product-strategy/primeatlas-product-recalibration-2026-07-20.md`
- `PrimeAtlas_完整需求蓝图_Final.md`
- `primeatlas-prototype-v6.html`

本设计输入覆盖追踪矩阵重点 Requirement：A1–A4、B1–B4、C1–C6、D1–D5、E1–E3、F1–F2、G1–G3、H1–H2、I1–I3、J1–J5、K1–K4、AG1–AG4、X1–X2、NF1–NF3。

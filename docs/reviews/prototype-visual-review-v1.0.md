# PrimeAtlas 双基线原型视觉复核 v1.0

> 日期：2026-07-21  
> 角色：颜好看  
> 评估路径：降级单 context 静态审查。已逐行审查 HTML、CSS、结构和交互声明；本轮没有浏览器截图、计算样式、真机录屏、可访问性树或真实参与者证据。  
> 主基线：`docs/prototype/primeatlas-prototype-v6.html`  
> 合同对照：`docs/prototype/primeatlas-review-prototype-v1.0.html`  
> 寄存器：Product Register。PrimeAtlas 是移动产品界面，视觉必须服务任务、状态与可信决策。  
> 平台轴：Web 评审原型，目标行为按 adaptive 移动产品验证。  
> 三轴建议：`DESIGN_VARIANCE=4 / MOTION_INTENSITY=3 / VISUAL_DENSITY=6`。

## 0. RoleVerdict

```yaml
verdict: fail
blocking:
  - 违反项: V6 存在大量功能性 emoji 与字符图标
    证据: V6 静态扫描命中 306 个含 pictograph 的代码行；代表证据见 692、2629、2678、2727、2982、3093、3105、3195、3336、3449、3501、3544 行
    期望: 全部替换为同一套 Lucide SVG，行内 16px、按钮内 20px、独立图标 24px，并为功能图标提供可访问名称
  - 违反项: V6 不具备终局四入口与 V0.2 两入口边界
    证据: V6 2612、2809、2991、3192、3329、3414 行仍为今日、身体、训练、目标、知识、我的六区；3573-3603 行渲染六项底部导航
    期望: 终局固定今日、旅程、成长域、我的；V0.2 身份确认前无 Tab，确认后仅旅程、我的
  - 违反项: V6 的固定画布、字体、焦点、语义和动效不满足可访问门禁
    证据: 145-146 行固定 390x844；573、937、1474、2478 行移除 outline；无 focus-visible、prefers-reduced-motion、aria-live 和对话框语义；339 处 9-15px 字号声明；385 行持续呼吸动画；4742、4748 行弹跳动画
    期望: 200% 字体不截断；全键盘和读屏等效；正文不低于 16px 等效；可见焦点；reduced motion；无 bounce 或持续吸引操作动画
  - 违反项: V6 的 Pulse、进度和训练反馈视觉语义与 Spec 冲突
    证据: 2678 行状态徽章、3885-3887 行把 Pulse 表达为训练区域解锁；4585、4607 行 RPE 预设及跳过复用上次值；1285-1310 行目标百分比环；2325-2337 行训练解锁模糊态
    期望: Pulse 可完全绕过；RPE 跳过保存 missing；精确百分比仅在公式、样本、窗口、置信边界齐备时显示；主行动始终直接可达
  - 违反项: 两个原型均没有本轮真实渲染证据
    证据: 本报告仅有源码静态证据，没有浏览器截图、计算样式、横竖屏录屏、对比度工具报告、可访问性树或控制台记录
    期望: 在指定手机和平板矩阵执行真实浏览器 D1/D2，保存截图、录屏、控制台、焦点顺序、读屏输出与对比度结果
  - 违反项: D3/D4 证据缺失
    证据: review prototype 58、69、171 行明确 Research only 且 D0-D2 不构成 D3/D4；仓库低保真验证包也将真实 D3/D4 标为未完成
    期望: 完成真实目标用户 D3 与真实辅助技术用户 D4，或获得 QA 明确接受的等价真实证据后，才可冻结 IA
advisory:
  - 建议项: 保留 V6 的专业体能密度和动作执行层级
    理由: 训练、动作详情、教学、调整理由和来源回溯具有真实任务感，适合作为成长域内体能专业空间的视觉基线
  - 建议项: 复用 review prototype 的合同表达与自适应骨架
    理由: 它已包含范围标记、终局四入口、V0.2 线性流程、焦点样式、200% 字体预设、平板重排和 reduced motion
  - 建议项: review prototype 的暖纸背景改为设计输入已锁定的冷静中性色
    理由: 9-18 行的 paper/warm neutrals 与禁止奶油背景默认化冲突，也弱化 V6 的精密工具连续性
  - 建议项: 为 V6 做增量归属迁移而非重画通用浅色后台
    理由: V6 是视觉与体验主基线，review prototype 是合同与异常状态对照，不应反客为主
  - 建议项: Token 迁移先解决语义和组件引用，再处理暗浅主题
    理由: V6 已有变量雏形，但存在大量组件内裸值、inline style 和语义色混用；直接换主题会保留结构性债务
evidence:
  - artifact_ref: docs/prototype/primeatlas-prototype-v6.html
    line: 11-47
    说明: V6 暗色 Token 雏形、字体、圆角、状态栏与导航尺寸
  - artifact_ref: docs/prototype/primeatlas-prototype-v6.html
    line: 2611-3603
    说明: 六区页面和六项底部导航的静态证据
  - artifact_ref: docs/prototype/primeatlas-review-prototype-v1.0.html
    line: 8-34
    说明: review prototype 的 Token、自适应、200% 字体、焦点与 reduced motion 合同
  - artifact_ref: docs/prototype/primeatlas-review-prototype-v1.0.html
    line: 77-103
    说明: V0.2 十一页、终局任务和设备矩阵
  - artifact_ref: docs/prototype/primeatlas-review-prototype-v1.0.html
    line: 155-171
    说明: 终局四入口、Pulse 绕过、安全、Consent、异常和辅助技术切片
```

结论：当前双基线只能进入修复与真实渲染验证，不能进入 IA 冻结或视觉放行。V6 仍是主要视觉/体验资产库；review prototype 只作为合同、异常状态和 IA 对照，不替代 V6。

## 1. 审查边界与证据等级

| 项目 | 本轮状态 | 可裁决内容 | 不可裁决内容 |
|---|---|---|---|
| 源码结构 | 已审查 | 页面、Token、组件、断点、静态状态、明显 P0 | 实际视觉质量、运行时溢出、浏览器兼容 |
| 静态 P0 扫描 | 已执行 | emoji 行命中、禁用渐变声明、裸色、bounce、reduced motion 声明 | 伪元素运行结果、Canvas、动态字符串全部可视结果 |
| 对比度 | 仅手算代表值 | 指出明显低对比风险 | 不能替代全页面计算样式扫描 |
| 真机/浏览器 | 未执行 | 无 | CLS、遮挡、滚动、焦点回归、虚拟键盘、实际字体回退 |
| D3 用户测试 | 未执行 | 无 | 首次理解、任务成功率、返回迷失、入口心智 |
| D4 辅助技术用户测试 | 未执行 | 无 | 真实读屏、动态字体、运动限制与键盘完成率 |

阻塞声明：`Insufficient evidence — 尚未完成符合招募条件的真实用户/辅助技术用户可用性测试。本项保持 Candidate/Spec Blocked。团队走查、静态审查或原型自测不构成冻结证据。`

## 2. 视觉北极星与继承原则

### 2.1 视觉北极星

PrimeAtlas 应保留“专业成长手册 + 精密决策工具”的产品气质：高信息密度、可追溯来源、明确状态、克制品牌色、真实专业动作内容。品牌记忆来自持续可见的“当前身份到目标身份”迁移线索，不来自 AI 光球、完成圆环、streak、头像或装饰性庆祝。

### 2.2 双基线职责

| 基线 | 负责 | 不负责 |
|---|---|---|
| V6 | 移动端内容节奏、专业体能密度、动作执行、教学、反馈、调整理由、来源回溯、调性预览 | 六 Tab 真源、Pulse 解锁、伪精确指标、功能 emoji、登录门槛 |
| review prototype | V0.2 范围边界、终局四入口、异常状态、研究控制台、设备预设、200% 字体、键盘/读屏/reduced motion 合同 | 取代 V6 的成熟视觉、证明真实实现、证明 D3/D4、作为正式 Release UI |

### 2.3 增量迁移规则

1. 先复用 V6 页面骨架和专业内容，再调整信息归属。
2. 对与 Spec 冲突的语义做替换，不为保持旧貌保留错误产品规则。
3. review prototype 的异常页、范围标记和可访问骨架可移植到 V6 视觉语言中。
4. 不建立第二套通用浅色卡片系统。
5. 同一对象只有一个正式编辑真源；交叉入口保留 return context。

## 3. V6 资产保留矩阵

| V6 资产 | 代码证据 | 裁决 | 终局落点 | 必须修改 |
|---|---:|---|---|---|
| 390px 单列移动画布 | 144-157 | 保留节奏，重做尺寸约束 | 全局移动骨架 | 从固定 390x844 改为内容驱动 compact/medium/expanded；保留最大阅读宽度而非固定高度 |
| 暗浅主题变量 | 11-76 | 保留概念，重建语义链 | 全局主题 | 对齐 Foundation → Semantic → Component；浅色优先；组件禁止裸值 |
| 底部导航密度 | 193-250 | 保留触达节奏，不保留六项 | 终局四入口 | 固定为今日/旅程/成长域/我的；移动 44/48 最小目标；平板改 rail 或双栏 |
| 今日问候与首屏节奏 | 343-358 | 保留层级 | 今日 | 移除“完成率仪表盘”倾向；先安全、目标关联、安排理由、主行动 |
| Prime Pulse 视觉仪式 | 360-440 | 保留品牌概念，重做语义 | 今日次级入口 | 移除评分、streak、训练解锁、持续呼吸吸引；提供显式按钮与键盘/读屏等效 |
| 身体快照与 ACWR | 442-515、2809 起 | 保留专业数据密度 | 成长域 → 体能 → 状态 | 显示来源、窗口、充分度、更新时间；不足时不显示精确结论；图表必须有列表等效 |
| 训练场景和动作列表 | 657-735、2991 起 | 强保留 | 成长域 → 体能 → 计划/行动/历史 | 功能 emoji 改 Lucide；完成不能只靠滑动；补疼痛、安全和 RPE missing |
| 动作视频与关键帧 | 751-896、826-847 | 强保留 | 行动详情/动作学习 | 补字幕、转录、文本步骤、播放控制名称、失效替代 |
| 动作库和详情 Sheet | 900 起、3105 起 | 保留 | 成长域 → 体能 → 知识/动作学习 | 搜索、筛选、详情改为语义控件；目标关联与来源明确；管理权不混入业务消费 |
| 目标卡与里程碑 | 1211-1332、3192 起 | 保留内容，改结构 | 旅程 | 去掉“三个目标上限”、百分比环、彩色侧条和 streak；支持每域多目标、阶段/趋势/证据/充分度 |
| 知识图书、阅读、来源回溯 | 1335-1490、2340-2582、3329 起 | 保留业务资产，拆双入口 | 成长域/目标 + 我的 | 业务入口做消费/评估/注入；我的做来源库/导入/Consent/保留删除/治理；同一来源对象不复制编辑真源 |
| 我的与调性 | 1493-1589、3414 起 | 保留调性预览和设置层级 | 我的 | 身份主叙事移到旅程；调性不改变事实、安全、权限和入口；移除功能 emoji |
| 调整前后差异与 Agent 决策 | 4753-4762 | 保留解释价值，重做呈现 | 今日理由/成长域计划 | 去功能角色头像/emoji、彩色侧条；结构化为来源、职责、证据、充分度、影响、回退 |
| Toast 与 Sheet 模式 | 1618-1773 | 条件保留 | 全局反馈 | 高风险和持久状态不能只用 Toast；补焦点陷阱、Esc/返回、关闭后回焦、标题和 dialog 语义 |
| PR 庆祝与粒子 | 1591-1613、4736-4748 | P0 移除当前实现 | 旅程成果 | 只有证据规则和确认后才展示；静态摘要优先；移除 bounce、粒子依赖和自动全屏 |
| 登录解锁路径 | 3418-3443、5467-5487 | P0 移除 V0.2 依赖 | 我的/账号后续 | V0.2 本地模式无需登录完成；未来账号能力按范围单独进入 |

## 4. 六区到四入口视觉映射

| V6 六区 | 终局主入口 | 二级视觉位置 | 页面骨架 | 交叉入口与返回 |
|---|---|---|---|---|
| 今日 | 今日 | 根页 | 持续状态 → 安全/Eligibility → 身份目标关联 → 安排理由 → 主行动 → 状态摘要 → 可选 Pulse → 其他行动 → 证据 | 从行动进入目标/域/知识后返回原行动位置 |
| 身体 | 成长域 | 体能 → 状态/洞察/恢复/安全 | 域头部 → 目标关联 → 数据充分度 → 指标列表/趋势 → 来源与更新时间 | 今日只引用影响当日的摘要；旅程只引用目标证据 |
| 训练 | 成长域 | 体能 → 计划/行动/历史/动作学习 | 计划版本 → 今日切片 → 动作与组次 → 教学 → 执行/反馈 → 调整说明 | 今日直达行动；旅程目标进入专业计划；返回各自上下文 |
| 目标 | 旅程 | 身份迁移、域、目标、里程碑、证据、回顾 | 当前身份到目标身份 → 域分组 → 连续目标行 → 里程碑 → 证据 → 画像候选 | 成长域仅给专业上下文入口，不复制正式目标编辑 |
| 知识 | 成长域 + 我的 | 成长域/目标负责消费、适用性评估、计划注入；我的负责来源库、导入、Consent、保留删除、治理 | 业务页突出“服务哪个目标”和四类决策；治理页突出来源、接收方、范围、保留、撤回 | 两入口指向同一 Source/Knowledge 对象；来源回溯后返回原证据 |
| 我的 | 我的 | 画像版本、设备、本机状态、数据权利、调性、未来账号/同步 | 状态摘要 → 治理分组 → 版本/来源/权限/删除 → 调性 | 不承载核心身份迁移叙事；画像内容可从旅程交叉进入 |

### 4.1 终局导航视觉合同

- 顺序固定：今日、旅程、成长域、我的。
- Lucide 候选：`Sun`、`Route`、`Layers3`、`UserRound`。
- 手机底部导航保留文字，不退化成纯图标。
- 当前项用图标、字重和语义色共同表达，不只靠顶部彩线。
- 平板 medium/expanded 使用 NavigationRail 或列表详情双栏，不把手机底栏横向拉宽。

### 4.2 V0.2 导航视觉合同

- 身份确认前：无底部 Tab，使用线性页标题、进度、上一步、下一步。
- 身份确认后：仅旅程、我的两个入口。
- V0.2 完全隐藏今日、成长域、训练、Pulse、知识、Eligibility、远程模型、云同步和通知半入口。
- V0.2 状态只表达“本机已保存、保存失败、本机可恢复”；不将测试同步夹具伪装为 Release 能力。

## 5. Token 抽取与替换建议

### 5.1 V6 可抽取 Token

V6 11-47 行已有暗色变量，52-76 行已有浅色覆盖，可作为迁移输入，不作为最终真源。建议建立下列四层引用链：

| 层级 | 保留/新增 Token | 来源与替换 |
|---|---|---|
| A1 Identity | `--bg`、`--surface`、`--fg`、`--muted`、`--accent`、`--border`、`--font-display`、`--font-body` | 从 V6 `--bg-base`、`--bg-card`、`--text-primary` 等迁移；accent 从橙色改为已接受 Atlas Blue，橙色不再承担全局主操作 |
| A1 Structure | `--container-max`、`--text-*`、`--leading-*`、`--space-*`、`--radius-*` | 保留 4px 网格；移除 20/24px 普通卡片圆角；正文基准 16px |
| A2 Semantic | `--success`、`--warn`、`--danger`、`--info`、`--focus-ring`、`--motion-fast/base/slow` | 从 V6 green/yellow/red/blue 拆出；安全 danger 不受调性覆盖；时长 150/250/400ms |
| B Slot | `--fg-2`、`--meta`、`--border-soft`、`--button-primary-*`、`--input-*`、`--tab-*`、`--safety-*` | 组件只能引用语义别名；替换 V6 内联裸值和直接 foundation 引用 |
| C Extension | `--relation-fusion`、`--evidence-*`、`--data-sufficiency-*`、`--identity-transition-*` | 融合关系、证据、充分度、身份迁移是 PrimeAtlas 专属扩展，不与 success 混用 |

### 5.2 颜色裁决

- 浅色首发：使用设计输入的 `neutral-50 #F7F9FB`、`neutral-0 #FFFFFF`、`neutral-900 #15232E` 和 Atlas Blue ramp。
- review prototype 9-18 行的 `paper/warm` 色带属于奶油背景默认化，不能作为主产品视觉真源；可以保留在研究控制台极小范围，但产品画布应改为轻冷中性。
- V6 橙色可降级为体能域内的有限品牌遗产色或特殊强调，不可继续同时承担主操作、进度、Pulse、目标、Toast、选中和装饰光晕。
- 每屏可见 accent 不超过两处；成功、警告、危险、融合关系分别使用语义色与文本/图标。
- 禁止紫色到粉色渐变；紫色和粉色也不得继续作为无语义训练模式标签。

### 5.3 排版裁决

- 锁定：Inter + Noto Sans SC；版本、规则、时间和标识用 JetBrains Mono。
- V6 41-43 行缺 Noto Sans SC；review 21 行字体栈更接近合同，但两者都没有字体资源加载证据，真实渲染时可能直接回退系统字体。该项需浏览器 Network 和 computed font 验证。
- 正文 16/24；label 14/20；caption 12/16；title 18/24、20/28、24/32；display 32/40 谨慎使用。
- V6 中 9-11px 大量标签只可保留为非关键信息；关键状态、按钮、来源和设置不能低于 12px，普通正文不能低于 16px。
- 标题负字距、正文 0 字距、全大写追踪至少 0.06em；中文不强制全大写样式。

### 5.4 间距、圆角、阴影与动效

- 间距只允许 4/8/12/16/20/24/32/40/48/64/80。
- 圆角 4/8/12/16，pill 仅用于状态；V6 modal 24px 和 20px 常规容器需要收敛。
- Hairline first：默认卡片使用表面差与 1px 边框，无默认大阴影。
- 150ms 即时反馈，250ms 页面内变化，400ms 上限；不使用 bounce、elastic、持续呼吸、随机粒子。
- reduced motion 下取消位移、缩放、呼吸、粒子和庆祝；保留文本、状态和必要透明度变化。

## 6. 组件抽取矩阵

| 组件 | V6 输入 | review 对照 | 终局抽取合同 | 状态要求 |
|---|---|---|---|---|
| AppShell | phone-frame、status-bar、app-content、bottom-nav | device-canvas、app-status、app-nav-shell | `AdaptiveAppShell`，compact 底栏、medium/expanded rail/双栏，安全区完整 | loading/empty/error/populated/edge/offline |
| PrimaryNav | nav-item | product-nav/tab-btn | 四入口或 V0.2 两入口；文字 + Lucide；独立返回栈 | default/hover/focus/current/pressed/disabled |
| PageHeader | greeting、各 tab header | screenHead | 页面标题、对象状态、范围标识、可选说明 | 正常/数据不足/过期/安全 |
| IdentityTransition | V6 目标摘要可借内容 | identityLine | 当前身份到目标身份的持续主线，不做 Hero 指标 | 草案/候选/active/historical/restored |
| StateBanner | adjust-banner、readiness detail | state-box、paper-surface safety/warning | 持久解释“发生什么/依据/可做/不可做/恢复” | info/warn/danger/offline/revoked/conflict |
| ActionCard/List | scene-card、action-item | list-row、T03 | 目标关联、计划版本、离线可用、安全状态、显式完成 | 未开始/进行/暂停/完成/跳过/撤销/安全阻断 |
| PulseControl | pulse-orb | pulse-control/pulse-hold | 可选仪式；长按、按钮、Enter/Space 等效；不影响行动可达性 | idle/holding/cancelled/completed/reduced-motion |
| FeedbackSheet | rpe-selector | T03 feedback | RPE、疼痛、质量；跳过写 missing；疼痛进入 Safety | default/selected/missing/error/saved/safety |
| PlanReason | readiness/Agent 调整弹层 | T02 reason | 目标关联、来源、充分度、更新时间、前后差异、回退 | partial/complete/stale/revoked/timeout |
| GoalList/Detail | goal-card | goalRows/goalDetailContent | 旅程唯一正式编辑真源；连续分组列表优先，避免卡片墙 | candidate/active/paused/recalibrating/completed/archived |
| DomainSwitcher | 无终局结构 | active domain selector | 只显示 1-3 active 域；单域隐藏；长名和 200% 可用 | 1/2/3 域、暂停、第4域建议 |
| KnowledgeItem/Review | book-card、reader、注入评估 | T06/T07 | 业务上下文负责消费/评估/注入；来源可回溯；未确认不改计划 | adopt/adapt/defer/reject/safety/timeout/revoked |
| SourceGovernance | import、library、privacy | Consent/T11、我的合同 | 我的负责来源库、导入、Consent、保留删除、治理 | 未授权/授权/拒绝/撤回/传播中/删除中 |
| SafetyDecision | 旧强制调整提示 | safetyPage | 独立业务页；无继续危险方案；目标保留 | veto/reason-loading/alternative/reassess/paused |
| ConsentForm | 旧设置/登录 | T11 | 目的、接收方、字段、保留、撤回、拒绝后能力；默认未选 | not-granted/granted/rejected/revoked/processing |
| Modal/Sheet/Dialog | 多类 overlay | native dialog + 回焦 | 焦点陷阱、Esc/返回、标题、关闭名称、关闭后回焦 | open/closing/error/long-content/keyboard |
| Toast/LiveRegion | toast | toast + liveRegion | Toast 只做短反馈；持久业务状态写回页面；可控 aria-live | info/success/error/deduped |

## 7. Spec 冲突替换表

| 现状 | 静态证据 | 冲突 | 替换合同 | 优先级 |
|---|---:|---|---|---|
| 六 Tab 工具并列 | V6 2612-3603 | 终局已确认四入口 | 今日/旅程/成长域/我的；身体/训练下沉体能域；知识拆双入口 | P0 |
| V0.2 登录/解锁叙事 | V6 3418-3443、5467-5487 | V0.2 纯本地、无需空壳与远程依赖 | 线性身份流程；确认后仅旅程/我的；本机保存 | P0 |
| Pulse 评分、streak、解锁训练 | V6 406-439、2678、3885-3887、2325-2337 | Pulse 只是可选启动仪式 | 移除分数/streak/blur lock；主行动先可达；长按与按钮等效 | P0 |
| RPE 默认 7、跳过复用上次 | V6 4585、4607 | 缺失必须保持 missing | 初始未选；跳过明确保存 missing；不得复用历史 | P0 |
| 目标上限三个 | V6 3195、4420-4428 | 上限是三个 active 域，每域多个目标 | 域选择 1-3；第4域只提示聚焦；目标可多条 | P0 |
| 精确百分比与预计日期 | V6 1285-1310、3199 起 | 公式/样本/窗口/置信不足不得精确 | 阶段、趋势、证据、充分度、更新时间；充分时再开放精确值 | P0 |
| 功能 emoji | V6 306 行静态命中 | 图标唯一系统为 Lucide | 统一 SVG，16/20/24px；UGC 例外但当前原型未区分 | P0 |
| 弹跳、呼吸、粒子 | V6 385、1608、4742、4748 | 禁止 bounce、持续吸引和无 reduced motion | 150/250/400ms 标准缓动；reduced motion 即时替代 | P0 |
| 知识直接加入计划 | V6 5016、5295-5306 | 必须先评估、给理由、用户确认 | 成长域/目标提供四类决策；Safety 独立；我的提供来源治理 | P0 |
| 彩色侧条卡 | V6 748、3199、3241、3276、4760-4762、5298 | 禁止侧条纹强调；容易形成 AI 模板语法 | 用完整边框、状态图标、标题和背景层表达；不靠一条彩边 | P1 |
| 暖纸大背景 | review 9-18、30-33 | 奶油背景默认化；与精密工具连续性冲突 | 产品画布改 neutral-50/0；研究控制台可保留轻微区别但不得影响对照公平性 | P1 |
| 研究同步状态混入 V0.2 终点 | review 99、154 | V0.2 纯本地且不展示同步半入口 | A0 只显示本机保存/失败/恢复；同步冲突留在 Future IA 研究模式 | P0 |
| 字体只声明不加载 | V6 41-43；review 21 | 真实渲染可能系统字体直出 | 打包字体或可靠本地资源；用 computed font 取证；失败时有 metric-compatible fallback | P1 |

## 8. 手机与平板 portrait/landscape 矩阵

### 8.1 静态支持判定

| 形态 | 目标视口 | V6 静态状态 | review 静态状态 | 放行前真实验证 |
|---|---:|---|---|---|
| 紧凑手机 portrait | 320x568、360x800 | 仅 `max-width:430` 把固定画布铺满；内部大量固定 390px Sheet 与小字号，风险高 | VIEWPORTS 已列；compact 单列与 320/360 预设存在 | 所有 A0 页、T03/T09/T11；键盘弹出；底部操作不遮挡；无横滚 |
| 标准手机 portrait | 390x844、430x932 | 主要设计基线，390x844 最接近原始目标 | 390/430 预设存在 | 首屏层级、触控、Sheet、返回、字体实际加载、暗浅对比 |
| 手机 landscape | 568x320、800x360 | 无 landscape 专用重排；固定高 Sheet/Overlay 风险 | line 33 有横屏低高媒体规则；视口预设存在 | 主操作/键盘/底栏遮挡；高风险页可滚动完成；状态栏和安全区 |
| 小平板 portrait | 600x960 | 无平板断点和双栏 | medium、wide-enough、adaptive-split 已声明 | 身份编辑/目标编辑/旅程列表详情；不机械拉满，不造卡片墙 |
| 标准平板 portrait | 768x1024、834x1194 | 手机框居中放大，不构成适配 | medium/expanded 规则与 rail 候选存在 | 选择保持、指针 hover、键盘焦点、200% 回退单列 |
| 平板 landscape | 960x600、1024x768、1194x834 | 无适配 | expanded 双栏和 nav-primary 存在 | 列表详情、返回上下文、Safety/Consent 独立高关注；不藏核心能力 |
| 200% 字体 | 所有关键页面 | 无动态字体合同；大量 9-13px 和固定容器，静态判高风险 | text-200 preset、双栏强制回单列、sticky 取消 | 所有核心操作不截断/重叠；标题仍高于正文；底栏文字不消失 |

### 8.2 必测页面组合

- V0.2：A0-02、A0-04、A0-05、A0-06、A0-07、A0-08、A0-09、A0-11。
- 终局：今日理由、Pulse 绕过、行动反馈、普通冲突、三域多目标、知识评估、安全决定、Eligibility、Consent、离线/同步、异常解释。
- 每个组合记录：视口、浏览器、OS、缩放/字体倍率、输入方式、截图、录屏、滚动范围、焦点顺序、错误和原型版本。

## 9. 无障碍专项审计

### 9.1 200% 字体

**V6**

- 固定 `390x844` 画布见 145-146 行，RPE/Sheet 固定宽 390 见 2120 行，modal 固定宽 350/390 见 1630、1726 行。
- 静态统计出现 339 处 9-15px 字号声明；多个标签和说明为 9-11px。
- 只有 `max-width:430` 画布铺满规则，未提供文本放大、平板或横屏重排。
- 判定：P0 阻塞，必须真实渲染后逐页修复。

**review prototype**

- 23、30 行定义 200% 语义字号和 `.text-200`；32 行让双栏回单列并取消 sticky。
- 风险：其 200% 不是浏览器/OS 原生缩放，只是预设 Token；不能替代真实 200% zoom、系统大字体和浏览器最小字号测试。
- 判定：合同方向通过，证据仍阻塞。

### 9.2 键盘

**V6**

- 多数交互由 `div/span onclick` 和 cursor 构成，例如分类、设置、卡片、目标操作、RPE 数字，缺原生按钮语义和键盘激活。
- 573、937、1474、2478 行移除 outline；文件无 `focus-visible`。
- Modal/Sheet 缺焦点陷阱、Esc/返回、关闭后回焦证据。
- 判定：P0 阻塞。

**review prototype**

- 27 行统一 `focus-visible`；主要操作用 button/input/textarea/select。
- 159、192 行提供 Pulse Enter/Space；69、200 行 dialog 关闭回焦；64、68、119-120 行有焦点容器和 live region。
- 风险：一级 Tab 点击当前只触发 Toast，且需真实键盘走查验证所有动态重渲染后的焦点是否回到新标题；`h1 tabindex=-1` 已有但静态代码未见每次 route 后主动 focus。
- 判定：D2 前有条件，未放行。

### 9.3 屏幕阅读器

**V6**

- 无 `aria-live`、dialog role、aria-modal、aria-label 或可见状态关系的系统性声明。
- 多个图表为 Canvas，未见等价表格；功能 emoji 的朗读名称不可控。
- 状态大量只靠颜色、图形、Toast、滑动和动画。
- 判定：P0 阻塞。

**review prototype**

- 51-54 行控制台有 aria-label/group/pressed；62-69 行画布、导航、status、live region、dialog 有语义。
- 156 行 Tab 有 `aria-current=page`；163-171 行安全/异常以文本结构表达。
- 风险：动态 `innerHTML` 替换后标题未自动聚焦；来源、状态和按钮名称仍需用 NVDA/VoiceOver/TalkBack 实测；D2 不能替代 D4。
- 判定：合同较完整，D4 阻塞。

### 9.4 对比度

代表性静态计算，不能替代 computed style 全量扫描：

| 样式 | 估算对比度 | 判定 |
|---|---:|---|
| V6 暗色 secondary on card | 6.53:1 | 正文可用 |
| V6 暗色 tertiary on card | 3.19:1 | 小文本不达 4.5:1 |
| V6 暗色 muted on card | 2.16:1 | 不达标 |
| V6 浅色 secondary on white | 4.47:1 | 边缘失败，需按实际合成/字体重测 |
| V6 浅色 tertiary on white | 2.35:1 | 不达标 |
| V6 浅色 muted on white | 1.59:1 | 不达标 |
| review primary on surface | 16.90:1 | 通过 |
| review secondary on surface | 7.83:1 | 通过 |
| review muted on surface | 5.34:1 | 正文通过 |
| review action on surface | 7.73:1 | 通过 |

V6 18-20、58-60 行的低透明前景被大量用于 9-12px 标签，构成模式性问题。必须升级语义灰阶，不得只增大字重掩盖低对比。

### 9.5 reduced motion

- V6 无 `prefers-reduced-motion`；385 行 3.5s 无限呼吸，815 行 1.2s highlight，1608 行粒子，4742/4748 行 bounce，均阻塞。
- review 34 行全局关闭动画/过渡并隐藏 hold 进度伪元素，基础合同通过。
- 真实验证需开启系统 Reduce Motion，确认 Pulse 按钮、状态文本、焦点和 Safety 流程仍完全可用。

### 9.6 触控与等效入口

- V6 36px add button、24px 视频图标、32px RAG 发送、RPE skip 视觉区等低于 44/48；多个 div/span 无命中区合同。
- 滑动完成见 2069-2107 行，长按/动画解锁见 2325-2337 行，不能作为唯一入口。
- review 27 行统一表单/按钮 min-height 48px，159 行 Pulse 有显式按钮，基础合同更好。
- 所有手势必须有按钮、键盘和读屏等效；动作视频必须有字幕/转录/文本步骤。

## 10. P0 静态扫描

| 扫描项 | V6 | review prototype | 裁决 |
|---|---|---|---|
| emoji 功能图标 | 306 个命中代码行；大量用于按钮、设置、分类、状态、Toast、动作缩略图 | 0 命中 | V6 P0 失败；review 通过静态扫描 |
| 紫色到粉色渐变 | 未发现禁止色对直接组成的线性渐变；但 739-741 行硬编码紫/粉模式色，1415 行紫色渐变 | 未发现 | 直接禁用渐变扫描通过；V6 彩色模式标签与裸值仍需删除 |
| AI 模板味 | Pulse 光球、评分/streak、AI 引导卡、同构指标卡、全屏 PR 庆祝、泛化“开始/继续你的旅程” | 无空洞 Hero；使用真实结构与范围标记 | V6 P0 失败；review 方向通过 |
| 硬编码颜色 | 152 次 hex、48 个唯一 hex；大量组件/inline 直接使用；557 个 inline style | 35 次 hex、33 个唯一 hex，主要在 Token 声明；但 `--s-bg-workbench`、success subtle/border/shadow 直接硬编码，且 4 个 inline style | V6 P0 失败；review 需归一 Foundation → Semantic → Component 后才放行 |
| 弹跳/弹性缓动 | 4742、4748 明确 bounce；另有无限呼吸和粒子 | 仅标准 `cubic-bezier(.4,0,.2,1)`；未见 bounce/elastic | V6 P0 失败；review 静态通过 |
| 侧条纹边框 | 748、1161、2414、2444、3199、3241、3276、4760-4762、5298 等 | paper-surface relation/warning 使用 4px border-left，见压缩 CSS line 31 | 两者均违反绝对禁令；统一改完整边框/背景/图标/标题 |
| 毛玻璃/装饰模糊 | 多处 backdrop-filter、blur 解锁和阴影 | 未见默认毛玻璃；控制台/画布使用克制阴影 | V6 失败；review 需真实渲染确认 |
| 过度圆角 | 20/24px modal、40px phone frame | 4/8/12/16 token，device shell 例外 30px | V6 需收敛；设备外壳可例外，不进入产品组件 |

说明：静态扫描 clean 只能证明未命中指定模式，不能证明设计合格。

## 11. 五源对齐矩阵

本报告采用五个独立来源进行对齐：S1 V6 主视觉基线；S2 review prototype 合同对照；S3 `v6-evolution-strategy-v1.0.md` 已接受演进决策；S4 `primeatlas-spec-design-input-v1.0.md` 设计合同；S5 `v0.2-ia-lowfi-validation-pack.md` 研究和证据规则。

| 核心主题 | S1 V6 | S2 review | S3 演进策略 | S4 设计输入 | S5 低保真包 | 裁决 |
|---|---|---|---|---|---|---|
| V6 为主基线 | 提供成熟视觉/交互 | 视觉较新、合同更完整 | 明确禁止推倒 V6 | 明确只继承已验证交互品质 | 要求验证 V6 高频能力迁移 | 保留 V6 资产，review 不取代 |
| 终局四入口 | 六入口，不对齐 | line 156 四入口 | 已固定四入口 | 主候选结构相同 | 围绕四入口做真实测试 | 以四入口为终局，V6 六区下沉映射 |
| V0.2 两入口 | 不具备 | A0 线性流程，但 line 154 混入测试同步状态 | 确认前 0 Tab，确认后旅程/我的，纯本地 | 身份到目标闭环 | 明确禁止未来半入口 | review 需删除 A0 同步半入口表达后才对齐 |
| 身份迁移主轴 | 目标/训练主导，身份线索弱 | line 128-154 持续 identity line | 唯一最高主轴 | 页面必须说明迁移位置 | T01/T08 验证身份理解 | 把 identity transition 注入 V6，而非换掉专业页面 |
| 三 active 域、每域多目标 | 写成三个目标上限 | line 95-97 支持多域多目标 | 明确三域而非三目标 | 明确 1-3 active 域 | T05 压测三域多目标 | V6 目标上限表达 P0 替换 |
| Pulse 可绕过 | 解锁/评分/streak | T03 有直接行动和等效按钮 | 可绕过且等效 | 不解锁训练 | T03/T14 验证 | 采用 review 合同，保留 V6 仪式触感 |
| 安全 vs 普通冲突 | 混在 Agent 调整卡，侧条和颜色主导 | T04/T09 独立流程 | 严格分离 | 独立业务状态页 | T04/T09 分别验证 | 采用 review 结构，换回 V6 专业密度 |
| 知识双入口 | 独立一级知识并混合消费/导入/注入 | T06/T07 有业务入口，T11 有 Consent；我的来源库仍未完整可点 | 明确成长域/目标 + 我的双入口 | 设计输入较早版本偏成长域，需被后续接受决策覆盖 | T06/T07/T11 覆盖部分任务 | 终局严格拆职责；review 仍需补我的来源库/导入/保留删除/治理切片 |
| 纯本地与范围诚实 | 登录、云同步、模型入口混入 | Research only 标记清晰；无 HTTP 声明命中 | V0.2 禁远程/HTTP/第三方 | 最低能力和 Consent 合同 | 要求 Won't Have 为 0 | review 接近，但 A0 测试同步状态须移到 Future IA |
| 可访问性 | 明显不足 | 有 focus、live、200%、reduced motion | 要求等效入口 | WCAG 2.2 AA 合同 | D4 才能冻结 | review 可作实现参考，仍须 D2/D4 实证 |
| D3/D4 证据 | 无 | 主动声明无 | 明确不得冒充 | 需低保真验证 | 当前真实 D3/D4 未完成 | 保持 Candidate/Blocked |

## 12. 真实渲染验证门禁

### 12.1 必须补齐的 D1/D2 证据

1. 浏览器：Chrome、Safari/WebKit、Firefox；至少一台 iOS Safari 和一台 Android Chrome。
2. 视口：320x568、360x800、390x844、430x932、568x320、800x360、600x960、768x1024、834x1194、960x600、1024x768、1194x834。
3. 字体：100% 和 200%；记录实际 computed font，不接受只声明字体栈。
4. 输入：触摸、鼠标、全键盘；记录焦点顺序、可见焦点、Sheet/Dialog 回焦。
5. 读屏：至少 NVDA/Chrome 或 VoiceOver/Safari 的 D2 工具走查；真实 D4 另行执行。
6. 运动：系统 reduced motion 开启；确认无呼吸、bounce、粒子和位移动画依赖。
7. 对比度：对每个 text/background 计算实际合成值；正文至少 4.5:1，非文本组件至少 3:1。
8. 页面状态：正常、首次、空、加载、错误、离线、拒权、数据不足、过期、冲突、安全否决、撤回、成功、edge。
9. 运行记录：Console 0 error、资源 0 404、无横向滚动、主操作不被底栏/键盘遮挡。
10. 视觉证据：每个关键页面/状态保留截图；关键任务保留录屏与版本/hash。

### 12.2 D3/D4 阻塞项

- D3：四入口首次理解；旅程与成长域分工；三域多目标定位；普通冲突；知识双入口；返回上下文；V6 高频能力迁移成本。
- D4：Pulse 绕过/等效启动；行动完成；RPE missing；Safety；Eligibility；Consent；200% 字体；真实读屏和键盘导航。
- 在 D3/D4 完成前，不得写“IA Frozen”“可上线”“用户已理解”“无障碍通过”。

## 13. 修复顺序

### Phase 1：P0 清场

1. 替换 V6 全部功能 emoji 为 Lucide。
2. 移除 bounce、持续呼吸、粒子、Pulse 解锁和 blur lock。
3. 修正 RPE missing、三域多目标、精确指标条件、V0.2 登录/远程半入口。
4. 删除彩色侧条、紫/粉模式裸色和卡片模板痕迹。
5. 建立 focus-visible、reduced motion、语义按钮、dialog/sheet 焦点合同。

### Phase 2：视觉连续性迁移

1. 用 V6 的专业密度重构成长域体能页面。
2. 注入身份迁移头部、目标来源、证据和充分度。
3. 将身体/训练下沉成长域，将目标迁移到旅程唯一真源。
4. 按知识双入口拆业务消费与全局治理。
5. 用统一 Token 和组件矩阵替换 inline style。

### Phase 3：真实渲染与用户证据

1. 完成手机/平板 portrait/landscape、200% 字体和输入方式矩阵。
2. 完成 D2 对比度、键盘、读屏、reduced motion 走查。
3. 修复所有 P0/P1 后组织真实 D3/D4。
4. 只有证据达标后，才回填冻结裁决。

## 14. 最终裁决

`FAIL / BLOCKED`。

- V6：保留为主要视觉与体验资产库，但当前 P0 扫描、响应式、可访问性和 Spec 语义均不合格。
- review prototype：可作为合同、异常状态、范围隔离和自适应参考；它不能替代 V6，也未通过真实渲染和 D3/D4。
- V0.2：必须是身份确认前无 Tab、确认后仅旅程/我的的纯本地闭环；review 中 A0 测试同步表达需移出 Release 切片。
- 终局：固定今日/旅程/成长域/我的；知识严格采用成长域/目标业务入口 + 我的治理入口。
- 放行条件：P0 为 0、真实浏览器 D1/D2 证据完整、D3/D4 或 QA 接受的等价真实证据完成。

# PrimeAtlas V6 P0 修复规格 v1.0

> 状态：Implementation Candidate；本文件只定义修复，不修改 HTML/Flutter。  
> 基线：`primeatlas-prototype-v6.html`（视觉/体验资产）+ `primeatlas-review-prototype-v1.0.html`（合同/异常对照）。  
> 优先级：产品真源/冻结范围 > Release Spec/安全规则 > 演进策略 > V6 现状。P0 未归零不得冻结。

## 1. 不可协商边界

- 增量修复 V6，禁止推倒重做或让 review prototype 取代 V6。
- 图标只允许架构师最终锁定的**一套** SVG 图标系统；若尚未锁定，先阻断，不新增或混用第二图标库。
- V0.2 与 Future IA 必须是独立入口、状态、重置和评审记录；V0.2 纯本地、零 HTTP/远程/未来半入口。
- 终局固定四入口“今日 / 旅程 / 成长域 / 我的”；V0.2 身份确认前 0 Tab，确认后仅“旅程 / 我的”。
- Batch A 只改评审原型及其机械回归；真实 D1–D4、Flutter 工具链/55 Test ID 和发布构建隔离属于 Batch B。

## 2. 去重 P0 修复表

缩写：`V6`=`docs/prototype/primeatlas-prototype-v6.html`；`REV`=`docs/prototype/primeatlas-review-prototype-v1.0.html`。

| ID | 唯一问题与精确定位 | 唯一修法 | 机械验收 |
|---|---|---|---|
| P0-01 | 功能 emoji：`V6` 全文件，代表 `.pulse-streak` 2678、导航/设置 3568–3623、`showToast`/动态模板 4344–4490、`showPRCelebration` 4736–4748 | 在架构师锁定的唯一 SVG 集内建立语义映射；按钮图标有可访问名称，纯装饰 SVG `aria-hidden=true`；删除字符图标，不引入第二库 | Unicode pictograph 扫描对功能节点/JS 模板为 0；图标 import/sprite 来源唯一；按钮 accessible-name 非空 |
| P0-02 | DOM XSS：`V6 addAIBubble()` 4446、`sendAIMsg()` 4448–4494；用户 `userMsg` 进入 `innerHTML` | 用户文本只经 `textContent`/`createTextNode` 写入；固定选项用预建 DOM；禁止拼接事件属性；不得以自制黑名单替代安全 DOM | 输入 `<img src=x onerror=alert(1)>` 后 DOM 只含文本、无 `img/script/on*`；扫描 `userMsg.*innerHTML` 为 0；新增 XSS 回归 |
| P0-03 | RPE missing：`V6 .rpe-skip` 3737；`completeAction()` 4566–4577 默认 7；`selectedRPE` 4585；`skipRPE()` 4602–4609 | 初始值为 `null`；确认未选时阻断；跳过写显式 `{status:'missing', value:null}`，绝不读历史值 | 跳过后状态严格等于 missing/null；“上次 RPE/默认 7”扫描为 0；选值 1–10 分支保持可用 |
| P0-04 | localStorage 静默失败：`REV persist()` 122、`setBound()` 129、`deterministicReset()` 194、启动恢复 202 | `persist()` 返回成功/失败结果；异常进入 `save_error`，保留内存输入，页面显示重试/导出，不更新 `savedAt`、不播报成功；解析失败隔离坏数据并可重置 | stub `setItem` 抛 `QuotaExceededError`/`SecurityError`：状态为 error、输入 hash 不变、成功文案 0；坏 JSON 启动不崩溃且有恢复动作 |
| P0-05 | assisted failure 只有文案：`REV a003()` 141，输入链 `setBound()`/`bindInputs()` 129–130 | 增加 Research-only timeout/limit/invalid-response 三夹具；失败只产生可解释错误和手动草案入口，不生成正式结果；失败前后输入不变 | 三夹具各断言 input hash 前后相同、正式画像/审计/outbox 增量为 0、手动编辑可达；映射 T-V02-005/006 |
| P0-06 | 假版本冲突：`REV a011()` 154、`handleAction toggle-sync` 187；无双版本事务；`createRestoredVersion()` 178 也无回滚 | Research fixture 建立 immutable base/current 与 stale `baseVersion`；stale 写拒绝；并列差异、用户选择/合并、审计/outbox 同事务；禁止 LWW；恢复复用同一原子事务包装 | stale 写不改变 active；base/current 同屏可读；解决后仅新 active、历史未改；注入持久化失败时版本/审计/outbox 全量回滚 |
| P0-07 | 未激活域仅 UI 过滤：`REV activeDomains()` 124、`goalRows()` 145、`confirm-milestones` 186 | 建立唯一 `activeDomainIds` 读模型过滤器，供 Repository fixture、目标/里程碑、指标聚合、Agent-context 导出共同调用；未激活域不生成空占位 | 将某域 inactive 后四类输出均 0 命中该 domainId，其他域 hash 不变；映射 T-V02-018/033 |
| P0-08 | V0.2 隔离不足：`REV render()` 136 同文件可进 a1/compare；`V6` 含 Today/训练/Pulse/知识/模型 | 给 A0 Release 切片独立入口清单与状态命名空间；Release 产物不注册 a1/compare/V6 Future 路由、对象、文案或事件；研究工作台继续明确 Research only | 对 V0.2 产物扫描 Today/训练/Pulse/知识/Eligibility/模型/同步入口与 Future route 均 0；网络 API 静态命中 0；独立重置不影响 Future 状态 |
| P0-09 | 四入口/两入口冲突：`V6 .bottom-nav/.nav-item` 196–240、3568–3603，`switchTab()` 3744；`REV primaryNav()` 156 | Future IA 只渲染今日/旅程/成长域/我的；身体/训练下沉成长域，目标归旅程，知识按业务/治理双入口；V0.2 用独立 nav policy：确认前 0、确认后 2 | Future nav label/route 恰为 4 且顺序固定；V0.2 pre-confirm=0、post-confirm=2；旧六一级 route 扫描为 0；返回上下文测试通过 |
| P0-10 | 响应式：`V6 .phone-frame` 145–146 固定 390×844；`.video-player` 862、Sheet/Modal 1630 等固定 390；仅手机铺满 | 改为内容驱动 compact/medium/expanded；宽高用 `min()/max-width`、安全区和可滚动上限；≥600 rail/双栏，200% 强制关键页回单列 | 320/360/390/430 portrait、568/800 landscape、600/768/834 portrait、960/1024/1194 landscape：`scrollWidth<=clientWidth`、主操作未遮挡；200% 同断言 |
| P0-11 | A11y 语义/焦点：`V6` `outline:none` 573/937/1474/2478；大量 `div/span onclick`；`showDetail()` 3798–3811；`REV renderA0/renderA1` 138/157 未聚焦标题 | 交互换原生 button/input；统一 `:focus-visible`；Dialog/Sheet 具标题、`aria-modal`、焦点陷阱、Esc/返回和关闭回焦；route 后聚焦 `screenHead h1`; 状态用 live region | axe 严重/高危=0；全键盘无陷阱且焦点可见；每次路由 `document.activeElement` 为新页 h1；Dialog 开关焦点断言通过 |
| P0-12 | motion：`V6 .pulse-orb::before` 385、粒子 1608、highlight 815、bounce 4742/4748，无 reduced-motion | 删除 bounce/持续呼吸/随机粒子；只保留 150/250/400ms transform/opacity；增加 `prefers-reduced-motion:reduce` 即时替代，且不以隐藏内容门控 | reduced-motion 下 animation iteration=0、关键 transform 位移=0；关键任务结果与普通模式一致；`bounce|infinite|particle-burst` 扫描为 0 |
| P0-13 | Pulse 硬门槛：`V6 #pulseOrb` 2668、`#trainingUnlockTarget`、`switchTab()` 3771–3775、`handlePulseTap()` 3877–3887 | Pulse 仅可选仪式；主行动在初始 DOM 即启用；删除 `pulseUnlocked` 对训练可达性的 guard/blur/lock；保留长按时必须同时有按钮、Enter/Space 等效 | 未触碰 Pulse 即可开始行动；hold/button/Enter/Space 结果等价；Pulse 前后主行动 disabled/visibility hash 相同 |
| P0-14 | 伪精确指标：`V6 .pulse-score` 406–418/2675，目标环 1285–1310、3471–3486，ACWR/预计类视图 | 所有精确值统一通过 `metricEligibility(formula,sample,window,confidence)`；任一缺失只显示阶段/趋势/证据/充分度/更新时间，Pulse 不显示准备度分 | 四条件逐一 false 时百分号/预计日期/确定性结论 0；全部 true 时同时展示公式、样本、窗口、置信说明；边界样本测试通过 |
| P0-15 | 对比度：`V6 --text-tertiary/--text-muted` 18–20、58–60，广泛用于 9–12px 标签；静态估算最低 1.59:1 | 调整语义前景 Token；正文/关键小字 ≥4.5:1，大字 ≥3:1，非文本组件/焦点 ≥3:1；不得靠加粗或纯颜色表达状态 | 真实 computed-style 全页组合扫描：文本/组件阈值 100% 通过；暗/浅、hover/focus/disabled、Canvas 等效文本均覆盖 |
| P0-16 | 触控/等效入口：`V6 .add-goal-btn`、视频图标、RAG 发送、`.rpe-skip`；滑动 `handleTouchEnd()` 4515–4524；长按 Pulse | 所有操作命中区 min 44×44（移动目标 48 优先）、间距 ≥8；滑动/长按均配同名按钮、键盘与读屏路径；视频补字幕/转录/文本步骤 | computed rect 交互目标全部 ≥44×44、相邻间距 ≥8；关闭触控后键盘可完成同任务；手势删除不影响按钮路径 |
| P0-17 | 彩色侧条与裸色：`V6 .superset-group` 748、`.goal-card` 3199/3241/3276、Agent 模板 4760–4762、知识 5298；action-mode 738–744 和大量 inline hex；`REV .paper-surface.relation/.warning` 压缩 CSS 31 | 侧条改完整 1px 语义边框+状态图标+标题/表面层；颜色全部收口 Foundation→Semantic→Component Token（仅 `#fff/#000` 例外），Canvas 从 CSS Token 取值 | `border-left/right:[2-9]px` 强调扫描为 0；组件/inline 非例外 hex 为 0；状态去色截图仍可由文本/图标识别 |

## 3. Batch A：允许实施的原型修复

1. **安全与数据真实性**：P0-02、03、04、05、06、07；先落回归夹具，再改实现。
2. **范围与 IA**：P0-08、09；只建立 V0.2 Release 切片与 Future IA 的硬隔离，不把 Future 功能倒灌 V0.2。
3. **可达性与行为**：P0-11、12、13、16；主行动先可达，Pulse/手势只作增强。
4. **视觉系统**：P0-01、14、15、17；图标待架构师确认唯一锁定集后执行，绝不自行新增第二库。
5. **自适应代码与自动检查**：P0-10 的 CSS/DOM 修复、viewport 自动断言、静态扫描和原型 E2E。
6. Batch A 只允许改 `V6`、`REV`、独立 V0.2 评审产物及原型回归；不得修改正式 Flutter 业务逻辑。

## 4. Batch B：后置真实证据与正式工程依赖

- **D1 真实渲染**：Chrome、Safari/WebKit、Firefox；至少 iOS Safari + Android Chrome；保存截图、录屏、Console、computed font/style、网络记录和版本 hash。
- **D2 工具验证**：完整 viewport/200%/键盘/至少 NVDA 或 VoiceOver/对比度/reduced-motion；Console error=0、资源 404=0、请求出口符合切片合同。
- **D3 目标用户**：四入口理解、旅程/成长域分工、三域多目标、普通冲突、知识双入口、返回上下文、V6 高频能力迁移；无样本一律 `Insufficient evidence`。
- **D4 辅助技术用户**：Pulse 绕过、行动完成、RPE missing、Safety、Eligibility、Consent、200%、真实读屏/键盘；D0–D2 不得替代。
- **Flutter/发布**：恢复 Flutter SDK 后执行 `flutter analyze`、`flutter test`；落实 `T-V02-001..055` 55/55、发布构建级路由/对象隔离、真实本地存储与事务。工具链不可用即阻断，不写 N/A。

## 5. V6 不可破坏资产

- 移动单列的内容节奏、拇指可达操作密度与专业克制气质；尺寸约束可改，体验连续性不可丢。
- 体能的身体/训练专业深度、动作详情/教学/组次执行/反馈；迁入“成长域 → 体能”而非通用卡片化。
- 调整前后差异、安排理由、来源回溯、知识注入前评估、调性预览；补来源/充分度/安全边界，不删解释价值。
- Pulse 的 500ms 仪式触感可保留为可选增强；不得保留评分、streak、解锁或唯一长按入口。
- 本地可点击、即时反馈和 Mock/Research-only 诚实标识；不得伪装真实算法、同步或用户证据。
- 同一对象只有一个正式编辑真源；旅程管目标，成长域/目标管知识消费，我的管来源/Consent/保留删除。

## 6. 实施顺序、门禁与回滚点

| 阶段 | 实施与退出门 | 回滚点 |
|---|---|---|
| R0 基线封存 | 记录 V6/REV hash、代表页截图清单、P0 扫描结果；HTML 不改 | `RB0`：原始双基线可逐文件恢复 |
| R1 安全/状态 | 完成 P0-02..07；XSS、RPE、存储异常、assisted、冲突、域过滤回归全绿 | `RB1`：只回滚安全状态批次；不得回退到 XSS/伪保存，失败则停止后续 |
| R2 范围/导航 | 完成 P0-08/09；V0.2 Won't Have=0，Future=4，V0.2=0/2 | `RB2`：恢复 R1 快照；禁止用旧六 Tab 临时发布 |
| R3 可达性/交互 | 完成 P0-10..13/16；自动 viewport、键盘、motion、Pulse 绕过通过 | `RB3`：恢复 R2；若专业流程退化，仅回滚布局层，不回滚语义修复 |
| R4 视觉收口 | 完成 P0-01/14/15/17；唯一图标源、指标门、对比、Token 扫描通过 | `RB4`：恢复 R3 Token 快照；保留安全、范围和 A11y 修复 |
| R5 真实证据 | 执行 Batch B D1→D2→D3→D4 与 Flutter 55/55；P0=0 才申请冻结 | 任一真实证据失败回对应 R1–R4 最小批次；不得改测试阈值或降级为 N/A |

最终机械门：功能 emoji=0、用户文本 `innerHTML`=0、RPE missing 正确、保存失败不伪报、V0.2 禁止入口=0、Future/V0.2 导航计数正确、非例外裸色/侧条纹=0、真实 D1–D4 证据齐全、Flutter 55/55 可追踪且全绿。
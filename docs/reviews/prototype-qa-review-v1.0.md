# PrimeAtlas 双基线原型 QA 复核 v1.0

> RoleVerdict: **FAIL / BLOCKED**  
> 审查对象：`docs/prototype/primeatlas-prototype-v6.html`（主要体验基线）与 `docs/prototype/primeatlas-review-prototype-v1.0.html`（合同对照）  
> 范围约束：终局四入口、V0.2 两入口、纯本地闭环均作为已确认决策；本报告不修改原型或业务代码。  
> 裁决规则：P0 不归零不放行；静态自检、场景夹具与 42 个 S0 单元测试均不得替代真实浏览器、真实辅助技术、D3/D4 与 55 个 V0.2 Test ID。

## 1. 独立复核输入与方法

已先读 QA 强制知识库：

- `test-discipline.md`：先做影响图，回归率与解决率并列；测试作者与实现作者解耦。
- `test-integrity-anti-gaming.md`：绿测须经过删测、弱断言、skip/focus、框架篡改和硬编码审查。
- `verifier-critic-pattern.md`：只给 `pass/fail`，阻断项必须带验收条款与证据。
- `generated-code-failure-modes.md`：逐项检查 Happy-path、沉默逻辑错误、幻觉依赖、系统上下文、性能盲区、静默缺失。
- `production-readiness-scorecard.md`：七维取最低档，未达 Silver 不交付商业生产。

证据分级：

- **静态证据**：源文件行号、机械扫描结果；只能说明实现表面存在或缺失。
- **D0–D2 自检**：合同原型的内置 fixture、场景状态与人工代码审查；不能代替真实任务证据。
- **D3/D4**：真实浏览器/设备/辅助技术/参与者任务；本环境未具备则必须判 FAIL，而不是 N/A 或推断通过。

## 2. 改动影响分析

### 本次改动范围

- 审查文件：上述两个 HTML 单文件原型；未发现当前工作树业务改动，`git status --short` 为零输出。
- V6：六入口历史体验、Today/Pulse/训练/知识/模型切换等完整演示面。
- review prototype：A0 的 11 步 V0.2 合同对照，以及明确标记为 Future IA 的四入口结构壳。
- 改动类型：本轮为验收复核与报告新增，不修改实现。

### 下游影响面

- 直接受影响行为：V0.2 身份草案、显式画像确认、活跃域、目标/里程碑、旅程、画像版本、本地状态。
- 共享状态：review prototype 的 `prototypeState` 与 `localStorage`；V6 的内存 DOM 状态。
- 高风险旧行为：
  - A0 顺序门禁与 deep-link 回退，风险高；绕过会导致未确认事实被使用。
  - 画像、审计、outbox 原子提交，风险高；半写会破坏因果链。
  - 第 4 域、未激活域过滤、版本冲突与恢复，风险高；涉及用户主权及数据完整性。
  - V0.2 范围隔离，风险高；Today、训练、Pulse、知识、第三方模型任何半入口均越界。
  - 本地持久化错误处理，风险高；保存失败却显示成功会造成数据丢失错觉。
  - 键盘、读屏、200% 字体、reduced motion，风险高；属于 P0 无障碍门。
  - V6 历史体验资产，风险中；可保留为体验参考，但不得作为 V0.2 放行基线。

### 回归测试优先级

1. A0 端到端顺序、原子失败回滚、本地重启恢复、未激活域零展示、版本冲突/恢复：必测。
2. V0.2 两入口及 Won't Have 零入口扫描：必测。
3. 键盘、读屏、200% 字体、reduced motion：必须真实浏览器/辅助技术执行。
4. V6 六入口体验与历史交互：作为非 V0.2 回归参考抽测，不可把其范围错误带入 V0.2。

## 3. V6 现有回归资产

| 资产 | 静态证据 | QA 判定 |
|---|---|---|
| 六入口历史体验 | V6 的 Today、身体、训练、目标、知识、我的面板位于 `2612`、`2809`、`2991`、`3192`、`3329`、`3414` 行；导航位于 `3569–3599` 行 | 可作为主要体验基线，但不是 V0.2 IA/范围合同 |
| Today → 训练 deep-link | `2765`、`2773`、`2781`、`2802` 行调用 `switchTab('training', scene)`；`3744–3769` 行实现切换/滚动 | 静态存在；真实浏览器回归未执行，FAIL |
| Pulse 长按 | `2668` 行为点击/鼠标/触摸处理；`3860–3887` 行含 500ms 定时与“解锁训练” | 与冻结合同冲突：Pulse 不得成为训练门槛；只保留历史体验参考，不得进入 V0.2 |
| RPE 交互 | `3719–3737`、`4567–4609` 行 | 存在明确旧缺陷：`3737` 写“跳过，使用上次 RPE”，`4602–4607` 也复用历史；违反 RPE missing 合同，P0 |
| 目标/AI 引导 | `4432–4496` 行 | `4446`、`4452` 把用户输入直接拼接进 `innerHTML`，存在可执行 HTML/XSS 风险，P0 |
| 动作库、知识阅读与导入 | `4683–5016`、`5044–5331` 行 | 体验参考资产；V0.2 必须零入口 |
| 明暗主题、调性、模型切换 | `3501–3560`、`5381–5420`、`5606–5628` 行 | 体验参考资产；V0.2 不得出现第三方模型/底层模型选择半入口 |
| S0 核心测试 | `test/core/**` 共 13 文件；机械统计 `42` 个 `test(`、`98` 个 `expect(`、0 skip/focus | 仅纯 Dart S0 基线，不覆盖 HTML 原型、V0.2 55 Test ID 或真实设备 |

**结论：**V6 资产可用于视觉、信息密度和历史交互回归，但其六入口、Pulse 解锁、训练/知识/模型切换、RPE 复用等不得被误判为 V0.2 合格实现。

## 4. A0 合同专项门禁

| 门禁 | 合同对照证据 | 验证状态 | 裁决 |
|---|---|---|---|
| 顺序门禁 | A0 11 页路由 `77–89`；最大可达计算 `112`；可达性与归一化 `113–115`；逐页 guard `176` | 静态实现明确；未跑真实浏览器正反旅程 | **FAIL / P0 阻断** |
| deep-link | hash 生成/解析 `110–115`；`hashchange` `201` | 深链对未解锁页会归一化回退；但无浏览器历史/刷新/返回栈证据 | **FAIL / P0 阻断** |
| 原子事务 | UI/失败夹具 `143`；`atomicConfirm` 快照、提交、异常整体恢复 `177` | D2 fixture 可表明代码意图；无真实存储断电/异常/半写检测 | **FAIL / P0 阻断** |
| 第 4 域 | 选择页 `144`；第 4 域拒绝与聚焦提示 `181` | 原 3 域保持不变的代码路径存在；无浏览器状态前后快照 | **FAIL / P0 阻断** |
| 辅助失败输入不丢 | A0-03 文案 `141`；输入每次 `setBound→persist` 在 `129–130` | 没有真正 dependency timeout/invalid response 注入动作；仅文案和通用持久化，不能证明 assisted failure 后输入不丢 | **FAIL / P0 阻断** |
| 版本冲突 | A0-11 只提供测试同步状态切换 `154`、`187` | 仅展示 `test_conflict` 标签，无 base/current 双版本对象、选择/解决事务或 stale base_version 拒绝 | **FAIL / P0 阻断** |
| 离线恢复 | `persist`/启动恢复 `122`、`202`；A0-11 声明浏览器恢复 `154` | `localStorage.setItem` 异常被 `catch(e){}` 吞掉，仍 `renderStatus()` 显示已保存；可能静默丢数据 | **FAIL / P0 阻断** |
| 恢复历史版本 | 恢复按钮与详情 `152–154`；新建 restored active `178` | 静态语义符合“新建不覆盖”；无重启后历史链/审计/outbox 原子证据 | **FAIL / P0 阻断** |
| 未激活域零展示 | `activeDomains()` `124`；目标列表只遍历活跃域 `145`；里程碑确认过滤活跃域 `186` | 对旅程默认展示有静态过滤；仍缺仓库/指标/Agent context 零占位证据 | **FAIL / P0 阻断** |

补充：`restore-version` 的 `createRestoredVersion` 在 `178` 行是多步直接写，无与审计/outbox 同成同败的 rollback 包装；若持久化失败同样会被 `persist` 吞掉。恢复路径的数据完整性不能放行。

## 5. V0.2 范围隔离

### 5.1 已确认边界

- V0.2 业务闭环只允许两类产品入口：旅程、我的；A0 自身使用底部“上一步/下一步”流控而非终局产品导航（`137–154`）。
- 终局结构壳为四入口：今日、旅程、成长域、我的（`156`），并在每页持续标注 `Future IA · 非 V0.2`（`155`）。
- A0 终点明确声明不出现未来能力半入口（`154`）。

### 5.2 Won't Have 零入口判定

| 禁止项 | review prototype A0 | V6 主要体验基线 | QA 解释 |
|---|---|---|---|
| Today | A0 页面/流控未见产品 Today 入口 | Today 面板 `2612`、导航 `3569` | V6 不能作为 V0.2 可交付产物直接上线 |
| 训练/PlanAction/Execution | A0 未见训练入口；Future 壳有训练任务，仅标非 V0.2 | 训练面板/导航 `2991`、`3581–3585` | 任何打包时把 Future/V6 入口混入 V0.2 即 P0 |
| Pulse | A0 未见；Future T03 明确“可选、不解锁行动” `159` | V6 `2676`/`2757`/`3884–3887` 明确解锁训练 | V6 行为与合同冲突，必须隔离 |
| 知识 | A0 未见；Future T07 为非 V0.2 | V6 知识面板/导航 `3329`、`3593–3597` | 必须保持零入口 |
| 第三方/底层模型 | A0 未见模型选择/发送入口 | V6 模型切换 `3544`、`5606–5628` | V0.2 不可出现模型半入口，且不得发送身份原文 |

**范围裁决：**review prototype 的 A0 静态结构守住 V0.2 页面边界；但 V6 本身明显包含全部 Won't Have。交付包/路由/构建级隔离未提供，故不能证明 V0.2 “零半入口”，仍 FAIL。

## 6. 纯本地零网络调用证据

机械扫描模式：`fetch(`、`XMLHttpRequest`、`WebSocket`、`EventSource`、`axios`、`http://`、`https://`。

- review prototype：0 命中。
- V6：唯一 `http://` 字符串命中为 `564` 行内联 `data:image/svg+xml` 的 SVG namespace，不是网络地址；未发现 fetch/XHR/WebSocket/EventSource/axios。
- review prototype 使用 `localStorage`：`122`、`194`、`202`；V6 无显式外链脚本/字体命中。

**静态结论：**双 HTML 文件没有显式出网调用，支持“纯本地原型”声明。  
**限制：**没有真实浏览器 DevTools/HAR/Service Worker/DNS 观察，不能把静态零调用升级成第三方出口测试 `T-V02-052` 的通过证据。真实浏览器网络面板必须记录所有请求为 0 后才可放行。

## 7. 无障碍与响应专项

| 项目 | 静态证据 | 缺失证据与裁决 |
|---|---|---|
| 键盘 | review prototype 主要使用原生 button/input；Pulse Enter/Space `192`；dialog 关闭后恢复触发点焦点 `200` | 动态重渲染后没有统一把焦点移到新页标题；`screenHead` 虽有 `tabindex=-1`（`127`）但未调用 `.focus()`。真实全流程键盘焦点序未测，FAIL |
| 读屏 | `aria-live` `68`、toast announce `119–120`；产品 nav label `64` | A0 状态变化、页标题、冲突双版本的实际播报未在 NVDA/VoiceOver/TalkBack 验证，FAIL |
| 200% 字体 | viewport preset 定义 `91`，应用 `133`；CSS 存在 `.text-200` | 仅模拟容器 text scale，不等于浏览器/OS 真实 200%；未验证不截断、不重叠、核心操作无需横滚，FAIL |
| reduced motion | review prototype `34` 行禁用 transition/animation 并隐藏 Pulse 环 | 未在真实浏览器切换媒体特性并完成闭环；V6 未发现 `prefers-reduced-motion`，且含 canvas/粒子/庆祝动画，P0 无障碍风险，FAIL |
| 触控替代 | Future T14 自述等效路径 `171`；Pulse 等效按钮 `159` | V6 大量 `div onclick`/滑动/触摸交互，机械计数 `onclick=` 等命中 253 行；真实键盘等效不足，FAIL |

D3/D4 明示结论：review prototype 自己在 `69` 行声明“内部自检属于 D0–D2，不构成真实 D3/D4”；`T-V02-040..042` 和 `LF-V02-001..008` 也要求真实参与者/辅助技术。本环境未找到 Chrome/Edge/Chromium 可执行程序，无法执行真实浏览器或辅助技术任务，因此 **D3/D4 = FAIL（P0 阻断）**。

## 8. P0 专项扫描与安全快检

### 8.1 团队视觉绝对规则

| 扫描项 | V6 | review prototype | 裁决 |
|---|---:|---:|---|
| emoji 范围逐行命中 | 306 行 | 0 行 | V6 大量 emoji 被用作按钮、导航/设置、状态及内容图标；示例 `2629`、`2636–2646`、`2982`、`3093`、`3501–3560`、`3614–3623`。按团队绝对规则为 **P0** |
| 紫色→粉色渐变 | 0 | 0 | 通过静态扫描 |
| AI 模板占位（Welcome to/Lorem ipsum/Sign up today） | 0 | 0 | 通过静态扫描 |

注意：V6 的 306 是“含 emoji 的行数”，不等于唯一 emoji 数。即使扣除文本装饰，已明确存在功能图标用法，因此无需争议计数即可判 P0。

### 8.2 安全与数据真实性

- **P0 XSS：**V6 `4446`/`4452` 将用户输入 `userMsg` 未转义拼进 `innerHTML`。输入 `<img src=x onerror=alert(1)>` 可构成 DOM XSS 风险；未在浏览器执行 payload，但静态数据流已足以阻断。
- **P0 RPE 真实性：**V6 `3737`、`4602–4607` 把跳过解释为使用上次 RPE；合同要求保存 `missing`，不得复用历史。
- **P0 静默本地保存失败：**review prototype `122`、`194`、`202` 吞掉 localStorage 异常；UI 可继续显示保存成功，违反输入不丢与可观测错误。
- 纯静态 HTML 不涉及服务端 SQL/CSRF/JWT/API 越权，不能据此判相关 OWASP 项通过；这里只审可见前端攻击面。

## 9. 测试完整性反作弊门

| 检测项 | 机械结果 | 判定 |
|---|---|---|
| 测试文件删除 | `git diff --name-status HEAD~1 -- test/ **/*.test.* **/*.spec.*` 零输出 | 未发现删除 |
| 断言下降 | 当前 13 个 Dart 测试文件、42 test、98 expect；最近提交无测试 diff | 未发现下降，但没有完整的逐历史文件断言基线脚本产物 |
| skip/xfail/.only/focus 新增 | diff 扫描新增数 0；当前文件扫描 0 | 通过 |
| 硬编码断言 | 本轮未修改测试；未逐条开展变异/held-out | **未证明通过** |
| 框架配置篡改 | `git diff HEAD~1 -- pubspec.yaml analysis_options.yaml` 零输出 | 未发现篡改 |

完整性门结论：未发现删测、skip 或门禁篡改；但缺少作者不可改的 held-out、变异杀手测试与 HTML E2E，因此只能判“无已见作弊信号”，不能用 42 绿测放行原型。

## 10. 42 个 S0 测试与 55 个 V0.2 Test ID 的关系

机械证据：

- `test/core/**`：13 个文件，42 个 `test(`，98 个 `expect(`，0 skip/focus。
- `docs/spec/v0.2-test-traceability-v1.0.md`：机械解析得到 `T-V02-001..055` 共 55 个定义、55 个唯一 ID、0 缺失；合同原文在 `417` 行要求 55/55，在 `469–474` 行声明静态追踪结果。
- 55 Test ID 覆盖草案、画像、域/目标/里程碑、旅程、离线/幂等/冲突、安全出口、低保真与 A11y；42 S0 仅覆盖 `lib/core` 的早期纯 Dart 不变量。

**硬结论：42 ≠ 55。** 42 个 S0 测试不能替代、折抵或推断 55 个 V0.2 Test ID 已实现/执行，更不能替代 `T-V02-040..042`、`LF-V02-001..008` 的真实证据。当前环境执行 `flutter test` 与 `flutter analyze` 均失败：`flutter: command not found`，所以连“42/42 本轮复跑通过”也无法签字，只能引用仓库历史交接记录。

## 11. 失效模式核对

| 失效模式 | 结果 | 详情 |
|---|---|---|
| Happy-path 偏差 | FAIL | A0 有 happy path/fixture，但 assisted failure、真实 deep-link、版本冲突解决、存储失败用户恢复不完整 |
| 沉默逻辑错误 | FAIL | localStorage 异常被吞；V6 RPE 跳过复用历史；缺 held-out/变异验证 |
| 幻觉依赖接口 | FAIL（证据不足） | HTML 无外部依赖，但 Flutter 工具链不可用，无法构建/分析证明依赖存在性 |
| 缺失系统上下文 | FAIL | 无交付包级路由隔离、真实网络出口证据、完整浏览器存储/冲突语义 |
| 性能盲区 | FAIL | 未跑 Lighthouse、内存/长任务、320/200% 实机性能或容量测试 |
| 静默缺失 | FAIL | 无 HTML lint/build/browser console 门；V6/review runtime error 未验证 |

## 12. 生产就绪记分卡

目标档：Silver；总档取最低。

| 维度 | 档位 | 证据 |
|---|---|---|
| 测试 + 回归 | Bronze 以下 | 42 测试本轮不可执行；55 V0.2 Test ID 未实现/执行；D3/D4 缺失 |
| 契约 | Bronze | review prototype 对照较完整，但版本冲突、assisted failure、本地错误恢复与 V0.2 构建隔离未闭合 |
| 安全 | Bronze 以下 | V6 DOM XSS、emoji P0、RPE 真实性错误；真实网络出口未测 |
| 无障碍 | Bronze 以下 | 只有 D2 静态/fixture；真实键盘/读屏/200%/reduced motion 0 证据 |
| 性能 | Bronze 以下 | 无 Lighthouse/浏览器性能/容量数据 |
| 可观测 | Bronze | review prototype 有匿名日志/aria-live，但本地保存异常被吞；无 console/runtime 采集 |
| 发布安全 | Bronze 以下 | 无 V0.2/V6/Future 构建隔离与回退演练证据 |
| **总档（最低）** | **Bronze 以下** | 未达 Silver，不得商业生产交付 |

## 13. 阻断缺陷清单

| ID | 级别 | 描述 | 证据/复现 | 期望 |
|---|---|---|---|---|
| QA-P0-001 | P0 | V6 使用 emoji 作为功能图标 | 静态扫描 306 命中行；`2629`、`2982`、`3093`、`3501–3560`、`3614–3623` 等 | 使用锁定 SVG 图标库；扫描零功能图标命中 |
| QA-P0-002 | P0 | V6 AI 引导存在 DOM XSS 数据流 | `4451–4452`：输入值未经转义拼入 `innerHTML`；`4446` 继续拼接消息 | 使用 `textContent`/安全 DOM API 或严格转义，并新增回归用例 |
| QA-P0-003 | P0 | RPE 跳过复用历史值 | `3737`、`4602–4607` | 跳过必须保存 `missing`，不得复用历史 |
| QA-P0-004 | P0 | 本地保存异常被静默吞掉并可能显示成功 | review `122`、`194`、`202` | 保存失败进入明确 error/重试；不得声明已保存；输入仍留内存且可导出/重试 |
| QA-P0-005 | P0 | A0 assisted failure“输入不丢”只有文案，无可执行故障注入 | review `141`、`129–130` | 增加 timeout/limit/invalid fixture，证明失败前后输入 hash 相同且无正式结果 |
| QA-P0-006 | P0 | A0 版本冲突仅标签切换，无真实双版本/解决合同 | review `154`、`187` | stale base 拒绝、base/current 并列、无 LWW、用户解决与审计均可执行 |
| QA-P0-007 | P0 | 未激活域零展示只证明部分 UI 过滤 | review `124`、`145`、`186` | Repository/read model/指标/Agent context 全链路零占位证据 |
| QA-P0-008 | P0 | V0.2 构建级零半入口未证明 | V6 存在 Today/训练/Pulse/知识/模型；review Future 壳同文件存在 | 提供 V0.2 独立构建/路由清单与 DB 零对象/入口自动扫描 |
| QA-P0-009 | P0 | 真实浏览器、键盘、读屏、200% 字体、reduced motion 未执行 | 无浏览器可执行程序；`LF-V02-007` 证据缺失 | 在冻结平台矩阵真实执行并归档录屏、焦点日志、截图、版本 |
| QA-P0-010 | P0 | D3/D4 与真实参与者任务未执行 | review `69` 明示 D0–D2；55 合同的低保真证据仍 required | 完成 `LF-V02-001..008`，修复后复测且 P0=0 |
| QA-P0-011 | P0 | 55 个 V0.2 Test ID 未被实现/执行 | 只有 42 个 S0 test；flutter 命令不可用 | `T-V02-001..055` 有可追踪实现和结果；不可用工具链修复 |

## 14. 回归集更新要求

本轮只允许创建一个 QA 报告文件，未修改测试。阻断缺陷修复后至少沉淀：

| 新增回归用例 | 对应缺陷 | 建议路径 |
|---|---|---|
| emoji 功能图标静态门 | QA-P0-001 | `tests/regression/no-emoji-functional-icons.test.ts` |
| AI 输入 DOM XSS | QA-P0-002 | `tests/regression/ai-input-xss.test.ts` |
| RPE 跳过为 missing | QA-P0-003 | `tests/regression/rpe-skip-missing.test.ts` |
| localStorage quota/security error 不伪报成功 | QA-P0-004 | `tests/regression/local-save-failure.test.ts` |
| assisted failure 输入 hash 不变 | QA-P0-005 | 映射 `T-V02-005/006` |
| stale base 冲突与无 LWW | QA-P0-006 | 映射 `T-V02-013/014/046/047` |
| 未激活域全链路零展示 | QA-P0-007 | 映射 `T-V02-018/033` |
| V0.2 Won't Have 零路由/零对象 | QA-P0-008 | 映射 `T-V02-036` |

## 15. 机械命令记录

以下均在 `F:\AIPM\atlas-repo` 或显式绝对路径执行：

```bash
# 工作树与影响面
git -C "F:/AIPM/atlas-repo" status --short
git -C "F:/AIPM/atlas-repo" diff --stat
git -C "F:/AIPM/atlas-repo" log -1 --oneline

# 测试资产
git -C "F:/AIPM/atlas-repo" ls-files "test/**"
python -c '<统计 test_files/test_calls/expect_calls/skip_focus>'
# 结果：13 / 42 / 98 / 0

# 完整性差异
git -C "F:/AIPM/atlas-repo" diff --name-status HEAD~1 -- "test/" "**/*.test.*" "**/*.spec.*"
git -C "F:/AIPM/atlas-repo" diff HEAD~1 -- "test/" "**/*.test.*" "**/*.spec.*" | <新增 skip/focus 扫描>
git -C "F:/AIPM/atlas-repo" diff HEAD~1 -- pubspec.yaml analysis_options.yaml
# 结果：删除 0；新增 skip/focus 0；配置 diff 0

# P0 视觉/模板扫描
python -c '<逐行扫描 emoji、purple-pink、Welcome/Lorem/Sign up>'
# 结果：V6 emoji 306 行，review emoji 0；紫粉渐变 0；占位文案 0

# 纯本地扫描
python -c '<扫描 fetch/XHR/WebSocket/EventSource/axios/http(s)>'
# 结果：review 0；V6 仅 data:image 内 SVG namespace 假阳性，无显式网络调用

# V0.2 Test ID 完整性
python -c '<解析以 | `T-V02- 开头的定义行>'
# 结果：55 rows / 55 unique / T-V02-001..055 / missing=[]

# 本轮可执行门
flutter test
flutter analyze
# 结果：两者均失败，/usr/bin/bash: flutter: command not found

# 真实浏览器探测
where.exe chrome.exe || where.exe msedge.exe || where.exe chromium.exe
# 结果：零输出；不能执行 D3/D4
```

## 16. 最终裁决

```text
verdict: FAIL
blocking: QA-P0-001..011
advisory: 无；本报告未以风格偏好制造阻断项
production_readiness: Bronze 以下
release_recommendation: 不通过
```

**上线建议：不通过。** 当前 P0 非零，真实浏览器/D3/D4/辅助技术证据缺失，55 个 V0.2 Test ID 未执行，且 V6 存在 emoji 功能图标、DOM XSS 与 RPE 真实性缺陷。静态“纯本地零显式网络调用”与 review prototype 的 D2 合同实现是有效正向证据，但不足以抵消任何 P0。P0 全部修复、持久回归用例落盘、55 Test ID 全绿、`LF-V02-001..008` 真实复测通过且七维至少 Silver 后，方可重新申请放行。

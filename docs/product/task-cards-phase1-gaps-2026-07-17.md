# PrimeAtlas 三大硬缺口 Phase1 — 开发就绪任务卡清单

**日期**：2026-07-17
**类型**：任务卡清单 / 工程执行规格
**参与成员**：数析（数据分析师）、路径（路线图规划师）、析客（需求分析师）

---

## 📌 TL;DR（执行摘要）
- **核心目标**：将三大硬缺口补完 PRD 的 18 条需求 + 13 张埋点卡整合为开发就绪的任务卡清单，含验收标准/接口契约/依赖/估点/Sprint 归属。
- **关键产出**：44 张任务卡（模块开发 27 + 数据埋点 12 + 集成收口 5），P0 硬门槛 34 张 / ≈77.5 人日，覆盖 S0–S10 共 11 个双周 Sprint / 22 周。
- **关键决策**：M0 已完全冻结（默认主调=专业、身份角色 启程者→践行者→进阶者→掌控者、约束 B 默认开启、C4 生理数据 Phase1 即接入）；引擎类（T2/C1/P3）拆为契约/算法/集成/单测 4 张。
- **下一步**：S0 启动设计冻结 + 埋点基建 + 三引擎方案；待产品负责人确认口径差异（模块逐项 69 vs PRD 总括 79 人日）。

---

## 🎯 核心结论卡片

| 项目 | 内容 |
|------|------|
| 推荐方案 | 44 张开发就绪任务卡，按 S0–S10 串行+并行排期 |
| 优先级 | P0（34 张硬门槛，须全交付才能进红线验收） |
| 预期影响 | 解锁 Phase1 工程执行；三模块红线可验、可灰度上线 |
| 资源需求 | ≈6 人（前端2/算法1/数据1/设计1/内容1）/ ≈99 人日 / 约 5 个月 |
| 风险等级 | 中（埋点基建 S0 前置为单点故障；引擎滑期级联） |

---

## 一、S0 (W1–2) — M0：设计冻结 + 埋点基建 + 三引擎方案

### 【T2-1】调性引擎接口契约
- PRD编号: T2（调性引擎）| 估点: 1人日 | Sprint: S0 | 角色: 设计+算法 | 优先级: P0
- 描述: 定义调性状态机、切换请求/响应模型、健康带宽配置参数，作为 T2 引擎全部后续开发的设计基准。产出接口文档+状态机图，经设计 sign-off。
- 验收标准:
  ① ToneState 状态机定义完成，覆盖 启程者/践行者/进阶者/掌控者 四阶段身份×专业/温和/激励 三调性的合法状态空间
  ② ToneSwitchRequest/Response 接口定义完成，Response 包含 health_bandwidth 剩余量与 intervention 策略
  ③ HealthBandwidthConfig 参数定义完成（max_switches_per_session / cooldown_duration / warning_threshold）
  ④ 设计 sign-off 通过，接口文档入库
- 接口契约:
  ```
  ToneState { current_tone, session_anchor_tone, switch_count, last_switch_at }
  ToneSwitchRequest { target_tone, trigger(user_explicit|system_suggested|context_adaptive), context }
  ToneSwitchResponse { accepted, new_tone, health_bandwidth{remaining,threshold}, intervention(none|gentle_nudge|cooldown) }
  HealthBandwidthConfig { max_switches_per_session, cooldown_duration_ms, warning_threshold_pct }
  ```
- 依赖: 无（S0 起始）
- DoD(P0): 设计 sign-off✓ + 接口文档入库✓ + 状态机图评审✓

### 【C1-1】冲突检测引擎接口契约
- PRD编号: C1（冲突检测引擎）| 估点: 1.5人日 | Sprint: S0 | 角色: 设计+算法 | 优先级: P0
- 描述: 定义冲突检测请求/结果模型、冲突类型枚举、身体理由追溯结构、仲裁编排模型。产出接口文档+冲突分类树，经设计 sign-off。
- 验收标准:
  ① ConflictDetectionResult 接口定义完成，含 conflict_type/is_body_related/body_reason/body_reason_traceable_id/disposition
  ② disposition.blocked_user 恒 false 约束写入接口契约文档
  ③ conflict_type 枚举完整（goal_goal / goal_body / goal_resource / goal_identity）
  ④ Orchestration 模型定义完成，含 type(one_click_adopt|i_will_do_it|defer)/rationale/safety_channel_required
  ⑤ 设计 sign-off 通过
- 接口契约:
  ```
  ConflictDetectionResult { conflict_id, conflict_type, is_body_related, body_reason, body_reason_traceable_id, disposition{blocked_user:false, recommended_orchestration} }
  Orchestration { type, rationale, safety_channel_required }
  ```
- 依赖: 无（S0 起始）
- DoD(P0): 设计 sign-off✓ + 接口文档入库✓ + 冲突分类树评审✓

### 【P3-1】画像版本化引擎接口契约
- PRD编号: P3（画像版本化引擎）| 估点: 1人日 | Sprint: S0 | 角色: 设计+算法 | 优先级: P0
- 描述: 定义画像版本快照模型、版本差异结构、维度激活/停用模型。产出接口文档+版本流转图，经设计 sign-off。
- 验收标准:
  ① PortraitVersion 接口定义完成，含 version_id/snapshot/change_summary/consent_record_id
  ② VersionDiff 接口定义完成，含 changes[]/has_narratable_change
  ③ ProfileSnapshot 含 active_dimensions/inactive_dimensions 区分
  ④ 设计 sign-off 通过
- 接口契约:
  ```
  PortraitVersion { version_id, created_at, snapshot:ProfileSnapshot, change_summary, consent_record_id }
  VersionDiff { from_version, to_version, changes:FieldChange[], has_narratable_change }
  ProfileSnapshot { fields:Map, active_dimensions[], inactive_dimensions[] }
  ```
- 依赖: 无（S0 起始）
- DoD(P0): 设计 sign-off✓ + 接口文档入库✓ + 版本流转图评审✓

### 【TRK-M0-INFRA】埋点基建
- PRD编号: 数据专项 | 估点: 6人日 | Sprint: S0 | 角色: 数据 | 优先级: P0
- 描述: identity_event_bus 基建 + 6 事件 schema 定义 + 校验器 + 看板底座。为全部后续埋点卡提供基建底座。
- 验收标准:
  ① identity_event_bus 可用，支持事件发布/订阅/持久化
  ② 6 事件 schema 定义完成（tone_change / content_tone_tag / conflict_detected / arbitration_event / profile_field_update / identity_transition_event），均含字段类型+必填校验
  ③ 校验器可用，非法 payload 拒绝率=100%
  ④ 看板底座可用，支持按事件类型/时间维度查询
  ⑤ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish(event_type, payload) → EventReceipt; validate(event_type, payload) → ValidationResult
- 依赖: 无（S0 起始）
- DoD(P0): 数析 sign-off✓ + 校验器单测✓ + 看板底座演示✓

**S0 小计: 9.5人日**（模块 3.5 + 数据 6）

---

## 二、S1–S2 (W3–6) — M1：调性模块

### 【T1】默认调性设定 UI
- PRD编号: T1（默认调性设定）| 估点: 6人日 | Sprint: S1–S2 | 角色: 前端+设计 | 优先级: P0
- 描述: 用户可在设置页面选择默认主调（专业/温和/激励），系统据此锚定会话调性。约束 B 默认开启聚焦卖点。包含调性选择器、预览效果、保存确认完整端到端流程。
- 验收标准:
  ① Given 用户进入调性设定页面 When 选择默认主调并保存 Then 系统记录调性偏好，后续会话以此调性为锚点
  ② T-RL2: 同会话内内容层（文案/视觉/交互/推送）调性与锚定调性一致（consistent_with_anchor=true 占比≥95%）
  ③ 约束 B: 默认开启"聚焦卖点"调性，用户可手动切换
  ④ 调性切换埋点 TRK-T1 联调通过
- 接口契约: 消费 T2-3 集成 API（setTone / getToneState）
- 依赖: T2-2（算法）, T2-3（集成 API）, TRK-T1（埋点联调）
- DoD(P0): 代码评审✓ + 单测✓ + 集成含埋点联调✓ + 设计 sign-off✓ + 量化验收（consistent_with_anchor≥95%）✓

### 【T2-2】调性引擎核心算法
- PRD编号: T2（调性引擎-算法）| 估点: 2人日 | Sprint: S1 | 角色: 算法 | 优先级: P0
- 描述: 实现调性状态机核心逻辑、健康带宽检测算法、切换干预策略。基于 T2-1 契约实现算法层。
- 验收标准:
  ① T-RL1: 调性切换频率超健康带宽阈值时触发温和干预（gentle_nudge），非阻断
  ② 状态机正确处理三种调性间合法切换，非法转换拒绝率=100%
  ③ 健康带宽检测：switch_count > warning_threshold 时预警，> max_switches_per_session 时进入 cooldown
  ④ 量化：调性切换判定延迟 < 50ms；健康带宽检测准确率 > 98%
- 接口契约: 实现 ToneEngine.switchTone(req:ToneSwitchRequest):ToneSwitchResponse / ToneEngine.getHealthBandwidth():HealthBandwidth
- 依赖: T2-1（契约）
- DoD(P0): 代码评审✓ + 单测（覆盖率≥80%）✓ + 算法 sign-off✓ + 量化验收✓

### 【T2-3】调性引擎集成 API
- PRD编号: T2（调性引擎-集成）| 估点: 1人日 | Sprint: S2 | 角色: 算法+前端 | 优先级: P0
- 描述: 封装调性引擎为 REST API，供前端调用。包含 setTone / getToneState / getHealthBandwidth 三个端点，对接 identity_event_bus 触发 tone_change_event。
- 验收标准:
  ① REST API 可被前端正常调用，响应格式符合 T2-1 契约
  ② tone_change_event 埋点在每次调性切换时正确触发
  ③ 与 TRK-T1 埋点联调通过，payload 字段完整
  ④ API 错误码定义完整，异常场景不 crash
- 接口契约: POST /api/tone/switch → ToneSwitchResponse; GET /api/tone/state → ToneState; GET /api/tone/health → HealthBandwidth
- 依赖: T2-2（算法）, TRK-M0-INFRA（事件总线）
- DoD(P0): 代码评审✓ + 集成测试✓ + 埋点联调✓

### 【T2-4】调性引擎单测+压测
- PRD编号: T2（调性引擎-测试）| 估点: 1人日 | Sprint: S2 | 角色: 算法+QA | 优先级: P0
- 描述: 对调性引擎进行单元测试和压力测试，覆盖状态机全部路径、健康带宽边界、并发切换场景。
- 验收标准:
  ① 单测覆盖率 ≥ 80%，全部通过
  ② 压测：1000 次/秒并发切换无异常，无状态不一致
  ③ 边界用例覆盖：max_switches 达限、cooldown 期间切换、非法目标调性
  ④ 测试报告入库
- 接口契约: 无（测试卡）
- 依赖: T2-3（集成 API）
- DoD(P0): 测试报告✓ + 覆盖率报告✓ + 压测报告✓

### 【T3】调性内容评审
- PRD编号: T3（调性内容评审）| 估点: 4人日 | Sprint: S1–S2 | 角色: 内容+前端 | 优先级: P0
- 描述: 内容生成/展示时进行调性一致性检查，焦虑敏感内容触发量表评估。覆盖文案/视觉/交互/推送四层内容。
- 验收标准:
  ① T-RL3: 焦虑敏感内容（含威胁词）触发焦虑量表前后测，threat_word_hit 正确标记
  ② T-RL2: 内容层调性一致性检查，resolved_tone 与 session_anchor_tone 不一致时标记 consistent_with_anchor=false
  ③ 四层内容（copy/visual/interaction/push）均接入评审
  ④ 量化：内容评审延迟 < 200ms；焦虑量表触发准确率 > 90%
  ⑤ TRK-T2 / TRK-T3 埋点联调通过
- 接口契约: 消费 T2-3 API（getToneState）; 产出 content_tone_tag + anxiety_measure 事件
- 依赖: T2-3（集成 API）, TRK-T2, TRK-T3
- DoD(P0): 代码评审✓ + 单测✓ + 集成含埋点联调✓ + 内容 sign-off✓ + 量化验收✓

### 【T4】调性预览
- PRD编号: T4（调性预览）| 估点: 4人日 | Sprint: S2 | 角色: 前端 | 优先级: P1
- 描述: 用户在设定默认调性前可预览不同调性的内容效果，帮助决策。
- 验收标准:
  ① 预览页面展示三种调性下的示例内容（文案/视觉风格差异可见）
  ② 预览不触发实际调性切换，不产生 tone_change_event
  ③ 预览加载延迟 < 500ms
- 接口契约: 消费 T2-3 API（getToneState，只读模式）
- 依赖: T2-3（集成 API）
- DoD: 代码评审✓ + 功能测试✓

### 【T5】调性切换提示
- PRD编号: T5（调性切换提示）| 估点: 2人日 | Sprint: S2 | 角色: 前端 | 优先级: P1
- 描述: 调性切换时的温和提示（非阻断），告知用户当前调性已变更。
- 验收标准:
  ① 切换提示为非阻断式（toast/inline），不中断用户操作
  ② 提示内容包含切换前后调性名称
  ③ cooldown 期间提示健康带宽剩余量
- 接口契约: 消费 T2-3 API（ToneSwitchResponse.intervention）
- 依赖: T2-3（集成 API）
- DoD: 代码评审✓ + 功能测试✓

### 【TRK-T1】调性切换埋点
- PRD编号: 数据专项（T-RL1）| 估点: 1.5人日 | Sprint: S1 | 角色: 数据 | 优先级: P0
- 描述: tone_change_event → T-RL1 健康带宽看板。采集调性切换全链路数据。
- 验收标准:
  ① tone_change_event 在每次调性切换时正确触发
  ② payload 完整: from_tone / to_tone / trigger / blocked_by_system / unlock_path
  ③ T-RL1 健康带宽看板可用，展示切换频率/分布/cooldown 触发率
  ④ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("tone_change_event", {from_tone, to_tone, trigger, blocked_by_system, unlock_path})
- 依赖: TRK-M0-INFRA（基建）, T2-3（集成 API 触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓

### 【TRK-T2】内容调性标签埋点
- PRD编号: 数据专项（T-RL2）| 估点: 2人日 | Sprint: S1 | 角色: 数据 | 优先级: P0
- 描述: content_tone_tag → T-RL2 同会话守恒看板。采集内容层调性一致性数据。
- 验收标准:
  ① content_tone_tag 在内容评审时正确标记
  ② payload 完整: session_anchor_tone / resolved_tone / layer(copy|visual|interaction|push) / consistent_with_anchor
  ③ T-RL2 同会话守恒看板可用，展示一致率/偏离分布/层维度拆分
  ④ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("content_tone_tag", {session_anchor_tone, resolved_tone, layer, consistent_with_anchor})
- 依赖: TRK-M0-INFRA, T3（内容评审触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓

### 【TRK-T3】焦虑量表埋点
- PRD编号: 数据专项（T-RL3）| 估点: 1人日 | Sprint: S2 | 角色: 数据 | 优先级: P0
- 描述: 焦虑量表前后测+内容评审 → T-RL3 看板。采集焦虑敏感内容评估数据。
- 验收标准:
  ① 焦虑量表事件在 content_review 触发时正确记录
  ② payload 完整: measure_type / tone_context / score / threat_word_hit
  ③ T-RL3 看板可用，展示量表分布/威胁词命中率/调性上下文关联
  ④ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("anxiety_measure", {measure_type, tone_context, score, threat_word_hit})
- 依赖: TRK-M0-INFRA, T3（触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓

### 【TRK-V3】调性防虚荣指标
- PRD编号: 数据专项（验证指标）| 估点: 1.5人日 | Sprint: S1–S2 | 角色: 数据 | 优先级: P0
- 描述: 调性切换率×健康带宽非零（防虚荣），确保调性切换是真实有效的而非空转。M0 定义 schema，M1 持续采集。
- 验收标准:
  ① 指标定义：有效切换率 = health_bandwidth.remaining > 0 的切换次数 / 总切换次数
  ② 防虚荣逻辑：cooldown 期间的切换不计入有效切换
  ③ 看板可用，展示有效切换率趋势
  ④ 数析契约 sign-off 通过
- 接口契约: 消费 tone_change_event 流，计算防虚荣指标
- 依赖: TRK-M0-INFRA, TRK-T1（事件源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓

**S1–S2 小计: 26人日**（模块 20 + 数据 6）

---

## 三、S3 (W7–8) — 过渡：T6 + C1 引擎启动

### 【T6】调性历史记录
- PRD编号: T6（调性历史记录）| 估点: 1人日 | Sprint: S3 | 角色: 前端 | 优先级: P2
- 描述: 记录调性切换历史，供用户回溯查看。
- 验收标准:
  ① 历史列表展示切换时间/前后调性/触发原因
  ② 支持按时间范围筛选
  ③ 历史数据从 tone_change_event 流读取
- 接口契约: GET /api/tone/history → ToneSwitchRecord[]
- 依赖: TRK-T1（事件源）, T2-3（API）
- DoD: 代码评审✓ + 功能测试✓

### 【C1-2】冲突检测核心算法
- PRD编号: C1（冲突检测引擎-算法）| 估点: 3人日 | Sprint: S3–S4 | 角色: 算法 | 优先级: P0
- 描述: 实现冲突检测核心算法：目标冲突识别、身体冲突判定、理由追溯链生成、仲裁编排推荐。基于 C1-1 契约实现算法层。
- 验收标准:
  ① C-RL1: 冲突检出率 ≥ 80%（对比标注数据集）；误报率 < 5%
  ② C-RL3: 身体冲突 is_body_related 判定准确率 > 90%；body_reason_traceable_id 100% 可追溯
  ③ disposition.blocked_user 恒 false（非阻断设计）
  ④ recommended_orchestration 推荐合理性 > 85%（人工评审）
  ⑤ 量化：单次冲突检测延迟 < 100ms
- 接口契约: 实现 ConflictDetector.detect(req:ConflictDetectionRequest):ConflictDetectionResult
- 依赖: C1-1（契约）
- DoD(P0): 代码评审✓ + 单测（覆盖率≥80%）✓ + 算法 sign-off✓ + 量化验收✓

**S3 小计: 4人日**（模块 4）

---

## 四、S4–S5 (W9–12) — M2：冲突模块

### 【C1-3】冲突检测集成 API
- PRD编号: C1（冲突检测引擎-集成）| 估点: 2人日 | Sprint: S4 | 角色: 算法+前端 | 优先级: P0
- 描述: 封装冲突检测引擎为 REST API，供前端调用。对接 identity_event_bus 触发 conflict_detected 事件。
- 验收标准:
  ① REST API 可被前端正常调用，响应格式符合 C1-1 契约
  ② conflict_detected 埋点在每次冲突检出时正确触发
  ③ 与 TRK-C1 埋点联调通过，payload 字段完整
  ④ API 错误码定义完整
- 接口契约: POST /api/conflict/detect → ConflictDetectionResult; GET /api/conflict/{id} → ConflictDetail
- 依赖: C1-2（算法）, TRK-M0-INFRA
- DoD(P0): 代码评审✓ + 集成测试✓ + 埋点联调✓

### 【C1-4】冲突检测单测+压测
- PRD编号: C1（冲突检测引擎-测试）| 估点: 1.5人日 | Sprint: S5 | 角色: 算法+QA | 优先级: P0
- 描述: 对冲突检测引擎进行单元测试和压力测试，覆盖全部冲突类型、身体理由追溯、并发检测场景。
- 验收标准:
  ① 单测覆盖率 ≥ 80%，全部通过
  ② 压测：100 并发冲突检测无异常，无漏检
  ③ 边界用例：无冲突场景、多冲突同时触发、身体冲突安全通道触发
  ④ 测试报告入库
- 接口契约: 无（测试卡）
- 依赖: C1-3（集成 API）
- DoD(P0): 测试报告✓ + 覆盖率报告✓ + 压测报告✓

### 【C2】冲突仲裁界面
- PRD编号: C2（冲突仲裁界面）| 估点: 4人日 | Sprint: S4–S5 | 角色: 前端+设计 | 优先级: P0
- 描述: 冲突发生时的仲裁选择界面，用户可选择"一键采纳"或"自行处理"。展示冲突详情、推荐编排、rationale，保留覆盖入口。
- 验收标准:
  ① C-RL2: 仲裁过程透明——rationale 完整展示（rationale_display_complete=true）
  ② C-RL2: 保留覆盖入口可见（retained_override_entry=true），用户可选"自行处理"
  ③ 两个选项（one_click_adopt / i_will_do_it）均可点击，选择后触发 arbitration_event
  ④ 非阻断式：用户可关闭仲裁卡片暂不决策
  ⑤ TRK-C2 埋点联调通过
- 接口契约: 消费 C1-3 API（detect）; 产出 arbitration_event
- 依赖: C1-3（集成 API）, TRK-C2
- DoD(P0): 代码评审✓ + 单测✓ + 集成含埋点联调✓ + 设计 sign-off✓ + 量化验收（rationale_display_complete=100%）✓

### 【C3】冲突展示卡片
- PRD编号: C3（冲突展示卡片）| 估点: 6人日 | Sprint: S4–S5 | 角色: 前端+设计 | 优先级: P0
- 描述: 冲突信息的可视化展示组件，含冲突类型图标、身体理由追溯链路、推荐编排摘要。作为 C2 仲裁界面和日常冲突提示的共用基础组件。
- 验收标准:
  ① 冲突类型可视化区分（goal_goal / goal_body / goal_resource / goal_identity）
  ② 身体冲突时展示 body_reason + 可追溯链路（body_reason_traceable_id 可点击展开）
  ③ 非阻断式展示，不阻塞用户当前操作
  ④ 卡片支持折叠/展开，信息层级清晰
  ⑤ 设计 sign-off 通过
- 接口契约: 消费 C1-3 API（ConflictDetectionResult）
- 依赖: C1-3（集成 API）
- DoD(P0): 代码评审✓ + 单测✓ + 设计 sign-off✓ + 量化验收（body_reason 展示完整率=100%）✓

### 【C4】身体冲突安全通道
- PRD编号: C4（身体冲突安全通道）| 估点: 4人日 | Sprint: S4–S5 | 角色: 前端+内容+合规 | 优先级: P1
- 描述: 身体相关冲突接入安全通道，提供 consent 流程和合规处理。Phase1 即接入（M0 决策：需 consent + 合规）。
- 验收标准:
  ① C-RL3: is_body_related=true 时自动路由至安全通道
  ② consent 流程完整：用户明确同意后方可继续，consent_record_id 正确生成
  ③ 合规检查：安全通道内容经合规审核，不含违规建议
  ④ 安全通道内容与普通冲突处理路径隔离
  ⑤ blocked_user 恒 false（安全通道非阻断，而是提供专业引导）
- 接口契约: POST /api/conflict/{id}/safety-channel → SafetyChannelResult{consent_record_id, guidance, compliance_checked}
- 依赖: C1-3（集成 API）, C1-2（身体冲突判定）
- DoD: 代码评审✓ + 合规审核✓ + consent 流程测试✓

### 【C5】冲突覆盖保留
- PRD编号: C5（冲突覆盖保留）| 估点: 2人日 | Sprint: S5 | 角色: 前端 | 优先级: P1
- 描述: 用户可保留/覆盖系统仲裁建议，选择"自行处理"后记录 user_initiated_edit。
- 验收标准:
  ① C-RL2: 用户选择"自行处理"后，retained_override_entry=true
  ② user_initiated_edit 正确记录用户手动修改内容
  ③ 覆盖操作不删除原推荐，保留可对比
  ④ arbitration_event 中 chosen_track=i_will_do_it 时 user_initiated_edit 须有值
- 接口契约: POST /api/conflict/{id}/override → OverrideResult{retained_override_entry, user_initiated_edit}
- 依赖: C2（仲裁界面）, C1-3（集成 API）
- DoD: 代码评审✓ + 功能测试✓

### 【TRK-C1】冲突检测埋点
- PRD编号: 数据专项（C-RL1+C-RL3）| 估点: 2.5人日 | Sprint: S4–S5 | 角色: 数据 | 优先级: P0
- 描述: conflict_detected → C-RL1(非阻断)+C-RL3(身体理由) 看板。
- 验收标准:
  ① conflict_detected 在每次冲突检出时正确触发
  ② payload 完整: conflict_type / is_body_related / body_reason / body_reason_traceable_id / disposition(blocked_user恒false) / recommended_orchestration
  ③ C-RL1 看板可用：冲突检出率/类型分布/非阻断率
  ④ C-RL3 看板可用：身体冲突占比/理由追溯率/安全通道触发率
  ⑤ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("conflict_detected", {conflict_type, is_body_related, body_reason, body_reason_traceable_id, disposition, recommended_orchestration})
- 依赖: TRK-M0-INFRA, C1-3（触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓

### 【TRK-C2】仲裁事件埋点
- PRD编号: 数据专项（C-RL2）| 估点: 2人日 | Sprint: S4–S5 | 角色: 数据 | 优先级: P0
- 描述: arbitration_event → C-RL2 透明+保留覆盖看板。
- 验收标准:
  ① arbitration_event 在用户做出仲裁选择时正确触发
  ② payload 完整: conflict_id / chosen_track(one_click_adopt|i_will_do_it) / rationale_display_complete / retained_override_entry / user_initiated_edit
  ③ C-RL2 看板可用：采纳率/主动编辑率/rationale 展示完整率/覆盖保留率
  ④ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("arbitration_event", {conflict_id, chosen_track, rationale_display_complete, retained_override_entry, user_initiated_edit})
- 依赖: TRK-M0-INFRA, C2（触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓

### 【TRK-V1】冲突防虚荣指标
- PRD编号: 数据专项（验证指标）| 估点: 2人日 | Sprint: S4–S5 | 角色: 数据 | 优先级: P0
- 描述: 冲突检出率×有效冲突率（防虚荣），确保检出的冲突是真实有效的。
- 验收标准:
  ① 指标定义：有效冲突率 = 用户产生交互的冲突数 / 检出冲突总数
  ② 防虚荣逻辑：无人交互的冲突不计入有效冲突
  ③ 看板可用，展示有效冲突率趋势
  ④ 数析契约 sign-off 通过
- 接口契约: 消费 conflict_detected + arbitration_event 流，计算防虚荣指标
- 依赖: TRK-M0-INFRA, TRK-C1, TRK-C2
- DoD(P0): 数析 sign-off✓ + 看板演示✓

### 【TRK-V2】仲裁防虚荣指标
- PRD编号: 数据专项（验证指标）| 估点: 2人日 | Sprint: S4–S5 | 角色: 数据 | 优先级: P0
- 描述: 仲裁采纳率×主动编辑率（防虚荣），确保仲裁是真实有效的而非自动采纳空转。
- 验收标准:
  ① 指标定义：有效仲裁率 = (one_click_adopt 中有后续行为 + i_will_do_it 中有 user_initiated_edit) / 总仲裁数
  ② 防虚荣逻辑：无后续行为的采纳不计入有效仲裁
  ③ 看板可用，展示有效仲裁率趋势
  ④ 数析契约 sign-off 通过
- 接口契约: 消费 arbitration_event 流，计算防虚荣指标
- 依赖: TRK-M0-INFRA, TRK-C2
- DoD(P0): 数析 sign-off✓ + 看板演示✓

**S4–S5 小计: 28人日**（模块 19.5 + 数据 8.5）

---

## 五、S6 (W13–14) — 过渡：C6 + P3 版本化启动

### 【C6】冲突历史记录
- PRD编号: C6（冲突历史记录）| 估点: 1人日 | Sprint: S6 | 角色: 前端 | 优先级: P2
- 描述: 记录冲突处理历史，供用户回溯查看。
- 验收标准:
  ① 历史列表展示冲突时间/类型/仲裁选择/处理结果
  ② 支持按冲突类型筛选
  ③ 历史数据从 conflict_detected + arbitration_event 流读取
- 接口契约: GET /api/conflict/history → ConflictRecord[]
- 依赖: TRK-C1, TRK-C2（事件源）, C1-3（API）
- DoD: 代码评审✓ + 功能测试✓

### 【P3-2】画像版本化核心算法
- PRD编号: P3（画像版本化引擎-算法）| 估点: 1.5人日 | Sprint: S6–S7 | 角色: 算法 | 优先级: P0
- 描述: 实现画像版本管理算法：版本快照生成、版本差异计算、维度激活/停用管理、回溯查询。基于 P3-1 契约实现算法层。
- 验收标准:
  ① 版本快照在画像变更时自动生成，snapshot 数据完整
  ② VersionDiff 正确计算字段级差异，has_narratable_change 准确判定
  ③ P-RL1: inactive_dimensions 的 occupied_storage=false（未用维度不占存储）
  ④ 量化：版本对比延迟 < 200ms；回溯查询无数据丢失
- 接口契约: 实现 PortraitVersioner.createVersion() / diff(from,to) / rollback(version_id) / getDimensionStatus()
- 依赖: P3-1（契约）
- DoD(P0): 代码评审✓ + 单测（覆盖率≥80%）✓ + 算法 sign-off✓ + 量化验收✓

**S6 小计: 2.5人日**（模块 2.5）

---

## 六、S7–S8 (W15–18) — M3：画像模块

### 【P3-3】画像版本化集成 API
- PRD编号: P3（画像版本化引擎-集成）| 估点: 1人日 | Sprint: S7 | 角色: 算法+前端 | 优先级: P0
- 描述: 封装画像版本化引擎为 REST API，供前端调用。对接 identity_event_bus 触发 identity_transition_event。
- 验收标准:
  ① REST API 可被前端正常调用，响应格式符合 P3-1 契约
  ② identity_transition_event 在身份角色变化时正确触发
  ③ 与 TRK-P2 埋点联调通过
  ④ API 错误码定义完整
- 接口契约: GET /api/portrait/version/{id} → PortraitVersion; GET /api/portrait/diff → VersionDiff; POST /api/portrait/rollback → RollbackResult
- 依赖: P3-2（算法）, TRK-M0-INFRA
- DoD(P0): 代码评审✓ + 集成测试✓ + 埋点联调✓

### 【P3-4】画像版本化单测+压测
- PRD编号: P3（画像版本化引擎-测试）| 估点: 0.5人日 | Sprint: S8 | 角色: 算法+QA | 优先级: P0
- 描述: 对画像版本化引擎进行单元测试和压力测试。
- 验收标准:
  ① 单测覆盖率 ≥ 80%，全部通过
  ② 压测：100 次版本快照生成无异常，无数据丢失
  ③ 边界用例：空快照、大规模字段变更、跨版本回溯
  ④ 测试报告入库
- 接口契约: 无（测试卡）
- 依赖: P3-3（集成 API）
- DoD(P0): 测试报告✓ + 覆盖率报告✓

### 【P1】画像字段管理
- PRD编号: P1（画像字段管理）| 估点: 6人日 | Sprint: S7–S8 | 角色: 前端+设计 | 优先级: P0
- 描述: 画像字段的增删改查 UI，所有修改需用户明确确认。系统不自动修改画像字段。
- 验收标准:
  ① P-RL2: 系统不自动修改画像字段——confirm_source 为 system_auto 的占比须 = 0
  ② 字段修改需用户明确确认，consent_record_id 正确关联
  ③ 字段修改触发 profile_field_update 事件，old_value/new_value 正确记录
  ④ portrait_version 在每次修改后递增
  ⑤ TRK-P1 埋点联调通过
  ⑥ 量化：confirm_source=system_auto 占比 = 0（硬性红线）
- 接口契约: 消费 P3-3 API（createVersion）; 产出 profile_field_update 事件
- 依赖: P3-3（集成 API）, TRK-P1
- DoD(P0): 代码评审✓ + 单测✓ + 集成含埋点联调✓ + 设计 sign-off✓ + 量化验收（system_auto占比=0）✓

### 【P2】身份叙事渲染
- PRD编号: P2（身份叙事渲染）| 估点: 5人日 | Sprint: S7–S8 | 角色: 前端+内容 | 优先级: P0
- 描述: 根据画像变化动态渲染/隐藏身份叙事。身份角色命名：启程者→践行者→进阶者→掌控者。叙事仅在发生可叙述变化时显示。
- 验收标准:
  ① P-RL3: narrative_shown == has_narratable_change（严格相等）
  ② 身份角色转换时（如启程者→践行者）展示叙事内容，change_summary 正确生成
  ③ 无可叙述变化时叙事不展示（narrative_shown=false）
  ④ transition_id/from_role/to_role 正确记录
  ⑤ TRK-P2 埋点联调通过
  ⑥ 量化：narrative_shown==has_narratable_change 一致率 = 100%
- 接口契约: 消费 P3-3 API（VersionDiff）; 产出 identity_transition_event
- 依赖: P3-3（集成 API）, TRK-P2
- DoD(P0): 代码评审✓ + 单测✓ + 集成含埋点联调✓ + 内容 sign-off✓ + 量化验收（一致率=100%）✓

### 【P4】画像维度管理
- PRD编号: P4（画像维度管理）| 估点: 4人日 | Sprint: S7–S8 | 角色: 前端 | 优先级: P1
- 描述: 画像维度的启用/停用管理 UI。未用维度不渲染、不占存储。
- 验收标准:
  ① P-RL1: is_active=false 的维度 rendered=false（不渲染）
  ② P-RL1: is_active=false 的维度 occupied_storage=false（不占存储）
  ③ 维度启停需用户确认
  ④ dimension_data_presence 埋点正确触发
  ⑤ 量化：rendered==is_active 一致率 = 100%
- 接口契约: 消费 P3-3 API（getDimensionStatus）; 产出 dimension_data_presence 事件
- 依赖: P3-3（集成 API）, TRK-P3
- DoD: 代码评审✓ + 功能测试✓ + 量化验收（rendered==is_active 一致率=100%）✓

### 【P5】画像确认流程
- PRD编号: P5（画像确认流程）| 估点: 2人日 | Sprint: S8 | 角色: 前端 | 优先级: P1
- 描述: 画像修改的确认流程，记录 consent。
- 验收标准:
  ① P-RL2: consent 记录完整，consent_record_id 正确生成并关联至 portrait_version
  ② 确认流程展示变更摘要（change_summary），用户可对比 old_value/new_value
  ③ 用户可拒绝修改，拒绝后不生成新版本
- 接口契约: POST /api/portrait/confirm → ConfirmResult{consent_record_id, portrait_version, applied}
- 依赖: P1（字段管理）, P3-3（集成 API）
- DoD: 代码评审✓ + 功能测试✓

### 【TRK-P1】画像字段更新埋点
- PRD编号: 数据专项（P-RL2）| 估点: 1.5人日 | Sprint: S7–S8 | 角色: 数据 | 优先级: P0
- 描述: profile_field_update → P-RL2 不自动改看板。
- 验收标准:
  ① profile_field_update 在画像字段修改时正确触发
  ② payload 完整: field_name / old_value / new_value / confirm_source(user_explicit|user_override|system_auto) / consent_record_id / portrait_version
  ③ confirm_source=system_auto 占比须 = 0（硬性红线监控）
  ④ P-RL2 看板可用：字段变更分布/确认来源分布/system_auto 占比告警
  ⑤ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("profile_field_update", {field_name, old_value, new_value, confirm_source, consent_record_id, portrait_version})
- 依赖: TRK-M0-INFRA, P1（触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓ + system_auto=0 告警配置✓

### 【TRK-P2】身份转换埋点
- PRD编号: 数据专项（P-RL3）| 估点: 1人日 | Sprint: S7–S8 | 角色: 数据 | 优先级: P0
- 描述: identity_transition_event → P-RL3 叙事按变化显隐看板。
- 验收标准:
  ① identity_transition_event 在身份角色变化时正确触发
  ② payload 完整: transition_id / from_role / to_role / has_narratable_change / narrative_shown / change_summary
  ③ narrative_shown 须 == has_narratable_change（硬性红线监控）
  ④ P-RL3 看板可用：角色转换分布/叙事展示率/显隐一致率
  ⑤ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("identity_transition_event", {transition_id, from_role, to_role, has_narratable_change, narrative_shown, change_summary})
- 依赖: TRK-M0-INFRA, P2（触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓ + narrative_shown==has_narratable_change 告警配置✓

### 【TRK-P3】维度数据存在性埋点
- PRD编号: 数据专项（P-RL1）| 估点: 1人日 | Sprint: S7–S8 | 角色: 数据 | 优先级: P0
- 描述: dimension_data_presence → P-RL1 未用维度不占位看板。
- 验收标准:
  ① dimension_data_presence 在维度状态变化时正确触发
  ② payload 完整: dimension / is_active / rendered / occupied_storage
  ③ rendered 须 == is_active；is_active=false 时 occupied_storage 须 == false（硬性红线监控）
  ④ P-RL1 看板可用：维度激活分布/渲染一致率/存储占用合规率
  ⑤ 数析契约 sign-off 通过
- 接口契约: identity_event_bus.publish("dimension_data_presence", {dimension, is_active, rendered, occupied_storage})
- 依赖: TRK-M0-INFRA, P4（触发源）
- DoD(P0): 数析 sign-off✓ + 看板演示✓ + payload 校验通过✓ + rendered==is_active 告警配置✓

**S7–S8 小计: 22人日**（模块 18.5 + 数据 3.5）

---

## 七、S9 (W19–20) — 过渡：P6 + 集成联调 + 埋点对账

### 【P6】画像历史回溯
- PRD编号: P6（画像历史回溯）| 估点: 1人日 | Sprint: S9 | 角色: 前端 | 优先级: P2
- 描述: 画像变更历史记录，支持版本对比和回溯查看。
- 验收标准:
  ① 历史列表展示版本时间/变更摘要/角色转换
  ② 支持两版本对比，展示字段级差异
  ③ 历史数据从 profile_field_update + identity_transition_event 流读取
- 接口契约: GET /api/portrait/history → PortraitVersion[]; GET /api/portrait/compare?a={v1}&b={v2} → VersionDiff
- 依赖: TRK-P1, TRK-P2（事件源）, P3-3（API）
- DoD: 代码评审✓ + 功能测试✓

### 【INT-1】三模块集成联调
- PRD编号: 集成收口 | 估点: 2人日 | Sprint: S9 | 角色: QA+前端+算法 | 优先级: P0
- 描述: 调性/冲突/画像三模块端到端集成联调，验证跨模块交互场景（如调性切换触发冲突检测、画像变更触发叙事渲染等）。
- 验收标准:
  ① 跨模块场景：调性切换→内容评审→冲突检测 全链路畅通
  ② 跨模块场景：画像字段修改→版本快照→叙事渲染 全链路畅通
  ③ 跨模块场景：身体冲突→安全通道→consent→画像更新 全链路畅通
  ④ 三模块指标看板（T-RL1/2/3 + C-RL1/2/3 + P-RL1/2/3）均可正常展示
  ⑤ 集成测试报告入库
- 接口契约: 无（集成测试卡）
- 依赖: 全部 P0 模块卡 + 全部 TRK 卡
- DoD(P0): 集成测试报告✓ + 跨模块场景演示✓

### 【INT-2】埋点对账
- PRD编号: 集成收口 | 估点: 1人日 | Sprint: S9 | 角色: 数据 | 优先级: P0
- 描述: 全部 12 张埋点卡的事件流对账，验证事件覆盖率、payload 完整性、看板数据准确性。
- 验收标准:
  ① 12 个事件类型均有数据流入，无遗漏
  ② 各事件 payload 字段完整率 = 100%
  ③ 看板数据与原始事件流一致，无偏差
  ④ 防虚荣指标（V1/V2/V3）计算逻辑验证通过
  ⑤ 数析契约最终 sign-off 通过
- 接口契约: 无（对账卡）
- 依赖: 全部 TRK 卡
- DoD(P0): 对账报告✓ + 数析最终 sign-off✓

**S9 小计: 4人日**（模块 1 + 缓冲 3）

---

## 八、S10 (W21–22) — M4：P2 收口 + 缺陷清零 + 灰度上线

### 【INT-3】P2 项收口验证
- PRD编号: 集成收口 | 估点: 0.5人日 | Sprint: S10 | 角色: QA | 优先级: P2
- 描述: T6/C6/P6 三张 P2 卡的最终收口验证，确认功能完整可用。
- 验收标准:
  ① T6 调性历史记录功能验证通过
  ② C6 冲突历史记录功能验证通过
  ③ P6 画像历史回溯功能验证通过
  ④ 三项 P2 功能不阻塞灰度上线
- 接口契约: 无（验证卡）
- 依赖: T6, C6, P6
- DoD: 验证报告✓

### 【INT-4】缺陷清零
- PRD编号: 集成收口 | 估点: 1.5人日 | Sprint: S10 | 角色: 全角色 | 优先级: P0
- 描述: 灰度前的缺陷清零，P0/P1 缺陷须全部修复，P2 缺陷评估后决定是否修复或记录为已知问题。
- 验收标准:
  ① P0 缺陷数 = 0（阻塞性缺陷全部修复）
  ② P1 缺陷数 ≤ 3（非阻塞性，有 workaround）
  ③ P2 缺陷已评估并记录
  ④ 回归测试全部通过
- 接口契约: 无（修复卡）
- 依赖: INT-1, INT-2
- DoD(P0): 缺陷清零报告✓ + 回归测试通过✓

### 【INT-5】灰度上线
- PRD编号: 集成收口 | 估点: 1人日 | Sprint: S10 | 角色: 全角色 | 优先级: P0
- 描述: 灰度上线，按比例放量，监控三模块红线指标。
- 验收标准:
  ① 灰度比例：5% → 10% → 25% → 50% → 100%，每级观察 ≥ 2h
  ② 灰度期间三模块红线指标（T-RL1/2/3 + C-RL1/2/3 + P-RL1/2/3）均在阈值内
  ③ 灰度期间无 P0 级线上事故
  ④ 回滚预案就绪，可一键回滚至灰度前版本
- 接口契约: 无（上线卡）
- 依赖: INT-4（缺陷清零）
- DoD(P0): 灰度上线报告✓ + 红线指标监控确认✓

**S10 小计: 3人日**（缓冲 3）

---

## 九、汇总统计

### 9.1 总卡数
| 类别 | 卡数 |
|------|------|
| 模块开发卡（含引擎拆分） | 27 |
| 数据埋点卡（TRK-*） | 12 |
| 集成收口卡（INT-*） | 5 |
| **总计** | **44** |

### 9.2 各 Sprint 负载人日
| Sprint | 时间 | 模块 | 数据 | 缓冲 | 小计 |
|--------|------|------|------|------|------|
| S0 | W1–2 | 3.5 | 6 | 0 | 9.5 |
| S1–S2 | W3–6 | 20 | 6 | 0 | 26 |
| S3 | W7–8 | 4 | 0 | 0 | 4 |
| S4–S5 | W9–12 | 19.5 | 8.5 | 0 | 28 |
| S6 | W13–14 | 2.5 | 0 | 0 | 2.5 |
| S7–S8 | W15–18 | 18.5 | 3.5 | 0 | 22 |
| S9 | W19–20 | 1 | 0 | 3 | 4 |
| S10 | W21–22 | 0 | 0 | 3 | 3 |
| **合计** | | **69** | **24** | **6** | **99** |

### 9.3 总人日拆分（口径说明）
| 口径 | 人日 | 说明 |
|------|------|------|
| 模块开发 | 69 | 18 条 PRD 需求按逐项估点加总（T=22 + C=25 + P=22）|
| 数据埋点专项 | 24 | 12 张 TRK 卡逐项估点加总，与模块开发单列不重复 |
| 缓冲 | 6 | INT-1~INT-5 集成收口 |
| **总计** | **99** | |

> **口径差异说明**：
> - PRD 原文称"模块开发≈79人日"，逐项加总为 69（差 10 人日）。差额可能含模块级设计规范/集成联调 overhead 未逐项列出。建议以逐项估点 69 为基准，差额 10 人日纳入 Sprint 级缓冲统筹。
> - PRD 原文称"数据埋点≈23人日"，逐项加总为 24（差 1 人日），属四舍五入误差。
> - PRD 原文称"P0共≈51人日"，逐项加总 P0 模块为 48（T1+T2+T3=15, C1+C2+C3=18, P1+P2+P3=15），差 3 人日同上。

### 9.4 卡数分布
| 优先级 | 模块卡 | 埋点卡 | 集成卡 | 小计 |
|--------|--------|--------|--------|------|
| P0 | 18 | 12 | 4 | 34 |
| P1 | 6 | 0 | 0 | 6 |
| P2 | 3 | 0 | 1 | 4 |
| **合计** | **27** | **12** | **5** | **44** |

---

## 十、关键依赖总览

### 10.1 引擎依赖链（硬依赖）
```
S0: T2-1(契约) ──→ S1: T2-2(算法) ──→ S2: T2-3(集成) ──→ S2: T2-4(测试)
S0: C1-1(契约) ──→ S3: C1-2(算法) ──→ S4: C1-3(集成) ──→ S5: C1-4(测试)
S0: P3-1(契约) ──→ S6: P3-2(算法) ──→ S7: P3-3(集成) ──→ S8: P3-4(测试)
```

### 10.2 引擎→UI 依赖链
```
T2-2(算法) ──→ T1(UI), T3(内容评审), T4(预览), T5(切换提示)
C1-2(算法) ──→ C2(仲裁UI), C3(展示卡片), C4(安全通道), C5(覆盖保留)
P3-2(算法) ──→ P1(字段管理), P2(叙事渲染), P4(维度管理), P5(确认流程)
```

### 10.3 埋点基建依赖链
```
TRK-M0-INFRA(S0) ──→ 全部 TRK-* 卡（schema + bus 依赖）
TRK-T1 ──→ TRK-V3（防虚荣指标消费 tone_change_event）
TRK-C1 + TRK-C2 ──→ TRK-V1, TRK-V2（防虚荣指标消费冲突+仲裁事件）
```

### 10.4 集成收口依赖链
```
全部 P0 模块卡 + 全部 TRK 卡 ──→ INT-1(集成联调) ──→ INT-2(埋点对账)
INT-1 + INT-2 ──→ INT-4(缺陷清零) ──→ INT-5(灰度上线)
T6 + C6 + P6 ──→ INT-3(P2收口)
```

### 10.5 跨模块依赖（P3 版本化 → P-RL2）
```
P3-2(版本化算法, S6) ──→ P1(字段管理, S7) ──→ P-RL2 红线（confirm_source=system_auto 占比=0）
P3-2(版本化算法, S6) ──→ P2(叙事渲染, S7) ──→ P-RL3 红线（narrative_shown==has_narratable_change）
```

---

## 十一、P0 硬门槛卡清单（必须全交付才能进红线验收）

以下 34 张 P0 卡为红线验收的前置条件，必须全部完成 DoD 才能进入三模块红线闸门：

### 调性模块 P0（11 张）
| # | 卡 ID | 标题 | 估点 | Sprint | 对应红线 |
|---|-------|------|------|--------|----------|
| 1 | T2-1 | 调性引擎接口契约 | 1 | S0 | T-RL1/RL2 基础 |
| 2 | T2-2 | 调性引擎核心算法 | 2 | S1 | T-RL1 |
| 3 | T2-3 | 调性引擎集成 API | 1 | S2 | T-RL1 |
| 4 | T2-4 | 调性引擎单测+压测 | 1 | S2 | T-RL1 |
| 5 | T1 | 默认调性设定 UI | 6 | S1–S2 | T-RL2 |
| 6 | T3 | 调性内容评审 | 4 | S1–S2 | T-RL2/RL3 |
| 7 | TRK-M0-INFRA | 埋点基建 | 6 | S0 | 全红线基建 |
| 8 | TRK-T1 | 调性切换埋点 | 1.5 | S1 | T-RL1 |
| 9 | TRK-T2 | 内容调性标签埋点 | 2 | S1 | T-RL2 |
| 10 | TRK-T3 | 焦虑量表埋点 | 1 | S2 | T-RL3 |
| 11 | TRK-V3 | 调性防虚荣指标 | 1.5 | S1–S2 | T-RL1 防虚荣 |

### 冲突模块 P0（11 张）
| # | 卡 ID | 标题 | 估点 | Sprint | 对应红线 |
|---|-------|------|------|--------|----------|
| 12 | C1-1 | 冲突检测引擎接口契约 | 1.5 | S0 | C-RL1/RL3 基础 |
| 13 | C1-2 | 冲突检测核心算法 | 3 | S3–S4 | C-RL1/RL3 |
| 14 | C1-3 | 冲突检测集成 API | 2 | S4 | C-RL1 |
| 15 | C1-4 | 冲突检测单测+压测 | 1.5 | S5 | C-RL1 |
| 16 | C2 | 冲突仲裁界面 | 4 | S4–S5 | C-RL2 |
| 17 | C3 | 冲突展示卡片 | 6 | S4–S5 | C-RL1/RL3 |
| 18 | TRK-C1 | 冲突检测埋点 | 2.5 | S4–S5 | C-RL1/RL3 |
| 19 | TRK-C2 | 仲裁事件埋点 | 2 | S4–S5 | C-RL2 |
| 20 | TRK-V1 | 冲突防虚荣指标 | 2 | S4–S5 | C-RL1 防虚荣 |
| 21 | TRK-V2 | 仲裁防虚荣指标 | 2 | S4–S5 | C-RL2 防虚荣 |
| 22 | INT-1 | 三模块集成联调 | 2 | S9 | 跨模块验证 |

### 画像模块 P0（10 张）
| # | 卡 ID | 标题 | 估点 | Sprint | 对应红线 |
|---|-------|------|------|--------|----------|
| 23 | P3-1 | 画像版本化引擎接口契约 | 1 | S0 | P-RL1/RL2 基础 |
| 24 | P3-2 | 画像版本化核心算法 | 1.5 | S6–S7 | P-RL1/RL2/RL3 |
| 25 | P3-3 | 画像版本化集成 API | 1 | S7 | P-RL2/RL3 |
| 26 | P3-4 | 画像版本化单测+压测 | 0.5 | S8 | P-RL1 |
| 27 | P1 | 画像字段管理 | 6 | S7–S8 | P-RL2 |
| 28 | P2 | 身份叙事渲染 | 5 | S7–S8 | P-RL3 |
| 29 | TRK-P1 | 画像字段更新埋点 | 1.5 | S7–S8 | P-RL2 |
| 30 | TRK-P2 | 身份转换埋点 | 1 | S7–S8 | P-RL3 |
| 31 | TRK-P3 | 维度数据存在性埋点 | 1 | S7–S8 | P-RL1 |
| 32 | INT-2 | 埋点对账 | 1 | S9 | 全红线验证 |

### 收口 P0（2 张）
| # | 卡 ID | 标题 | 估点 | Sprint | 对应红线 |
|---|-------|------|------|--------|----------|
| 33 | INT-4 | 缺陷清零 | 1.5 | S10 | 上线门槛 |
| 34 | INT-5 | 灰度上线 | 1 | S10 | 上线门槛 |

### P0 硬门槛人日合计
- 模块 P0: 48 人日
- 数据 P0: 24 人日
- 集成 P0: 5.5 人日
- **P0 硬门槛总计: 77.5 人日**（须全量落地）

---

## 十二、补充说明

### 12.1 红线校验规则汇总（埋点卡须配置的硬性告警）
| 红线 | 校验规则 | 告警阈值 |
|------|----------|----------|
| P-RL2 | confirm_source=system_auto 占比 | 须 = 0（>0 即告警）|
| P-RL3 | narrative_shown == has_narratable_change | 一致率须 = 100%（<100% 即告警）|
| P-RL1 | rendered == is_active；is_active=false 时 occupied_storage==false | 一致率须 = 100% |
| C-RL1 | disposition.blocked_user | 须恒 = false |
| T-RL2 | consistent_with_anchor | 占比须 ≥ 95% |

### 12.2 身份角色命名（M0 冻结）
启程者 → 践行者 → 进阶者 → 掌控者（四阶段递进），贯穿 P2 叙事渲染和 TRK-P2 埋点。

### 12.3 约束 B（M0 冻结）
默认开启"聚焦卖点"调性，在 T1 默认调性设定中作为初始值，用户可手动切换。

### 12.4 C4 身体冲突安全通道（M0 决策）
Phase1 即接入，需 consent + 合规审核。虽为 P1 优先级，但因安全/合规要求，建议在 S4–S5 与 P0 冲突卡同期交付，不可延后。

### 12.5 三模块指标定位
全部为 Process/Guardrail 指标（T-RL1/2/3 + C-RL1/2/3 + P-RL1/2/3 + V1/V2/V3），不进北极星。身份进度指数动态权重不变。

---

## ✅ 行动清单

| # | 行动 | 负责方 | 时间窗 |
|---|------|--------|--------|
| 1 | S0 启动：三引擎接口契约（T2-1/C1-1/P3-1）+ 埋点基建 TRK-M0-INFRA | 设计+算法+数据 | W1–2 |
| 2 | M1 调性模块交付：T2-2→T2-3→T2-4 引擎链 + T1/T3 UI + 埋点 TRK-T1/T2/T3/V3 | 前端+算法+数据+内容 | W3–6 |
| 3 | M2 冲突模块交付：C1-2→C1-3→C1-4 引擎链 + C2/C3 UI + C4 安全通道 + 埋点 TRK-C1/C2/V1/V2 | 算法+前端+数据+合规 | W9–12 |
| 4 | M3 画像模块交付：P3-2→P3-3→P3-4 引擎链 + P1/P2 UI + 埋点 TRK-P1/P2/P3 | 前端+算法+数据+内容 | W15–18 |
| 5 | 集成收口 + 红线验收 + 灰度上线（INT-1~5）| 全角色 | W19–22 |
| 6 | 产品负责人确认口径差异（模块逐项 69 vs PRD 总括 79 人日）| 产品负责人 | S0 前 |

---

## ⚠️ 待确认 / 假设 / Non-goals

- **待确认**：模块开发人日口径差异（逐项 69 vs PRD 总括 79，差 10 人日）——建议以逐项估点为基准，差额纳入 Sprint 级缓冲统筹，待产品负责人确认。
- **待确认**：埋点卡数量差异（数析称 13 张，实际落卡 12 张，差 1 张可能为 TRK-M0-INFRA 拆分或后续补充）——建议与数析确认。
- **假设**：埋点基建（TRK-M0-INFRA）S0 必须完成，否则 M1–M3 全量红线验收阻塞。
- **假设**：C4 身体冲突安全通道虽为 P1，但因 M0 决策（Phase1 即接入）须与 P0 冲突卡同期交付。
- **Non-goals**：不在 Phase1 引入调性全层换皮的独立设计系统重构（T2 仅用 CSS 语义变量引擎实现，不重做设计稿）。
- **Non-goals**：不在 Phase1 实现画像维度的自动推荐启停（P4 维度启停须用户确认，系统不自动改）。

---

## 📚 数据来源 & 成员产出索引
- 析客（需求分析师）：44 张开发就绪任务卡整合产出（含接口契约/验收标准/DoD/依赖/估点/Sprint 归属/P0 硬门槛清单）
- 数析（数据分析师）：13 张埋点任务卡（9 条红线信号全覆盖，≈23 人日数据专项增量，含 sign-off 机制）
- 路径（路线图规划师）：S0–S10 Sprint 分配框架（依赖链 + 拆卡规则 + 5 风险点）
- 瑞思（用户研究员）：本专项未参与（Phase1 工程执行阶段，用户研究已在 PRD 阶段完成）
- 竞析（竞品分析师）：本专项未参与（同上）

---

> 本报告由产品战略团队 AI 协作生成，重要决策请由产品负责人审定。

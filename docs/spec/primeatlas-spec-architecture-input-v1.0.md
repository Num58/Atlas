# PrimeAtlas Spec 架构输入 v1.0

> 阶段：Phase 1.5 · Spec 输入研究  
> 状态：Architecture Input / 非实现文档  
> 日期：2026-07-20  
> 技术基线：Flutter + Riverpod + GoRouter + sqlite3 + SyncAdapter，本地优先  
> 范围约束：只转换已 Accepted 的产品规则；不冻结候选 IA，不扩产品范围，不给出实现代码  
> 上游真源：全量 PRD、蓝图—原型—PRD 追踪矩阵、PRD 门禁审查、产品决策确认单、长期记忆

---

## 0. 本文的使用方式

本文提供可直接并入 `PrimeAtlas Spec v1.0` 的九类合同输入：

1. 核心数据对象与字段级最小 Schema；
2. 目标方向、目标、计划、执行、Consent、适用范围、安全、兼容版本对象、同步状态机；
3. 领域事件；
4. API / Repository 接口清单；
5. 离线幂等与冲突优先级；
6. 第三方模型字段级可见矩阵；
7. 分场景 SLO 与降级；
8. fail-closed 边界；
9. 必须继续保持 `Spec Blocked`、不可由工程自行填默认值的参数。

### 0.1 约束级别

- **MUST**：已由 Accepted PRD 或门禁明确裁决，Spec 不得反向修改。
- **SHOULD**：本架构输入建议的最小合同；Spec 可在不改变产品语义的前提下细化。
- **BLOCKED**：仍缺产品、合规、数据或 QA 冻结；不得进入实现。

### 0.2 全局数据约定

- 数据类字段和序列化键 MUST 使用 `snake_case`。
- 所有可跨设备实体 MUST 有全局唯一、不依赖本地自增的 `id`；具体 UUID 版本仍可由后续架构决定，业务合同只依赖“稳定、不可复用、跨设备唯一”。
- 时间 MUST 以 UTC 微秒字段 `*_at_us` 保存；原发生时区另存 `timezone_id` 与 `timezone_offset_min`，不得仅保存本地墙上时间。
- 可修改聚合 MUST 保存 `version`；离线写入 MUST 保存稳定 `event_id` / `operation_id` 与设备单调递增 `device_seq`。
- 推断、生成、预测不得伪装成用户事实。所有关键值 MUST 带 `source_type`：
  `user_declared | device_observed | imported | system_inferred | model_generated | professional_content | deterministic_rule`。
- 系统只引导用户形成目标，不生成或确认角色身份、人格标签、“我现在是/我想成为”或身份差距。用户控制目标、时间、场景、现实约束和是否发起知识注入；Atlas 自主决定知识采纳、计划生成及普通调整，并保存可展示的依据、差异、影响和版本。
- 安全规则是独立且不可覆盖的决策层；用户普通偏好、Atlas 编排、调性、模型或其他 Agent 均不能降低安全结论。
- 数据充分度至少使用：`insufficient | partial | sufficient`；不足时禁止显示伪精确百分比。
- 未激活成长域 MUST 不渲染、不创建占位业务记录、不进入 Agent 上下文、不进入指标分母。
- 软删除只用于需要同步 tombstone 的用户可删除对象；执行事实、安全审计、Consent 回执等不可直接物理覆盖，按保留/删除合同处理。

---

## 1. 核心数据对象与字段级最小 Schema

> 以下为逻辑最小 Schema。它定义产品语义、所有权、版本与同步字段，不提前裁决 sqlite3 的拆表、JSON 列、FTS、迁移框架或云端物理存储。

### 1.1 通用字段组

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| `id` | text | 是 | 跨端稳定唯一 ID |
| `owner_id` | text | 是 | 游客本地身份或账号主体；切换账号不得串写 |
| `created_at_us` | int64 | 是 | UTC 微秒 |
| `updated_at_us` | int64 | 是 | UTC 微秒 |
| `version` | int | 是 | 聚合版本，从 1 递增 |
| `source_type` | enum | 是 | 用户、设备、推断、模型、规则等来源 |
| `source_ref_id` | text? | 否 | 来源事件、设备观测、内容或 AgentRun |
| `device_id` | text | 是 | 首次写入设备 |
| `device_seq` | int64 | 是 | 设备内单调序号，用于排序和查重 |
| `sync_state` | enum | 是 | 见同步状态机 |
| `deleted_at_us` | int64? | 否 | 需要跨端传播删除时使用 |

### 1.2 主体、设备与会话

#### `subjects`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 | 本地游客或云账号下的产品主体 |
| `account_id` | text? | 否 | 未登录可为空 |
| `subject_kind` | enum | 是 | `guest | registered` |
| `status` | enum | 是 | `active | signed_out | pending_deletion | deleted` |
| `created_at_us` | int64 | 是 |  |
| `updated_at_us` | int64 | 是 |  |

#### `devices`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 | 安装级稳定 ID，重装后的身份策略 BLOCKED |
| `owner_id` | text | 是 | 当前归属主体 |
| `platform` | enum | 是 | `ios | android` |
| `app_version` | text | 是 | 审计和兼容判断 |
| `last_device_seq` | int64 | 是 | 本地单调序列 |
| `last_seen_at_us` | int64 | 是 |  |

#### `app_sessions`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 |  |
| `owner_id` | text | 是 |  |
| `tone_version_id` | text | 是 | 会话内所有新输出使用同一已确认版本 |
| `started_at_us` | int64 | 是 |  |
| `ended_at_us` | int64? | 否 |  |

### 1.3 目标方向草案、成长域与版本历史

> `identity_drafts`、`portrait_versions`、`portrait_candidates` 是 V0.2 已固化 SQLite 表名，只作存储兼容，不再承载角色身份定义、身份差距或画像确认产品语义。本次不改表、不增字段；应用层将其解释为“用户原话/目标边界草案”“目标边界版本”“方向候选”。

#### `identity_drafts`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `state` | enum | 是 | `draft | pending_confirmation | confirmed | discarded | superseded` |
| `current_identity_text` | text? | 否 | 兼容字段：仅存用户对当前情况/基线的原话；UI 与领域层不得称“当前身份” |
| `target_identity_text` | text? | 否 | 兼容字段：仅存用户想提升的方向或目标原话；不得生成身份称谓 |
| `constraints_summary` | text? | 否 | 用户可控的时间、场景与现实约束摘要；不得把模型推断写成用户自述 |
| `inference_source` | enum | 是 | `user_only | assisted`；assisted 只能产出可修改目标候选 |
| `data_sufficiency` | enum | 是 |  |
| `confirmed_at_us` | int64? | 否 | 只有用户确认目标边界时存在；不是身份确认 |
| `confirmed_by` | enum? | 否 | 兼容枚举只允许 `user_explicit`；含义是确认目标/约束原话 |

#### `active_domains`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `portrait_version_id` | text | 是 | 关联已确认目标边界版本；字段名仅为兼容 |
| `domain_code` | text | 是 | 首发域字典由 Spec 冻结 |
| `display_name` | text | 是 |  |
| `state` | enum | 是 | `active | paused | archived` |
| `priority_rank` | int | 是 | 同时 active 的域最多 3 个 |
| `activated_at_us` | int64 | 是 |  |
| `paused_at_us` | int64? | 否 |  |
| `archived_at_us` | int64? | 否 |  |

#### `portrait_versions`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `state` | enum | 是 | `active | superseded | archived | restored` |
| `previous_version_id` | text? | 否 | 版本链 |
| `identity_draft_id` | text | 是 | 兼容字段：形成此目标边界版本的草案/候选 |
| `current_identity_text` | text | 是 | 兼容字段：用户确认的当前情况/基线原话；不得解释为角色身份 |
| `target_identity_text` | text | 是 | 兼容字段：用户确认的目标方向原话；不得解释为目标身份 |
| `role_stage` | enum? | 否 | Deprecated；新写入 MUST 为 null，UI/指标/计划不得读取，后续迁移再移除 |
| `evidence_summary` | text? | 否 | 目标、基线与约束证据的用户可见摘要 |
| `confirmation_source` | enum | 是 | MUST 为 `user_explicit`；仅表示用户确认目标边界，禁止 `system_auto` |
| `activated_at_us` | int64 | 是 |  |

#### `portrait_candidates`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `base_portrait_version_id` | text | 是 |  |
| `state` | enum | 是 | `candidate | pending_confirmation | accepted | rejected | withdrawn | conflicted` |
| `proposed_patch` | json | 是 | 字段级差异，不存私有推理链 |
| `reason_summary` | text | 是 | 可解释理由 |
| `evidence_ids` | json[text] | 是 | 可追溯证据 |
| `generated_by` | enum | 是 | `system_inferred | model_generated | user_requested` |
| `decided_at_us` | int64? | 否 |  |

### 1.4 目标与里程碑

#### `goals`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `domain_id` | text | 是 | 必须属于已激活或暂停域 |
| `state` | enum | 是 | `draft | pending_confirmation | active | paused | recalibrating | completed | archived` |
| `title` | text | 是 |  |
| `description` | text? | 否 |  |
| `source_identity_gap` | text | 是 | 兼容字段：保存用户原话、基线/约束来源摘要；不得计算或展示身份差距 |
| `baseline_kind` | enum | 是 | `quantitative | evidence_based | exploratory` |
| `baseline_value` | real? | 否 | 仅 quantitative |
| `baseline_unit` | text? | 否 |  |
| `target_value` | real? | 否 | 不足时为空，禁止伪精确 |
| `target_unit` | text? | 否 |  |
| `target_date_us` | int64? | 否 | 仅有依据时使用 |
| `priority_rank` | int | 是 | 域内优先级 |
| `confirmed_at_us` | int64? | 否 |  |
| `pause_reason_code` | text? | 否 |  |
| `archive_reason_code` | text? | 否 | 归档不同于删除 |

#### `milestones`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `goal_id` | text | 是 |  |
| `state` | enum | 是 | `not_started | in_progress | achieved | not_achieved | superseded` |
| `title` | text | 是 |  |
| `sequence_no` | int | 是 | 同一 goal 唯一 |
| `evidence_rule_id` | text | 是 | 规则须版本化 |
| `baseline_value` | real? | 否 |  |
| `target_value` | real? | 否 |  |
| `unit` | text? | 否 |  |
| `window_start_at_us` | int64? | 否 |  |
| `window_end_at_us` | int64? | 否 |  |
| `achieved_at_us` | int64? | 否 |  |

### 1.5 约束、场景与数据观测

#### `context_observations`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 追加记录 |
| `observation_type` | enum | 是 | `energy | sleep | hrv | resting_hr | soreness | pain | calendar | location | equipment | venue | scene_declaration` |
| `value_json` | json | 是 | 按类型校验；原文可设为仅设备可见 |
| `observed_at_us` | int64 | 是 | 原发生时间 |
| `timezone_id` | text | 是 |  |
| `timezone_offset_min` | int | 是 |  |
| `valid_until_at_us` | int64? | 否 | 新鲜度 |
| `confidence` | real? | 否 | 0..1，仅来源可提供时 |
| `correction_of_id` | text? | 否 | 更正链 |
| `consent_receipt_id` | text? | 否 | 需要授权的数据必须关联 |

### 1.6 适用范围确认、Consent 与可见策略

#### `eligibility_declarations`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 不等同于数据处理 Consent |
| `state` | enum | 是 | `not_presented | presented | incomplete | eligible_confirmed | ineligible | rejected | unavailable | expired | superseded` |
| `declaration_version` | text | 是 | 当时展示内容版本 |
| `purpose_code` | text | 是 | `ordinary_training_plan_eligibility` |
| `adult_confirmed` | bool? | 否 | 默认 null，不得预填 true |
| `minor_status` | enum | 是 | `unanswered | no | yes` |
| `pregnancy_status` | enum | 是 | `unanswered | no | yes | not_applicable`；具体选项文案 BLOCKED |
| `acute_pain_status` | enum | 是 | `unanswered | no | yes` |
| `known_disease_status` | enum | 是 | `unanswered | no | yes` |
| `postoperative_rehab_status` | enum | 是 | `unanswered | no | yes` |
| `user_action` | enum | 是 | `none | explicitly_confirmed | explicitly_rejected | could_not_complete` |
| `presented_content_hash` | text | 是 | 审计当时展示内容 |
| `presented_at_us` | int64 | 是 |  |
| `decided_at_us` | int64? | 否 |  |
| `valid_until_at_us` | int64? | 否 | 有效期 BLOCKED |
| `supersedes_id` | text? | 否 | 规则/状态变化重新确认 |

#### `consent_receipts`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 版本化审计回执 |
| `state` | enum | 是 | `not_requested | pending | granted | denied | revoked | expired | superseded` |
| `purpose_code` | text | 是 | 单一明确目的 |
| `data_categories` | json[text] | 是 | 字段类别而非模糊“全部数据” |
| `scope_json` | json | 是 | 功能、域、内容范围 |
| `recipient_type` | enum | 是 | `device_only | primeatlas_service | third_party_model | third_party_service | public_share_recipient` |
| `recipient_id` | text? | 否 | 第三方接收方必须指定 |
| `policy_version` | text | 是 |  |
| `retention_policy_id` | text | 是 | 时限值 BLOCKED |
| `granted_at_us` | int64? | 否 |  |
| `valid_until_at_us` | int64? | 否 |  |
| `revoked_at_us` | int64? | 否 |  |
| `revocation_reason_code` | text? | 否 |  |
| `user_action_evidence` | text | 是 | 不允许默认勾选或捆绑同意 |

#### `visibility_policies`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 |  |
| `purpose_code` | text | 是 | 当前具体任务 |
| `policy_version` | text | 是 |  |
| `field_path` | text | 是 | 如 `portrait.target_identity_summary` |
| `visibility_tier` | enum | 是 | `device_only | primeatlas_service | third_party_model` |
| `transform` | enum | 是 | `none | omit | pseudonymize | summarize | categorize | redact` |
| `requires_consent_purpose` | text? | 否 | 第三方通常必填 |
| `retention_class` | text | 是 |  |

### 1.7 计划、计划版本与行动单元

#### `plans`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 计划聚合根 |
| `state` | enum | 是 | `generating | draft | pending_review | safety_blocked | pending_confirmation | active | expired | superseded | archived` |
| `plan_kind` | enum | 是 | `cycle | weekly | daily | conservative` |
| `period_start_at_us` | int64 | 是 |  |
| `period_end_at_us` | int64 | 是 |  |
| `eligibility_declaration_id` | text? | 否 | 含普通精细训练时 MUST 有有效准入 |
| `active_version_id` | text? | 否 | 只有 active 后存在 |
| `safety_status` | enum | 是 | `not_evaluated | evaluating | passed | blocked | stale | unavailable` |
| `professional_status` | enum | 是 | `not_evaluated | evaluating | passed | failed | partial | unavailable` |
| `data_sufficiency` | enum | 是 |  |

#### `plan_versions`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 不原地覆盖旧版本 |
| `plan_id` | text | 是 |  |
| `revision_no` | int | 是 | 同一计划唯一递增 |
| `base_revision_id` | text? | 否 |  |
| `state` | enum | 是 | `draft | pending_review | safety_blocked | pending_confirmation | active | superseded | expired` |
| `change_class` | enum | 是 | `initial | minor_reversible | major | safety | user_override | recovery` |
| `change_reason_code` | text | 是 |  |
| `goal_ids` | json[text] | 是 |  |
| `input_snapshot_ref` | text | 是 | 输入依据快照 |
| `rule_set_version` | text | 是 |  |
| `agent_run_id` | text? | 否 |  |
| `confirmed_by_user_at_us` | int64? | 否 | 重大变化必须存在 |
| `revert_to_version_id` | text? | 否 | 可逆回退 |

#### `plan_actions`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `plan_version_id` | text | 是 |  |
| `domain_id` | text | 是 | 单一 action 只属于一个域 |
| `goal_id` | text | 是 |  |
| `milestone_id` | text? | 否 |  |
| `action_kind` | text | 是 | 专业字典由域 Spec 冻结 |
| `title` | text | 是 |  |
| `scheduled_start_at_us` | int64? | 否 |  |
| `scheduled_end_at_us` | int64? | 否 |  |
| `timezone_id` | text | 是 |  |
| `required_content_version_id` | text? | 否 |  |
| `risk_level` | enum | 是 | `low | medium | high` |
| `safety_status` | enum | 是 |  |
| `replaced_action_id` | text? | 否 | 等价替换链 |

### 1.8 执行与反馈

#### `execution_records`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 执行事实聚合 |
| `plan_action_id` | text | 是 | 指向执行时所见具体版本 |
| `state` | enum | 是 | `not_started | in_progress | paused | skipped | completed | interrupted | reverted`；用户界面避免羞辱性“失败” |
| `started_at_us` | int64? | 否 | 原发生时间 |
| `completed_at_us` | int64? | 否 |  |
| `occurred_timezone_id` | text | 是 |  |
| `occurred_timezone_offset_min` | int | 是 |  |
| `completion_source` | enum | 是 | `user_declared | device_observed | imported` |
| `quality_state` | enum | 是 | `unknown | self_reported | partially_observed | observed`；完成不等于质量 |
| `reverted_at_us` | int64? | 否 | 撤销追加记录，不删除事实 |

#### `execution_events`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `event_id` | text | 是 | 幂等主键 |
| `owner_id` | text | 是 |  |
| `execution_record_id` | text | 是 |  |
| `event_type` | enum | 是 | `started | paused | resumed | skipped | completed | interrupted | reverted` |
| `operation_id` | text | 是 | 一次用户意图稳定 ID |
| `occurred_at_us` | int64 | 是 |  |
| `timezone_id` | text | 是 |  |
| `timezone_offset_min` | int | 是 |  |
| `device_id` | text | 是 |  |
| `device_seq` | int64 | 是 | 同设备唯一 |
| `payload` | json | 是 | 最小事件数据 |
| `sync_state` | enum | 是 |  |

#### `feedback_records`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 追加/更正链 |
| `execution_record_id` | text | 是 |  |
| `rpe_state` | enum | 是 | `recorded | missing | not_applicable` |
| `rpe_value` | real? | 否 | 跳过时必须为空，不复用历史值 |
| `pain_state` | enum | 是 | `none_reported | recorded | missing` |
| `pain_value` | real? | 否 | 量表与阈值 BLOCKED |
| `quality_state` | enum | 是 | `unknown | self_reported | partially_observed | observed` |
| `quality_value` | real? | 否 | 不能由滑动完成自动填充 |
| `notes` | text? | 否 | 默认仅设备可见；外发需独立 Consent |
| `recorded_at_us` | int64 | 是 |  |
| `correction_of_id` | text? | 否 |  |

### 1.9 普通冲突与安全事件

#### `conflict_records`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 仅普通冲突 |
| `conflict_type` | enum | 是 | `direction | time | energy | domain_priority` |
| `state` | enum | 是 | `detected | presented | recommendation_accepted | user_editing | user_resolved | dismissed | obsolete` |
| `affected_goal_ids` | json[text] | 是 |  |
| `tradeoff_summary` | text | 是 |  |
| `recommendation_patch` | json | 是 |  |
| `blocked_user` | bool | 是 | MUST 恒为 false |
| `resolved_at_us` | int64? | 否 |  |

#### `safety_events`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 | 与普通冲突独立 |
| `state` | enum | 是 | `detected | precautionary_paused | evaluating | blocked | alternative_available | awaiting_reassessment | resolved | superseded` |
| `trigger_type` | enum | 是 | `eligibility | acute_pain | injury_risk | recovery_anomaly | load_rule | stale_data | dependency_failure | other_rule` |
| `scope_type` | enum | 是 | `plan | plan_action | domain` |
| `scope_id` | text | 是 |  |
| `rule_id` | text | 是 |  |
| `rule_version` | text | 是 |  |
| `evidence_ids` | json[text] | 是 |  |
| `reason_summary` | text | 是 | 可先给紧急短理由，完整理由异步补充 |
| `user_overridable` | bool | 是 | MUST 为 false |
| `alternative_plan_version_id` | text? | 否 |  |
| `reassessment_rule_id` | text? | 否 |  |
| `resolved_at_us` | int64? | 否 |  |

### 1.10 Agent、证据与审计

#### `agent_runs`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `job_id` | text | 是 | 重试必须复用或关联原 job |
| `purpose_code` | text | 是 | 具体任务 |
| `state` | enum | 是 | `queued | running | partial | completed | degraded | timed_out | cancelled | failed | safety_blocked` |
| `role_codes` | json[text] | 是 | 产品职责，不代表模型实例数 |
| `input_manifest_id` | text | 是 | 记录字段集合，不记录敏感原文日志 |
| `rule_set_version` | text | 是 |  |
| `model_provider_id` | text? | 否 | 若使用第三方 |
| `visibility_policy_version` | text | 是 |  |
| `data_sufficiency` | enum | 是 |  |
| `started_at_us` | int64? | 否 |  |
| `finished_at_us` | int64? | 否 |  |
| `degradation_code` | text? | 否 |  |

#### `role_decisions`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `agent_run_id` | text | 是 |  |
| `role_code` | text | 是 | 12 类职责之一 |
| `decision_type` | enum | 是 | `design | review | recommend | veto | abstain | degraded` |
| `decision_state` | enum | 是 | `pending | passed | failed | partial | unavailable` |
| `reason_summary` | text | 是 | 结构化理由，不含私有思维链 |
| `evidence_ids` | json[text] | 是 |  |
| `rule_hits` | json[text] | 是 |  |
| `write_scope` | text | 是 | 记录其可影响对象 |

#### `evidence_links`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 |  |
| `owner_id` | text | 是 |  |
| `subject_type` | text | 是 | 目标、计划、PR、方向候选等；物理枚举若保留 portrait 命名仅为兼容 |
| `subject_id` | text | 是 |  |
| `evidence_type` | text | 是 |  |
| `evidence_ref_id` | text | 是 | 指向执行、反馈、内容、规则或观测 |
| `source_type` | enum | 是 |  |
| `observed_at_us` | int64 | 是 |  |
| `valid_until_at_us` | int64? | 否 |  |
| `confidence` | real? | 否 |  |
| `status` | enum | 是 | `active | corrected | revoked | stale` |

#### `audit_records`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 | 追加审计 |
| `owner_id` | text | 是 |  |
| `action_type` | text | 是 |  |
| `actor_type` | enum | 是 | `user | device | primeatlas_service | rule | model | support_operator` |
| `actor_ref_id` | text? | 否 |  |
| `object_type` | text | 是 |  |
| `object_id` | text | 是 |  |
| `before_version` | int? | 否 |  |
| `after_version` | int? | 否 |  |
| `reason_code` | text | 是 |  |
| `evidence_ids` | json[text] | 是 |  |
| `occurred_at_us` | int64 | 是 |  |
| `policy_version` | text? | 否 | Consent/安全/可见策略变更 |
| `metadata_redacted` | json | 是 | 禁止写健康原文、笔记全文、完整身份叙事 |

### 1.11 融合与知识注入

#### `derived_contents`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `state` | enum | 是 | `candidate | visible | edited | withdrawn | deleted` |
| `parent_type` | enum | 是 | `training_replay | book_note | note | goal | plan | review` |
| `parent_id` | text | 是 | 来源芯片可回溯 |
| `domain_id` | text | 是 | 真实活跃域 |
| `content_kind` | enum | 是 | `term | expression | review_material | writing_material` |
| `content_text` | text | 是 |  |
| `confidence` | real | 是 | 低置信阈值 BLOCKED；未达阈值不展示 |
| `generation_consent_id` | text? | 否 | 需要生成授权时关联 |
| `user_corrected_at_us` | int64? | 否 | 用户可校正 |

#### `knowledge_suggestions`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| 通用字段 |  | 是 |  |
| `state` | enum | 是 | `extracting | evaluating | proposed_accept | proposed_adapt | proposed_defer | proposed_reject | accepted | adapted | deferred | rejected | integrated | withdrawn | conflicted`；`pending_confirmation` 仅兼容旧记录，新流程不得写入 |
| `source_content_id` | text | 是 | 原文/笔记来源 |
| `target_goal_id` | text | 是 |  |
| `target_plan_id` | text? | 否 |  |
| `decision_summary` | text | 是 | Atlas 的采纳/改造/暂缓/不采纳结论 |
| `reason_summary` | text | 是 | 1–2 句可读理由；必须解释依据和预期影响 |
| `evidence_ids` | json[text] | 是 | 依据、来源、版本 |
| `safety_status` | enum | 是 | 阻断级独立存在，普通知识决策不可覆盖 |
| `confirmed_at_us` | int64? | 否 | Deprecated 兼容字段；新流程 MUST 为 null，用户不逐条确认 |
| `integration_stage` | enum? | 否 | `adaptation | transition | stable` |

### 1.12 同步、冲突与 tombstone

#### `sync_operations`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `operation_id` | text | 是 | 稳定幂等键 |
| `owner_id` | text | 是 |  |
| `device_id` | text | 是 |  |
| `device_seq` | int64 | 是 | `(owner_id, device_id, device_seq)` 唯一 |
| `aggregate_type` | text | 是 |  |
| `aggregate_id` | text | 是 |  |
| `operation_type` | enum | 是 | `append | create_version | update | tombstone | restore | resolve_conflict` |
| `base_version` | int? | 否 | 比较并发版本 |
| `payload_hash` | text | 是 | 同 key 不同 payload 必须报错 |
| `occurred_at_us` | int64 | 是 |  |
| `recorded_at_us` | int64 | 是 | 本机落库时间 |
| `state` | enum | 是 | 同步状态机 |
| `retry_count` | int | 是 |  |
| `last_error_code` | text? | 否 |  |

#### `sync_conflicts`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 |  |
| `owner_id` | text | 是 |  |
| `aggregate_type` | text | 是 |  |
| `aggregate_id` | text | 是 |  |
| `local_version_id` | text | 是 |  |
| `remote_version_id` | text | 是 |  |
| `conflict_class` | enum | 是 | `execution_vs_plan | concurrent_user_edit | portrait_candidate | consent | safety | deletion | account_ownership | generic_version` |
| `resolution_policy` | enum | 是 | `append_both | stricter_wins | user_explicit_wins | user_resolution_required | tombstone_wins | reject_cross_owner` |
| `state` | enum | 是 | `detected | auto_resolved | awaiting_user | resolved | rejected` |
| `resolution_result` | json? | 否 |  |
| `detected_at_us` | int64 | 是 |  |
| `resolved_at_us` | int64? | 否 |  |

#### `tombstones`

| 字段 | 类型 | 必填 | 约束 |
|---|---|---:|---|
| `id` | text | 是 | 通常可等于业务对象 ID |
| `owner_id` | text | 是 |  |
| `object_type` | text | 是 |  |
| `object_id` | text | 是 |  |
| `deleted_at_us` | int64 | 是 |  |
| `deletion_request_id` | text? | 否 |  |
| `policy_version` | text | 是 |  |
| `sync_state` | enum | 是 |  |

### 1.13 最小索引合同

> 不做过早复合索引优化；以下仅是数据正确性和高频本地路径的最小索引要求。

| 对象 | 唯一/查询索引 |
|---|---|
| 全部跨端实体 | `PRIMARY KEY(id)` |
| 设备序列 | `UNIQUE(owner_id, device_id, device_seq)` |
| 幂等操作 | `UNIQUE(operation_id)`，以及服务端语义上的 `UNIQUE(owner_id, operation_id)` |
| 目标 | `(owner_id, domain_id, state)` |
| 计划 | `(owner_id, state, period_start_at_us)` |
| 行动 | `(plan_version_id, scheduled_start_at_us)` |
| 执行事件 | `(execution_record_id, occurred_at_us)`；`UNIQUE(event_id)` |
| Consent | `(owner_id, purpose_code, recipient_type, state)` |
| 适用范围确认 | `(owner_id, purpose_code, state, valid_until_at_us)` |
| 安全事件 | `(owner_id, scope_type, scope_id, state)` |
| 同步队列 | `(owner_id, state, device_seq)` |
| 审计 | `(owner_id, object_type, object_id, occurred_at_us)` |

---

## 2. 状态机合同

### 2.1 目标方向草案状态机（复用 V0.2 身份命名）

```text
[draft]
  ├─ submit → [pending_confirmation]
  ├─ discard → [discarded]
  └─ assisted_update → [draft]

[pending_confirmation]
  ├─ user_confirm → [confirmed]
  ├─ user_edit → [draft]
  ├─ user_reject → [discarded]
  └─ concurrent_new_draft → [superseded]

[confirmed] ── newer_confirmed_identity → [superseded]
```

硬规则：

- `system_auto`、模型完成、追问轮数达到阈值均不得触发 `confirmed`。
- `confirmed` 只表示用户确认目标、时间、场景和现实约束原话；不得表示系统为用户定义了角色身份或人格画像，也不得成为建立目标的前置身份门槛。
- 未确认草案不得成为正式目标约束事实或第三方模型长期画像；系统推断始终保留来源，不得写成用户事实。

### 2.2 目标状态机

```text
[draft] → [pending_confirmation] → [active]
   │              │                  ├─ pause → [paused]
   │              └─ reject → archived│
   └─ discard                         ├─ major_change → [recalibrating]
                                      ├─ evidence_complete → [completed]
[paused] ── resume_request → [recalibrating]
[recalibrating] ── user_confirm + reviews → [active]
[active|paused|completed] ── archive → [archived]
```

硬规则：

- 超过 3 个 active 域时只产生聚焦建议，不静默暂停/归档目标。
- 恢复目标必须重新运行受影响的专业、安全、时间冲突评审。
- `completed` 不自动修改目标边界版本；若产生 `PortraitCandidate` 兼容对象，其产品语义仅为方向/边界变化候选，不得定义角色身份或人格。

### 2.3 计划状态机

```text
[generating]
  ├─ partial_or_data_insufficient → [draft]
  ├─ generated → [pending_review]
  ├─ timeout_non_safety → [draft/degraded]
  └─ eligibility_or_safety_fail → [safety_blocked]

[pending_review]
  ├─ safety_fail → [safety_blocked]
  ├─ professional_fail → [draft]
  ├─ minor_reversible + passed → [active] + explanation/version
  └─ major + all_reviews_passed → [active] + explanation/version

[pending_confirmation]  # 仅兼容旧记录，新流程不得进入
  ├─ legacy_reviews_passed → [active]
  ├─ upstream_constraints_changed → [draft]
  └─ legacy_record_archived → [archived]

[active]
  ├─ end_of_validity → [expired]
  ├─ new_active_version → [superseded]
  ├─ safety_trigger → [safety_blocked]
  └─ minor_reversible_adjustment → [active(new version)]

[safety_blocked]
  ├─ safe_alternative_reviewed → [pending_confirmation|active conservative]
  └─ reassessment_passed → [pending_review]
```

硬规则：

- 训练普通精细方案没有有效 `eligibility_declaration` 不得离开 `draft/safety_blocked` 进入可执行态。
- `safety_status != passed` 时不得把普通精细方案标记为 `active/ready`。
- 安全超时、规则不可用、数据过期不得转为通过。
- 计划更新不得覆盖已经发生的执行事实。

### 2.4 执行状态机

```text
[not_started]
  ├─ start → [in_progress]
  ├─ skip → [skipped]
  └─ safety_block → stays unavailable, no execution transition

[in_progress]
  ├─ pause → [paused]
  ├─ complete → [completed]
  ├─ interrupt/process_loss → [interrupted]
  └─ safety_trigger → [paused] + SafetyEvent.precautionary_paused

[paused|interrupted]
  ├─ resume_if_safe → [in_progress]
  ├─ skip → [skipped]
  └─ complete_with_evidence → [completed]

[completed|skipped] ── user_revert → [reverted]
[reverted] ── start_again_as_new_attempt → new ExecutionRecord
```

硬规则：

- 每次转换追加 `execution_event`，不得只原地改最终状态。
- 重复点击同一意图复用 `operation_id`，不得重复完成。
- `completed` 只表达完成声明/观测，不自动等于质量通过。
- 跳过 RPE 后为 `missing`，不得带入上次值。

### 2.5 Consent 状态机

```text
[not_requested] → [pending]
[pending]
  ├─ explicit_grant → [granted]
  ├─ explicit_deny → [denied]
  └─ leave/incomplete → [not_requested|pending]

[granted]
  ├─ explicit_revoke → [revoked]
  ├─ expiry → [expired]
  └─ purpose/scope/recipient/policy_change → [superseded] + new pending

[denied|revoked|expired|superseded] ── new_explicit_request → [pending]
```

硬规则：

- 新用途、扩大字段范围、更换接收方、拟用于通用模型训练必须重新授权。
- 撤回立即停止新采集/新发送；既有数据、派生结果、索引、备份和第三方副本按独立删除/保留合同处理。
- Consent 不得由通用协议、健康权限、文件权限或历史画像替代。

### 2.6 训练适用范围确认状态机

```text
[not_presented] → [presented]
[presented]
  ├─ all_items_answered + adult + no_exclusion + explicit_confirm
  │      → [eligible_confirmed]
  ├─ any_exclusion_yes → [ineligible]
  ├─ explicit_reject → [rejected]
  ├─ cannot_complete → [unavailable]
  └─ leave/timeout/partial → [incomplete]

[eligible_confirmed]
  ├─ validity_end → [expired]
  ├─ rule_version_change → [superseded]
  └─ identity/health/pain_change → [superseded] + re-present
```

硬规则：

- 所有筛查项默认必须为 `unanswered`，不得预选安全答案。
- `incomplete | ineligible | rejected | unavailable | expired | superseded` 均禁止普通精细训练方案。
- 此声明不等于医疗判断，不替代生成前、调整时和执行中的持续安全检查。

### 2.7 安全状态机

```text
[detected] → [precautionary_paused] → [evaluating]
[evaluating]
  ├─ rule_hit → [blocked]
  ├─ safe_alternative_ready → [alternative_available]
  ├─ needs_new_data → [awaiting_reassessment]
  ├─ timeout/dependency_failure → stays [precautionary_paused|blocked]
  └─ verified_clear → [resolved]

[blocked]
  ├─ safe_alternative → [alternative_available]
  └─ reassessment_required → [awaiting_reassessment]

[alternative_available]
  ├─ user_selects_safe_alternative → new reviewed plan version
  └─ user_waits → [awaiting_reassessment]

[awaiting_reassessment] ── pass_new_review → [resolved]
```

硬规则：

- 用户、调性、TIME-ORCHESTRATOR、普通 Agent、模型切换均不得覆盖 `blocked`。
- 阻止的是危险具体方案，不删除目标，不阻断查看依据和安全替代。
- 新疼痛离线时必须本地即时进入保守暂停。

### 2.8 方向候选与目标边界版本状态机（兼容对象名）

```text
[candidate] → [pending_confirmation]
[pending_confirmation]
  ├─ user_accept → [accepted] → create PortraitVersion.active
  ├─ user_reject → [rejected]
  ├─ source_corrected → [withdrawn]
  └─ concurrent_candidate/version → [conflicted]

[conflicted] ── user_resolve → accepted/rejected/withdrawn
[active goal-boundary version; PortraitVersion 兼容对象] ── new version activated → [superseded]
[superseded] ── user_restore → new PortraitVersion.restored(active)
```

硬规则：

- 方向/目标边界版本冲突不得自动字段合并为用户事实；`Portrait*` 仅为兼容对象名。
- `system_auto` 仅能生成可修改 `candidate`，不得定义用户角色、身份或人格。
- 恢复旧目标边界版本必须创建新版本，不改写历史版本。

### 2.9 同步状态机

```text
[local_pending] → [syncing]
[syncing]
  ├─ ack_same_payload → [synced]
  ├─ retryable_error → [retry_pending]
  ├─ version_conflict → [conflict]
  ├─ terminal_validation_error → [failed_action_required]
  └─ account_mismatch → [rejected]

[retry_pending] → retry → [syncing]
[conflict]
  ├─ deterministic_policy → [synced] + SyncConflict.auto_resolved
  └─ user_resolution_required → stays [conflict]

[failed_action_required] ── corrected_new_operation → new local_pending
```

硬规则：

- 同步失败不阻断本地执行，但必须可见“待同步/冲突/需处理”。
- 同一 `operation_id` 同一 payload 重放必须返回原结果；同 key 不同 payload 必须拒绝。
- 账号归属不一致不得尝试合并。

---

## 3. 领域事件清单

### 3.1 统一事件 Envelope

每个领域事件最少包含：

```text
event_id, event_type, schema_version,
owner_id, aggregate_type, aggregate_id, aggregate_version,
operation_id, causation_id?, correlation_id?,
source_type, actor_type, actor_ref_id?,
device_id, device_seq,
occurred_at_us, timezone_id, timezone_offset_min,
recorded_at_us, payload, payload_hash
```

规则：

- `event_id` 唯一；`operation_id` 表示一次业务意图，可关联多事件。
- `causation_id` 指直接触发事件；`correlation_id` 串联方向/约束→目标→计划→执行→证据/版本因果链。
- payload 不得记录第三方模型不可见的健康原文、笔记全文或完整角色/人格叙事。

### 3.2 事件目录

#### 方向 / 目标边界版本（兼容 Identity / Portrait 事件名）

- `identity_draft_created`
- `identity_draft_updated`
- `identity_draft_submitted`
- `identity_draft_confirmed`
- `identity_draft_discarded`
- `domain_activated`
- `domain_paused`
- `domain_archived`
- `portrait_candidate_created`
- `portrait_candidate_accepted`
- `portrait_candidate_rejected`
- `portrait_candidate_withdrawn`
- `portrait_version_activated`
- `portrait_version_restored`

#### 目标 / 里程碑

- `goal_proposed`
- `goal_confirmed`
- `goal_updated`
- `goal_paused`
- `goal_recalibration_started`
- `goal_recalibrated`
- `goal_completed`
- `goal_archived`
- `milestone_created`
- `milestone_started`
- `milestone_achieved`
- `milestone_superseded`
- `domain_limit_focus_suggested`

#### 适用范围 / Consent / 可见性

- `eligibility_presented`
- `eligibility_confirmed`
- `eligibility_incomplete`
- `eligibility_ineligible`
- `eligibility_rejected`
- `eligibility_unavailable`
- `eligibility_expired`
- `consent_requested`
- `consent_granted`
- `consent_denied`
- `consent_revoked`
- `consent_expired`
- `consent_superseded`
- `visibility_manifest_created`
- `third_party_payload_blocked`

#### 计划 / Agent / 冲突

- `plan_generation_requested`
- `plan_draft_created`
- `plan_review_started`
- `plan_review_degraded`
- `plan_safety_blocked`
- `plan_confirmation_requested`
- `plan_activated`
- `plan_minor_adjustment_applied`
- `plan_adjustment_reverted`
- `plan_superseded`
- `plan_expired`
- `conflict_detected`
- `conflict_recommendation_accepted`
- `conflict_user_edit_started`
- `conflict_user_resolved`
- `agent_run_queued`
- `agent_role_decided`
- `agent_run_completed`
- `agent_run_timed_out`
- `agent_run_degraded`

#### 执行 / 反馈 / 安全

- `execution_started`
- `execution_paused`
- `execution_resumed`
- `execution_skipped`
- `execution_completed`
- `execution_interrupted`
- `execution_reverted`
- `feedback_recorded`
- `feedback_missing`
- `pain_reported`
- `safety_detected`
- `safety_precautionary_paused`
- `safety_blocked`
- `safety_alternative_offered`
- `safety_reassessment_requested`
- `safety_resolved`

#### 融合 / 知识

- `derived_content_created`
- `derived_content_visible`
- `derived_content_corrected`
- `fusion_collection_disabled`
- `fusion_generation_disabled`
- `knowledge_extraction_requested`
- `knowledge_evaluated`
- `knowledge_confirmation_requested`
- `knowledge_accepted`
- `knowledge_adapted`
- `knowledge_deferred`
- `knowledge_rejected`
- `knowledge_integrated`

#### 同步 / 更正 / 删除

- `sync_operation_enqueued`
- `sync_started`
- `sync_succeeded`
- `sync_retry_scheduled`
- `sync_conflict_detected`
- `sync_conflict_resolved`
- `sync_operation_rejected`
- `source_data_corrected`
- `recomputation_requested`
- `tombstone_created`
- `deletion_requested`
- `deletion_scope_completed`

---

## 4. API 与 Repository 合同清单

> 本节是领域接口，不裁决本地调用、PrimeAtlas 服务端 HTTP、后台 Job 或第三方模型协议。所有变更命令 MUST 接收 `operation_id`；跨端更新 MUST 接收 `base_version`。

### 4.1 统一错误码最小集

| 错误码 | 语义 | 客户端要求 |
|---|---|---|
| `invalid_state_transition` | 非法状态转换 | 不重试，恢复最新状态 |
| `validation_failed` | 字段或业务校验失败 | 显示字段级错误 |
| `eligibility_required` | 未完成有效适用范围确认 | 转入主动确认，不代填 |
| `eligibility_not_supported` | 命中不支持场景 | 保守提示/专业转介 |
| `consent_required` | 缺少该目的独立 Consent | 不发送数据 |
| `consent_revoked` | 授权已撤回 | 立即停止新处理 |
| `safety_blocked` | 危险方案被阻止 | 不展示继续原方案入口 |
| `safety_review_unavailable` | 安全评审不可用/超时 | fail-closed，保持暂停 |
| `professional_review_incomplete` | 专业门禁未完成 | 仅草案/保守方案 |
| `data_insufficient` | 数据不足 | 学习态/补录/保守降级 |
| `version_conflict` | 基线版本冲突 | 进入冲突处理 |
| `idempotency_key_reused` | 同 key 不同 payload | 严格拒绝 |
| `account_ownership_mismatch` | 账号归属不一致 | 拒绝合并/写入 |
| `dependency_unavailable` | 外部服务不可用 | 按场景降级 |
| `content_unavailable` | 内容失效/撤权 | 停止作为专业依据 |
| `offline_pending` | 当前只能保存待处理 | 显示待联网 |
| `not_found` | 对象不存在或已不可见 | 刷新本地索引 |

### 4.2 应用 API / Use-case 接口

#### Identity API

- `create_identity_draft(input, operation_id) -> IdentityDraft`
- `update_identity_draft(draft_id, patch, base_version, operation_id) -> IdentityDraft`
- `submit_identity_draft(draft_id, base_version, operation_id) -> IdentityDraft`
- `confirm_identity_draft(draft_id, base_version, user_confirmation, operation_id) -> PortraitVersion`
- `discard_identity_draft(draft_id, base_version, operation_id) -> IdentityDraft`
- `list_portrait_versions(owner_id) -> List<PortraitVersionSummary>`
- `restore_portrait_version(version_id, current_base_version, operation_id) -> PortraitVersion`

#### Domain / Goal API

- `activate_domain(domain_code, priority_rank, operation_id) -> ActiveDomain | FocusSuggestion`
- `pause_domain(domain_id, reason_code, base_version, operation_id) -> ImpactAnalysis`
- `propose_goals(portrait_version_id, domain_id, operation_id) -> GoalProposalJob`
- `confirm_goal(goal_id, patch, base_version, operation_id) -> Goal`
- `pause_goal(goal_id, reason_code, base_version, operation_id) -> Goal`
- `start_goal_recalibration(goal_id, change_context, base_version, operation_id) -> ImpactAnalysis`
- `confirm_goal_recalibration(goal_id, proposal_id, base_version, operation_id) -> Goal`
- `archive_goal(goal_id, reason_code, base_version, operation_id) -> Goal`
- `upsert_milestone(goal_id, input, base_version, operation_id) -> Milestone`

#### Eligibility / Consent API

- `present_eligibility(declaration_version, purpose_code, operation_id) -> EligibilityDeclaration`
- `submit_eligibility(declaration_id, answers, explicit_user_action, base_version, operation_id) -> EligibilityDecision`
- `get_current_eligibility(purpose_code) -> EligibilityDeclaration?`
- `request_consent(purpose_code, data_categories, scope, recipient, policy_version, operation_id) -> ConsentReceipt`
- `grant_consent(receipt_id, explicit_user_action, base_version, operation_id) -> ConsentReceipt`
- `deny_consent(receipt_id, explicit_user_action, base_version, operation_id) -> ConsentReceipt`
- `revoke_consent(receipt_id, reason_code, base_version, operation_id) -> RevocationImpact`
- `get_visibility_manifest(purpose_code, recipient_id?) -> VisibilityManifest`

#### Plan / Conflict / Safety API

- `request_plan_generation(goal_ids, period, operation_id) -> PlanGenerationJob`
- `get_plan_generation_status(job_id) -> PlanGenerationStatus`
- `cancel_plan_generation(job_id, operation_id) -> AgentRun`
- `confirm_plan(plan_version_id, base_version, operation_id) -> PlanVersion`
- `apply_minor_adjustment(proposal_id, base_version, operation_id) -> PlanVersion`
- `revert_plan_adjustment(plan_version_id, operation_id) -> PlanVersion`
- `accept_conflict_recommendation(conflict_id, base_version, operation_id) -> PlanVersion`
- `resolve_conflict_manually(conflict_id, user_patch, base_version, operation_id) -> PlanVersion`
- `report_safety_signal(scope, signal, operation_id) -> SafetyEvent`
- `select_safe_alternative(safety_event_id, alternative_id, operation_id) -> PlanVersion`
- `request_safety_reassessment(safety_event_id, new_evidence_ids, operation_id) -> SafetyReviewJob`

#### Execution / Feedback API

- `start_execution(plan_action_id, operation_id, occurred_at) -> ExecutionRecord`
- `pause_execution(execution_id, operation_id, occurred_at) -> ExecutionRecord`
- `resume_execution(execution_id, operation_id, occurred_at) -> ExecutionRecord`
- `skip_execution(plan_action_id, reason_code?, operation_id, occurred_at) -> ExecutionRecord`
- `complete_execution(execution_id, completion_source, operation_id, occurred_at) -> ExecutionRecord`
- `revert_execution(execution_id, reason_code, operation_id) -> ExecutionRecord`
- `record_feedback(execution_id, rpe_state/value, pain_state/value, quality_state/value, operation_id) -> FeedbackRecord`
- `correct_feedback(feedback_id, corrected_fields, operation_id) -> FeedbackRecord`

#### Portrait / Fusion API

- `list_portrait_candidates() -> List<PortraitCandidate>`
- `accept_portrait_candidate(candidate_id, base_portrait_version, operation_id) -> PortraitVersion`
- `reject_portrait_candidate(candidate_id, reason_code?, operation_id) -> PortraitCandidate`
- `set_fusion_collection_enabled(domain_id, enabled, operation_id) -> ConsentImpact`
- `set_fusion_generation_enabled(domain_id, enabled, operation_id) -> ConsentImpact`
- `correct_derived_content(content_id, patch, base_version, operation_id) -> DerivedContent`
- `request_knowledge_evaluation(source_content_id, target_goal_id, operation_id) -> KnowledgeEvaluationJob`
- `decide_knowledge_suggestion(suggestion_id, decision, patch?, base_version, operation_id) -> KnowledgeSuggestion`

#### Sync API

- `enqueue_sync_operation(operation) -> SyncOperation`
- `push_operations(owner_id, device_id, after_device_seq, operations[]) -> SyncBatchResult`
- `pull_changes(owner_id, cursor, visibility_scope) -> ChangeBatch`
- `acknowledge_changes(owner_id, cursor, operation_id) -> SyncCursor`
- `list_sync_conflicts(owner_id) -> List<SyncConflict>`
- `resolve_sync_conflict(conflict_id, resolution, operation_id) -> SyncConflict`
- `retry_sync_operation(operation_id) -> SyncOperation`

### 4.3 Repository 接口清单

所有 Repository MUST 以 `owner_id` 隔离，读取默认排除 tombstone；需要审计时提供包含历史版本的专用查询。

- `SubjectRepository`
  - `get_current_subject()`
  - `bind_guest_to_account(...)`
  - `switch_subject(...)`
- `IdentityRepository`
  - `get_draft(id)` / `save_draft(...)`
  - `get_active_portrait()` / `list_portrait_versions()`
  - `append_portrait_candidate(...)` / `activate_portrait_version(...)`
- `DomainRepository`
  - `list_active_domains()` / `save_domain_version(...)`
- `GoalRepository`
  - `get_goal(id)` / `list_by_domain(domain_id, states)`
  - `save_goal_version(...)` / `list_milestones(goal_id)`
- `ObservationRepository`
  - `append_observation(...)`
  - `list_valid_observations(types, at_us)`
  - `append_correction(...)`
- `EligibilityRepository`
  - `get_current_valid(purpose_code, at_us)`
  - `append_declaration(...)`
  - `supersede_current(...)`
- `ConsentRepository`
  - `get_effective_consent(purpose_code, recipient, at_us)`
  - `append_receipt(...)`
  - `revoke(...)`
  - `list_audit_history(...)`
- `VisibilityPolicyRepository`
  - `get_manifest(purpose_code, policy_version)`
  - `validate_payload(manifest, payload_fields)`
- `PlanRepository`
  - `get_active_plan(period)` / `get_plan_version(id)`
  - `append_plan_version(...)`
  - `activate_version_if_reviews_pass(...)`
  - `list_actions(version_id, time_range)`
- `ExecutionRepository`
  - `get_or_create_attempt(plan_action_id, operation_id)`
  - `append_event(...)`
  - `reduce_current_state(execution_id)`
  - `append_feedback(...)`
- `ConflictRepository`
  - `append_conflict(...)` / `resolve_conflict(...)`
- `SafetyRepository`
  - `append_safety_event(...)`
  - `get_effective_block(scope)`
  - `append_reassessment(...)`
- `AgentRunRepository`
  - `create_job(...)` / `append_role_decision(...)` / `update_job_state(...)`
- `EvidenceRepository`
  - `link_evidence(...)` / `invalidate_evidence(...)` / `list_for_subject(...)`
- `FusionRepository`
  - `append_derived_content(...)` / `append_knowledge_suggestion(...)`
  - `list_by_parent(...)`
- `AuditRepository`
  - `append(record)` / `list_by_object(...)`
- `SyncRepository`
  - `enqueue(operation)` / `next_batch(...)` / `mark_synced(...)`
  - `append_conflict(...)` / `resolve_conflict(...)`
  - `save_cursor(...)`
- `TombstoneRepository`
  - `create_tombstone(...)` / `list_pending()`

---

## 5. 离线幂等与冲突优先级

### 5.1 离线能力矩阵

| 能力 | 离线读取 | 离线写入 | 离线最终结论 |
|---|---:|---:|---|
| 已确认目标边界版本/目标/里程碑 | 是 | 草案、暂停请求可写 | 复杂重校准待同步 |
| 已缓存今日计划/动作说明 | 是 | 是 | 使用缓存版本；不伪造新专业审核 |
| 开始/暂停/完成/撤销 | 是 | 是，追加事件 | 本地立即生效 |
| RPE/疼痛/能量 | 是 | 是 | 新疼痛立即本地安全暂停 |
| Pulse | 是 | 是 | 完整本地，不锁训练 |
| 新目标 AI 推导 | 缓存结果可读 | 请求可排队 | 无网不伪生成结果 |
| 新完整计划/多职责评审 | 缓存计划可读 | 请求可排队 | 未完成安全评审不得 ready |
| 知识注入评估 | 已缓存结论可读 | 导入/请求可排队 | 不自动注入 |
| 第三方模型调用 | 否 | 只排队 | 离线绝不外发或伪结果 |
| Consent 撤回 | 是 | 是 | 本地立即停止新处理，后续传播待同步 |
| 数据导出/云端删除 | 本地范围可准备 | 请求可排队 | 云端完成状态待同步 |

### 5.2 幂等合同

1. 每次用户意图生成稳定 `operation_id`，从 UI 重试、进程恢复、同步重放到服务端确认都不改变。
2. 每个追加事实有唯一 `event_id`；`event_id` 重放只返回既有结果。
3. `(owner_id, device_id, device_seq)` 唯一，设备序列不得回退或复用。
4. 服务端/SyncAdapter 保存 `operation_id + payload_hash + result_ref`：
   - 同 key + 同 hash：返回原结果；
   - 同 key + 不同 hash：`idempotency_key_reused`，不得择一覆盖。
5. PR、方向候选（兼容 `PortraitCandidate`）、计划调整等衍生副作用必须以原始事件 ID 作为去重输入；重复执行同步不得重复生成。
6. 一次“完成 + 反馈”可共享 `correlation_id`，但完成事件与反馈事件使用不同 `event_id`，避免部分失败时整组重复。
7. 重试不能创建新的安全通过或 Consent；必须引用原审核/授权版本。

### 5.3 冲突优先级（从高到低）

| 优先级 | 冲突类型 | 决策规则 |
|---:|---|---|
| 1 | 账号所有权 | 不同 `owner_id` 的数据拒绝自动合并，进入账号合并专门流程 |
| 2 | 安全阻止 / 新安全限制 | 更严格且当前有效的安全状态优先；旧设备、旧计划、用户普通编辑不得覆盖 |
| 3 | Consent 撤回/拒绝/过期 | 更严格状态优先；撤回立即阻止新采集/发送，时间戳只用于审计而非放宽授权 |
| 4 | 适用范围失效/命中不支持 | `ineligible/rejected/unavailable/expired/superseded` 优先于旧 `eligible_confirmed` |
| 5 | 已发生执行事实 | 追加保留；云端新计划不得删除或改写过去的开始/完成/RPE/疼痛事实 |
| 6 | 用户上游输入 vs 系统建议 | 用户对目标、时间、场景、现实约束和知识注入开关的显式修改优先；建议保留审计但不覆盖 |
| 7 | 目标边界版本并发修改 | 不自动字段合并；保留两个兼容候选，用户解决其上游输入冲突后生成新版本，不定义角色身份 |
| 8 | 计划版本并发 | 版本并存；实际执行继续绑定当时版本；Atlas 基于有效上游约束与独立安全结论决定未来版本并解释差异和影响 |
| 9 | 普通冲突 | Atlas 自主编排并解释；用户通过修改上游约束影响后续版本，系统不得静默删除目标或要求逐项审批 |
| 10 | 非关键展示偏好 | 可采用最新明确用户操作；仍保留版本与账号隔离 |

### 5.4 对象级合并规则

- **执行**：append-only；相同 `event_id` 去重，不进行 last-write-wins。
- **疼痛/安全观测**：追加并允许更正链；删除旧值不能使当前风险自动消失，须重新评估。
- **目标**：用户显式状态变化优先于普通建议；两个设备并发改目标核心字段进入冲突，不按更新时间静默覆盖。
- **计划**：保留版本；过去执行绑定旧版本，未来时间槽绑定 Atlas 基于有效上游约束和独立安全结论生成的新版本；展示触发来源、依据、差异和影响，不逐项审批。
- **目标边界版本**：`Portrait*` 仅为兼容对象名；系统推断只生成可修改候选，并发变更不得定义用户角色、身份或人格。
- **Consent**：拒绝/撤回/过期采用更严格结果；扩大授权必须新回执，禁止字段并集。
- **删除**：有效 tombstone 防止旧设备复活对象；审计/法定保留与用户界面删除分开处理。
- **调性**：当前会话已确认 `tone_version` 作为新输出真源；历史内容不回写。

### 5.5 时钟与排序

- 业务发生时间使用 `occurred_at_us + timezone_id + timezone_offset_min`；同步时间使用 `recorded_at_us/synced_at_us`，二者不得混为一项。
- 不可信设备时间不得用于放宽 Consent、解除安全阻止或判断准入有效；此类有效性使用可信策略时钟，具体服务端/本地可信时间方案 BLOCKED 至架构实现阶段。
- 同设备事件顺序以 `device_seq` 为准；跨设备无天然先后且涉及核心字段时进入版本冲突，不能靠毫秒/微秒“谁晚谁赢”。

---

## 6. 第三方模型字段级可见矩阵

### 6.1 三层可见原则

- **设备可见**：用户全部本地输入和缓存，但仍受账号隔离、设备安全与删除策略约束。
- **PrimeAtlas 服务端可见**：仅在用户启用云同步/云能力且有相应目的时，接收完成该能力所需最小字段；本矩阵不假设所有字段都会上传。
- **第三方模型可见**：必须同时满足具体任务、字段白名单、独立 Consent、默认去标识化、接收方/用途/保留策略已记录；默认不得用于训练通用模型。

### 6.2 字段矩阵

| 数据字段/类别 | 仅设备 | PrimeAtlas 服务端 | 第三方模型默认 | 独立 Consent 后第三方 | 变换/限制 |
|---|---:|---:|---:|---:|---|
| `owner_id/account_id/email/phone` | 是 | 账号能力必要时 | 否 | 否 | 模型只用请求级伪名 `subject_alias` |
| `device_id`, 推送 token | 是 | 同步/推送必要时 | 否 | 否 | 不进入模型 payload |
| 身份原始自由文本/完整叙事 | 是 | 身份云推理启用时最小范围 | 否 | 默认否 | 优先发送用户批准的任务摘要，不发送完整叙事 |
| `current_identity_summary` | 是 | 任务需要时 | 条件可见 | 是 | 去标识、限当前任务 |
| `target_identity_summary` | 是 | 任务需要时 | 条件可见 | 是 | 去标识、限当前任务 |
| 内部标签 | 是 | 规则/推荐必要时 | 否 | 条件可见 | 仅发送与任务直接相关的类别，禁止人格定性扩散 |
| 活跃域代码 | 是 | 是，若同步/编排 | 条件可见 | 是 | 最多发送当前任务相关域 |
| 目标标题原文 | 是 | 云生成/同步需要时 | 否 | 条件可见 | 优先结构化 `goal_type + target_state` |
| 目标结构化摘要、里程碑约束 | 是 | 云计划任务需要时 | 条件可见 | 是 | 去标识、删除无关目标 |
| 日历事件标题/参与人/地点原文 | 是 | 默认否 | 否 | 默认否 | 仅派生 `available_window`；原文不得进模型 |
| 位置精确坐标/历史轨迹 | 是 | 默认否 | 否 | 默认否 | 仅派生场地类别/可用设备；需位置独立 Consent |
| 场地、器材、时间窗类别 | 是 | 计划任务需要时 | 条件可见 | 是 | 类别化，不含具体地址 |
| 年龄/出生日期 | 是 | 准入/规则必要时 | 否 | 默认否 | 第三方只收 `adult_eligibility_passed=true`，不得发送生日 |
| 适用范围逐项回答 | 是 | 审计/规则必要时 | 否 | 否 | 模型只获“是否允许进入普通方案”结果；原回答不外发 |
| 健康、伤病、疾病、孕期原文 | 是 | 明确启用且目的必要时最小范围 | 否 | 仅字段清单明确时 | 优先本地/PrimeAtlas确定性安全规则；不得打包原文 |
| 疼痛原始备注 | 是 | 安全同步必要时 | 否 | 默认否 | 可发送规则派生的 `safety_constraint_code`，不得发送自由文本 |
| 疼痛等级/部位类别 | 是 | 安全能力必要时 | 否 | 条件可见 | 必须健康/第三方模型双重独立 Consent；只发最小类别 |
| 睡眠、HRV、静息心率原始序列 | 是 | 启用云分析时最小范围 | 否 | 默认否 | 优先发送派生等级、充分度、新鲜度 |
| 准备度/恢复派生等级 | 是 | 云调整需要时 | 条件可见 | 是 | `low/medium/high/recovering/insufficient`，避免原始健康数据 |
| RPE 数值 | 是 | 云计划调整启用时 | 否 | 条件可见 | 仅当前受影响动作/窗口；健康类独立 Consent |
| 执行事实摘要 | 是 | 同步/调整需要时 | 条件可见 | 是 | 发送动作类型、完成状态、时间窗口；去除账号标识 |
| 完整执行历史 | 是 | 同步启用时 | 否 | 默认否 | 模型任务只取窗口化聚合，不取全史 |
| 知识/笔记/书摘原文 | 是 | 云知识评估启用时最小范围 | 否 | 仅用户选择的有界片段 | 每次选择具体片段；记录来源、版权和目的 |
| 笔记标题、标签 | 是 | 同步启用时 | 否 | 条件可见 | 只发送当前片段必要上下文 |
| 专业内容规则与内容版本 | 是 | 是 | 条件可见 | 是 | 可发送已授权/自研规则片段，不泄露无关用户数据 |
| 已确认计划完整内容 | 是 | 同步/云评审启用时 | 否 | 默认否 | 模型只收当前任务相关计划片段和约束 |
| `safety_constraint_codes` | 是 | 是 | 条件可见 | 是 | 结构化、无疾病原文；不得让模型绕过规则结论 |
| 方向候选/目标边界版本历史全集（兼容 Portrait 对象） | 是 | 同步启用时 | 否 | 否 | 仅发送当前任务已确认版本的最小摘要 |
| Consent/撤回审计全文 | 是 | 审计必要时 | 否 | 否 | 模型只接收布尔能力门控，不见回执细节 |
| Agent 私有推理链 | 不应持久化为用户数据 | 不应记录 | 否 | 否 | 只保存结构化结论、证据、规则、版本 |
| Audit 日志 | 是 | 是，按政策 | 否 | 否 | 日志本身不得含敏感原文 |

### 6.3 任务级模型 Input Manifest

每次第三方模型调用 MUST 先生成并审计 `input_manifest`，至少包含：

- `purpose_code`
- `recipient_id`
- `model_id/model_version`
- `visibility_policy_version`
- `consent_receipt_id`
- `field_paths_sent[]`
- `transform_applied[]`
- `source_record_ids[]`（可使用内部引用，不含原文）
- `retention_class`
- `general_model_training_allowed=false`
- `payload_hash`
- `created_at_us`

若 payload 出现 manifest 白名单外字段，MUST 在发送前返回 `third_party_payload_blocked`。

---

## 7. 分场景 SLO、降级与 fail-closed

> 统一计时：从用户提交有效操作或本地安全信号被记录，到首个可操作、语义正确的用户可见结果。P95 设备档位、网络条件和统计窗口仍须在 Spec 的 NFR 附录冻结。

| 场景 | P95 目标 | 超时/依赖失败时仍可用 | 禁止输出 | fail-closed |
|---|---:|---|---|---:|
| 本地今日摘要首屏 | `<2s` 候选目标 | 最近有效本地摘要、同步状态 | 空白等待云 Agent | 否 |
| Pulse 首反馈 | `<100ms` | 等效按钮、可直接绕过 | 把未完成 Pulse 当训练锁 | 否 |
| 调性适配 | `≤5s` | 保持当前已确认 `tone_version` | 混合调性、改变事实/权限/安全 | 否 |
| 方向/目标引导单轮 | `≤10s` | 保存输入、稍后继续 | 系统推断写成角色身份、人格或用户事实 | 否 |
| 日内重排/小幅调整 | `≤20s` | 保留最近有效安全计划，标待处理 | 清空今日、伪称已评审 | 涉及安全则是 |
| 有界语言评测 | `≤30s` | 估计等级/未完成 | 正式权威等级 | 否 |
| 睡眠/营养非紧急建议 | `≤30s` | 一般建议、数据不足态 | 精确健康结论/诊断 | 否 |
| 安全/康复触发 | 立即暂停；完整理由 `≤30s` | 短理由、保守替代、等待复评 | 继续原危险方案 | **是** |
| 知识提取与适用性评估 | `≤60s` | 待评估、保存来源 | 自动注入、无来源结论 | 安全子评审是 |
| 完整计划与多职责评审 | `≤90s` | 进度、离开后台、已审核保守部分 | 把不完整方案标为专业 ready | **是** |
| PR/隐藏进步/趋势 | 非阻塞 | 下次回顾再展示 | 小样本惊喜、伪预测 | 否 |
| 正常网络同步 | `<5s` 候选目标 | 本地继续执行、展示待同步 | 覆盖本地事实/旧安全状态 | 安全与撤回传播是 |

### 7.1 fail-closed 场景清单

以下场景必须保持阻止/保守状态，不能因超时、离线、模型切换、数据缺失或用户普通覆盖而默认通过：

1. 训练适用范围未确认、拒绝、无法确认、已过期或命中不支持场景；
2. 急性疼痛、伤病风险、孕期/疾病/术后康复等不支持或高风险规则命中；
3. 安全/康复评审超时、不可用或规则版本缺失；
4. 安全数据过期且无法证明仍适用；
5. 计划结构/安全/专业强制检查任一失败，仍试图标记“已审核”；
6. 第三方模型调用缺独立 Consent、接收方/用途不匹配或字段超白名单；
7. Consent 已撤回/过期但离线旧设备尝试继续采集或发送；
8. 内容来源、版权、专业审核失效仍作为计划专业依据；
9. 账号所有权不匹配的同步或合并；
10. 新疼痛离线发生时尝试继续相关危险动作。

### 7.2 非安全 fail-open / 可解释降级

以下能力可保持本地或保守体验，但不得伪造云端/模型结果：

- 身份引导超时：保留输入草案；
- 普通目标生成超时：允许用户手动建探索目标；
- 普通时间编排失败：保留最近计划或让用户手调；
- 调性生成失败：保持当前专业调性模板；
- 知识评估失败：保持“待评估”，不注入；
- 融合生成关闭/失败：原域体验完整可用，无惩罚；
- 同步失败：本地执行继续，状态明确可重试；
- 可穿戴/日历/位置拒权：使用用户手动输入和保守规则。

### 7.3 外部依赖降级六要素

每个云端模型、可穿戴、日历、位置、同步和第三方内容依赖的 Spec 验收必须同时写明：

1. 仍可用能力；
2. 禁止输出；
3. 用户提示；
4. 缓存及新鲜度；
5. 重试或安全替代；
6. 审计证据。

并覆盖四类失败：权限拒绝/撤回、数据不足/异常/过期、服务超时/限流/不可用、内容失效/下架/撤权/来源不可达。

---

## 8. 必须继续保持 Spec Blocked 的未定参数

> 下列参数不得由开发“选一个常见值”或用原型硬编码值代替。对应 Requirement 在参数冻结前保持 `Spec Blocked`。

### 8.1 P0 阻塞参数

| Block ID | 未定参数 | 影响 | 解锁责任/证据 |
|---|---|---|---|
| `SB-P0-01` | 首发地区、适用法律、18 岁判断与地区例外 | Eligibility、账号、合规文案 | 产品 + 法务 |
| `SB-P0-02` | 适用范围声明逐项字段、用户可理解文案、`not_applicable` 规则 | 训练准入 | 产品 + 合规 + QA 可访问性验证 |
| `SB-P0-03` | Eligibility 有效期、状态变化触发重确认、规则版本升级策略 | 计划生成/恢复 | 安全 + 产品 + QA |
| `SB-P0-04` | 急性疼痛、伤病、负荷、恢复异常、安全暂停和复评的规则/阈值/金标 | Safety、C5、D3、AG2 | 专业内容负责人 + 合规 + QA |
| `SB-P0-05` | ACWR 的数据要求、计算窗口、阈值、数据不足行为 | 体能安全与报告 | 专业/数据 |
| `SB-P0-06` | 体能以外首发域的专业检查表和安全边界 | 多域计划 | 产品范围 + 专业负责人 |
| `SB-P0-07` | 计划何时属于“小幅、低风险、可逆”：除已确认上调≤15%、下调≤20%外的分类表、时限和回退规则 | 自动调整 | 产品 + 专业 + QA |
| `SB-P0-08` | 各计划状态的强制检查项、`partial/conservative` 可执行边界 | Plan 状态机 | 专业 + 安全 + QA |
| `SB-P0-09` | Consent 目的代码字典、字段范围、接收方、有效期、撤回传播、既有衍生数据处理 | 隐私/第三方 AI | 产品 + 隐私/法务 |
| `SB-P0-10` | 原始数据、衍生画像、索引、备份、第三方副本的保留与删除 SLA | 删除/撤回 | 法务 + 运维/产品 |
| `SB-P0-11` | 第三方模型供应方、字段白名单、保留时限、区域、训练政策和删除证明 | Visibility/Agent | 安全/隐私评审 |
| `SB-P0-12` | PrimeAtlas 服务端实际可见字段与“仅设备”承诺的能力开关 | 同步/云分析 | 产品 + 架构 + 隐私 |
| `SB-P0-13` | 12 职责各自属于确定性规则/专业内容/模型/人工的属性，读写权限、否决权限、失败接管 | Agent 合同 | 产品 + 专业 +架构评审 |
| `SB-P0-14` | 目标进展、目标邻近度、准备度、恢复、完成质量、融合的公式版本、样本、窗口、误差与禁止显示条件 | 指标呈现 | 数据 + 产品 + QA，至少 3 组金标 |
| `SB-P0-15` | PR/隐藏进步四类型规则、最小样本、去重、冷却、误判、撤销和重算 | 成果/方向候选（兼容 Portrait 对象） | 数据 + 产品 + QA |
| `SB-P0-16` | 各域“完成质量”的客观/主观证据、`unknown` 状态与来源优先级 | Execution/Evidence | 专业 + 数据 |
| `SB-P0-17` | 场景来源的新鲜度与冲突规则：用户声明、日历、位置、健康数据、系统推断的优先级 | 场景自适应 | 产品 + 数据 + 隐私 |
| `SB-P0-18` | 目标/计划/目标边界版本（兼容 Portrait 对象）并发冲突的用户上游输入解决 UI 合同与超时后的保留策略 | Sync/状态 | 产品 + 设计 + QA |
| `SB-P0-19` | 游客到账号合并、重装设备 ID、登出/切号本地缓存与删除规则 | 账号/同步隔离 | 产品 + 隐私 + 架构 |
| `SB-P0-20` | tombstone 保留期、旧设备防复活窗口、备份恢复后的再删除策略 | 删除/同步 | 隐私 + 架构 + QA |
| `SB-P0-21` | SLO 的设备档位、网络条件、计时起止、P95/P99 窗口、后台/取消行为 | NF1/AG4 | QA + 产品 + 架构 |
| `SB-P0-22` | Pulse 500ms 容差、提前松手、重复触发、切后台、触觉失败和平台等效入口细则 | G1/NF2 | 设计 + QA |
| `SB-P0-23` | 调性 cooldown 的提示频率、跨会话边界、异常恢复；必须保持“不系统阻断切换” | H1/H2 | 产品 + 设计 + QA |
| `SB-P0-24` | 统一事件 schema_version 演进、迁移兼容窗口、可信时钟策略 | 离线/审计 | Spec + 后续架构评审 |
| `SB-P0-25` | `domain_code` 首发字典与“最多 3 活跃域”的暂停/恢复/归档细则 | Identity/Goal | 产品 |
| `SB-P0-26` | 融合采集、生成、展示三个开关的粒度；关闭后旧派生内容、既有证据、撤回传播 | K1/J4 | 产品 + 隐私 + QA |
| `SB-P0-27` | 派生内容低置信阈值、用户校正如何影响历史和后续生成 | K1 | 数据/内容 + QA |
| `SB-P0-28` | 知识注入逐条拆分粒度、改造采纳补丁、渐进融入阶段完成规则 | K2 | 产品 + 专业 + QA |
| `SB-P0-29` | 内容失效后计划重审范围与缓存新鲜度 | J2/D5/K2 | 内容 + 专业 + QA |
| `SB-P0-30` | 最终 IA、页面树和路由归属；方案 A 仅是推荐候选，不能写成冻结合同 | GATE-IA | 产品 + 设计可用性验证 |

### 8.2 P1 / 对应模块前阻塞参数

| Block ID | 未定参数 | 影响 |
|---|---|---|
| `SB-P1-01` | 动作视频来源、版权、审核、下架与替代责任 | D5/J2 |
| `SB-P1-02` | 发音资源/离线包最终许可、版本与失效策略 | K1/J2 |
| `SB-P1-03` | 普通用户是否可选底层模型，或只选速度/质量/隐私策略 | Agent 设置；不得改变安全规则 |
| `SB-P1-04` | 高级审计视图展示到何种结构化细节 | AG3；仍禁止原始推理链 |
| `SB-P1-05` | 成果分享首发时机、分享副本 TTL、撤回 SLA | E3 |
| `SB-P1-06` | Apple/Google/手机号登录的首发地区与平台范围 | J1 |
| `SB-P1-07` | 精确同步 `<5s` 目标是否作为发布 SLO 及批量大小 | J5/NF1 |

### 8.3 不得重新打开的已确认产品参数

以下不是 Blocked，不应在 Spec 中重新讨论：

- 目标、方向、现实约束和证据是最高产品主轴；系统不得定义用户角色、身份或人格；
- 早期体能单域深扎 + 融合可见；
- 最多 3 个活跃成长域，每域多个目标；
- 普通冲突不硬阻断；Atlas 按用户上游约束自主编排并展示触发来源、依据、前后差异、影响和版本，不设置“一键采纳”或逐项审批；
- 安全否决独立且不可覆盖；
- 首发仅支持 18 岁以上普通健康成年人，训练方案前主动、默认未选确认；
- Pulse 可绕过，500ms 是产品建议阈值，不锁训练；
- 默认专业调性，四调性只改变表达；
- Atlas 自主执行重大与普通计划调整并保存可解释版本；安全/隐私授权保持独立，不得混成计划逐项审批；
- `PortraitCandidate/PortraitVersion` 只作兼容对象名，承载方向候选与目标边界版本，不形成角色身份或人格画像；
- 融合入口/证据默认可发现，采集和生成可关闭/撤回且无惩罚；
- 第三方模型最小必要、默认去标识、独立 Consent、默认不用于通用模型训练；
- 12 Agent 是职责/权限模型，不等于 12 个模型或真人专家；
- 六 Tab 仅为候选 IA。

---

## 9. Spec 合并建议与门禁结论

### 9.1 可直接标记为 Confirmed 的合同

- 本地优先，核心今日执行、反馈和安全暂停离线可用；
- 执行事实追加，云端计划不得覆盖；
- Consent/Eligibility/Safety/普通冲突为彼此独立的状态和权限边界；
- 用户显式控制目标、时间、场景、现实约束及是否发起知识注入；Atlas 自主决定知识采纳、计划生成和重大/普通调整，展示触发来源、依据、前后差异、影响和版本，不设置逐项审批；兼容目标边界版本不得解释为角色身份或人格画像；
- 安全、撤回、账号隔离优先于同步便利；
- 第三方模型调用前必须经过字段级 manifest 校验；
- 安全与专业未完成不得伪装 ready；
- 事件与序列化字段使用 `snake_case`；
- 时间采用 UTC 微秒 + 原时区语义；
- 未激活域零存储占位、零权重、零 Agent 上下文。

### 9.2 Spec Ready 判定

只有当以下内容全部形成唯一合同并由 QA 给出 Given/When/Then 时，相关 Requirement 才可从 `Spec Blocked` 转为 `Spec Ready`：

1. 状态转换、禁止转换与回退；
2. 字段级 Schema、数据所有者、来源、敏感级别、生命周期；
3. 接口输入、输出、错误码、幂等键；
4. 安全/Consent/Eligibility 的规则、阈值、有效期和审计；
5. 第三方模型字段 manifest、接收方、目的、保留/删除；
6. 对象级离线合并与用户冲突解决；
7. 公式、样本、误差、金标和禁止显示条件；
8. 分场景 P95、计时口径与四类外部依赖降级；
9. 候选 IA 的可用性验证和最终冻结。

### 9.3 当前门禁结论

- **产品 PRD：Accepted。**
- **本文：可作为 Spec 数据、状态、接口、同步、隐私和 SLO 章节的输入。**
- **详细架构实现：仍禁止。** 本文未选择云后端、ORM/迁移库、网络协议、队列、模型供应商或物理部署。
- **开发：仍禁止。** `SB-P0-*` 中对应模块参数未冻结前，相关 Requirement 必须保持 `Spec Blocked`。

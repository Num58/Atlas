# PrimeAtlas 产品需求文档 (PRD) V2.0

---

## 1. 文档信息

| 字段 | 内容 |
|------|------|
| **文档名称** | PrimeAtlas 产品需求文档 |
| **文档版本** | V2.0 |
| **撰写日期** | 2026-07-01 |
| **作者** | PrimeAtlas 产品团队 |
| **审核状态** | 已评审（综合评审报告 V1.0） |
| **批准人** | TBD |
| **下次评审日期** | 2026-07-15 |

### 修订历史

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|---------|------|
| V0.1 | 2026-06-15 | 初始草稿（核心需求V2.0） | 产品团队 |
| V0.2 | 2026-06-28 | 新增伙伴全场景陪伴设计 | 产品团队 |
| V1.0 | 2026-07-01 | 完整 PRD，EARS 规范化 | 产品团队 |
| V2.0 | 2026-07-01 | 采纳综合评审21项P0修正，补充训练编排算法/专业信任/视觉系统/趣味体验/市场策略 | 产品团队 |

### 配套文档索引

| 文档 | 用途 |
|------|------|
| PrimeAtlas_核心需求文档_V2.md | 产品全景概要（面向管理层） |
| PrimeAtlas_伙伴全场景陪伴设计.md | 伙伴在训练/英语/读书中的详细交互设计 |
| PrimeAtlas_训练编排与资源摄入引擎.md | 训练编排算法（NVU/ACWR/疲劳模型）+ 万能资源摄入引擎 |
| PrimeAtlas_多Agent评审体系设计.md | 11 Agent 评审委员会 + 五阶段协作模型 |
| PrimeAtlas_开放Agent协作生态设计.md | 四类 Agent 体系 + Marketplace + 数据反哺 |
| PrimeAtlas_PRD综合评审报告.md | 5 位专家评审结论 + 21 项 P0 修正清单 |
| PrimeAtlas_UX_Review_V1.0.md | UX 交互评审报告 |
| PrimeAtlas_Visual_Design_Review.md | 视觉设计评审报告 |
| PrimeAtlas_趣味体验评审报告.md | 趣味体验评审报告 |
| PrimeAtlas_市场调研评审报告.md | 市场调研评审报告 |

---

## 2. 产品概述

### 2.1 产品愿景与一句话定位

> **PrimeAtlas 是一个有灵魂的个人效能系统——AI 训练伙伴陪你变强，不只是工具，更是陪伴。**

当用户决定改变自己时，第一反应往往是健身、学英语、读书。现有产品（Keep、多邻国、微信读书）只提供模板、关卡和书架——没有一个让用户感觉"有人在陪我变强"。

PrimeAtlas 将"专项健身训练 + AI 英语听说 + AI 读书伙伴"融合为一个有机整体，核心差异化是：**一个拥有名字、性格、记忆、成长轨迹的 AI 训练伙伴贯穿始终。** 它记得你的里程碑，注意到你的异常，在你状态差时给理解而非打鸡血，在你突破时比你还激动。

### 2.2 目标市场与用户画像

#### 画像一：张逸飞（核心用户）

| 维度 | 详情 |
|------|------|
| **年龄/职业** | 26 岁 / 互联网产品经理 |
| **运动目标** | 篮球弹跳扣篮（提升垂直弹跳 15cm） |
| **英语目标** | 职场听说（英文会议无压力） |
| **核心场景** | 家（晨练 15min）→ 单位（午休 10min）→ 球场（晚练 75min） |
| **痛点** | 训练碎片化、没有专业指导、英语学了不用、孤独坚持 |
| **推荐伙伴** | Alex·赤焰 |
| **付费意愿** | 高（月收入 25K+，愿为专业指导付费） |

#### 画像二：林雨桐（扩展用户）

| 维度 | 详情 |
|------|------|
| **年龄/职业** | 32 岁 / 市场经理 |
| **运动目标** | 产后康复（核心力量重建） |
| **英语目标** | 恢复英语（留学基础但多年不用） |
| **核心场景** | 碎片化 15 分钟窗口（带娃间隙） |
| **痛点** | 时间不可控、身体状态波动大、容易放弃 |
| **推荐伙伴** | Elena·晨曦 |
| **付费意愿** | 中（愿为康复指导付费） |

#### 画像三：陈知行（潜力用户）

| 维度 | 详情 |
|------|------|
| **年龄/职业** | 21 岁 / 大学生 |
| **运动目标** | 羽毛球竞技（校队选拔） |
| **英语目标** | 考研 75+（英语一） |
| **核心场景** | 宿舍 → 课堂 → 球馆 |
| **痛点** | 预算有限、训练不系统、英语应试转能力 |
| **推荐伙伴** | 小野·疾风 |
| **付费意愿** | 低（学生预算，但社交传播力强） |

### 2.3 核心差异化优势

| 维度 | 竞品现状 | PrimeAtlas |
|------|---------|------------|
| **AI 角色** | 工具型（Siri/小爱） | **人格化伙伴**：有名字、性格、记忆、成长 |
| **健身** | 模板化计划（Keep） | **多场景编排 + AI 动态调整 + Agent 评审委员会** |
| **英语** | 关卡制（多邻国） | **只做听说 + 碎片化场景融合 + 训练中无缝切换** |
| **读书** | 书架制（微信读书） | **书籍 Agent 对话 + 伙伴共读 + 跨域知识 PR** |
| **跨模块** | 无 | **三位一体时刻**：读书→英语讨论→训练实践 |

### 2.4 产品设计铁律（5条）

| 编号 | 铁律 | 说明 |
|------|------|------|
| **I** | **"参考但不绝对"** | AI 提供分析推理过程，用户拥有最终决策权。The system shall always present AI reasoning transparently and allow user override. |
| **II** | **"场景融合"** | 不是三个独立模块的拼凑，是深度关联的有机整体。训练、英语、读书共享同一伙伴和同一数据层。 |
| **III** | **"碎片化不是妥协"** | 15 分钟 / 5 分钟 / 2 分钟均为场景化设计，不是功能阉割版。 |
| **IV** | **"AI 透明推理"** | 展示 AI 推理过程，建立信任。The system shall always display the reasoning chain behind AI recommendations. |
| **V** | **"数据自有"** | 用户数据归用户所有，可导出、可删除、可拒绝任何数据使用。The system shall provide full data portability and deletion capabilities. |

---

## 3. 用户故事

### 3.1 张逸飞（核心用户）

| 编号 | 用户故事 | 模块 |
|------|---------|------|
| US-01 | As a 产品经理想在夏天扣篮，I want 一个 AI 教练根据我的体能数据和弹跳目标编排多场景训练计划（家→单位→球场），So that 我能在忙碌的工作日里最大化训练效率。 | 训练 |
| US-02 | As a 需要英文开会的产品经理，I want 在组间休息时用英语和我的伙伴对话，So that 我能利用碎片时间提升职场英语听说能力。 | 英语 |
| US-03 | As a 想从书中找训练灵感的人，I want 和《原子习惯》的作者（书籍 Agent）以及我的训练伙伴进行三方对话，So that 书里的方法能直接应用到我的训练计划中。 | 读书 |
| US-04 | As a 已经训练 30 次的用户，I want 我的伙伴 Alex 能记住我的训练习惯并在状态差时给我合适的建议而非打鸡血，So that 我觉得被理解而不是被催促。 | 伙伴 |
| US-05 | As a 突破深蹲 PR 的用户，I want 全屏庆祝动画 + 伙伴激动欢呼 + 可分享的成就卡片，So that 我的努力被看见，仪式感驱使我继续突破。 | 激励 |

### 3.2 林雨桐（扩展用户）

| 编号 | 用户故事 | 模块 |
|------|---------|------|
| US-06 | As a 产后康复的妈妈，I want AI 根据我每天的身体状态（疲劳度、疼痛标记）动态调整康复计划，So that 我不会因为固定计划而受伤或放弃。 | 训练 |
| US-07 | As a 只有 15 分钟碎片时间的妈妈，I want 在通勤/等孩子时进行 2 分钟英语跟读训练，So that 我能在零碎时间里恢复英语能力。 | 英语 |
| US-08 | As a 深夜哄娃后想读书的人，I want 伙伴用深夜陪伴模式安静陪读，So that 深夜读书不再孤独，有人陪伴但不打扰。 | 读书 |
| US-09 | As a 长期未训练后重新开始的用户，I want 伙伴用"来了就是胜利"的态度而非追问"为什么这么久没来"，So that 我不会因为愧疚而再次逃避。 | 伙伴 |
| US-10 | As a 产后康复用户，I want 能看到核心力量的增长趋势和每周自动总结，So that 我能看到微小的进步并保持动力。 | 数据 |

### 3.3 陈知行（潜力用户）

| 编号 | 用户故事 | 模块 |
|------|---------|------|
| US-11 | As a 想进校队的大学生，I want 一个像科比一样严厉的羽毛球教练 Agent，So that 我能得到专业级训练指导。 | Agent |
| US-12 | As a 考研备考的学生，I want 在训练间隙练习考研英语口语话题，So that 训练和备考两不误。 | 英语 |
| US-13 | As a 预算有限的学生，I want 通过贡献脱敏训练数据获得会员权益，So that 我能以低成本使用专业功能。 | 数据反哺 |
| US-14 | As a 喜欢分享的大学生，I want 把训练成就生成卡片分享到朋友圈，So that 朋友们能看到我的进步并一起加入。 | 社交 |
| US-15 | As a 羽球爱好者，I want 阅读羽球技术书籍时书籍 Agent 能关联我的训练数据给出针对性建议，So that 理论直接转化为实战提升。 | 读书 |

---

## 4. 功能清单（完整分级）

### 4.1 功能模块概览

```
┌─────────────────────────────────────────────────────────────┐
│                     PrimeAtlas 功能架构                        │
├────────────┬────────────┬────────────┬──────────┬────────────┤
│  伙伴系统   │  训练模块   │  英语模块   │  读书模块  │  数据与收益  │
│  (产品灵魂)  │  (核心支柱)  │  (核心支柱)  │ (核心支柱) │  (价值感知)  │
├────────────┼────────────┼────────────┼──────────┼────────────┤
│  Agent生态  │   社交     │  激励与留存  │  数据反哺  │            │
│ (开放平台)  │ (网络效应)  │  (增长引擎)  │ (隐私合规)  │            │
└────────────┴────────────┴────────────┴──────────┴────────────┘
```

### 4.2 P0 功能清单（MVP 必做，Phase 1：3-4 个月）

#### 伙伴系统

| 编号 | 功能名称 | 描述 |
|------|---------|------|
| CP-01 | 伙伴创建与选择 | 首次启动的伙伴选择流程，5 个初始伙伴（Alex/小野/Elena/K/凛），含性格介绍和推荐匹配 |
| CP-02 | 伙伴动态头像 | 会呼吸、眨眼、随状态变化表情，PR 突破时跳起庆祝 |
| CP-03 | 伙伴基础记忆 | 记住用户训练里程碑（PR 记录、首次突破）、用户说过的关键话语 |
| CP-04 | 伙伴基础语音 | 训练中的语音鼓励，含情绪参数（兴奋/沉稳/关切） |
| CP-05 | 伙伴早安消息 | 每天首次打开的个性化早安问候，内容不重复 |
| CP-06 | Mode Shift 场景切换 | 训练→英语→读书的 1.5 秒过渡动画，伙伴人格一致语气切换 |

#### 训练模块

| 编号 | 功能名称 | 描述 |
|------|---------|------|
| TR-01 | 用户数据采集 | 六类数据采集（身体基础/运动目标/训练环境/可用器材/时间约束/伤病史） |
| TR-02 | 1RM 安全推算 | 基于次极限重量推算 1RM，含安全边界 |
| TR-03 | 单场景训练计划生成 | 基于用户数据的 AI 训练计划编排（单场景） |
| TR-04 | 训练执行页面 | 完整交互：组间计时、重量/次数录入、RPE 评分、疼痛标记 |
| TR-05 | 动作学习（三层体系） | 关键要领卡片 + 标杆视频 + 详细教学展开 |
| TR-06 | 视频资源获取与缓存 | 从云端获取动作教学视频并本地缓存 |
| TR-07 | 动作正确性判断 | 自我检查清单 + AI 参考分析 + 疼痛信号识别 |
| TR-08 | 3-2-1-GO 倒计时 | 能量光晕渐变 + 金色粒子爆发 + 伙伴语音 |
| TR-09 | 最后一组仪式 | LAST SET 横幅 + 火焰粒子 + 震动 + 伙伴语音 |
| TR-10 | PR 预警与庆祝 | AI 检测可能破 PR → 全屏金色边框 → 8 秒庆祝 → 三种风格卡片 |
| TR-11 | 训练总结 | 故事化训练总结，包含关键数据和伙伴评价 |
| TR-12 | 训练历史列表 | 按时间排列的训练记录，可查看详情 |

#### 英语模块

| 编号 | 功能名称 | 描述 |
|------|---------|------|
| EN-01 | LISA 四维能力评估 | 听力/发音可懂度/表达自发度/表达充分度的初始评估 |
| EN-02 | AI 自由对话 | 话题生成 + 难度自适应 + 基础纠错反馈 |
| EN-03 | 跟读训练 | 音素级发音比对与纠错 |
| EN-04 | 场景化对话 | 通勤/组间休息/睡前三种模式适配 |
| EN-05 | 英语 PR 系统 | 对话耐力/词汇爆发/发音突破/话题解锁/勇气 5 种 PR |
| EN-06 | 英语每周总结 | 伙伴的一封信形式，包含关键数据和鼓励 |

#### 读书模块

| 编号 | 功能名称 | 描述 |
|------|---------|------|
| RD-01 | 书籍导入与处理 | 支持 PDF 导入，文本解析与结构化 |
| RD-02 | AI 多层总结 | L0-L3 总结：一句话/摘要/章节/全书 |
| RD-03 | 书籍 Agent 对话 | 以书中专家口吻对话（基础层+关联层） |
| RD-04 | 伙伴共读体验 | 伙伴的读书笔记（读到才显形） |
| RD-05 | 读书笔记系统 | 划线/批注/语音笔记 |
| RD-06 | "知识 PR" 系统 | 检测训练中应用书中知识时触发 |
| RD-07 | 读完一本书庆祝 | 合书动画 + 伙伴感言 + 击拳动作 |
| RD-08 | 深夜读书陪伴 | 深夜时段切换安静陪伴模式 |

#### 数据与收益

| 编号 | 功能名称 | 描述 |
|------|---------|------|
| DA-01 | 综合效能仪表盘 | 训练+英语+读书的三合一总览 |
| DA-02 | 成长指数 | 加权计算训练/英语/读书/坚持度的综合指数 |
| DA-03 | 健身收益可视化 | 1RM 趋势、弹跳估算、专项能力指数 |
| DA-04 | LISA 雷达图 | 四维能力可视化 |
| DA-05 | 自动周报 | 每周自动生成跨模块周报 |

#### 激励与留存

| 编号 | 功能名称 | 描述 |
|------|---------|------|
| MT-01 | AI 语音教练 | 三种风格 + 六种 RPE 对应鼓励 |
| MT-02 | 连续训练火焰 | 连续训练天数火焰动画（递增强度） |
| MT-03 | 目标承诺仪式 | 用户设定目标时的仪式化交互 |
| MT-04 | 成就卡片分享 | 训练/英语/读书成就的可分享卡片 |

#### 基础架构

| 编号 | 功能名称 | 描述 |
|------|---------|------|
| IF-01 | 用户注册与登录 | 手机号/邮箱注册，含伙伴引导 |
| IF-02 | 本地数据加密 | SQLCipher 加密存储 |
| IF-03 | 基础推送通知 | 训练提醒、伙伴早安消息推送 |

### 4.3 P1 功能清单（Phase 2：+2-3 个月）

| 编号 | 功能名称 | 模块 | 描述 |
|------|---------|------|------|
| CP-07 | 伙伴成长等级 Lv.2-3 | 伙伴 | 10 次解锁数据分析，30 次解锁故事模式和场景对话定制 |
| CP-08 | 伙伴情绪自适应 | 伙伴 | 检测 RPE 偏离和训练时长自动调整响应策略 |
| CP-09 | 伙伴周记（一封信） | 伙伴 | 每周伙伴手写风格的总结信 |
| TR-13 | 多场景全天编排 | 训练 | 早上家→中午单位→晚上球场，全天统一编排 |
| TR-14 | ACWR 负荷监控 | 训练 | 急慢性负荷比监控，超限预警 |
| TR-15 | 疼痛熔断机制 | 训练 | 用户标记疼痛 → AI 评估 → 自动调整或终止训练 |
| TR-16 | 训练数据仪表盘 | 训练 | 详细数据可视化：体积趋势、强度分布、肌肉群热力图 |
| EN-07 | 组间休息英语无缝切换 | 英语 | 训练中组间休息自动切入 30 秒英语对话 |
| EN-08 | 难度自适应算法 | 英语 | 基于 LISA 评估和近期表现的难度动态调整 |
| EN-09 | 开车模式（纯语音） | 英语 | 纯语音交互，免操作 |
| RD-09 | 三方读书会 | 读书 | 用户+伙伴+书籍 Agent 三方讨论 |
| RD-10 | 书籍 Agent 深度对话 | 读书 | 四层深度：基础→关联→批判→应用 |
| RD-11 | 跨域关联（运动书→训练） | 读书 | 运动书籍自动关联训练计划 |
| AG-01 | Agent 评审委员会 | Agent | 11 个 Agent 交叉验证训练计划 |
| AG-02 | 五阶段圆桌协作 | Agent | 评审→辩论→融合→验证→交付 |
| DA-06 | 阅读收益量化 | 数据 | 阅读量/思考深度/知识应用率 |
| DA-07 | 自动月报 | 数据 | 每月自动生成跨模块月报 |
| MT-05 | 好友 PK | 社交 | 训练量/英语时长匿名 PK |
| MT-06 | 影子模式排行 | 社交 | 同类用户（同目标/同年龄）的匿名排行 |
| MT-07 | 流失预警 | 留存 | 检测活跃度下降触发召回 |

### 4.4 P2 功能清单（Phase 3：+2-3 个月）

| 编号 | 功能名称 | 模块 | 描述 |
|------|---------|------|------|
| CP-10 | 伙伴成长等级 Lv.4-5 | 伙伴 | 60 次解锁精准预判和跨域关联，100 次解锁自定义外观和回顾视频 |
| CP-11 | 伙伴自定义外观 | 伙伴 | 服装、配饰、主题色自定义 |
| CP-12 | 回顾视频生成 | 伙伴 | 训练历程回顾视频自动生成 |
| AG-03 | Agent Marketplace | Agent | 厂商/三方/用户 Agent 的上架与下载 |
| AG-04 | 自然语言创建 Agent | Agent | 用户说"我要像科比一样严厉的教练"→自动生成 Agent |
| AG-05 | 四类 Agent 体系 | Agent | 内置/厂商/三方/用户 Agent 管理框架 |
| AG-06 | 产品决策层 | Agent | 双层信息架构 + L1/L2/L3 权限 |
| AG-07 | Tips 生成与展示 | Agent | 多 Agent 结论的自然语言化 Tips |
| MT-08 | 碰拳社交 | 社交 | 附近用户训练完成时的碰拳交互 |
| MT-09 | 四级召回策略 | 留存 | 伙伴消息→Push→短信→人工 |
| MT-10 | 差异化留存策略 | 留存 | 三个画像不同的留存策略 |
| DP-01 | 数据反哺系统 | 数据反哺 | 四层脱敏流水线 |
| DP-02 | 用户 Opt-in 授权 | 数据反哺 | 数据贡献的授权管理界面 |
| DP-03 | 贡献者权益体系 | 数据反哺 | 青铜→白银→黄金→钻石 |
| RD-12 | 关联笔记 | 读书 | 跨书/跨模块笔记关联 |
| EN-10 | 健身术语英语学习 | 英语 | 训练场景的英语术语专项学习 |
| TR-17 | 小程序版本 | 训练 | 微信小程序端训练执行 |
| IF-04 | 数据导出 | 基础 | 用户数据完整导出（JSON/CSV） |
| IF-05 | 数据删除 | 基础 | 账户数据彻底删除（GDPR 合规） |

---


### 5.3 英语模块

#### 5.3.1 LISA 四维能力评估

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall assess the user's English speaking and listening ability across four dimensions (Listening, Intelligibility, Spontaneity, Adequacy) before generating a personalized learning path. |
| Event-driven | When the user first enters the English module, the system shall present the LISA assessment with a brief introduction: "我们先花5分钟了解一下你的英语水平。放轻松，这不是考试。" |
| Event-driven | When the assessment begins, the system shall administer 4 sub-tests: (1) Listening: 3 audio clips of increasing difficulty, answer comprehension questions; (2) Intelligibility: read 5 sentences aloud, AI scores pronunciation; (3) Spontaneity: respond to 3 open-ended questions with 30-second answers; (4) Adequacy: describe an image for 60 seconds, scoring vocabulary range and grammatical complexity. |
| Event-driven | When the assessment completes, the system shall generate a LISA radar chart with scores (0-100) for each dimension, an overall CEFR level estimate (A1-C2), and 3 personalized learning recommendations. |
| State-driven | While the user is speaking during assessment, the system shall display a waveform visualization and a "recording" indicator. |
| Unwanted | If the user exits the assessment mid-way, then the system shall save partial results and allow resumption from the last completed sub-test. |
| Unwanted | If speech recognition fails (no audio detected, excessive background noise), then the system shall prompt "听不到你的声音，检查一下麦克风？" and allow retry. |

**LISA 维度定义：**

| 维度 | 英文 | 评估内容 | 评分方式 |
|------|------|------|------|
| L | Listening | 听力理解准确度 | 选择题正确率 + 难度系数 |
| I | Intelligibility | 发音可懂度 | 音素级比对 + 流利度 |
| S | Spontaneity | 表达自发度 | 响应时间 + 停顿频率 + 填充词占比 |
| A | Adequacy | 表达充分度 | 词汇多样性 + 语法复杂度 + 内容深度 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| EN-01-AC01 | 完成完整评估 | 首次进入英语模块 | 依次完成 4 个子测试 | 生成 LISA 雷达图 + CEFR 估计 |
| EN-01-AC02 | 中途中止恢复 | 完成 2/4 测试后退出 | 重新进入英语模块 | 从第 3 个子测试继续 |
| EN-01-AC03 | 麦克风异常 | 评估中关闭麦克风权限 | 朗读句子 | 提示检查麦克风 + 允许重试 |

#### 5.3.2 AI 自由对话

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide an AI-powered free conversation experience with topic generation, adaptive difficulty, and corrective feedback. |
| Event-driven | When the user enters free conversation mode, the system shall suggest 3 conversation topics based on: (1) user's interests from profile, (2) recent training/reading activity, (3) current events (optional), with a "随机话题" option. |
| Event-driven | When the user selects a topic, the partner shall initiate the conversation in English using the partner's configured accent and speaking style. |
| Event-driven | When the user speaks, the system shall transcribe in real-time and display the transcription with subtle corrections: grammatical errors underlined in yellow, pronunciation errors in red with the correct form shown on tap. |
| Event-driven | When the user makes a significant error (grammar or pronunciation that impedes understanding), the partner shall gently interject with a correction framed as clarification: "Did you mean...?" rather than "That's wrong." |
| State-driven | While the conversation is active, the system shall track: conversation duration, word count, unique vocabulary count, error count, and speaking time ratio (user vs partner). |
| State-driven | While the difficulty is set to "adaptive", the system shall monitor the user's error rate and speaking fluency; if error rate < 5% for 3 consecutive exchanges, increase difficulty by one level (vocabulary complexity +15%, speed +5%); if error rate > 20%, decrease difficulty. |
| Unwanted | If the user is silent for 15 seconds, then the partner shall offer a gentle prompt: "Take your time." / "Want me to rephrase the question?" / "Should we try a different topic?" |
| Unwanted | If the speech recognition returns low confidence repeatedly (3+ times), then the system shall suggest switching to text input mode: "Having trouble with voice? We can type instead." |

**话题生成策略：**

| 来源 | 示例话题 | 优先级 |
|------|------|:---:|
| 用户兴趣 | "你最近在练深蹲，用英语说说你的训练计划？" | 高 |
| 训练关联 | "Describe your last workout in English." | 高 |
| 读书关联 | "Let's talk about the book you're reading." | 中 |
| 生活日常 | "What did you have for breakfast?" | 中 |
| 时事（可选） | "There's a basketball game tonight. Your thoughts?" | 低 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| EN-02-AC01 | 选择话题开始对话 | 进入自由对话 | 选择一个话题 | 伙伴用英语发起对话 |
| EN-02-AC02 | 纠错反馈 | 对话中说出错误句子 | 完成发言 | 错误标注 + 伙伴委婉纠正 |
| EN-02-AC03 | 难度自适应 | 连续 3 轮低错误率 | 继续对话 | 难度自动提升 |
| EN-02-AC04 | 长时间沉默 | 对话中沉默 15 秒 | 不说话 | 伙伴给出温和提示 |
| EN-02-AC05 | 语音识别失败 | 嘈杂环境 | 多次发言 | 3 次后建议切换到文字输入 |

#### 5.3.3 跟读训练（音素级纠错）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide phoneme-level pronunciation comparison and correction in the shadowing (跟读) training mode. |
| Event-driven | When the user enters shadowing mode, the system shall play a model sentence spoken by the partner (or native speaker recording) and display the text. |
| Event-driven | When the user records their repetition, the system shall perform phoneme-level alignment between the model audio and user audio, highlighting mispronounced phonemes in red, acceptable deviations in yellow, and correct pronunciations in green. |
| Event-driven | When the user taps a mispronounced phoneme (red), the system shall display: the target phoneme symbol, mouth shape diagram, and a "listen again" button for isolated phoneme playback. |
| Event-driven | When the user completes a set of sentences (5 sentences per set), the system shall display an overall pronunciation score and the most improved phoneme (compared to last session). |
| State-driven | While in shadowing mode, the system shall support: re-play model audio, re-record, skip sentence, and adjust playback speed (0.75x/1x/1.25x). |
| Unwanted | If the user's recording is too short (<50% of model duration), then the system shall prompt "说得太短了，再试一次？" and not score that attempt. |

**音素颜色编码：**

| 颜色 | 含义 | 偏差阈值 |
|------|------|:---:|
| 绿色 | 正确 | 置信度 > 80% |
| 黄色 | 可接受偏差 | 置信度 60-80% |
| 红色 | 需要改进 | 置信度 < 60% |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| EN-03-AC01 | 跟读并获取反馈 | 进入跟读模式 | 听→跟读 | 显示音素级颜色标注 |
| EN-03-AC02 | 点击红色音素 | 有红色标注 | 点击红色音素 | 显示音素详情 + 口型图 |
| EN-03-AC03 | 录音太短 | 进入跟读 | 只说 1 个词 | 提示"说得太短了"不评分 |
| EN-03-AC04 | 完成一组跟读 | 完成 5 句 | 查看结果 | 显示总分 + 进步音素 |

#### 5.3.4 场景化对话

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall adapt the English conversation experience to different usage scenarios: commute, between-set rest, and bedtime. |
| Event-driven | When the system detects the user is in commute mode (enabled by user or detected via motion/speed), the system shall switch to pure voice interaction: no visual UI required, all responses via TTS, large tap-to-speak button, and simplified topic selection. |
| Event-driven | When the user is in a training session and the rest timer starts (see 5.2.4), the system shall offer a "30秒英语" chip button: "来30秒英语？" which, when tapped, initiates a 30-second micro-conversation with a training-related English prompt. |
| Event-driven | When the user enters the English module during bedtime hours (22:00-06:00), the system shall switch to "睡前模式": reduced speaking speed, quieter TTS volume, calming topics (reflections, gratitude, daily summary), and dark UI theme. |
| State-driven | While in commute mode, the system shall keep the screen on with a minimal UI (large microphone button, current topic text) and auto-advance to the next topic after each exchange. |
| Unwanted | If the user is in commute mode but the system detects the user has stopped moving for 60+ seconds (likely arrived), then the system shall suggest switching to standard mode. |

**场景参数对比：**

| 参数 | 通勤模式 | 组间休息 | 睡前模式 |
|------|------|------|------|
| 交互方式 | 纯语音 | 语音+快捷选项 | 语音（轻声） |
| 单次时长 | 不限 | 30 秒 | 5-10 分钟 |
| UI 复杂度 | 极简 | 嵌入式小组件 | 深色主题 |
| 话题类型 | 日常/兴趣 | 训练相关 | 反思/感恩 |
| 语音速度 | 标准 | 标准 | -10% |
| 音量 | 标准 | 标准 | -20% |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| EN-04-AC01 | 通勤模式纯语音 | 开启通勤模式 | 使用英语模块 | 纯语音交互，极简 UI |
| EN-04-AC02 | 组间休息英语 | 训练中休息计时开始 | 点击"30秒英语" | 30 秒训练相关微对话 |
| EN-04-AC03 | 睡前模式 | 23:00 进入英语 | 开始对话 | 语速降低，音量降低，深色主题 |
| EN-04-AC04 | 通勤结束检测 | 通勤模式中停止移动 60s | 自动 | 建议切换到标准模式 |

#### 5.3.5 英语 PR 系统

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall track 6 types of English PR (Personal Records) and trigger celebrations when milestones are achieved. |
| Event-driven | When the user achieves a continuous conversation of 10+ minutes for the first time, the system shall trigger "对话耐力 PR": full-screen celebration with "你第一次说了 10 分钟英语不停顿！这个 PR 不比重量的 PR 差！" |
| Event-driven | When the user's verb diversity in a single conversation increases by 40%+ compared to their average, the system shall trigger "词汇爆发 PR": vocabulary firework animation. |
| Event-driven | When a specific phoneme accuracy improves significantly (e.g., th- from 62% to 78%), the system shall trigger "发音突破 PR": phoneme evolution animation showing the journey. |
| Event-driven | When the user discusses a new topic domain for the first time (e.g., first time discussing basketball tactics in English), the system shall trigger "话题解锁 PR": new domain badge unlocked. |
| Event-driven | When the user returns to English conversation after a previous session where they "broke down" (exited due to frustration), the system shall trigger "勇气 PR": the most special celebration — partner says "你上次在这里摔倒了。今天你站起来了。" |
| Event-driven | When the user achieves 30 total minutes of English speaking in a single week, the system shall trigger "周坚持 PR": weekly milestone celebration. |
| Unwanted | If the same PR type is triggered multiple times in a short period (e.g., 2 "词汇爆发 PR" in one day), then the system shall only celebrate the first occurrence and quietly record the second. |

**PR 类型详情：**

| PR 类型 | 触发条件 | 庆祝方式 | 冷却时间 |
|------|------|------|:---:|
| 对话耐力 PR | 首次 10 分钟不间断 | 全屏庆祝 + 伙伴感言 | 每递增 5 分钟 |
| 词汇爆发 PR | 动词多样性 +40% | 词汇烟花动画 | 24 小时 |
| 发音突破 PR | 音素准确度 +15% | 音素进化动画 | 每音素仅一次 |
| 话题解锁 PR | 首次聊新领域 | 新领域徽章 | 每领域一次 |
| 勇气 PR | 上次崩溃后回归 | 伙伴特殊对话 | 每次回归 |
| 周坚持 PR | 周总时长 ≥30 分钟 | 周报高亮 | 每周 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| EN-05-AC01 | 对话耐力 PR | 首次连续对话 10 分钟 | 达到 10 分钟 | 全屏庆祝 + 伙伴感言 |
| EN-05-AC02 | 词汇爆发 PR | 动词多样性超过平均 40% | 结束对话 | 词汇烟花动画 |
| EN-05-AC03 | 勇气 PR | 上次崩溃退出 | 重新开始对话 | 伙伴特殊鼓励对话 |
| EN-05-AC04 | 同类型 PR 冷却 | 刚触发词汇爆发 PR | 再次触发 | 仅记录不庆祝 |

#### 5.3.6 碎片化场景适配

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall support micro-learning sessions of 30 seconds to 5 minutes across all English training modes. |
| Event-driven | When the user says "来，练两句" (voice command or taps quick-start), the partner shall immediately switch to English mode and initiate a 2-minute rapid conversation. |
| Event-driven | When the user is idle on the home screen, the system shall occasionally display a "微挑战" card: e.g., "等电梯的 30 秒，用英语说出你今天要练的三个动作". |
| Event-driven | When the user opens the app during a non-training time window (e.g., lunch break), the system shall suggest a 5-minute English quick session based on the user's recent learning focus. |
| State-driven | While in a micro-session, the system shall display a prominent countdown timer and auto-end the session when time expires, with a summary of what was accomplished. |
| Unwanted | If the user starts a micro-session but the app is backgrounded, then the session shall be paused and the remaining time preserved for 10 minutes before being discarded. |

**微会话类型：**

| 时长 | 类型 | 内容示例 |
|:---:|------|------|
| 30 秒 | 快速问答 | "What exercise are you doing today?" |
| 1 分钟 | 主题描述 | "Describe your training plan in 1 minute" |
| 2 分钟 | 角色扮演 | "You're ordering a protein shake. Go!" |
| 5 分钟 | 迷你辩论 | "Cardio vs weights — your take?" |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| EN-06-AC01 | 语音快速启动 | 在首页 | 说"来，练两句" | 立即进入 2 分钟英语对话 |
| EN-06-AC02 | 微挑战卡片 | 首页空闲 10 秒 | 观察 | 显示 30 秒微挑战卡片 |
| EN-06-AC03 | 微会话倒计时 | 开始 2 分钟会话 | 观察 | 倒计时显示，到时自动结束 |
| EN-06-AC04 | 后台暂停 | 微会话中切换到微信 | 10 分钟内回来 | 会话暂停，可继续 |

#### 5.3.7 英语每周总结

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall generate a weekly English learning summary every Sunday at 20:00, presented as "伙伴的一封信". |
| Event-driven | When the weekly summary is generated, the system shall send a push notification: "[伙伴名] 给你写了一封英语周报。" |
| Event-driven | When the user opens the weekly summary, the system shall display a letter-style layout with the partner's avatar in the corner, including: (1) total speaking minutes, (2) longest continuous conversation, (3) vocabulary diversity trend, (4) pronunciation improvements, (5) topics discussed, (6) one personalized encouragement, (7) next week's suggested focus. |
| State-driven | While the user is reading the weekly summary, the system shall offer a "read aloud" option where the partner reads the letter in English. |
| Unwanted | If the user had zero English activity in the week, then the summary shall be a gentle check-in: "这周没练英语。没关系，下周从 2 分钟开始？" without any guilt-inducing language. |

**周报示例：**

```
"这周你说了 87 分钟英语。最长一次连续说了 12 分钟——新纪录。
 你在周二那次对话里用了 23 个不同的动词，比上周多了 40%。
 你第一次用英语聊了篮球战术。虽然'pick and roll'说成了'pick and roll over'，
 但对面听懂了。听懂了就是胜利。
 下周，我们试试用英语和《原子习惯》的作者聊一聊？"
```

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| EN-07-AC01 | 正常周报 | 本周有英语活动 | 周日 20:00 查看 | 完整周报 + 数据 + 鼓励 |
| EN-07-AC02 | 零活动周 | 本周无英语活动 | 周日 20:00 查看 | 温和关怀，无负罪感语言 |
| EN-07-AC03 | 语音朗读 | 打开周报 | 点击朗读 | 伙伴用英语朗读周报 |

---

### 5.4 读书模块

#### 5.4.1 书籍导入与处理

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall support importing reading materials in PDF format, with automatic text extraction, chapter segmentation, and structured storage. |
| Event-driven | When the user taps "导入书籍" and selects a PDF file, the system shall upload the file, extract text content, detect chapter boundaries (via heading patterns), and create a structured book record within 30 seconds for a 500-page book. |
| Event-driven | When the text extraction completes, the system shall display a confirmation page showing: detected title, author (if extractable), chapter count, page count, and a preview of the first chapter's text. |
| State-driven | While the PDF is being processed, the system shall display a progress bar with the current stage: "上传中..." → "提取文本..." → "识别章节..." → "生成摘要...". |
| Unwanted | If the PDF is a scanned image (no extractable text), then the system shall display "无法识别文本内容。请确保 PDF 包含可选择的文字，而非扫描图片。" and reject the import. |
| Unwanted | If the file exceeds 100MB, then the system shall reject the upload with "文件过大，请压缩后重试（最大 100MB）。" |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-01-AC01 | 导入文本 PDF | 选择可提取文本的 PDF | 点击导入 | 30s 内完成提取+章节识别 |
| RD-01-AC02 | 导入扫描版 PDF | 选择扫描图片 PDF | 点击导入 | 提示无法识别，拒绝导入 |
| RD-01-AC03 | 文件过大 | 选择 150MB PDF | 点击导入 | 提示文件过大 |
| RD-01-AC04 | 确认导入结果 | 处理完成 | 查看确认页 | 显示书名/作者/章节/预览 |

#### 5.4.2 AI 多层总结

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall generate multi-level AI summaries for imported books, from single-sentence to full-book synthesis. |
| Event-driven | When a book is successfully imported, the system shall automatically generate L0-L2 summaries in the background. |
| Event-driven | When the user requests L3 (全书总结), the system shall generate it on-demand and cache the result. |
| Event-driven | When the user requests L4 (跨域关联总结), the system shall analyze the book's content against the user's training data and English learning history to find actionable connections. |
| Event-driven | When the user requests L5 (批判性总结), the system shall generate a critical analysis including: potential biases, alternative viewpoints, and questions for further exploration. |
| State-driven | While L3-L5 summaries are generating, the system shall display the partner avatar in "reading/thinking" pose with a progress indicator. |
| Unwanted | If the book content is too short to generate a meaningful summary (<1000 words), then the system shall generate L0-L1 only and display "内容较短，部分总结层级不可用" for L2+. |

**总结层级定义：**

| 层级 | 名称 | 长度 | 触发方式 | 内容 |
|:---:|------|:---:|------|------|
| L0 | 一句话总结 | 1 句 | 导入后自动 | 核心观点一句话 |
| L1 | 章节摘要 | 3-5 句/章 | 导入后自动 | 每章核心内容摘要 |
| L2 | 全书概览 | 300-500 字 | 导入后自动 | 全书结构+核心论点+关键概念 |
| L3 | 全书总结 | 800-1500 字 | 用户手动触发 | 深度分析+逻辑链+案例总结 |
| L4 | 跨域关联 | 500-800 字 | 用户手动触发 | 与训练/英语的关联点 |
| L5 | 批判性总结 | 500-1000 字 | 用户手动触发 | 偏见分析+替代观点+延伸问题 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-02-AC01 | 自动生成 L0-L2 | 书籍导入完成 | 等待 | L0-L2 自动生成 |
| RD-02-AC02 | 手动生成 L3 | 书籍已导入 | 点击"全书总结" | 生成 800-1500 字总结 |
| RD-02-AC03 | 生成 L4 跨域关联 | 有训练数据 | 点击"跨域关联" | 关联训练和英语数据 |
| RD-02-AC04 | 内容太短 | 导入短文(<1000词) | 查看总结 | 仅 L0-L1 可用，L2+ 提示不可用 |

#### 5.4.3 书籍 Agent 对话

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall create a book-specific AI Agent that converses in the persona of the book's author or core perspective, with configurable depth levels. |
| Event-driven | When the user taps "与作者对话" on a book, the system shall create a Book Agent with a system prompt based on the book's content, author's known style, and core arguments. |
| Event-driven | When the user asks a question at depth level 1 (基础理解), the Book Agent shall answer by directly referencing the book's content with page/chapter citations. |
| Event-driven | When the user switches to depth level 2 (关联延伸), the Book Agent shall connect the book's ideas to related concepts from other works or real-world examples. |
| Event-driven | When the user switches to depth level 3 (批判讨论), the Book Agent shall present counterarguments, limitations of the author's view, and invite the user to form their own opinion. |
| Event-driven | When the user switches to depth level 4 (应用实践), the Book Agent shall help the user create actionable plans based on the book's principles, integrating with the training module where relevant. |
| State-driven | While in Book Agent conversation, the system shall display the current depth level as a badge and allow switching via a dropdown. |
| Unwanted | If the Book Agent cannot find relevant content for the user's question, then it shall honestly respond: "这本书里没有直接讨论这个话题。不过根据作者的整体思路，我的推测是..." clearly marking speculation vs. fact. |

**四层深度示例（以《原子习惯》为例）：**

| 深度 | 用户问题 | Book Agent 回答风格 |
|:---:|------|------|
| 1-基础 | "什么是身份驱动习惯？" | 引用第 2 章原文，解释核心概念 |
| 2-关联 | "这和《刻意练习》有什么不同？" | 对比两本书的观点，找出互补和冲突 |
| 3-批判 | "这个理论有什么局限性？" | 分析适用边界，提出反例 |
| 4-应用 | "怎么用这个改掉熬夜习惯？" | 制定具体行动计划，关联训练日程 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-03-AC01 | 基础对话 | 书籍已导入 | 问基础问题 | 引用原文回答 |
| RD-03-AC02 | 切换深度层级 | 对话中 | 切换深度到批判 | 回答风格变为批判性分析 |
| RD-03-AC03 | 超出书内容 | 书籍已导入 | 问书中没有的话题 | 明确标注推测 vs 事实 |
| RD-03-AC04 | 应用实践 | 有训练数据 | 深度 4 问应用问题 | 生成含训练关联的行动计划 |

#### 5.4.4 伙伴共读体验

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide a co-reading experience where the partner leaves notes and annotations on the book, revealed progressively as the user reads. |
| Event-driven | When the user finishes reading a chapter or a significant section (detected by scroll position), the partner's notes for that section shall "fade in" with a subtle animation (like invisible ink appearing), ensuring no spoilers. |
| Event-driven | When a partner note appears, the system shall display it in the partner's signature color and style, clearly distinguished from the user's own notes. |
| Event-driven | When the user taps the visibility toggle, the system shall switch between "只看自己的笔记" / "也看伙伴的笔记" / "隐藏所有笔记" modes. |
| Event-driven | When the user taps a partner note, the system shall allow the user to "respond" to the partner's note, initiating a threaded discussion on that passage. |
| State-driven | While the user is reading, the partner avatar shall be displayed in the corner in "reading" pose (holding a book, occasional page turns). |
| Unwanted | If the user scrolls rapidly (skimming), then the system shall NOT reveal partner notes to avoid spoiling content the user hasn't actually read. (Use scroll velocity threshold: <500px/s considered "reading") |

**伙伴笔记浮现规则：**

| 条件 | 行为 |
|------|------|
| 用户滚动速度 < 500px/s | 视为"正在阅读"，到达位置后浮现笔记 |
| 用户滚动速度 ≥ 500px/s | 视为"快速浏览"，不浮现笔记 |
| 用户停留在某页 > 10 秒 | 视为"仔细阅读"，提前浮现该页笔记 |
| 用户已读过该章节（历史记录） | 立即显示所有笔记（不隐藏） |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-04-AC01 | 读到后浮现笔记 | 有伙伴笔记的书 | 正常阅读到有笔记的位置 | 笔记淡入显示 |
| RD-04-AC02 | 快速滚动不浮现 | 有伙伴笔记的书 | 快速滚动 | 笔记不浮现 |
| RD-04-AC03 | 切换笔记可见性 | 已有笔记显示 | 点击切换按钮 | 循环切换三种模式 |
| RD-04-AC04 | 回复伙伴笔记 | 伙伴笔记已显示 | 点击笔记→回复 | 进入线程讨论 |

#### 5.4.5 读书笔记系统

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall support four types of reading annotations: highlight, text note, voice note, and linked note (cross-book/cross-module). |
| Event-driven | When the user selects text and chooses "划线", the system shall highlight the text in the user's chosen color (yellow/green/blue/purple) and save the highlight with position data. |
| Event-driven | When the user selects text and chooses "批注", the system shall open a text input panel where the user can write a note attached to the selected passage. |
| Event-driven | When the user taps the "语音笔记" button, the system shall start recording and transcribe the user's spoken note, attaching both the audio and transcription to the current passage. |
| Event-driven | When the user creates a linked note, the system shall allow the user to reference another book, a training session, or an English conversation, creating a bidirectional link between the two items. |
| State-driven | While recording a voice note, the system shall display a waveform visualization and a running transcription. |
| Unwanted | If the user attempts to create a highlight that overlaps with an existing highlight, then the system shall merge the highlights and append the new note to the existing annotation thread. |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-05-AC01 | 划线标注 | 阅读中 | 选中文字→划线 | 高亮显示，保存位置 |
| RD-05-AC02 | 文字批注 | 阅读中 | 选中文字→批注→输入 | 批注附加到选中文本 |
| RD-05-AC03 | 语音笔记 | 阅读中 | 语音笔记→说话 | 录音+转写保存 |
| RD-05-AC04 | 关联笔记 | 阅读中 | 创建关联→选训练记录 | 双向链接建立 |

#### 5.4.6 "知识 PR" 系统

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall detect when the user applies knowledge from reading to real-world training or English practice, and trigger a "知识 PR" celebration. |
| Event-driven | When the system detects a correlation between a book concept and a user's training behavior change (e.g., user adjusted barbell placement consistent with a book recommendation), the system shall flag it as a potential Knowledge PR candidate. |
| Event-driven | When a Knowledge PR is confirmed (AI confidence ≥80%), the system shall trigger the celebration at the end of the training session: display the relevant book excerpt, the training action, and the "知识 PR" golden text animation. |
| Event-driven | When the Knowledge PR celebration appears, the partner shall deliver a personalized acknowledgment connecting the reading to the action. |
| State-driven | While the Knowledge PR is displayed, the system shall offer a "查看书中原文" button linking back to the exact passage in the book. |
| Unwanted | If the AI confidence is between 60-80%, then the system shall present it as a "可能的关联" hint rather than a full PR celebration: "我们注意到你今天调整了杠铃位置。这和你上周读的《原子习惯》第6章有关吗？" |

**检测策略：**

| 书的概念 | 训练中的表现 | 检测方法 |
|------|------|------|
| 习惯堆叠 | 连续在同一时间训练 | 时间模式匹配 |
| 环境设计 | 训练前准备器材 | 训练前行为变化 |
| 身份驱动 | 训练标题/目标语句变化 | NLP 语义匹配 |
| 渐进负荷 | 按计划逐步加重 | 数据趋势匹配 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-06-AC01 | 知识 PR 触发 | 读书后在训练中应用 | 训练结束 | 金色"知识 PR"庆祝 |
| RD-06-AC02 | 低置信度提示 | 可能关联但不确认 | 训练结束 | "可能的关联"温和提示 |
| RD-06-AC03 | 查看书中原文 | 知识 PR 展示中 | 点击"查看原文" | 跳转到书中对应位置 |

#### 5.4.7 读完一本书的庆祝

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall trigger a special celebration ceremony when the user completes reading a book, with personalized partner response. |
| Event-driven | When the user reaches the last page of a book (scroll position ≥98%), the system shall display a "即将读完" subtle indicator. |
| Event-driven | When the user turns past the final page, the system shall trigger the completion ceremony: (1) 3 seconds of silence with the book cover displayed, (2) book closing sound effect, (3) golden light gathering animation, (4) partner's personalized completion speech, (5) statistics display: reading duration, note count, discussion count, (6) fist-bump gesture from partner. |
| Event-driven | When the ceremony completes, the system shall add the book to the "已读完" shelf with a completion badge and offer "下一本推荐". |
| State-driven | While the ceremony is playing, the system shall block all navigation. |
| Unwanted | If the user closes the app during the ceremony, then the system shall save the completion state and replay the ceremony on next app launch. |

**伙伴完成台词：**

| 伙伴 | 台词 |
|------|------|
| Alex | "读完了。3 周，42 条笔记，我们讨论了 8 次。这本书现在不是书店里那本了。它是你的了。" + 击拳 |
| 小野 | "读完了读完了读完了！！兄弟你知道我上次读完一本书是什么时候吗？这本书是我们的了！" |
| Elena | "恭喜读完。你的 42 条笔记中有 7 条我已经帮你关联到了训练计划。去看看吧。" |
| K | "阅读完成。数据：3 周，42 条笔记，8 次讨论，2 次知识 PR。效率高于 78% 的用户。" |
| 凛 | "一本书读完了。但书里的东西才刚刚开始。你已经在训练中用上了两次。那才是真正的'读完'。" |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-07-AC01 | 翻到最后一页 | 读到 98% | 继续翻页 | 触发完整庆祝仪式 |
| RD-07-AC02 | 仪式中退出 | 仪式播放中 | 关闭 App | 重开时重播仪式 |
| RD-07-AC03 | 仪式后状态 | 仪式完成 | 查看书架 | 书标记为"已读完"+ 徽章 |

#### 5.4.8 深夜读书陪伴

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide a subdued, companionable reading experience during late-night hours (22:00-06:00). |
| Event-driven | When the user opens a book during late-night hours, the partner avatar shall switch to "深夜模式": subdued colors, no sudden animations, soft breathing animation only, and the greeting delivered in a whisper-like voice. |
| Event-driven | When the user has been reading for 30+ minutes in late-night mode, the partner shall gently suggest: "快两点了。这章读完，就去睡吧。书不会跑的。" |
| Event-driven | When the user closes the book (exits reading) in late-night mode, the system shall display a "床头灯熄灭" animation: screen slowly dims over 3 seconds, partner says "晚安。", and the partner avatar fades to a sleeping pose. |
| State-driven | While in late-night reading mode, the system shall use a warm-color reading theme (amber-tinted background, reduced blue light) and disable all non-essential notifications. |
| Unwanted | If the user continues reading after the gentle bedtime suggestion (another 30+ minutes), then the partner shall not repeat the suggestion, respecting the user's autonomy. |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RD-08-AC01 | 深夜打开读书 | 凌晨 1:23 打开书 | 观察 | 伙伴轻声问候+暖色主题 |
| RD-08-AC02 | 30 分钟提醒 | 深夜读 30 分钟 | 自动 | 伙伴建议休息 |
| RD-08-AC03 | 退出熄灯动画 | 深夜退出读书 | 关闭书 | 屏幕渐暗+伙伴晚安 |
| RD-08-AC04 | 不重复提醒 | 已被提醒一次 | 继续读 30 分钟 | 不再提醒 |

---

### 5.5 数据与收益

#### 5.5.1 综合效能仪表盘

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide a unified dashboard that integrates training, English, and reading metrics into a single view. |
| Event-driven | When the user navigates to the "效能" tab, the system shall display: (1) 成长指数 (large number at top, see 5.5.2), (2) 本周概览卡片 (训练次数/英语时长/阅读进度), (3) 连续活跃天数 (火焰动画, see 5.6.2), (4) 最新伙伴评价. |
| State-driven | While the dashboard is displayed, the user shall be able to tap any metric card to drill down into the respective module's detailed view. |
| Unwanted | If the user has no activity in any module, then the system shall display the onboarding prompt: "开始你的第一次训练、英语对话或阅读吧！" with quick-start buttons for each module. |

**仪表盘布局：**

```
┌────────────────────────────────────┐
│         [伙伴头像]  成长指数         │
│                 782               │
│              ↑ 12 本周              │
├────────────────────────────────────┤
│  ┌─────────┬─────────┬─────────┐  │
│  │ 训练 4次 │ 英语 87分│ 读书 32% │  │
│  │ 本周     │ 本周     │ 原子习惯  │  │
│  └─────────┴─────────┴─────────┘  │
├────────────────────────────────────┤
│  🔥 连续活跃 12 天                 │
│  ████████████░░░░░░░░             │
├────────────────────────────────────┤
│  ┌─ Alex 说 ───────────────────┐  │
│  │ "这周训练质量很高。英语        │  │
│  │  也进步了。继续保持。"        │  │
│  └────────────────────────────┘  │
└────────────────────────────────────┘
```

#### 5.5.2 成长指数算法

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall compute a composite "Growth Index" (0-1000) based on weighted contributions from training, English, reading, and consistency. |
| Event-driven | When any training session, English session, or reading progress is recorded, the system shall recalculate the Growth Index within 5 minutes. |

**算法公式：**

```
GrowthIndex = w1 × TrainingScore + w2 × EnglishScore + w3 × ReadingScore + w4 × ConsistencyScore

TrainingScore (0-250):
  = (volume_trend_zscore × 80) + (pr_count_30d × 50) + (rpe_adherence × 60) + (frequency_score × 60)
  capped at 250

EnglishScore (0-250):
  = (speaking_minutes_zscore × 80) + (pronunciation_improvement × 60) + (vocabulary_diversity × 60) + (lisa_improvement × 50)
  capped at 250

ReadingScore (0-250):
  = (pages_read_30d_zscore × 80) + (notes_created × 50) + (knowledge_pr_count × 60) + (books_completed × 60)
  capped at 250

ConsistencyScore (0-250):
  = (streak_days / 30 × 100) + (weekly_completion_rate × 80) + (cross_module_days × 70)
  capped at 250

权重: w1=0.3, w2=0.2, w3=0.2, w4=0.3
```

#### 5.5.3 健身收益六大维度

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall track and visualize six dimensions of fitness progress. |

**六大维度：**

| 维度 | 指标 | 可视化方式 |
|------|------|------|
| 最大力量 | 1RM 趋势（深蹲/卧推/硬拉） | 折线图 + 对比 |
| 爆发力 | 弹跳估算高度趋势 | 柱状图 |
| 肌耐力 | 容量趋势（总训练量） | 面积图 |
| 体成分 | 体重/体脂率变化（需手动输入） | 双轴折线图 |
| 专项能力 | 目标专项评分（弹跳/敏捷/康复等） | 雷达图 |
| 训练坚持度 | 训练频率+计划完成率 | 日历热力图 |

#### 5.5.4 LISA 英语雷达图

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall visualize LISA assessment results as an interactive radar chart with historical comparison. |
| Event-driven | When the user views the LISA radar chart, the system shall overlay the current assessment with the initial assessment using different color lines, with the improvement area shaded. |
| Event-driven | When the user taps a dimension on the radar, the system shall display a tooltip with: dimension name, current score, initial score, improvement %, and contributing sub-metrics. |

#### 5.5.5 阅读收益量化

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall quantify reading benefits across three dimensions: volume, depth, and application. |

**三维量化：**

| 维度 | 计算方式 | 单位 |
|------|------|:---:|
| 阅读量 | 累计阅读字数 / 阅读天数 | 万字/周 |
| 思考深度 | (笔记数 × 1 + 批注字数/100 × 2 + 讨论次数 × 5) / 阅读量 | 深度分 |
| 知识应用率 | 知识 PR 次数 / 阅读书籍数 × 100 | % |

#### 5.5.6 自动周报/月报

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall generate weekly (every Sunday 20:00) and monthly (last day of month 20:00) reports automatically. |
| Event-driven | When the report is generated, the system shall send a push notification with a preview snippet. |
| Event-driven | When the user opens the report, the system shall display it in the partner's voice and style, covering all active modules. |

#### 5.5.7 AI 发现"隐藏进步"

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall periodically analyze user data to discover non-obvious progress patterns and present them as "隐藏进步" discoveries. |
| Event-driven | When the AI detects a statistically significant positive trend that the user may not have noticed (e.g., "你的组间休息时间比上月平均缩短了 15 秒"), the system shall surface it as a "隐藏进步" card on the dashboard. |
| Event-driven | When the user taps the card, the system shall display the full analysis with data visualization and partner commentary. |

---

### 5.6 激励与留存

#### 5.6.1 AI 语音教练三种风格 + 六种 RPE 鼓励

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall offer three coaching styles selectable by the user, with adaptive encouragement based on RPE. |

**三种教练风格：**

| 风格 | 名称 | 特点 | 适用画像 |
|------|------|------|------|
| 🔥 | 硬核驱动 | 直接、高强度、push 为主 | 追求极限者 |
| 🤝 | 科学引导 | 数据导向、技术提醒、温和坚定 | 科学训练者 |
| 🧘 | 身心陪伴 | 关注感受、正念引导、尊重节奏 | 康复/初学者 |

**六种 RPE 对应鼓励：**

| RPE | 感知 | 硬核驱动 | 科学引导 | 身心陪伴 |
|:---:|------|------|------|------|
| 1-3 | 极轻 | "这不算热身，加重量。" | "当前负荷偏低，建议增加 10%。" | "慢慢感受身体。准备好了再加。" |
| 4-5 | 中等 | "节奏不错，继续保持。" | "当前在有效刺激区间的下限。" | "呼吸稳定，姿势保持得很好。" |
| 6-7 | 较难 | "这才是训练。顶住。" | "进入有效增肌区间。注意核心收紧。" | "挑战来了。你准备好了。" |
| 8 | 很重 | "最后两个！咬牙！" | "接近力竭。优先保证姿势。" | "就快到了。感受你的力量。" |
| 9 | 极重 | "拼了！！全部放进去！！" | "RPE 9。这是最后一组有效的。停止。" | "你已经拼尽全力。够了。" |
| 10 | 极限 | "新的极限。干得漂亮。" | "达到极限。建议停止此动作。" | "你到达了极限。这是值得尊重的。" |

#### 5.6.2 连续训练火焰系统

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall track consecutive training days and display a flame animation that grows in intensity with streak length. |
| Event-driven | When the user completes any training/English/reading activity in a day, the system shall increment the streak counter and update the flame animation. |
| Event-driven | When the streak reaches milestones (7/14/21/30/60/100 days), the system shall trigger a special flame evolution animation and a partner congratulation message. |

**火焰等级：**

| 连续天数 | 火焰颜色 | 动画效果 |
|:---:|:---:|------|
| 1-3 | 小火苗 | 微小闪烁 |
| 4-6 | 橙色火焰 | 轻微跳动 |
| 7-13 | 橙红火焰 | 活跃跳动 + 火星 |
| 14-20 | 红焰 | 强烈跳动 + 光晕 |
| 21-29 | 蓝焰核心 | 蓝白高温 + 粒子环绕 |
| 30-59 | 金色火焰 | 金焰 + 光环 |
| 60-99 | 紫焰 | 紫焰 + 星光 |
| 100+ | 彩虹焰 | 彩虹渐变 + 全效果 |

#### 5.6.3 目标承诺仪式

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide a ritualized goal-setting experience that creates psychological commitment. |
| Event-driven | When the user sets or updates a major goal, the system shall present a full-screen commitment ceremony: (1) goal input with specificity guidance, (2) "为什么这个目标重要？" reflection prompt, (3) partner response acknowledging the commitment, (4) a "承诺书" card generated with the goal, reason, date, and partner's signature. |
| Event-driven | When the user achieves the goal, the system shall retrieve the commitment card and display a "承诺兑现" celebration. |

#### 5.6.4 社交激励

**EARS 需求描述（P1-P2）：**

| 类型 | 需求 |
|------|------|
| Event-driven | When the user achieves a PR, the system shall offer to generate a shareable achievement card (P0). |
| Optional | Where the friend PK feature is enabled (P1), users shall be able to challenge friends on weekly training volume or English speaking minutes. |
| Optional | Where the shadow ranking feature is enabled (P1), users shall see their anonymous percentile ranking among users with similar goals and demographics. |

#### 5.6.5 流失预警与召回

**EARS 需求描述（P1）：**

| 类型 | 需求 |
|------|------|
| Event-driven | When a user's activity drops below 50% of their 30-day average for 7 consecutive days, the system shall flag the user as "at-risk" and trigger the retention flow. |
| Event-driven | When retention flow is triggered, the system shall execute a 4-level re-engagement strategy with increasing intensity and channel escalation. |

**四级召回策略：**

| 级别 | 触发条件 | 渠道 | 内容策略 |
|:---:|------|------|------|
| L1 | 3 天未活跃 | 伙伴 App 内消息 | 低压关怀，不提"训练" |
| L2 | 7 天未活跃 | Push 通知 | 分享一个成就回忆或周报亮点 |
| L3 | 14 天未活跃 | 短信 | 简洁问候 + 新功能介绍 |
| L4 | 30 天未活跃 | 人工（可选） | 个性化邮件/电话 |

#### 5.6.6 差异化留存策略

**三个画像的留存策略：**

| 策略维度 | 张逸飞 | 林雨桐 | 陈知行 |
|------|------|------|------|
| 核心钩子 | PR 突破、数据增长 | 微小进步被看见 | 社交展示、竞技排行 |
| 流失原因 | 瓶颈期、忙碌 | 愧疚感、时间碎片 | 新鲜感消退、预算 |
| 召回内容 | "你的深蹲 PR 还在等你" | "5 分钟核心训练，随时可以" | "你的朋友也在这里训练" |
| 推送频率 | 中等（3-4/周） | 低（1-2/周） | 中高（含社交动态） |

---

### 5.7 Agent 生态

#### 5.7.1 11 个 Agent 评审委员会（P1）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall maintain an 11-agent review committee that cross-validates every training plan before delivery. |
| Event-driven | When a training plan is generated, the system shall dispatch it to all 11 agents for review, each evaluating from their domain perspective. |
| Event-driven | When all reviews are complete (or 30-second timeout), the system shall synthesize the feedback using the five-stage roundtable model. |

**11 个 Agent 角色：**

| 编号 | Agent 角色 | 评审视角 |
|:---:|------|------|
| 1 | 运动科学家 | 训练学原理正确性 |
| 2 | 运动生理学家 | 能量系统/恢复周期 |
| 3 | 生物力学家 | 动作安全性/关节负荷 |
| 4 | 运动心理学家 | 动机维持/心理负荷 |
| 5 | 营养学家 | 训练与营养配合 |
| 6 | 运动康复师 | 伤病风险评估 |
| 7 | 专项教练 | 专项运动适配性 |
| 8 | 数据分析师 | 数据趋势/统计验证 |
| 9 | 用户体验专家 | 计划可执行性 |
| 10 | 安全审核员 | 安全红线检查 |
| 11 | 主评审（协调） | 综合判断/冲突仲裁 |

**五阶段圆桌协作：**

```
阶段1: 独立评审 — 每个Agent独立分析，不参考他人意见
阶段2: 交叉辩论 — 冲突观点进行辩论，引用证据
阶段3: 意见融合 — 主评审Agent综合所有观点
阶段4: 安全验证 — 安全审核员最终检查
阶段5: 交付输出 — 生成最终计划 + 评审摘要
```

#### 5.7.2 四类 Agent 体系（P2）

| 类别 | 来源 | 示例 | 权限 |
|------|------|------|:---:|
| 内置 Agent | PrimeAtlas 官方 | 11 个评审委员会成员 | 全权限 |
| 厂商 Agent | AI 厂商提供 | OpenAI/DeepSeek 训练模型 | 受限 |
| 三方 Agent | 健身博主/康复机构 | "科比的篮球教练" | 需审核 |
| 用户 Agent | 用户自然语言创建 | "我的私人羽毛球教练" | 个人使用 |

#### 5.7.3 Agent Marketplace（P2）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide an Agent Marketplace where users can browse, install, and rate third-party and community-created Agents. |
| Event-driven | When a user browses the marketplace, the system shall display Agents sorted by relevance (based on user goals) with ratings, review count, and compatibility badge. |
| Event-driven | When a user installs an Agent, the system shall run a sandboxed validation test before granting access to user data. |

#### 5.7.4 用户自然语言创建 Agent（P2）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Event-driven | When the user inputs a natural language description (e.g., "我要一个像科比一样严厉的篮球教练"), the system shall generate an Agent with: system prompt based on the description, default coaching style, recommended training focus, and a generated avatar/name. |
| Event-driven | When the Agent is generated, the system shall present a preview allowing the user to adjust parameters (strictness, focus areas, communication style) before saving. |

#### 5.7.5 产品决策层（P2）

**双层信息架构：**

| 层级 | 内容 | 面向对象 |
|:---:|------|------|
| 表层 | 自然语言 Tips、伙伴对话 | 用户 |
| 底层 | Agent 原始评审意见、数据依据、推理链 | 高级用户/开发者 |

**L1/L2/L3 权限：**

| 权限级别 | 可见内容 | 默认 |
|:---:|------|:---:|
| L1 | 仅 Tips（最终建议） | 所有用户 |
| L2 | Tips + 推理摘要 | 手动开启 |
| L3 | Tips + 完整推理链 + 各 Agent 原始意见 | 手动开启 |

#### 5.7.6 Tips 生成与展示（P2）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall translate multi-agent conclusions into natural language Tips that are actionable and jargon-free. |
| Event-driven | When the Agent committee completes a review, the system shall generate 1-3 Tips in the partner's voice, prioritized by impact. |
| Event-driven | When Tips are displayed, the user shall be able to expand each Tip to see the "为什么" (reasoning) section. |

---

### 5.8 数据反哺

#### 5.8.1 数据分类

**可反哺数据 vs 不可反哺数据：**

| 可反哺（脱敏后） | 不可反哺 |
|------|------|
| 训练数据（动作/重量/组数/RPE） | 个人身份信息（姓名/手机/邮箱） |
| 匿名化的身体数据（年龄范围/身高范围） | 精确位置数据 |
| 训练计划模板效果统计 | 对话原文（英语/读书） |
| 动作偏好与器材使用统计 | 健康/医疗数据 |
| 目标达成率统计 | 支付信息 |

#### 5.8.2 四层脱敏流水线（P2）

| 层级 | 处理 | 技术手段 |
|:---:|------|------|
| 1 | PII 剥离 | 正则 + NER 去除姓名/电话/邮箱/IP |
| 2 | 泛化 | 年龄→年龄段，体重→体重区间，地点→城市级别 |
| 3 | K-匿名化 | 确保每个组合至少 K=10 个用户 |
| 4 | 差分隐私 | ε=1.0 噪声注入 |

#### 5.8.3 用户授权机制（P2）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall default to Opt-out for data contribution. Data sharing must be explicitly enabled by the user. |
| Event-driven | When the user navigates to privacy settings, the system shall display a clear, plain-language explanation of what data would be shared, how it's protected, and what benefits the user receives. |
| Event-driven | When the user enables data contribution, the system shall present a granular selection: "仅训练数据" / "训练+英语" / "全部". |

#### 5.8.4 贡献者权益体系（P2）

| 等级 | 贡献要求 | 权益 |
|:---:|------|------|
| 青铜 | 贡献训练数据 30 天 | 专属徽章 + 优先体验新功能 |
| 白银 | 贡献训练+英语数据 60 天 | 青铜权益 + 每月 1 次专家 Agent 咨询 |
| 黄金 | 贡献全部数据 90 天 + 数据质量评分 >80 | 白银权益 + Agent Marketplace 折扣 |
| 钻石 | 贡献全部数据 180 天 + 数据质量评分 >90 | 黄金权益 + 参与产品决策投票 |

---


### 5.1 伙伴系统

#### 5.1.1 伙伴创建与选择流程（首次启动体验）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall present the partner selection flow as the mandatory first step after user registration. |
| Event-driven | When the user launches the app for the first time, the system shall display an immersive onboarding sequence introducing the concept of AI training partners. |
| Event-driven | When the user views a partner profile card, the system shall display the partner's name, tagline, personality description, specialty, English accent, and recommended user profile. |
| Event-driven | When the user selects a partner, the system shall trigger a 2-second handshake animation where the partner extends a hand and the screen flashes with the partner's signature color. |
| Event-driven | When the user confirms partner selection, the system shall save the selection and proceed to the user data collection flow (TR-01). |
| State-driven | While the user is in the partner selection flow, the system shall allow back-navigation to review previously viewed partners. |
| Unwanted | If the partner selection data fails to save to the server, then the system shall retry 3 times with exponential backoff and display a "Retry" button if all attempts fail. |
| Optional | Where the user expresses indecision, the system shall offer a 3-question personality quiz to recommend the best-matched partner. |

**5 个初始伙伴详情：**

| 伙伴 | 代号 | 人格描述 | 专长 | 英语口音 | 推荐用户 |
|------|------|---------|------|:---:|------|
| **Alex** | 赤焰 | 硬核老兵，退伍军人转健身教练。话少但精准，激励靠行动不靠嘴。 | 力量训练、体能突破 | 美式 | 追求极限突破者 |
| **小野** | 疾风 | 街头篮球少年，野生练出来的。口语化、情绪化、喜欢说"兄弟"。 | 弹跳训练、爆发力 | 美式+街头 | 球类运动爱好者 |
| **Elena** | 晨曦 | 运动科学博士，严谨但温柔。用数据说话，但永远先共情。 | 康复训练、动作优化 | 学术清晰 | 康复/科学训练者 |
| **K** | 零 | 数据狂人，少言寡语。说话像报告，但精准得可怕。 | 数据分析、计划优化 | 中性 | 数据驱动型用户 |
| **凛** | 静流 | 禅修武者，把训练当修行。说话慢，但每一句都值得想。 | 动作质量、身心连接 | 慢而清晰 | 追求身心平衡者 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|---------|
| CP-01-AC01 | 首次启动进入伙伴选择 | 新用户注册完成 | 完成注册 → 观察 | 自动进入伙伴介绍动画 → 展示第一个伙伴 |
| CP-01-AC02 | 浏览伙伴列表 | 在伙伴选择页 | 左右滑动 | 流畅切换伙伴卡片，动画无卡顿 |
| CP-01-AC03 | 选择伙伴 | 已浏览所有伙伴 | 点击"选择"按钮 | 手握手动画播放 → 进入数据采集流程 |
| CP-01-AC04 | 网络异常时选择 | 选择伙伴时断网 | 点击"选择" | 显示"正在保存…"→ 失败后显示重试按钮 |
| CP-01-AC05 | 返回重新浏览 | 已滑到第 3 个伙伴 | 点击返回 | 回到第 2 个伙伴，不丢失浏览进度 |

#### 5.1.2 伙伴动态头像系统

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall render the partner avatar at minimum 30 FPS with smooth animation transitions between states. |
| Ubiquitous | The system shall display the partner avatar on the main tab bar, training execution page, English conversation page, and reading page. |
| Event-driven | When the app is idle (no user interaction for 5 seconds), the partner avatar shall display idle animations: breathing cycle (4 seconds inhale, 4 seconds exhale), occasional blinking (every 3-7 seconds at random), and subtle head tilt (every 15-30 seconds at random). |
| Event-driven | When the user starts a training set, the partner avatar shall transition to "focused" state: narrowed eyes, slight forward lean, arms crossed or hands on hips. |
| Event-driven | When the user completes a set with RPE ≤ 7, the partner avatar shall display "satisfied" state: slight nod, small smile, thumbs up. |
| Event-driven | When the user completes a set with RPE ≥ 8.5, the partner avatar shall display "impressed" state: widened eyes, raised eyebrows, slow clap. |
| Event-driven | When the user achieves a new PR, the partner avatar shall display "celebration" state: jump animation (3 bounces), arms raised, confetti particles around avatar, for 8 seconds. |
| Event-driven | When the user marks a pain signal, the partner avatar shall transition to "concerned" state: furrowed brows, slight step forward, open palm gesture (stop signal). |
| Event-driven | When the user enters English conversation mode, the partner avatar shall display "conversational" state: relaxed posture, occasional head nods, speech bubble indicators. |
| Event-driven | When the user enters reading mode, the partner avatar shall display "reading" state: holding a book, page-turning animation every 30-60 seconds, glasses (if character-appropriate). |
| State-driven | While the partner is speaking (TTS active), the avatar's mouth shall animate in sync with audio waveform. |
| State-driven | While the user is in late-night mode (22:00-06:00), the avatar shall display subdued animations with reduced motion amplitude (50% scale) and dimmed color saturation. |
| Unwanted | If the device GPU cannot sustain 30 FPS for avatar rendering, then the system shall fall back to a simplified static avatar with minimal animations (blink only). |

**状态机：**

```
                    ┌─────────────┐
         ┌─────────→│   IDLE      │←─────────┐
         │          │  呼吸/眨眼   │          │
         │          └──────┬──────┘          │
         │                 │                  │
    ┌────┴────┐      ┌────┴────┐       ┌─────┴────┐
    │CELEBRATE│      │ FOCUSED │       │CONCERNED │
    │  庆祝    │      │  专注    │       │   关切    │
    └─────────┘      └────┬────┘       └──────────┘
                          │
              ┌───────────┼───────────┐
              │           │           │
         ┌────┴────┐ ┌────┴────┐ ┌────┴──────────┐
         │SATISFIED│ │IMPRESSED│ │CONVERSATIONAL │
         │  满意    │ │  惊叹    │ │    对话中      │
         └─────────┘ └─────────┘ └───────────────┘
```

**动画规格：**

| 动画 | 时长 | 缓动函数 | 关键属性 |
|------|------|---------|---------|
| 呼吸 | 8s 循环 | ease-in-out | 胸腔缩放 1.0 → 1.05 → 1.0 |
| 眨眼 | 0.15s | ease-out | 眼睑从开到关再开 |
| 跳跃庆祝 | 1.5s × 3 | ease-out bounce | Y 偏移 +30px → -10px → 0 |
| 点头 | 0.5s | ease-in-out | 头部旋转 ±5° |
| 合书 | 0.8s | ease-in | 手臂内收 + 书缩放 |
| Mode Shift | 1.5s | custom curve | 全身变换（见 5.1.6） |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| CP-02-AC01 | 空闲动画播放 | 打开 App，不操作 | 等待 10 秒 | 看到呼吸+眨眼+偶尔歪头 |
| CP-02-AC02 | 训练中状态切换 | 进入训练执行 | 开始一组训练 | 伙伴切换到专注状态 |
| CP-02-AC03 | PR 庆祝动画 | 训练中突破 PR | 完成突破组 | 8 秒庆祝动画完整播放 |
| CP-02-AC04 | 低端机降级 | 低端 Android 设备 | 进入训练页 | 静态头像显示，无卡顿 |
| CP-02-AC05 | 深夜模式动画 | 凌晨 1 点打开读书 | 观察伙伴 | 动画幅度减半，色彩偏暗 |

#### 5.1.3 伙伴记忆系统（四层记忆的数据结构）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall maintain a four-layer memory structure for each user-partner pair, stored in the local encrypted database and synced to the server. |
| Event-driven | When a user achieves a PR, completes a book, or reaches an English milestone, the system shall write a "milestone memory" (Layer 1) with timestamp, type, and quantitative data. |
| Event-driven | When a user makes a statement expressing emotion, goal, or preference (e.g., "我今天不想练" / "我想扣篮"), the system shall extract and store a "declaration memory" (Layer 2) with the original text, sentiment, and topic tags. |
| Event-driven | When the system detects a pattern across 3+ similar events (e.g., "连续 3 周周三训练质量最差"), the system shall generate a "pattern memory" (Layer 3) with the pattern description, confidence score, and supporting evidence. |
| Event-driven | When the system detects a cross-module connection (e.g., user applies book concept to training), the system shall generate a "synthesis memory" (Layer 4) linking the related memories across modules. |
| State-driven | While the partner is generating a response, the system shall query relevant memories (recency-weighted) and incorporate them into the response context. |
| Unwanted | If memory storage exceeds 10MB on device, then the system shall compress older memories (30+ days) and offload raw data to server while keeping embeddings and summaries locally. |

**四层记忆数据结构：**

```json
// Layer 1: 里程碑记忆
{
  "memory_id": "mem_m001",
  "layer": 1,
  "type": "milestone",
  "subtype": "pr_break",
  "timestamp": "2026-06-15T18:30:00Z",
  "data": {
    "exercise": "深蹲",
    "old_pr": "85kg",
    "new_pr": "90kg",
    "improvement_pct": 5.88
  },
  "partner_reaction": "excited",
  "tags": ["深蹲", "PR", "力量突破"]
}

// Layer 2: 声明记忆
{
  "memory_id": "mem_d042",
  "layer": 2,
  "type": "declaration",
  "timestamp": "2026-06-20T08:15:00Z",
  "original_text": "我真的想在今年夏天扣篮",
  "sentiment": "determined",
  "topic_tags": ["目标", "篮球", "弹跳"],
  "importance_score": 0.85
}

// Layer 3: 模式记忆
{
  "memory_id": "mem_p007",
  "layer": 3,
  "type": "pattern",
  "timestamp": "2026-06-28T02:00:00Z",
  "pattern": "周三训练质量下降",
  "confidence": 0.78,
  "evidence": [
    {"date": "2026-06-04", "rpe_avg": 7.8, "volume_pct": 85},
    {"date": "2026-06-11", "rpe_avg": 7.2, "volume_pct": 78},
    {"date": "2026-06-18", "rpe_avg": 7.5, "volume_pct": 82}
  ],
  "suggestion": "考虑将周三调整为低强度恢复日"
}

// Layer 4: 合成记忆
{
  "memory_id": "mem_s003",
  "layer": 4,
  "type": "synthesis",
  "timestamp": "2026-06-30T19:00:00Z",
  "linked_memories": ["mem_m001", "mem_d042", "mem_p007"],
  "cross_module": true,
  "modules": ["training", "reading"],
  "description": "用户在训练中应用了《原子习惯》的身份驱动理念",
  "trigger_event": "knowledge_pr"
}
```

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| CP-03-AC01 | PR 里程碑写入 | 训练中突破 PR | 完成突破训练 | 系统写入 Layer 1 记忆 |
| CP-03-AC02 | 声明记忆写入 | 用户在对话中说"我想扣篮" | 完成对话 | 系统提取并存储 Layer 2 记忆 |
| CP-03-AC03 | 伙伴引用记忆 | 已有 10 条记忆 | 开启新对话 | 伙伴引用最近的 PR 或声明 |
| CP-03-AC04 | 存储超限压缩 | 本地存储超过 10MB | 自动触发 | 30 天前记忆压缩，原始数据上传 |
| CP-03-AC05 | 跨模块合成记忆 | 读书后训练中应用知识 | 训练结束 | 生成 Layer 4 合成记忆 |

#### 5.1.4 伙伴语音系统（情绪参数调节）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall generate partner speech using TTS with emotion parameter modulation based on context. |
| Event-driven | When the partner needs to encourage during high-intensity training (RPE ≥ 8), the system shall apply voice parameters: pitch +5%, speed +10%, volume +15%, with "energetic" prosody profile. |
| Event-driven | When the partner detects user fatigue or low state, the system shall apply voice parameters: pitch -3%, speed -10%, volume -5%, with "gentle" prosody profile. |
| Event-driven | When the partner is speaking in English mode, the system shall switch to the partner's configured English accent and language (see accent table in 5.1.1). |
| State-driven | While the user is in late-night mode (22:00-06:00), the partner voice shall reduce volume by 20% and add a "whisper" quality filter. |
| State-driven | While the user is in driving/commute mode, the partner voice shall increase clarity (slower articulation +10%) and reduce background effects. |
| Unwanted | If TTS generation fails (network error or timeout), then the system shall fall back to pre-cached local TTS samples for common phrases (50 phrases minimum). |

**情绪参数表：**

| 情绪 | Pitch 偏移 | Speed 偏移 | Volume 偏移 | 使用场景 |
|------|:--------:|:--------:|:---------:|------|
| 高能量 | +5% | +10% | +15% | 训练倒数、PR 突破 |
| 沉稳 | 0% | 0% | 0% | 日常对话、训练指导 |
| 关切 | -3% | -5% | -5% | 检测疲劳、疼痛信号 |
| 温柔 | -5% | -10% | -10% | 深夜、用户说"不想练" |
| 兴奋 | +8% | +15% | +20% | PR 庆祝、读完书庆祝 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| CP-04-AC01 | 高能量语音 | 训练中 RPE=9 | 完成一组 | 语音音调升高、语速加快 |
| CP-04-AC02 | 温柔语音 | 凌晨 1 点读书 | 伙伴说话 | 音量降低 20%，带轻柔质感 |
| CP-04-AC03 | 英语口音切换 | 进入英语对话 | 伙伴说英语 | 使用配置的英语口音 |
| CP-04-AC04 | TTS 离线回退 | 飞行模式 | 触发伙伴语音 | 使用本地缓存语音 |

#### 5.1.5 伙伴成长等级体系

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall track partner growth level based on cumulative training sessions across all modules. |
| Event-driven | When the user completes their first training session, the partner shall reach Lv.1 "初识" and unlock basic encouragement voice and basic error correction. |
| Event-driven | When the user completes 10 training sessions, the partner shall reach Lv.2 "熟悉" and unlock data analysis capability (training), topic recommendation (English), and proactive discussion initiation (reading). |
| Event-driven | When the user completes 30 training sessions, the partner shall reach Lv.3 "信任" and unlock story mode (training), scene conversation customization (English), and three-party book club (reading). |
| Event-driven | When the user completes 60 training sessions AND achieves at least 1 PR, the partner shall reach Lv.4 "默契" and unlock precise prediction (training), difficulty auto-adaptation (English), and cross-domain correlation (reading). |
| Event-driven | When the user completes 100 training sessions AND has accumulated 20+ memories, the partner shall reach Lv.5 "共生" and unlock partner appearance customization, full-topic free conversation (English), and retrospective video generation. |
| State-driven | While the partner is at Lv.1-2, the system shall limit certain advanced features with a lock icon and tooltip showing the unlock condition. |
| Unwanted | If the partner level-up animation is interrupted (app closed), then the system shall replay the animation on next app launch. |

**等级详解：**

| 等级 | 名称 | 条件 | 训练解锁 | 英语解锁 | 读书解锁 |
|:---:|------|------|------|------|------|
| Lv.1 | 初识 | 首次训练 | 基础鼓励语音 | 基础纠错 | 基础笔记 |
| Lv.2 | 熟悉 | 10 次 | 数据分析能力 | 话题推荐 | 主动发起讨论 |
| Lv.3 | 信任 | 30 次 | 故事模式 | 场景对话定制 | 三方读书会 |
| Lv.4 | 默契 | 60 次 + 1 PR | 精准预判 | 难度自适应 | 跨域关联 |
| Lv.5 | 共生 | 100 次 + 20 记忆 | 自定义外观 | 全话题自由对话 | 回顾视频生成 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| CP-05-AC01 | 首次升级 Lv.1 | 新用户完成首次训练 | 结束训练 | 显示升级动画，解锁基础功能 |
| CP-05-AC02 | 升级到 Lv.2 | 已完成 10 次训练 | 第 10 次训练结束 | 升级动画 + 新功能解锁提示 |
| CP-05-AC03 | 锁定功能提示 | Lv.1 用户 | 点击锁定功能 | 显示解锁条件 tooltip |
| CP-05-AC04 | 升级动画中断 | 升级时关闭 App | 重新打开 App | 重新播放升级动画 |

#### 5.1.6 Mode Shift 场景切换过渡

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall execute a 1.5-second Mode Shift animation when the user switches between training, English, and reading modules. |
| Event-driven | When the user switches from training to English module, the partner avatar shall perform: "shake off sweat" animation (0.5s) → lighting change from gym to casual (0.5s) → outfit change to casual wear (0.5s), and the system shall speak the transition line in the partner's new tone. |
| Event-driven | When the user switches from English to reading module, the partner avatar shall perform: close conversation pose (0.5s) → lighting change to warm reading light (0.5s) → pull out a book (0.5s). |
| Event-driven | When the user switches from reading to training module, the partner avatar shall perform: close book (0.3s) → lighting change to gym (0.5s) → outfit change to training gear (0.7s). |
| State-driven | While the Mode Shift animation is playing, the system shall block module interaction and display a transition overlay with the partner's name and the new module name. |
| Unwanted | If the user rapidly switches modules (within 2 seconds of previous switch), then the system shall cancel the current animation and jump directly to the target module state. |

**过渡台词示例：**

| 切换 | 伙伴台词 |
|------|---------|
| 训练→英语 | Alex: "好了，杠铃放下来了。来聊两句英语？" / 小野: "练完了！英语时间，兄弟！" |
| 英语→读书 | Elena: "口语练得不错。该翻几页书了。" / 凛: "说够了。安静看会儿书吧。" |
| 读书→训练 | K: "理论够了。该动起来了。" / Alex: "书合上。杠铃在等你。" |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| CP-06-AC01 | 训练切换到英语 | 在训练模块 | 点击英语 Tab | 1.5s 过渡动画 + 伙伴语音切换 |
| CP-06-AC02 | 快速连续切换 | 在训练模块 | 快速点击英语→读书 | 取消第一个动画，直接跳到读书 |
| CP-06-AC03 | 过渡中不响应点击 | 动画播放中 | 点击按钮 | 无响应，动画结束后才可交互 |

#### 5.1.7 伙伴消息推送策略

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall deliver partner push notifications in the partner's voice and personality style. |
| Event-driven | When the user opens the app for the first time each day (between 06:00-12:00), the partner shall display a personalized "good morning" message that varies daily and incorporates recent memories. |
| Event-driven | When the user has not trained for 3 consecutive days, the partner shall send a push notification at 18:00 with a low-pressure check-in message (not a guilt-trip). |
| Event-driven | When the user achieves a PR, the partner shall send a push notification the next morning referencing the achievement. |
| Event-driven | When the system generates the weekly summary, the partner shall send a push notification: "[伙伴名] 给你写了一封信。". |
| State-driven | While the user is in "do not disturb" hours (22:00-08:00, configurable), the system shall suppress all push notifications except critical system alerts. |
| Unwanted | If the user dismisses 3 consecutive push notifications without opening the app, then the system shall reduce push frequency to maximum 1 per day for the next 7 days. |

**消息模板示例：**

| 场景 | 伙伴 | 消息内容 |
|------|------|---------|
| 早安（平常） | Alex | "早。阳光不错。准备好了就开干。" |
| 早安（PR 次日） | Alex | "早。昨天那个深蹲 PR，我看了三遍回放。90kg，干净利落。" |
| 早安（雨天） | 小野 | "下雨了。室内也能练。今天来点核心训练？" |
| 3 天未训练 | Elena | "嘿，三天没见了。不用解释。什么时候准备好了，我都在。" |
| 周报已生成 | K | "本周数据报告已生成。你有一封来自 K 的信。" |
| 知识 PR | 凛 | "你昨天在训练中用上了书里的东西。那是真正的进步。" |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| CP-07-AC01 | 早安消息 | 当天首次打开 App | 打开 App | 伙伴显示个性化早安 |
| CP-07-AC02 | 3 天未训练推送 | 3 天未训练 | 到达 18:00 | 收到低压力关怀推送 |
| CP-07-AC03 | 勿扰模式 | 用户设置勿扰 22-08 | 凌晨收到消息 | 无推送，次日 8 点后送达 |
| CP-07-AC04 | 推送降频 | 连续 3 次忽略推送 | 第 4 天 | 推送频率降至 1 次/天 |

---

### 5.2 训练模块

#### 5.2.1 用户数据采集流程

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall collect six categories of user data during the onboarding flow, presented in a wizard-style multi-step form. |
| Event-driven | When the user completes partner selection, the system shall immediately present the data collection wizard starting with "身体基础数据". |
| Event-driven | When the user completes each data category step, the system shall save progress locally and advance to the next step with a progress indicator (e.g., "Step 3/6"). |
| State-driven | While the user is in the data collection wizard, the system shall allow back-navigation to previous steps to modify data. |
| Unwanted | If the user exits the wizard before completing all 6 steps, then the system shall save partial data and prompt completion on next app launch with a "继续完善资料" banner. |
| Optional | Where the user is unsure about a measurement (e.g., body fat %), the system shall provide a "跳过，稍后补充" option with an explanation of how the missing data affects plan quality. |

**六类数据采集详情：**

| 步骤 | 类别 | 采集内容 | 必填/选填 | 采集方式 |
|:---:|------|------|:---:|------|
| 1 | 身体基础 | 性别、年龄、身高、体重、体脂率（可选） | 身高体重必填 | 手动输入 |
| 2 | 运动目标 | 主目标（专项运动/增肌/减脂/康复等）、具体目标值（如"弹跳+15cm"）、目标期限 | 必填 | 选择+输入 |
| 3 | 训练环境 | 可用场地（家/健身房/户外/球场等）、每个场地的可用时段 | 必填 | 多选+时间选择 |
| 4 | 可用器材 | 每个场地可用的器材清单（哑铃/杠铃/弹力带/自重等） | 必填 | 多选标签 |
| 5 | 时间约束 | 每周可训练天数、每天可用时段及时长 | 必填 | 日历选择 |
| 6 | 伤病史 | 过往伤病、手术史、当前疼痛/不适部位、医生建议限制 | 选填 | 自由文本+部位标记 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-01-AC01 | 完成全部数据采集 | 伙伴选择完成 | 依次填写 6 步 | 每步保存进度，最终进入首页 |
| TR-01-AC02 | 中途退出 | 填写到第 3 步 | 关闭 App 再打开 | 显示"继续完善资料"提示 |
| TR-01-AC03 | 修改已填数据 | 在第 4 步 | 点击返回 | 回到第 3 步，数据保留可修改 |
| TR-01-AC04 | 跳过可选数据 | 第 1 步 | 跳过体脂率 | 显示提示"影响计划精确度"→继续 |

#### 5.2.2 1RM 安全推算

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall calculate estimated 1RM (One-Rep Max) using the Epley formula with a safety ceiling of 10% above the user's highest recorded weight. |
| Event-driven | When the user records a set with ≤10 reps and RPE ≥7, the system shall calculate and update the estimated 1RM for that exercise. |
| Event-driven | When the estimated 1RM exceeds the safety ceiling (highest recorded weight × 1.1), the system shall cap the estimate and display a "待实测验证" indicator. |
| State-driven | While the estimated 1RM has not been validated by an actual near-maximal attempt (RPE ≥9.5, ≤3 reps), the system shall display a "estimated" badge next to the 1RM value. |
| Unwanted | If the user records data with inconsistent patterns (e.g., sudden 30% jump), then the system shall flag the data point as anomalous and exclude it from 1RM calculation, requesting user confirmation. |

**推算公式：**

```
1RM = Weight × (1 + Reps / 30)    // Epley 公式（Reps ≤ 10）
1RM_capped = min(1RM, MaxRecordedWeight × 1.1)  // 安全上限
```

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-02-AC01 | 正常推算 | 深蹲 80kg × 8 reps, RPE=8 | 记录该组 | 1RM 显示为 ~101kg |
| TR-02-AC02 | 安全上限 | 最高记录 80kg, 推算 95kg | 自动计算 | 1RM 封顶 88kg，显示"待验证" |
| TR-02-AC03 | 异常数据 | 上次 80kg, 本次 120kg × 8 | 记录该组 | 标记异常，不参与计算 |

#### 5.2.3 训练计划生成

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall generate a training plan based on user goals, available equipment, time constraints, and training history, presented with AI reasoning visible to the user. |
| Event-driven | When the user requests a new training plan (initial or regeneration), the system shall invoke the training plan orchestration algorithm that considers: goal → muscle groups → exercise selection → volume/reps/sets → intra-session ordering → inter-session sequencing. |
| Event-driven | When the plan is generated, the system shall display the full plan with each exercise's sets, reps, target RPE, and rest time, along with an expandable "AI 推理过程" section. |
| Event-driven | When the user adjusts any plan parameter (exercise swap, volume change, rest time), the system shall re-run the orchestration for downstream effects and highlight affected items. |
| State-driven | While the plan is being generated, the system shall display an animated "编排中" indicator with the partner avatar in "thinking" pose and a progress animation (exercise cards filling in). |
| Unwanted | If the plan generation API times out (15 seconds), then the system shall fall back to a pre-computed template plan based on the user's goal category, with a "AI 精调中，先用基础版" notice. |

**编排算法输入输出：**

```
输入层：
├── 用户画像
│   ├── 身体数据：性别/年龄/身高/体重
│   ├── 运动目标：目标类型/目标值/期限
│   ├── 训练经验：初级(0-6月)/中级(6-24月)/高级(24+月)
│   └── 伤病史：限制部位/动作
├── 环境约束
│   ├── 可用场地：[家/健身房/球场]
│   ├── 可用器材：{场地: [器材列表]}
│   └── 时间窗口：{天: [时段, 时长]}
├── 训练历史
│   ├── 近期负荷：ACWR (急慢性负荷比)
│   ├── 各动作1RM/容量趋势
│   └── RPE趋势
└── 专项参数
    ├── 弹跳：力量阶段/爆发阶段/专项阶段
    ├── 羽毛球：敏捷/力量/耐力比例
    └── 康复：禁忌动作/渐进负荷限制

输出层：
├── 训练日列表：[{日期, 场地, 时长}]
├── 每训练日：
│   ├── 热身动作：[{动作, 时长, 强度}]
│   ├── 主项动作：[{动作, 组数, 次数/时长, 目标RPE, 组间休息}]
│   ├── 辅项动作：[{动作, 组数, 次数, 目标RPE, 组间休息}]
│   └── 冷身动作：[{动作, 时长}]
├── AI推理链：[{步骤, 决策, 依据}]
└── 安全警告：[{类型, 描述}]
```

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-03-AC01 | 生成弹跳训练计划 | 目标=弹跳+15cm, 器材=杠铃/哑铃 | 请求生成 | 计划包含力量+爆发+专项阶段 |
| TR-03-AC02 | 调整后重新编排 | 已有计划 | 替换一个动作 | 下游受影响项高亮显示 |
| TR-03-AC03 | API 超时回退 | 模拟网络延迟 | 请求生成 | 15s 后回退到模板计划 + 提示 |
| TR-03-AC04 | AI 推理可见 | 计划已生成 | 展开推理区域 | 显示完整推理链 |

#### 5.2.4 训练执行页面

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide a training execution interface with real-time set tracking, rest timer, data entry, RPE input, and pain signal marking. |
| Event-driven | When the user starts a training session, the system shall enter full-screen training mode with the current exercise displayed prominently, the partner avatar in the top-right corner, and the rest timer ready. |
| Event-driven | When the user taps "开始一组", the system shall start the 3-2-1-GO countdown (see 5.2.8) and transition to the "recording" state. |
| Event-driven | When the user completes a set, the system shall present the data entry panel with: weight input (pre-filled from last set), reps input, RPE slider (1-10), and an optional "疼痛标记" button. |
| Event-driven | When the user taps "疼痛标记", the system shall display an anatomical body map for the user to pinpoint the pain location and a severity selector (1-5). |
| Event-driven | When the user confirms set data, the system shall start the rest timer based on the planned rest duration, with the partner avatar displaying a countdown. |
| State-driven | While the rest timer is counting down, the system shall display: remaining time (large digits), next exercise preview, and the partner's "rest encouragement" message. |
| State-driven | While the user is on the last planned set of an exercise, the system shall display the "LAST SET" banner with flame particles (see 5.2.9). |
| Unwanted | If the user fails to input data within 60 seconds after set completion, then the system shall auto-save with empty reps/weight and RPE=5 (estimated), flagging the set as "数据缺失". |
| Unwanted | If the user marks pain at severity ≥4, then the system shall immediately pause the training plan and display the pain assessment flow: "建议停止当前训练。是否继续？[停止训练] [仅跳过此动作] [忽略继续]" |

**页面布局规格：**

```
┌────────────────────────────────────┐
│  ← 退出  │  深蹲训练日  │ 伙伴头像  │  ← 顶栏
├────────────────────────────────────┤
│                                    │
│        当前动作：杠铃深蹲            │
│        第 3/5 组                   │
│                                    │
│    ┌──────────────────────┐       │
│    │                      │       │
│    │    [动作示意图/GIF]    │       │  ← 动作预览区
│    │                      │       │
│    └──────────────────────┘       │
│                                    │
│   ┌──────────────────────────┐    │
│   │  上一组：80kg × 8  RPE 7  │    │  ← 历史组数据
│   │  计划：85kg × 6  RPE 8    │    │
│   └──────────────────────────┘    │
│                                    │
│   ┌──────────────────────────┐    │
│   │      [ 开始一组 ]         │    │  ← 主按钮
│   └──────────────────────────┘    │
│                                    │
│  ┌─ 组间休息 ──────────────────┐  │
│  │       02:30                 │  │  ← 休息计时器
│  │  "深呼吸，下组稳住核心"      │  │  ← 伙伴提示
│  └────────────────────────────┘  │
│                                    │
│  ┌─ 数据录入 ──────────────────┐  │
│  │  重量: [85  ] kg            │  │
│  │  次数: [   ] reps           │  │  ← 数据输入
│  │  RPE:  ○○○○○●○○○  8       │  │  ← RPE 滑块
│  │  [ 🚨 标记疼痛 ]            │  │  ← 疼痛标记
│  │         [ 确认完成 ]         │  │
│  └────────────────────────────┘  │
│                                    │
└────────────────────────────────────┘
```

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-04-AC01 | 正常训练流程 | 已生成训练计划 | 点击开始→完成一组→录入数据→休息→下一组 | 完整流程无卡顿 |
| TR-04-AC02 | 疼痛标记 | 训练中感到不适 | 点击疼痛标记→选择部位→选择严重度=4 | 训练暂停，显示停止建议 |
| TR-04-AC03 | 数据录入超时 | 完成一组后不操作 | 等待 60 秒 | 自动保存为空数据+标记"数据缺失" |
| TR-04-AC04 | 最后一组提示 | 执行最后一组 | 观察界面 | 显示 LAST SET 横幅+火焰粒子 |

#### 5.2.5 动作学习三层体系

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide a three-tier exercise learning system for every exercise in the training plan. |
| Event-driven | When the user taps an exercise name in the training plan, the system shall open the "关键要领卡片" (Tier 1) with 3-5 bullet points of critical form cues, a simple stick-figure illustration, and common mistake warnings. |
| Event-driven | When the user taps "查看视频示范" on the key points card, the system shall expand to "标杆视频" (Tier 2) displaying a looped video demonstration (front + side angles) with slow-motion toggle. |
| Event-driven | When the user taps "详细教学", the system shall expand to "详细教学" (Tier 3) with step-by-step breakdown, muscle activation guide, breathing pattern, progression/regression options, and links to related exercises. |
| State-driven | While the video is playing, the system shall support: play/pause, seek, 0.5x/1x/2x speed, front/side angle toggle. |
| Unwanted | If the video fails to load (network error or not cached), then the system shall display a static image sequence (key frames) with text descriptions as fallback. |

**三层内容结构：**

```
Tier 1: 关键要领卡片 (默认展示)
├── 动作名称
├── 目标肌群标签
├── 3-5 条关键要领（红色高亮）
├── 简笔画示意图
├── 3 条常见错误（黄色警告）
└── [查看视频示范 →] [详细教学 →]

Tier 2: 标杆视频 (展开)
├── 正面视角视频 (循环播放)
├── 侧面视角视频 (切换)
├── 慢动作开关 (0.5x)
├── 关键帧标记点
└── [详细教学 →]

Tier 3: 详细教学 (展开)
├── 分步骤图文教学 (每步配图)
├── 肌肉激活感受描述
├── 呼吸节奏指导
├── 进退阶变式
├── 关联动作推荐
└── 常见问题 Q&A
```

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-05-AC01 | 查看关键要领 | 在训练计划页 | 点击动作名称 | 展示 Tier 1 卡片 |
| TR-05-AC02 | 展开视频 | 在 Tier 1 卡片 | 点击"查看视频示范" | 展开 Tier 2 视频播放 |
| TR-05-AC03 | 视频加载失败 | 断网状态 | 点击"查看视频示范" | 显示关键帧图片序列 |
| TR-05-AC04 | 展开详细教学 | 在 Tier 2 | 点击"详细教学" | 展开 Tier 3 完整教学 |

#### 5.2.6 视频资源获取与缓存

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall cache exercise demonstration videos locally using a LRU (Least Recently Used) strategy with a maximum cache size of 500MB. |
| Event-driven | When a video is requested for display, the system shall first check the local cache; if cached and version is current, play from cache; if not cached, download from CDN with progress indicator. |
| Event-driven | When the user's training plan is generated, the system shall pre-fetch and cache all exercise videos referenced in the plan during WiFi connection. |
| State-driven | While downloading a video, the system shall display a circular progress indicator on the video thumbnail and allow the user to view Tier 1 content immediately. |
| Unwanted | If the cache exceeds 500MB, then the system shall evict the least recently accessed videos that are not in the current training plan. |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-06-AC01 | WiFi 预缓存 | 训练计划已生成, WiFi 连接 | 自动 | 计划中所有视频后台缓存 |
| TR-06-AC02 | 缓存命中 | 视频已缓存 | 打开视频 | 即时播放，无加载延迟 |
| TR-06-AC03 | 缓存未命中 | 视频未缓存 | 打开视频 | 显示下载进度→播放 |
| TR-06-AC04 | 缓存超限 | 缓存接近 500MB | 下载新视频 | LRU 淘汰旧视频 |

#### 5.2.7 动作正确性判断

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide multi-layered movement correctness assessment combining self-check, AI analysis, and pain signal recognition. |
| Event-driven | When the user completes a set, the system shall present a self-check checklist with 3-5 binary (Yes/No) questions tailored to the exercise (e.g., "深蹲时膝盖是否内扣？"). |
| Event-driven | When the user opts to record a video of their set (camera permission granted), the system shall submit the video for AI pose estimation analysis and return a report within 30 seconds, highlighting form deviations with annotated screenshots. |
| Event-driven | When the user marks a pain signal (see 5.2.4), the system shall cross-reference the pain location with the current exercise's target muscle groups to determine if the pain is "expected muscle burn" vs "potential injury signal". |
| State-driven | While AI video analysis is processing, the system shall display a "分析中" indicator with the partner avatar in "observing" pose. |
| Unwanted | If the AI pose estimation API returns low confidence (<70%), then the system shall display results with a "low confidence" warning and suggest the user record from a better angle. |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-07-AC01 | 自我检查清单 | 完成一组深蹲 | 查看清单 | 显示深蹲专项检查项 |
| TR-07-AC02 | AI 视频分析 | 录制训练视频 | 提交分析 | 30s 内返回姿势分析报告 |
| TR-07-AC03 | 低置信度结果 | 视频角度不佳 | 提交分析 | 显示警告 + 建议重新录制 |
| TR-07-AC04 | 疼痛信号判断 | 标记深蹲时膝盖疼 | 自动分析 | 判断是否为预期肌肉感受 vs 潜在损伤 |

#### 5.2.8 3-2-1-GO 倒计时

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall play a 3-second countdown animation before each set begins, synchronized with haptic feedback and partner voice. |
| Event-driven | When the user taps "开始一组", the system shall immediately enter full-screen countdown mode with the number displayed in the center of the screen. |
| Event-driven | At count "3", the system shall display a large "3" with the screen edge beginning to glow orange. |
| Event-driven | At count "2", the system shall display "2" with the glow intensifying to red and the screen slightly zooming in. |
| Event-driven | At count "1", the system shall display "1" with the glow at maximum intensity (golden), screen at maximum zoom, and a subtle screen shake. |
| Event-driven | At "GO!", the system shall trigger: the number shattering into golden particles that fly outward, a brief white flash, the partner shouting "来！"(or equivalent), and the screen returning to the training recording state. |
| State-driven | While the countdown is playing, the system shall disable all other interaction (full-screen immersive). |
| Optional | Where the user prefers a minimal countdown, the system shall offer a "简洁模式" with just a 1-second visual cue (no animation, no voice). |

**视觉规格：**

| 时间点 | 数字大小 | 屏幕效果 | 光晕颜色 | 音频 |
|------|:---:|------|:---:|------|
| T-3 | 120pt | 边缘微光 | #FF6B35 (橙) | 低沉"滴" |
| T-2 | 140pt | 光晕扩散 | #FF3B3B (红) | 中频"滴" |
| T-1 | 160pt | 最大光晕+微震 | #FFD700 (金) | 高频"滴" |
| GO! | 200pt→碎裂 | 闪白+粒子爆发 | 金色粒子 | 伙伴喊声 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-08-AC01 | 完整倒计时 | 进入训练执行 | 点击"开始一组" | 3-2-1-GO 完整动画播放 |
| TR-08-AC02 | 简洁模式 | 用户设置简洁模式 | 点击"开始一组" | 仅 1 秒视觉提示 |
| TR-08-AC03 | 倒计时不可中断 | 倒计时播放中 | 点击屏幕 | 无响应，倒计时完成 |

#### 5.2.9 最后一组仪式

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall trigger the "LAST SET" ceremony when the user reaches the final planned set of any exercise. |
| Event-driven | When the user completes the second-to-last set, the system shall slide in a "⚠️ LAST SET" banner from the top of the screen with animated flame particles on the banner edges. |
| Event-driven | When the LAST SET banner appears, the system shall trigger: 2 short haptic vibrations, and the partner voice speaking the last-set encouragement phrase. |
| Event-driven | When the user taps "开始一组" on the last set, the 3-2-1-GO countdown shall use an intensified version with red-gold color scheme and the partner's most energetic voice profile. |
| Unwanted | If the user adds an extra set beyond the plan (bonus set), then the system shall NOT trigger the LAST SET ceremony again for that exercise, treating it as user-initiated extra work. |

**伙伴最后一组台词：**

| 伙伴 | 台词 |
|------|------|
| Alex | "把所有剩下的力气都放进去。这是你的。" |
| 小野 | "最后一组！兄弟，飞到天上去！" |
| Elena | "最后一组。控制呼吸，保持姿势。你可以的。" |
| K | "最后一组。数据显示你能完成。开始。" |
| 凛 | "最后一组。不是为了数字。是为了你自己。" |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-09-AC01 | LAST SET 触发 | 完成倒数第二组 | 观察 | 横幅滑入 + 火焰 + 震动 + 语音 |
| TR-09-AC02 | 最后一组强化倒计时 | LAST SET 横幅显示中 | 点击"开始一组" | 红金色倒计时 + 最高能量语音 |
| TR-09-AC03 | 额外组不触发 | 已完成最后一组 | 手动加一组 | 无 LAST SET 仪式 |

#### 5.2.10 PR 预警与庆祝

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall monitor real-time training data to detect potential PR (Personal Record) breakthroughs and trigger celebration flows. |
| Event-driven | When the AI detects that the current set may result in a PR (estimated 1RM ≥ current PR × 0.95), the system shall enter "PR 预警" mode: a golden border pulses around the screen, the partner avatar displays an "anticipating" expression, and the system plays a subtle epic BGM loop. |
| Event-driven | When the user confirms a set that breaks a PR, the system shall trigger the full PR celebration sequence: (1) 0.5s screen freeze + BGM swell, (2) particle burst from center, (3) "新纪录！" large text animates in, (4) old PR vs new PR scrolling comparison, (5) partner avatar jumps and cheers, (6) total duration: 8 seconds. |
| Event-driven | When the PR celebration completes, the system shall present three shareable achievement card styles: "数据控"(numbers-focused), "热血"(cinematic), "极简"(minimalist). |
| Event-driven | When the user taps a card style, the system shall generate the share card with the user's data, partner avatar, date, and a QR code linking to the app. |
| State-driven | While the PR celebration is playing, the system shall disable the back button and all navigation. |
| Unwanted | If the user dismisses the celebration before completion (swipe down), then the system shall save the PR but skip the card generation flow, showing a subtle "PR 已记录" toast. |

**PR 类型与阈值：**

| PR 类型 | 检测条件 | 庆祝等级 |
|------|------|:---:|
| 1RM PR | 估算 1RM > 历史最高 | 最高 |
| 容量 PR | 单次训练总容量 > 历史最高 | 高 |
| 次数 PR | 同重量完成次数 > 历史最高 | 中 |
| 首次 PR | 用户首次突破任何 PR | 最高（特殊） |

**三种卡片风格：**

| 风格 | 配色 | 内容重点 | 适用场景 |
|------|------|------|------|
| 数据控 | 深蓝+白 | 数字对比、趋势箭头、百分比 | 健身圈分享 |
| 热血 | 红+金 | 大字 PR、火焰粒子、伙伴呐喊 | 朋友圈 |
| 极简 | 黑白 | 干净排版、留白、小字 | Instagram Story |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-10-AC01 | PR 预警触发 | 训练中接近 PR | 记录一组接近 PR 的数据 | 金色边框脉冲 + 伙伴期待表情 |
| TR-10-AC02 | PR 突破庆祝 | 确实突破 PR | 确认完成 | 8 秒完整庆祝序列 |
| TR-10-AC03 | 生成分享卡片 | PR 庆祝结束 | 选择卡片风格 | 生成带数据的分享卡片 |
| TR-10-AC04 | 提前关闭庆祝 | 庆祝播放中 | 下滑关闭 | PR 保存，卡片不生成 |
| TR-10-AC05 | 首次 PR 特殊 | 用户首次突破 | 确认完成 | 触发最高等级庆祝 |

#### 5.2.11 训练总结（故事化呈现）

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall generate a narrative-style training summary after each session, combining quantitative data with qualitative partner commentary. |
| Event-driven | When the user completes all planned exercises (or taps "结束训练"), the system shall compile the session data and generate a training summary within 3 seconds. |
| Event-driven | When the summary is ready, the system shall display it in a story-like format: (1) 训练总览卡片（时长/容量/动作数）, (2) 亮点时刻（最佳组/最大重量/PR）, (3) 伙伴评价（个性化语音+文字）, (4) 与目标的距离。 |
| State-driven | While the summary is generating, the system shall display the partner avatar in "reviewing" pose with a loading indicator. |
| Unwanted | If the user exits before viewing the summary, then the system shall save the summary and display a "查看训练总结" banner on the home screen. |

**总结结构：**

```
┌────────────────────────────────────┐
│          训练完成！🏋️               │
│                                    │
│  ┌─ 总览 ──────────────────────┐  │
│  │ 时长: 52 分钟               │  │
│  │ 动作: 6 个                  │  │
│  │ 总容量: 3,240 kg            │  │
│  │ RPE 均值: 7.2               │  │
│  └────────────────────────────┘  │
│                                    │
│  ┌─ 亮点 ──────────────────────┐  │
│  │ 🌟 深蹲 85kg × 8 — 容量PR   │  │
│  │ 💪 卧推 RPE 9 — 拼尽全力     │  │
│  └────────────────────────────┘  │
│                                    │
│  ┌─ Alex 说 ───────────────────┐  │
│  │ "今天深蹲进步明显。核心       │  │
│  │  稳定性还需要加强，下周       │  │
│  │  加一组平板支撑。"           │  │
│  └────────────────────────────┘  │
│                                    │
│  ┌─ 距离目标 ──────────────────┐  │
│  │ 弹跳扣篮目标：              │  │
│  │ ████████░░░░░░░░ 52%        │  │
│  │ 预计还需 8 周                │  │
│  └────────────────────────────┘  │
│                                    │
│         [ 分享总结 ]               │
│         [ 返回首页 ]               │
└────────────────────────────────────┘
```

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-11-AC01 | 正常完成训练 | 完成全部计划动作 | 结束训练 | 3s 内生成故事化总结 |
| TR-11-AC02 | 提前结束训练 | 训练中途 | 点击"结束训练" | 总结包含"未完成"标记 |
| TR-11-AC03 | 退出后查看 | 未看总结就退出 | 回到首页 | 显示"查看训练总结"横幅 |

#### 5.2.12 训练历史与数据仪表盘

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall maintain a complete training history accessible via a chronological list and a data dashboard with multiple visualization types. |
| Event-driven | When the user navigates to "训练历史", the system shall display a scrollable list of past training sessions grouped by week, each showing date, duration, exercise count, and a highlight indicator (PR/not). |
| Event-driven | When the user taps a historical session, the system shall display the full session detail with all sets, weights, reps, and RPE. |
| Event-driven | When the user navigates to "数据仪表盘", the system shall display: (1) 1RM trend line chart (selectable exercise), (2) weekly volume bar chart, (3) RPE distribution pie chart, (4) muscle group heatmap, (5) estimated jump height trend (for jump-related goals). |
| State-driven | While viewing the dashboard, the user shall be able to switch time ranges: 1周 / 1月 / 3月 / 6月 / 全部. |
| Unwanted | If the user has fewer than 3 training sessions, then the system shall display a "数据积累中" placeholder with a minimum data requirement notice instead of incomplete charts. |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| TR-12-AC01 | 查看训练历史 | 有 10 次训练记录 | 进入训练历史 | 按周分组显示，可滚动 |
| TR-12-AC02 | 查看训练详情 | 在历史列表 | 点击一次训练 | 显示完整组数据 |
| TR-12-AC03 | 数据仪表盘 | 有 10+ 次训练 | 进入仪表盘 | 多图表显示，可切换时间范围 |
| TR-12-AC04 | 数据不足 | 仅 1 次训练 | 进入仪表盘 | 显示"数据积累中"占位 |

---

## 6. 数据指标与埋点

### 6.1 北极星指标

> **"每周完成 3+ 次训练 + 3+ 次英语练习 + 1+ 次深度阅读的用户数"**

此指标衡量的是"真正在使用 PrimeAtlas 三大支柱的用户"，而非仅仅下载或注册的用户。代表了产品的核心价值交付。

### 6.2 关键业务指标（按模块）

#### 总体指标

| 指标 | 目标值（6个月） | 计算方式 |
|------|:---:|------|
| DAU（日活跃用户） | 50,000 | 每日至少打开一次 App 的用户数 |
| WAU（周活跃用户） | 150,000 | 每周至少打开一次 App 的用户数 |
| MAU（月活跃用户） | 500,000 | 每月至少打开一次 App 的用户数 |
| DAU/MAU 比值 | ≥0.3 | 日活 / 月活 |
| 次日留存 | ≥40% | D1 回访 / D0 新增 |
| 7 日留存 | ≥25% | D7 回访 / D0 新增 |
| 30 日留存 | ≥15% | D30 回访 / D0 新增 |
| NPS | ≥50 | 标准 NPS 调研 |

#### 训练模块指标

| 指标 | 目标值 | 计算方式 |
|------|:---:|------|
| 训练计划完成率 | ≥70% | 实际完成动作数 / 计划动作数 |
| 周均训练次数 | ≥3 | 周训练会话数均值 |
| 训练中 PR 触发率 | ≥15% | 有 PR 的训练会话 / 总训练会话 |
| 疼痛标记率 | ≤5% | 含疼痛标记的会话 / 总训练会话 |
| RPE 填写率 | ≥90% | 填写了 RPE 的组数 / 总组数 |

#### 英语模块指标

| 指标 | 目标值 | 计算方式 |
|------|:---:|------|
| 周均英语会话时长 | ≥30 分钟 | 周英语语音总时长均值 |
| 英语周活跃率 | ≥40% | 本周有英语活动的用户 / WAU |
| 跟读训练完成率 | ≥60% | 完成跟读组数 / 开始跟读组数 |
| 英语 PR 触发率 | ≥10% | 触发英语 PR 的会话 / 总会话 |
| LISA 改善率 | ≥20% | 30 天内 LISA 总分提升 ≥10% 的用户比例 |

#### 读书模块指标

| 指标 | 目标值 | 计算方式 |
|------|:---:|------|
| 月均阅读书籍数 | ≥1 | 月完成阅读书籍数均值 |
| 读书笔记创建率 | ≥50% | 创建笔记的用户 / 阅读用户 |
| 书籍 Agent 对话率 | ≥30% | 使用 Agent 对话的用户 / 阅读用户 |
| 知识 PR 触发率 | ≥5% | 触发知识 PR 的会话 / 总训练会话 |

#### 伙伴系统指标

| 指标 | 目标值 | 计算方式 |
|------|:---:|------|
| 伙伴选择完成率 | ≥95% | 完成伙伴选择的用户 / 注册用户 |
| 伙伴消息打开率 | ≥60% | 打开伙伴推送的用户 / 收到推送的用户 |
| 伙伴等级分布 | Lv.1: 40%, Lv.2: 30%, Lv.3: 20%, Lv.4: 8%, Lv.5: 2% | 各等级用户占比 |
| 伙伴切换率 | ≤5% | 更换伙伴的用户 / 总用户 |

### 6.3 训练模块埋点事件

| 事件名 | 触发时机 | 参数 |
|------|------|------|
| `training_session_start` | 用户点击开始训练 | session_id, plan_id, location, time_of_day |
| `training_set_start` | 开始一组训练 | session_id, exercise_name, set_number, planned_weight, planned_reps |
| `training_set_complete` | 完成一组训练 | session_id, exercise_name, set_number, actual_weight, actual_reps, rpe, duration_seconds |
| `training_pain_marked` | 用户标记疼痛 | session_id, exercise_name, body_part, severity, action_taken |
| `training_pr_achieved` | 突破 PR | session_id, pr_type, old_value, new_value, exercise_name |
| `training_pr_card_shared` | 分享 PR 卡片 | session_id, card_style, share_channel |
| `training_session_complete` | 完成训练 | session_id, total_duration, total_volume, exercises_completed, exercises_planned |
| `training_video_viewed` | 查看动作视频 | exercise_name, view_duration, tier_accessed |
| `training_plan_generated` | 生成训练计划 | plan_type (single/multi), generation_duration_ms, user_adjusted |

### 6.4 英语模块埋点事件

| 事件名 | 触发时机 | 参数 |
|------|------|------|
| `english_lisa_assessment_start` | 开始 LISA 评估 | - |
| `english_lisa_assessment_complete` | 完成 LISA 评估 | L, I, S, A scores, cefr_level |
| `english_conversation_start` | 开始自由对话 | topic_source, difficulty_level, mode |
| `english_conversation_end` | 结束自由对话 | duration_seconds, word_count, unique_words, error_count, user_speaking_ratio |
| `english_conversation_error` | 发生语法/发音错误 | error_type, error_severity, was_corrected |
| `english_shadowing_start` | 开始跟读训练 | sentence_count |
| `english_shadowing_complete` | 完成跟读训练 | total_score, phonemes_improved, phonemes_declined |
| `english_pr_achieved` | 触发英语 PR | pr_type, value |
| `english_micro_session` | 完成微会话 | duration, mode (commute/rest/bedtime) |

### 6.5 读书模块埋点事件

| 事件名 | 触发时机 | 参数 |
|------|------|------|
| `reading_book_import` | 导入书籍 | file_size_mb, format, import_duration_ms, success |
| `reading_book_open` | 打开书籍 | book_id, time_of_day, reading_streak_day |
| `reading_page_progress` | 阅读进度更新 | book_id, progress_pct, scroll_velocity |
| `reading_highlight_create` | 创建划线 | book_id, highlight_color |
| `reading_note_create` | 创建笔记 | book_id, note_type (text/voice/linked) |
| `reading_book_agent_chat` | 使用书籍 Agent | book_id, depth_level, message_count, duration_seconds |
| `reading_knowledge_pr` | 触发知识 PR | book_id, book_concept, training_action, confidence |
| `reading_book_complete` | 读完一本书 | book_id, total_reading_days, note_count, discussion_count |
| `reading_partner_note_view` | 查看伙伴笔记 | book_id, note_visibility_mode |

### 6.6 伙伴系统埋点事件

| 事件名 | 触发时机 | 参数 |
|------|------|------|
| `partner_selection_start` | 进入伙伴选择 | - |
| `partner_selected` | 选择伙伴 | partner_id, selection_method (browse/quiz) |
| `partner_level_up` | 伙伴升级 | partner_id, new_level, trigger_action |
| `partner_memory_created` | 创建记忆 | memory_layer, memory_type |
| `partner_mode_shift` | 场景切换 | from_module, to_module, animation_played |
| `partner_push_received` | 收到伙伴推送 | push_type, push_category |
| `partner_push_opened` | 打开伙伴推送 | push_type, time_to_open_seconds |
| `partner_good_morning_viewed` | 查看早安消息 | day_of_week, message_length |

### 6.7 留存与转化埋点

| 事件名 | 触发时机 | 参数 |
|------|------|------|
| `user_registration` | 用户注册 | registration_method, utm_source |
| `user_onboarding_complete` | 完成引导流程 | total_duration, steps_completed, partner_selected |
| `app_open` | 打开 App | time_of_day, days_since_last_open |
| `app_session_end` | 结束会话 | session_duration, modules_used, partner_interactions |
| `subscription_start` | 开始订阅 | plan_type, price_tier |
| `subscription_cancel` | 取消订阅 | days_subscribed, cancel_reason |
| `user_churn_risk` | 流失预警触发 | days_inactive, risk_level, last_active_module |

---

## 7. 验收标准

### 7.1 伙伴系统验收

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| AC-CP-001 | 新用户完成伙伴选择 | 全新安装 App | 注册→浏览伙伴→选择 | 伙伴选择保存，进入数据采集 |
| AC-CP-002 | 伙伴头像所有状态切换 | 已选伙伴 | 依次触发空闲/专注/满意/惊叹/庆祝/关切/对话/阅读 | 每个状态动画流畅切换，无闪烁 |
| AC-CP-003 | Mode Shift 完整播放 | 在训练模块 | 切换到英语 Tab | 1.5s 动画 + 过渡台词 + 不卡顿 |
| AC-CP-004 | 伙伴升级到 Lv.2 | 完成 10 次训练 | 第 10 次训练结束 | 升级动画 + Lv.2 功能解锁提示 |
| AC-CP-005 | 断网时伙伴选择保存失败 | 选伙伴时断网 | 点击确认 | 显示重试按钮，3 次后提示 |
| AC-CP-006 | 低端机伙伴渲染降级 | 低端设备 (<2GB RAM) | 进入训练页 | 静态头像，无崩溃无卡顿 |
| AC-CP-007 | 深夜模式语音变化 | 凌晨 1 点触发伙伴语音 | 听语音 | 音量 -20%，语速 -10%，轻柔质感 |
| AC-CP-008 | 3 天未训练推送 | 用户 3 天未训练 | 等待 18:00 | 收到低压关怀推送 |
| AC-CP-009 | 勿扰时段不推送 | 勿扰 22-08 设置 | 22:30 触发推送 | 无推送，次日 8:00 后送达 |
| AC-CP-010 | 连续忽略推送降频 | 连续忽略 3 次推送 | 第 4 天 | 推送频率降至 1 次/天 |

### 7.2 训练模块验收

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| AC-TR-001 | 完整数据采集流程 | 伙伴选择完成 | 依次填写 6 步 | 每步保存，最终生成训练计划 |
| AC-TR-002 | 中途退出数据采集 | 填写到第 3 步 | 关闭 App → 重开 | 显示"继续完善资料" |
| AC-TR-003 | 训练计划生成 | 数据采集完成 | 请求生成 | AI 推理过程可见，计划合理 |
| AC-TR-004 | 训练执行完整流程 | 已有计划 | 开始训练→完成所有动作 | 数据记录完整，无丢失 |
| AC-TR-005 | 3-2-1-GO 倒计时 | 训练执行中 | 点击"开始一组" | 完整动画 + 语音 + 震动同步 |
| AC-TR-006 | LAST SET 仪式 | 完成倒数第二组 | 观察界面 | 横幅 + 火焰 + 震动 + 语音 |
| AC-TR-007 | PR 突破庆祝 | 训练中突破 PR | 确认数据 | 8 秒庆祝序列 + 分享卡片 |
| AC-TR-008 | 疼痛标记 ≥4 | 训练中 | 标记疼痛=4 级 | 训练暂停，显示停止建议 |
| AC-TR-009 | 训练总结生成 | 完成训练 | 结束训练 | 3s 内生成故事化总结 |
| AC-TR-010 | 视频缓存回退 | 断网 + 未缓存 | 打开视频 | 显示关键帧图片序列 |
| AC-TR-011 | 动作自我检查 | 完成一组 | 查看检查清单 | 显示对应动作的检查项 |
| AC-TR-012 | 1RM 安全上限 | 最高记录 80kg, 推算 95kg | 自动 | 封顶 88kg + "待验证"标记 |
| AC-TR-013 | 异常数据排除 | 上次 80kg, 本次 120kg | 记录 | 标记异常，不参与 1RM 计算 |
| AC-TR-014 | 数据录入超时 | 完成一组后不操作 | 等 60 秒 | 自动保存 + 标记"数据缺失" |

### 7.3 英语模块验收

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| AC-EN-001 | LISA 评估完整 | 首次进入英语 | 完成 4 个子测试 | 生成雷达图 + CEFR 估计 |
| AC-EN-002 | LISA 中途中止恢复 | 完成 2/4 退出 | 重新进入 | 从第 3 个测试继续 |
| AC-EN-003 | AI 自由对话 | 已评估 | 选话题→对话 5 分钟 | 实时转写 + 错误标注 + 纠错 |
| AC-EN-004 | 难度自适应 | 连续 3 轮低错误 | 继续对话 | 难度自动提升 |
| AC-EN-005 | 跟读音素纠错 | 进入跟读模式 | 跟读 5 句 | 音素级颜色标注 |
| AC-EN-006 | 通勤模式纯语音 | 开启通勤模式 | 使用英语 | 纯语音，极简 UI |
| AC-EN-007 | 组间休息 30 秒英语 | 训练中休息 | 点击"30秒英语" | 30 秒训练相关微对话 |
| AC-EN-008 | 睡前模式 | 23:00 进入英语 | 对话 | 语速-10%，音量-20%，深色主题 |
| AC-EN-009 | 对话耐力 PR | 首次连续 10 分钟 | 达到 10 分钟 | 全屏庆祝 |
| AC-EN-010 | 勇气 PR | 上次崩溃退出 | 重新开始 | 伙伴特殊鼓励 |
| AC-EN-011 | 微会话 30 秒 | 首页空闲 | 点击微挑战 | 30 秒问答，到时自动结束 |
| AC-EN-012 | 英语周报 | 本周有活动 | 周日 20:00 | 伙伴的一封信 |

### 7.4 读书模块验收

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| AC-RD-001 | 导入文本 PDF | 选择可提取文本 PDF | 导入 | 30s 内完成提取+章节识别 |
| AC-RD-002 | 导入扫描版 PDF | 选择扫描图片 PDF | 导入 | 提示无法识别，拒绝 |
| AC-RD-003 | AI 多层总结 L0-L2 | 书籍导入完成 | 等待 | 自动生成 |
| AC-RD-004 | 书籍 Agent 基础对话 | 书籍已导入 | 问基础问题 | 引用原文回答 |
| AC-RD-005 | 四层深度切换 | 对话中 | 切换深度 1→4 | 回答风格相应变化 |
| AC-RD-006 | 伙伴笔记读到浮现 | 有笔记的书 | 正常阅读到标记处 | 笔记淡入，不剧透 |
| AC-RD-007 | 快速滚动不浮现 | 有笔记的书 | 快速滚动 (>500px/s) | 笔记不浮现 |
| AC-RD-008 | 读书笔记四类型 | 阅读中 | 划线/批注/语音/关联 | 各类型正确保存 |
| AC-RD-009 | 知识 PR 触发 | 读书后训练中应用 | 训练结束 | 金色"知识 PR"庆祝 |
| AC-RD-010 | 读完书庆祝 | 翻过最后一页 | 观察 | 完整庆祝仪式 |
| AC-RD-011 | 深夜读书陪伴 | 凌晨 1 点打开书 | 观察 30 分钟 | 轻声问候 → 暖色主题 → 提醒休息 |
| AC-RD-012 | 文件过大拒绝 | 选择 150MB PDF | 导入 | 提示文件过大 |

### 7.5 异常场景验收

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| AC-EX-001 | App 崩溃恢复（训练中） | 训练中记录数据 | 强制杀进程→重开 | 训练数据不丢失，回到训练页 |
| AC-EX-002 | 网络切换（WiFi→4G） | 训练中 | 关闭 WiFi | 无感知切换，数据正常同步 |
| AC-EX-003 | 离线训练 | 飞行模式 | 完成完整训练 | 数据本地保存，联网后自动同步 |
| AC-EX-004 | 低电量模式 | 电量 <20% | 正常使用 | 减少动画帧率，保持核心功能 |
| AC-EX-005 | 存储空间不足 | 剩余 <100MB | 导入新书 | 提示存储不足，清理建议 |
| AC-EX-006 | 权限拒绝（麦克风） | 拒绝麦克风权限 | 进入英语模块 | 提示需要麦克风，允许文字输入模式 |
| AC-EX-007 | 权限拒绝（相机） | 拒绝相机权限 | 录制训练视频 | 跳过 AI 分析，仅提供自我检查清单 |

---

## 8. 非功能性需求

### 8.1 性能要求

| 指标 | 要求 | 测量方法 |
|------|------|------|
| App 冷启动时间 | ≤ 2 秒（P50）, ≤ 4 秒（P95） | 点击图标到首页可交互 |
| App 热启动时间 | ≤ 1 秒 | 后台切回前台 |
| 页面切换响应 | ≤ 300ms | 从点击到页面渲染完成 |
| 伙伴头像帧率 | ≥ 30 FPS（标准设备）, ≥ 24 FPS（低端设备） | GPU 帧率监控 |
| 3-2-1-GO 动画 | 严格 3 秒，帧率 ≥ 60 FPS | 帧计时 |
| 训练计划生成 | ≤ 8 秒（P50）, ≤ 15 秒（P95） | API 请求到结果展示 |
| AI 对话响应 | ≤ 2 秒（首字延迟）, ≤ 5 秒（完整响应） | TTFB / TTFR |
| 语音识别延迟 | ≤ 1 秒 | 用户说完到文本显示 |
| 视频加载 | ≤ 3 秒（缓存命中）, ≤ 10 秒（WiFi 首次） | 点击到开始播放 |
| PDF 导入处理 | ≤ 30 秒（500 页） | 上传完成到章节识别完成 |
| 内存占用 | ≤ 300MB（前台）, ≤ 100MB（后台） | 系统内存监控 |
| 安装包大小 | ≤ 80MB（Android）, ≤ 120MB（iOS） | APK/IPA 大小 |

### 8.2 离线可用性

| 场景 | 离线能力 |
|------|------|
| 训练执行 | 完全离线可用（数据本地存储，联网后同步） |
| 训练历史查看 | 完全离线可用（本地缓存最近 30 天） |
| 动作视频 | 已缓存视频可离线播放 |
| 英语跟读 | 离线可用（本地 Whisper.cpp + 预存标准音频） |
| 英语自由对话 | 需要网络（依赖云端 LLM） |
| 读书 | 已导入书籍完全离线可读 |
| 书籍 Agent 对话 | 需要网络 |
| 伙伴基础语音 | 离线可用（预缓存 50+ 常用短语 TTS） |
| 伙伴动态对话 | 需要网络（依赖云端生成） |
| 数据同步 | 自动检测网络恢复后增量同步，冲突以服务器为准 |

### 8.3 数据安全与隐私

| 要求 | 实现方式 |
|------|------|
| 本地数据加密 | SQLCipher AES-256 加密 |
| 传输加密 | TLS 1.3, 证书固定 (Certificate Pinning) |
| 用户认证 | JWT + 刷新令牌, 支持生物识别 (Face ID / 指纹) |
| 数据最小化 | 仅收集功能必需数据 |
| 数据可导出 | 用户可导出全部个人数据（JSON/CSV） |
| 数据可删除 | 用户可永久删除账户及全部数据（30 天冷静期） |
| 数据反哺 Opt-in | 默认关闭，用户主动开启 |
| 隐私政策 | 分层展示：简版（一页看懂）+ 完整版 |
| GDPR 合规 | 数据主体权利（访问/更正/删除/可携带/限制处理） |
| 儿童保护 | 最低年龄 16 岁，不收集儿童数据 |

### 8.4 可访问性

| 要求 | 实现方式 |
|------|------|
| 屏幕阅读器支持 | VoiceOver (iOS) / TalkBack (Android) 完整支持 |
| 色彩对比度 | WCAG 2.1 AA 标准（对比度 ≥ 4.5:1） |
| 文字大小 | 支持系统字体缩放（至 200%） |
| 触控目标 | 最小触控区域 44×44pt |
| 字幕 | 伙伴语音提供可选文字字幕 |
| 振动替代 | 听力障碍用户可开启视觉闪烁替代震动反馈 |
| 简洁模式 | 减少动画，降低认知负荷 |

### 8.5 兼容性

| 平台 | 最低版本 | 推荐版本 |
|------|:---:|:---:|
| iOS | iOS 15.0+ | iOS 17.0+ |
| Android | Android 8.0+ (API 26) | Android 13+ (API 33) |
| 微信小程序 | 微信 8.0+ | 微信最新版 |
| 设备 RAM | 2GB+ | 4GB+ |

---

## 9. 风险与依赖

### 9.1 技术风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|:---:|:---:|------|
| LLM API 延迟过高 | AI 对话体验差，用户流失 | 中 | 本地 Whisper.cpp + 预缓存 + 流式响应 + 超时回退策略 |
| 语音识别准确率不足 | 英语模块核心体验受损 | 中 | 多引擎冗余（Deepgram + Whisper + 本地），嘈杂场景降级方案 |
| 伙伴动画性能 | 低端设备卡顿，影响体验 | 高 | 三级渲染配置（全效/简化/静态），自动检测设备能力 |
| 离线数据同步冲突 | 数据丢失或不一致 | 中 | CRDT 方案，服务器时间戳为准，冲突数据保留为"待确认" |
| AI 生成内容质量不稳定 | 训练计划/对话质量波动 | 高 | Agent 评审委员会交叉验证，安全审核 Agent 最终把关 |
| 视频 CDN 成本过高 | 运营成本超预算 | 中 | 渐进式缓存策略，P2P 分发考虑（Phase 2） |
| 跨平台一致性 | iOS/Android 体验不一致 | 中 | React Native 统一框架，关键动画原生实现 |

### 9.2 合规风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|:---:|:---:|------|
| 数据隐私法规（GDPR/个人信息保护法） | 法律处罚、下架 | 中 | 隐私设计原则（PbD），Opt-in 机制，四层脱敏，定期合规审计 |
| AI 生成内容合规 | 不当内容导致责任 | 中 | 内容安全审核 Agent，敏感词过滤，用户举报机制 |
| 运动指导责任 | 用户受伤法律纠纷 | 低 | 明确免责声明，"参考但不绝对"原则，疼痛熔断机制，安全边界 |
| 医疗建议合规 | 被视为医疗设备/建议 | 低 | 仅提供运动建议，不含医疗诊断，伤病史仅做参考 |
| 儿童数据保护 | COPPA / 未成年人保护法 | 低 | 最低年龄 16 岁限制 |

### 9.3 内容风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|:---:|:---:|------|
| 书籍版权问题 | 侵权诉讼 | 中 | 仅支持用户自有文件导入，不做内容分发 |
| 动作视频版权 | 侵权诉讼 | 中 | 自产视频内容 + 授权合作 + CC0 资源 |
| AI 幻觉（训练建议） | 危险训练建议 | 低 | 安全审核 Agent + 训练知识库约束 + 危险动作黑名单 |
| 伙伴不当言论 | 用户情感伤害 | 低 | 伙伴输出审核层，敏感话题回避策略 |

### 9.4 依赖项清单

| 依赖项 | 类型 | 影响范围 | 备选方案 |
|------|:---:|------|------|
| DeepSeek-V3 API | AI 核心 | 训练计划/对话/总结 | GPT-4o-mini 备用 |
| Deepgram ASR | 语音识别 | 英语模块 | Whisper.cpp 本地 + 讯飞 API |
| Edge TTS / Azure TTS | 语音合成 | 伙伴语音 | 本地 TTS 引擎 + 预录制音频 |
| pgvector | 向量存储 | 书籍检索/记忆检索 | Qdrant / Milvus |
| TimescaleDB | 时序数据 | 训练数据分析 | PostgreSQL 分区表 |
| CDN 服务 | 视频分发 | 动作视频加载 | 直连 OSS |
| 推送服务 (APNs/FCM) | 消息推送 | 伙伴推送/召回 | 短信备用（仅召回） |
| 微信 SDK | 小程序/分享 | 社交分享/小程序 | H5 分享页备用 |

---

## 10. 附录

### 10.1 术语表

| 术语 | 英文 | 定义 |
|------|------|------|
| 伙伴 | Partner | 用户的 AI 训练伙伴，拥有名字、性格、记忆和成长轨迹 |
| PR | Personal Record | 个人纪录，包括训练 PR（重量/容量/次数）、英语 PR（6种）、知识 PR |
| RPE | Rate of Perceived Exertion | 主观疲劳感知评分，1-10 分制 |
| 1RM | One-Rep Max | 单次最大重量，通过次极限重量推算 |
| ACWR | Acute:Chronic Workload Ratio | 急慢性负荷比，监控训练负荷的指标 |
| LISA | Listening/Intelligibility/Spontaneity/Adequacy | 英语四维能力评估体系 |
| CEFR | Common European Framework of Reference | 欧洲共同语言参考标准（A1-C2） |
| Mode Shift | - | 伙伴在训练/英语/读书三个模块间切换时的过渡动画 |
| 三位一体 | Trinity Moment | 训练+英语+读书三个模块的交叉融合时刻 |
| 知识 PR | Knowledge PR | 在训练中应用书中知识时触发的特殊 PR |
| 书籍 Agent | Book Agent | 以书籍作者/内容视角进行对话的 AI Agent |
| Agent 评审委员会 | Agent Review Committee | 11 个专业 Agent 交叉验证训练计划的协作系统 |
| 四层脱敏 | Four-Layer Anonymization | PII剥离→泛化→K-匿名化→差分隐私的数据处理流水线 |
| Opt-in | - | 用户主动授权（默认关闭）的数据贡献机制 |
| 成长指数 | Growth Index | 综合训练/英语/读书/坚持度的 0-1000 评分 |

### 10.2 参考文献列表

| 编号 | 文献 | 应用场景 |
|:---:|------|------|
| REF-01 | PrimeAtlas 核心需求文档 V2.0 | 产品核心定位与功能架构 |
| REF-02 | PrimeAtlas 伙伴全场景陪伴设计 | 伙伴跨模块陪伴体验设计 |
| REF-03 | NSCA Essentials of Strength Training and Conditioning | 训练科学基础 |
| REF-04 | Epley Formula (1985) | 1RM 推算公式 |
| REF-05 | Gabbett TJ (2016) - ACWR 模型 | 训练负荷监控 |
| REF-06 | CEFR (2001/2018) | 英语能力分级标准 |
| REF-07 | GDPR (EU 2016/679) | 数据隐私合规 |
| REF-08 | WCAG 2.1 | 可访问性标准 |
| REF-09 | 《个人信息保护法》(2021) | 中国数据隐私合规 |
| REF-10 | James Clear - Atomic Habits | 身份驱动习惯理论（知识 PR 概念来源） |

### 10.3 竞品参考

| 竞品 | 类型 | 值得学习 | PrimeAtlas 差异化 |
|------|:---:|------|------|
| **Keep** | 健身 App | 动作视频库、训练社区 | AI 个性化编排 vs 模板化计划 |
| **多邻国 (Duolingo)** | 语言学习 | 游戏化激励、连续打卡 | 只做听说+场景融合 vs 全技能 |
| **微信读书** | 读书 App | 划线分享、阅读时长排行 | AI 书籍对话+跨域关联 vs 社交阅读 |
| **Whoop** | 穿戴设备 | 恢复评分、负荷监控 | AI 教练 vs 被动数据呈现 |
| **Jabra Sport** | 运动耳机 App | 训练中语音指导 | 人格化伙伴 vs 工具化语音 |
| **Replika** | AI 陪伴 | 人格化 AI、情感记忆 | 专项领域深度 vs 泛聊天 |
| **Endel** | 专注 App | 场景自适应 | 多模态（语音+视觉+动画）vs 纯音频 |

---

## 11. 训练编排核心算法（V2.0 新增）

> 本章内容详见配套文档 `/workspace/PrimeAtlas_训练编排与资源摄入引擎.md`，此处定义 PRD 级别的核心规格。

### 11.1 标准化容量单位（NVU）

The system shall compute training volume using Normalized Volume Units (NVU) with five correction factors:

```
NVU = VL_raw × MF × CF × NF × EF × GF
```

| 因子 | 名称 | 范围 | 说明 |
|------|------|:---:|------|
| MF | 肌群参与度因子 | 0.3-1.0 | 深蹲=1.0，二头弯举=0.3 |
| CF | CNS 负荷因子 | 0.3-1.5 | 深蹲=1.5，腿举=0.6 |
| NF | 离心负荷因子 | 0.5-1.2 | 深蹲=1.2，硬拉=0.8 |
| EF | 动作效率因子 | 0.5-1.0 | 持续张力比例 |
| GF | 目标匹配因子 | 0.5-1.5 | 力量目标×1.5，耐力目标×0.5 |

### 11.2 ACWR 负荷监控

The system shall compute Acute:Chronic Workload Ratio as:

```
ACWR = Acute_Load_7d / Chronic_Load_28d
```

| 区间 | 标签 | 自动干预 |
|------|------|---------|
| < 0.8 | 欠载 | 建议 +10-15% |
| 0.8-1.0 | 保守区 | 维持或微增 5% |
| **1.0-1.3** | **最佳区** | 无干预 |
| 1.3-1.5 | 警戒区 | 黄色预警 |
| > 1.5 | 危险区 | 红色预警，强制降载 20-30% |

按训练水平的安全阈值：新手危险线 1.4，中级 1.5，进阶 1.6。

### 11.3 动作排序算法

The system shall sort exercises using multi-level topological sort:

**优先级（数字越小越先做）：** 1=爆发力 → 2=大重量复合 → 3=中等复合 → 4=肌肥大 → 5=耐力 → 6=纠正性

**同优先级内：** 大肌群>小肌群 → 复合>孤立 → 自由重量>固定器械

### 11.4 疲劳传递模型

The system shall compute inter-exercise fatigue transfer:

- 做完深蹲后：腿举效率 -15%，保加利亚分腿蹲效率 -20%
- 做完硬拉后：深蹲效率 -20%，杠铃划船效率 -18%
- CNS 系统疲劳：每个大重量动作给所有后续动作 +3% 疲劳

### 11.5 组间休息动态计算

The system shall compute rest time based on training goal and real-time RPE:

| 训练目标 | 基础休息 | RPE≥9 修正 |
|---------|:---:|:---:|
| 力量 | 3-5 分钟 | +30 秒 |
| 爆发力 | 3 分钟 | +30 秒 |
| 肌肥大 | 60-90 秒 | +15 秒 |
| 耐力 | 30-60 秒 | +10 秒 |

### 11.6 多场景容量分配

When user configures multi-scenario training (e.g., 07:00 home 15min → 13:00 office 10min → 20:00 gym 75min), the system shall allocate daily capacity as:

- 早上：12-15%（神经激活 + 灵活性）
- 中午：5-8%（恢复性 + 姿态纠正）
- 晚上：77-83%（主力训练）

### 11.7 热身与冷却嵌入（V2.1 新增）

The system shall embed warm-up and cool-down modules into every training plan. Warm-up and cool-down are NOT optional — they are mandatory components.

**热身分层：**
- **通用热身**（5-8分钟）：轻度有氧 + 动态拉伸 + 关节活动
- **专项热身**（3-5分钟）：针对当天主训动作的神经激活和动作模式预热
- 热身动作 NVU 不计入训练容量（空杆热身组除外，×0.3 系数）
- 热身疲劳系数：0.01-0.08（几乎不影响疲劳计算）

**冷却拉伸分层：**
- **即时冷却**（3-5分钟）：训练结束后降低心率
- **静态拉伸**（5-8分钟）：针对当天训练肌群的静态拉伸
- 冷却动作疲劳系数：0.00（不产生训练疲劳）

**按场景的热身/冷却分配（修正后的多场景容量模型）：**

```
早上家(15min)：
  ├── 热身激活(5min) — 全身动态+关节唤醒
  ├── 微训练(8min) — 神经激活+灵活性
  └── 冷却(2min) — 呼吸调整

中午工位(10min)：
  ├── 激活(2min) — 对抗久坐的关节活动
  ├── 微训练(6min) — 静态拉伸+姿态纠正
  └── 放松(2min) — 深呼吸+肩颈放松

晚上球场(75min)：
  ├── 热身(8-10min) — 通用+专项神经激活
  ├── 正式训练(55-60min) — 主力训练
  └── 冷却拉伸(8-10min) — 降心率+静态拉伸
```

**按专项目标的热身定制：**
- 篮球弹跳：踝关节激活 + 髋关节打开 + plyometric 低强度预演
- 羽毛球：肩关节绕环 + 侧向移动预演 + 手腕激活
- 产后康复：腹式呼吸激活 + 骨盆稳定 + 极轻度核心唤醒
- 大重量力量日：空杆热身组(递增负荷) + 髋关节活动 + 核心激活

**独立恢复模块：**
- 休息日主动恢复：伙伴推送 10-15 分钟恢复方案
- 睡前放松：5 分钟呼吸 + 轻度拉伸（深夜模式自动推荐）
- 工位微恢复：2 分钟颈椎/肩部/腰部放松

**伙伴在热身/恢复中的陪伴策略：**
- 热身阶段（GUIDE 语气）：温和引导，不急不躁。"先转一转肩膀。对，慢一点。让关节润滑起来。"
- 冷却阶段（RELAXED 语气）：柔和放松。"深呼吸——吸气 4 秒，屏住，呼气 6 秒。你的身体今天完成了很棒的工作。"
- 拉伸阶段：每 30 秒提示一个拉伸动作，配合呼吸节奏

**热身动作库（18个）+ 拉伸动作库（17个）详见配套文档：** `/workspace/Atlas/docs/PrimeAtlas_热身恢复拉伸体系设计.md`
### 11.7 综合疲劳指数

The system shall compute a composite fatigue index (0-100) weighted from five dimensions:

| 维度 | 权重 | 数据来源 |
|------|:---:|------|
| 局部疲劳（12 肌群） | 30% | 训练记录自动计算 |
| CNS 系统疲劳 | 20% | 大重量动作数 + 可选握力/HRV |
| 累积疲劳（ACWR） | 25% | 7d/28d 滚动窗口 |
| 感知疲劳（RPE） | 15% | 用户每次训练后输入 |
| 恢复质量 | 10% | 睡眠/HRV/静息心率 |

疲劳指数映射训练建议：0-30 全力训练 / 30-50 正常训练 / 50-70 降载 / 70+ 强制恢复。

### 11.8 连续高 RPE 动态调整规则

| 模式 | 调整 |
|------|------|
| Day1 RPE≥8 | Day2 降 10% |
| Day1 RPE≥8, Day2 RPE≥8 | Day3 降 25% |
| Day1 RPE≥8, Day2 RPE≥8, Day3 RPE≥8 | Day4 强制休息 |
| Day1 RPE≥9 | Day2 降 15% |
| 任意日 RPE=10 | 次日强制休息 |

---

## 12. 多 Agent 评审体系（V2.0 新增）

> 本章内容详见配套文档 `/workspace/PrimeAtlas_多Agent评审体系设计.md` 和 `/workspace/PrimeAtlas_开放Agent协作生态设计.md`，此处定义 PRD 级别的核心规格。

### 12.1 Agent 评审委员会

The system shall maintain an 11-Agent review committee that cross-validates all AI-generated training and learning plans:

**训练计划评审团（5 Agent）：**

| Agent | 职责 | 权力 |
|-------|------|:---:|
| 🏋️ 运动科学审核员 | ACWR/动作排序/容量/渐进策略 | 普通投票权 |
| 🛡️ 安全审核员 | 损伤史对照/高危组合/过度训练 | **一票否决权** |
| 🎯 个性化适配员 | 目标/设备/时间/水平/偏好匹配 | 普通投票权 |
| 📚 资料一致性审核员 | 对比导入资料，判断合理推翻 | 普通投票权 |
| 👤 用户视角体验员 | 复杂度/心理负担/指令清晰度 | 普通投票权 |

**英语学习计划评审团（4 Agent）：**
🔬 SLA 语言学审核员 / 📐 难度适配审核员 / 🔗 内容一致性审核员 / 😊 学习体验审核员

**通用评审 Agent（2 Agent）：**
🔄 跨模块协调员 / ⚖️ 首席评审官

### 12.2 五阶段圆桌协作模型

The system shall orchestrate Agent collaboration through five phases:

```
Phase 1: 提案（串行）— 1 个 Agent 产出初稿
Phase 2: 并行评审（并行）— N 个 Agent 同时独立评审
Phase 3: 交叉借鉴（半串行）— Agent 互读评审意见，可更新自己的判断
Phase 4: 分歧裁决（串行）— 首席 Agent 基于数据/优先级/安全原则裁决
Phase 5: 终稿确认（串行）— 提案 Agent 修订后发布
```

### 12.3 裁决优先级

The system shall resolve conflicts in strict order:

1. **安全红线**（最高优先级）：安全审核员 VETO → 直接驳回
2. **投票统计**：2 票以上 FAIL → 驳回；1 票 FAIL → 标注争议，有条件通过
3. **争议解决**：Agent 间直接矛盾 → 采纳更保守意见
4. **自动修改**：CONDITIONAL_PASS → 自动应用建议修改

### 12.4 防敷衍机制

The system shall prevent review complacency through four mechanisms:

1. **强制差异化输出**：每个 Agent 必须至少提出 1 条实质性建议
2. **分布监控**：PASS 率 > 80% 触发警报；目标分布 PASS 50-60%
3. **影子评审团**：每周 10% 样本交叉验证
4. **用户反馈闭环**：用户执行后反馈反向校准 Agent 准确率

### 12.5 开放 Agent 生态

The system shall support four categories of Agents:

| 类型 | 来源 | 接入方式 |
|------|------|---------|
| 内置 Agent（11 个） | 产品自带 | 本地执行 |
| 厂商 Agent | OpenAI/DeepSeek 等 | PAP 协议 + 适配层 |
| 三方 Agent | 健身博主/康复机构 | Agent SDK + 审核上架 |
| 用户 Agent | 用户自然语言创建 | 意图解析 → 能力生成 → Agent 生成 |

The system shall provide an Agent Marketplace for browsing, selecting, and adding Agents. Each Agent shall declare its capabilities via a unified Agent Manifest schema.

### 12.6 产品决策层（双层信息架构）

The system shall maintain two information layers:

- **Deep Layer（Agent 内部讨论）**：使用 ACWR/NVU/RPE 等专业指标
- **Surface Layer（用户可见）**：自然语言 Tips，专业术语自动转换

决策权限三级模型：

| 层级 | 决策类型 | 示例 |
|:---:|------|------|
| L1 完全自动 | 英语素材/读书推荐/格式优化 | 静默执行 |
| L2 条件自动 | 参数微调 <15%/同类动作替换 | 自动执行，事后告知 |
| L3 用户决策 | 目标变更/Agent 不可调和分歧/大范围调整 >30% | 必须用户确认 |

---

## 13. 专业信任体系（V2.0 新增）

### 13.1 学术依据引用

The system shall embed academic references for key design decisions. When users ask "why", the system shall display the research basis:

| 系统设计 | 学术依据 | 关键研究 |
|----------|----------|----------|
| ACWR 1.0-1.3 最佳区间 | Gabbett (2016), Br J Sports Med | ACWR>1.5 损伤风险 2.1-3.4 倍 |
| 1RM 次最大推算 | Brzycki (1993), Epley (1985) | 误差 ±5-10% |
| 动作排序 | NSCA Essentials (Haff & Triplett, 2016) | CNS 疲劳恢复需 2-3h |
| 组间休息 | Willardson (2006), Schoenfeld (2016) | ATP-PC 3min 恢复 85% |
| RPE 自调节 | Zourdos et al. (2016), Helms et al. (2016) | RPE 与 %1RM 相关 r=0.88 |
| 听说聚焦 | Krashen (1985), Swain (1985), Nation (2007) | 中国听力 436 vs 阅读 492 |
| LISA 模型 | Field (2008), Munro (1995), De Bot (1992), Skehan (1998) | 四个 SLA 核心领域 |
| AI 交互学习 | Long (1996), Lyster & Ranta (1997) | 意义协商促进习得 |

### 13.2 系统能力边界（诚实声明）

The system shall display capability limitations transparently:

**训练方面做不到的：**
- 实时动作技术纠错（无摄像头评估）
- 个性化心理激励（无法像真人教练了解性格）
- 训练中突发情况应对（无法检测头晕/关节异响）
- 医学诊断（不是医疗器械）

**英语方面做不到的：**
- 消除口音（成年人语音系统已固化，目标为可懂度）
- 评估写作能力（系统聚焦听说）
- 模拟真实社交压力（AI 对话零社交成本）

### 13.3 估算误差声明

The system shall display estimation error ranges when presenting computed metrics:

| 估算项 | 误差范围 | 来源 |
|--------|:---:|------|
| 1RM 推算 | ±5-10% | Reynolds et al. (2006) |
| RPE 自评（新手） | ICC 0.5-0.6 | Zourdos et al. (2016) |
| RPE 自评（老手） | ICC 0.8-0.9 | Zourdos et al. (2016) |
| 睡眠自报 vs 实际 | ±1-2h | Lauderdale et al. (2008) |

### 13.4 用户诚实依赖声明

The system shall inform users that the following data rely on honest self-reporting and cannot be verified: RPE ratings, completed weight/reps, sleep duration/quality, pain/discomfort reports, previous training experience.

---

## 14. 评审修正采纳清单（V2.0 新增）

本章汇总综合评审报告（5 位专家）的 21 项 P0 修正及采纳状态。

### 14.1 UX 交互修正（6 项）

| 编号 | 修正项 | 采纳 | PRD 对应章节 |
|------|--------|:---:|------|
| UX-01 | 首次训练路径增加"90 秒快速体验"免注册通道 | ✅ | 5.1.1 |
| UX-02 | 训练数据录入改为大按钮 + 语音为主 | ✅ | 5.2.4 |
| UX-03 | 设计完整"不想练"休息日模式 | ✅ | 5.2.7 |
| UX-04 | 连续火焰改为"本周活跃"模式，休息日休眠不灭 | ✅ | 5.6.2 |
| UX-05 | 增加 RPE 校准引导 + 具体感受描述 | ✅ | 5.2.4 |
| UX-06 | 训练执行页拆分为训练中/组间休息双视图 | ✅ | 5.2.4 |

### 14.2 视觉设计修正（5 项）

| 编号 | 修正项 | 采纳 | PRD 对应章节 |
|------|--------|:---:|------|
| VS-01 | 定义字体系统（数据/DIN、正文/PingFang SC、阅读/思源宋体） | ✅ | 8.4 |
| VS-02 | 输出 5 个伙伴完整视觉外观设定 | ✅ | 5.1.2 |
| VS-03 | 定义数据可视化设计规范 | ✅ | 5.5.1 |
| VS-04 | 输出品牌识别手册（Logo/色彩/图标） | ✅ | 8.4 |
| VS-05 | 定义四种训练氛围完整视觉规格 | ✅ | 5.2.6 |

### 14.3 趣味体验修正（5 项）

| 编号 | 修正项 | 采纳 | PRD 对应章节 |
|------|--------|:---:|------|
| FE-01 | 增加"90 秒试炼"免注册体验 | ✅ | 5.1.1 |
| FE-02 | 增加"今日伙伴日志"作为首页（替代纯仪表盘） | ✅ | 5.6.1 |
| FE-03 | 增加 AI 自动发现的隐藏成就 | ✅ | 5.6.3 |
| FE-04 | 每组完成增加微动效 + 训练中随机彩蛋 | ✅ | 5.2.5 |
| FE-05 | "匿名同行者"提前到 P0，碰拳提前到 P1 | ✅ | 4.1 / 5.7 |

### 14.4 市场策略修正（5 项）

| 编号 | 修正项 | 采纳 | PRD 对应章节 |
|------|--------|:---:|------|
| MK-01 | MVP 前完成 50+ 人"三合一"需求验证访谈 | ✅ | 9.4 |
| MK-02 | MAU 目标从 50 万修正为 8-15 万 | ✅ | 6.1 |
| MK-03 | 明确免费版/付费版功能边界 | ✅ | 4.2 |
| MK-04 | 增加竞争防御策略章节 | ✅ | 9.3 |
| MK-05 | 小程序从 P2 提升至 P0 | ✅ | 4.1 |

---

## 15. 文档维护规则（V2.0 新增）

The system shall maintain documentation hygiene through the following rules:

### 15.1 文档分类

| 类型 | 用途 | 保留规则 |
|------|------|---------|
| **主文档** | PRD V2.0（本文档） | 持续更新，版本号递增 |
| **配套设计文档** | 算法/Agent/伙伴详细设计 | 独立维护，PRD 引用 |
| **评审报告** | 各维度评审结论 | 归档保留，作为决策记录 |
| **概要文档** | 核心需求文档 V2 | 面向管理层，保持同步 |
| **中间产物** | 需求梳理/对齐会/领域分析 | ❌ 已清理 |

### 15.2 当前文档体系（精简后）

| 文档 | 类型 | 说明 |
|------|------|------|
| **PrimeAtlas_PRD_V2.0.md** | 🏛️ 主文档 | 本文档，PRD 完整规格 |
| PrimeAtlas_核心需求文档_V2.md | 📋 概要 | 管理层速览 |
| PrimeAtlas_伙伴全场景陪伴设计.md | 🎨 配套设计 | 伙伴交互细节 |
| PrimeAtlas_训练编排与资源摄入引擎.md | 🔬 配套设计 | 算法规格 |
| PrimeAtlas_多Agent评审体系设计.md | 🔬 配套设计 | Agent 评审规格 |
| PrimeAtlas_开放Agent协作生态设计.md | 🔬 配套设计 | Agent 生态规格 |
| PrimeAtlas_PRD综合评审报告.md | ✅ 评审 | 5 专家综合评审 |
| PrimeAtlas_UX_Review_V1.0.md | ✅ 评审 | UX 评审 |
| PrimeAtlas_Visual_Design_Review.md | ✅ 评审 | 视觉评审 |
| PrimeAtlas_趣味体验评审报告.md | ✅ 评审 | 趣味体验评审 |
| PrimeAtlas_市场调研评审报告.md | ✅ 评审 | 市场调研评审 |

---

## 文档结束

*本文档基于 PrimeAtlas 核心需求文档 V2.0 和伙伴全场景陪伴设计文档撰写，所有功能需求均采用 EARS 原则表述。V2.0 采纳了 5 位专家综合评审的 21 项 P0 修正，并补充了训练编排算法、多 Agent 评审体系、专业信任体系和评审修正采纳清单。*

*配套设计文档包含更详细的算法规格和交互设计，请与本文档配合使用。*

---

**下一步行动：**
1. 研发团队评审功能规格和验收标准
2. 设计团队评审交互规格和动画需求（参考 UX/视觉评审报告）
3. AI 团队评审 Agent 架构和模型选型（参考多Agent评审体系设计）
4. 法务团队评审隐私合规和数据反哺方案（参考专业信任体系章节）
5. 用研团队执行 50+ 人"三合一"需求验证访谈（参考市场调研评审报告 MK-01）
6. 确定 MVP Phase 1 开发排期

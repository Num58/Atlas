# PrimeAtlas 热身/恢复/拉伸体系 — 完整设计文档

> **文档定位**：PrimeAtlas 训练编排体系中热身(Warm-Up)、冷却拉伸(Cool-Down & Stretching)、独立恢复(Recovery)模块的完整设计
> **编制日期**：2026-07-02
> **编制人**：PrimeAtlas 运动科学与训练编排联合团队
> **基于文档**：PRD V2.0 / 完整功能蓝图 / 训练编排引擎
> **设计原则**：热身和恢复不是"可选附加项"，而是每个训练计划的强制嵌入模块

---

# 第一部分：热身动作库 (Warm-Up Exercise Library)

## 1.1 动作库结构说明

每个热身动作包含以下属性字段：

| 字段 | 说明 | 示例 |
|------|------|------|
| `exercise_id` | 唯一标识 | `WU-01` |
| `name_zh` | 中文名称 | 开合跳 |
| `name_en` | 英文名称 | Jumping Jacks |
| `category` | 动作分类 | 有氧激活 / 动态拉伸 / 关节活动 / 神经激活 / 呼吸激活 |
| `target_areas` | 目标肌群/关节 | ["肩关节", "髋关节", "踝关节"] |
| `applicable_scenarios` | 适用场景 | ["晨间激活", "球场热身", "工位激活"] |
| `applicable_goals` | 适用专项目标 | ["篮球弹跳", "大重量深蹲", "产后康复"] |
| `duration_seconds` | 建议时长(秒) | 30-60 |
| `intensity` | 强度等级 | 极低 / 低 / 中 / 中高 |
| `reps_or_time` | 建议组数/时间 | "2组 × 30秒" |
| `contraindications` | 禁忌症 | ["肩袖损伤急性期"] |
| `fatigue_coefficient` | 疲劳系数(0-1) | 0.02 |
| `nvu_contribution` | 是否产生 NVU | false |
| `partner_cue` | 伙伴引导语 | "先让身体醒过来。跟着我做。" |

---

## 1.2 通用热身动作（10 个）

### WU-01 开合跳 (Jumping Jacks)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 全身有氧激活、肩关节、髋关节 |
| **适用场景** | 所有场景（晨间/工位/球场） |
| **适用专项目标** | 篮球弹跳、羽毛球、大重量深蹲 |
| **建议时长** | 30-60 秒 |
| **强度** | 低-中 |
| **建议执行** | 2组 × 30秒，组间休息15秒 |
| **禁忌症** | 踝关节扭伤急性期、膝关节置换术后 |
| **疲劳系数** | 0.03 |
| **伙伴引导语** | "开合跳，慢慢来。让心率慢慢升上去。" |

### WU-02 高抬腿原地跑 (High Knees in Place)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 髋屈肌、股四头肌、核心稳定 |
| **适用场景** | 球场热身、晨间激活 |
| **适用专项目标** | 篮球弹跳、羽毛球 |
| **建议时长** | 30-45 秒 |
| **强度** | 中 |
| **建议执行** | 2组 × 30秒 |
| **禁忌症** | 髋关节撞击综合征、腰椎间盘突出急性期 |
| **疲劳系数** | 0.05 |
| **伙伴引导语** | "膝盖抬到髋的高度就好。不用太快。" |

### WU-03 肩关节绕环 (Arm Circles)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 肩关节囊、肩袖肌群、三角肌 |
| **适用场景** | 所有场景 |
| **适用专项目标** | 羽毛球、上肢推/拉、大重量深蹲（肩部灵活性） |
| **建议时长** | 30-45 秒 |
| **强度** | 极低 |
| **建议执行** | 向前15圈 + 向后15圈，由小圈渐大 |
| **禁忌症** | 肩关节脱位术后（需康复师许可） |
| **疲劳系数** | 0.01 |
| **伙伴引导语** | "先转小圈，慢慢变大。让关节润滑起来。" |

### WU-04 髋关节环绕 (Hip Circles)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 髋关节囊、臀中肌、髋外旋肌群 |
| **适用场景** | 球场热身、晨间激活 |
| **适用专项目标** | 篮球弹跳、大重量深蹲、下肢日 |
| **建议时长** | 30-45 秒 |
| **强度** | 极低 |
| **建议执行** | 每侧15圈，顺/逆时针各一组 |
| **禁忌症** | 髋关节置换术后（需康复师许可） |
| **疲劳系数** | 0.01 |
| **伙伴引导语** | "画圈，越大越圆越好。感受髋关节的活动范围。" |

### WU-05 踝关节激活 (Ankle Mobilization)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 踝关节、小腿前侧肌群、跟腱 |
| **适用场景** | 球场热身、晨间激活 |
| **适用专项目标** | 篮球弹跳（关键动作）、羽毛球 |
| **建议时长** | 30-45 秒 |
| **强度** | 极低 |
| **建议执行** | 踮脚尖15次 + 勾脚尖15次 + 踝关节绕环各10圈 |
| **禁忌症** | 跟腱断裂术后、踝关节急性扭伤 |
| **疲劳系数** | 0.02 |
| **伙伴引导语** | "弹跳从脚踝开始。把每个角度都活动到。" |

### WU-06 猫牛式脊柱活动 (Cat-Cow Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 脊柱（胸椎/腰椎）、核心肌群 |
| **适用场景** | 晨间激活、工位激活 |
| **适用专项目标** | 产后康复、大重量深蹲（核心预热） |
| **建议时长** | 30-45 秒 |
| **强度** | 极低 |
| **建议执行** | 8-10 次缓慢交替，配合呼吸（吸气弓背/呼气塌腰） |
| **禁忌症** | 腰椎骨折术后、严重骨质疏松 |
| **疲劳系数** | 0.01 |
| **伙伴引导语** | "像猫一样。吸气拱背，呼气塌腰。慢慢来。" |

### WU-07 世界最伟大拉伸 (World's Greatest Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 髋屈肌、胸椎旋转、腘绳肌、腹股沟 |
| **适用场景** | 球场热身、晨间激活 |
| **适用专项目标** | 篮球弹跳、羽毛球、大重量深蹲 |
| **建议时长** | 45-60 秒 |
| **强度** | 低-中 |
| **建议执行** | 每侧 5 次，每次保持拉伸 2 秒 + 旋转保持 2 秒 |
| **禁忌症** | 腰椎间盘突出急性期 |
| **疲劳系数** | 0.04 |
| **伙伴引导语** | "弓步下去，手肘碰脚踝。然后打开胸口，向上旋转。" |

### WU-08 死虫式核心激活 (Dead Bug Core Activation)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 腹横肌、腹直肌、骨盆稳定肌群 |
| **适用场景** | 晨间激活、球场热身 |
| **适用专项目标** | 产后康复（核心动作）、大重量深蹲、篮球弹跳 |
| **建议时长** | 30-45 秒 |
| **强度** | 低 |
| **建议执行** | 2组 × 每侧8次，慢速控制 |
| **禁忌症** | 产后腹直肌分离 > 2指（需康复师评估） |
| **疲劳系数** | 0.03 |
| **伙伴引导语** | "躺着不代表休息。核心收紧，腰贴地面。" |

### WU-09 弹力带肩部激活 (Band Pull-Apart)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 菱形肌、后三角肌、肩袖肌群 |
| **适用场景** | 球场热身、工位激活 |
| **适用专项目标** | 羽毛球、上肢推/拉日 |
| **建议时长** | 30-45 秒 |
| **强度** | 低 |
| **建议执行** | 2组 × 15次 |
| **禁忌症** | 肩袖撕裂（需康复师许可） |
| **疲劳系数** | 0.03 |
| **伙伴引导语** | "弹力带拉开，感受后背的收缩。" |

### WU-10 鸟狗式核心稳定 (Bird Dog)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 核心稳定、脊柱抗旋转、肩关节稳定、髋关节伸展 |
| **适用场景** | 晨间激活、球场热身 |
| **适用专项目标** | 产后康复、篮球弹跳、大重量深蹲 |
| **建议时长** | 30-45 秒 |
| **强度** | 低 |
| **建议执行** | 2组 × 每侧8次，每次保持2秒 |
| **禁忌症** | 腕管综合征（可改用前臂支撑） |
| **疲劳系数** | 0.03 |
| **伙伴引导语** | "对侧手脚同时伸展。核心锁住，不要晃动。" |

---

## 1.3 专项热身动作（8 个）

### WU-11 空杆热身组 (Empty Bar Warm-Up Sets)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 全身神经肌肉激活、动作模式预热 |
| **适用场景** | 球场（健身房）、大重量训练日 |
| **适用专项目标** | 大重量深蹲（核心热身方式） |
| **建议时长** | 90-120 秒（含休息） |
| **强度** | 低→中（递增负荷） |
| **建议执行** | 空杆 × 10次 → 40% 1RM × 8次 → 60% 1RM × 5次 → 80% 1RM × 2次 |
| **禁忌症** | 无（所有训练者通用） |
| **疲劳系数** | 0.08（计入热身 NVU） |
| **伙伴引导语** | "空杆开始。先把动作模式刻进肌肉记忆。" |

### WU-12 踝关节弹跳预演 (Ankle Bounce Prep)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 踝关节弹性、小腿三头肌、跟腱弹性 |
| **适用场景** | 球场热身 |
| **适用专项目标** | 篮球弹跳（专项关键动作） |
| **建议时长** | 30-45 秒 |
| **强度** | 中 |
| **建议执行** | 3组 × 10次轻跳，仅用踝关节发力，膝盖微弯 |
| **禁忌症** | 跟腱炎急性期 |
| **疲劳系数** | 0.06 |
| **伙伴引导语** | "膝盖锁住，只用脚踝发力。这是在唤醒你的弹簧。" |

### WU-13 侧向移动预演 (Lateral Shuffle Prep)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 髋外展/内收肌群、踝关节侧向稳定 |
| **适用场景** | 球场热身 |
| **适用专项目标** | 羽毛球（专项关键动作） |
| **建议时长** | 30-45 秒 |
| **强度** | 低-中 |
| **建议执行** | 3组 × 左右各5步，慢速→中速渐进 |
| **禁忌症** | 踝关节扭伤未完全康复 |
| **疲劳系数** | 0.05 |
| **伙伴引导语** | "侧向移动。羽毛球的第一步永远是横向的。" |

### WU-14 手腕/前臂激活 (Wrist & Forearm Activation)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 腕关节、前臂屈肌/伸肌 |
| **适用场景** | 球场热身、工位激活 |
| **适用专项目标** | 羽毛球（专项关键动作） |
| **建议时长** | 20-30 秒 |
| **强度** | 极低 |
| **建议执行** | 手腕绕环各10圈 + 抓握弹力球15次 |
| **禁忌症** | 腕管综合征急性发作 |
| **疲劳系数** | 0.01 |
| **伙伴引导语** | "手腕是羽毛球的生命线。活动开。" |

### WU-15 腹式呼吸激活 (Diaphragmatic Breathing Activation)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 横膈膜、腹横肌、盆底肌 |
| **适用场景** | 晨间激活 |
| **适用专项目标** | 产后康复（核心启动动作） |
| **建议时长** | 60-90 秒 |
| **强度** | 极低 |
| **建议执行** | 5-8 次深腹式呼吸（吸气4秒→屏息2秒→呼气6秒） |
| **禁忌症** | 无 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "躺下来。手放在肚子上。吸气时肚子鼓起来，呼气时肚子收回去。" |

### WU-16 Plyometric 低强度预演 (Low-Intensity Plyo Prep)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 下肢爆发力神经通路、牵张反射 |
| **适用场景** | 球场热身 |
| **适用专项目标** | 篮球弹跳 |
| **建议时长** | 30-45 秒 |
| **强度** | 中 |
| **建议执行** | 3组 × 5次跳箱轻跳（高度≤膝盖），专注落地缓冲 |
| **禁忌症** | 膝关节韧带损伤术后 |
| **疲劳系数** | 0.07 |
| **伙伴引导语** | "轻跳，专注落地。弹跳的秘诀在落地缓冲里。" |

### WU-17 骨盆稳定激活 (Pelvic Stability Activation)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 臀中肌、骨盆底肌、腹横肌 |
| **适用场景** | 晨间激活、球场热身 |
| **适用专项目标** | 产后康复（关键激活动作） |
| **建议时长** | 30-45 秒 |
| **强度** | 低 |
| **建议执行** | 臀桥15次（慢速，顶峰收缩2秒）+ 蚌式开合每侧12次 |
| **禁忌症** | 产后盆底肌脱垂（需康复师许可） |
| **疲劳系数** | 0.03 |
| **伙伴引导语** | "臀桥。骨盆稳定是所有动作的基础。" |

### WU-18 对抗久坐激活系列 (Anti-Sedentary Activation Series)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 胸椎旋转、髋屈肌拉伸、肩胛骨后缩 |
| **适用场景** | 工位激活（专属场景） |
| **适用专项目标** | 所有久坐用户 |
| **建议时长** | 90-120 秒 |
| **强度** | 极低 |
| **建议执行** | 坐姿胸椎旋转（每侧5次）+ 坐姿髋屈肌拉伸（每侧20秒）+ 肩胛骨后缩（15次）+ 颈部侧屈（每侧15秒） |
| **禁忌症** | 颈椎病急性发作 |
| **疲劳系数** | 0.01 |
| **伙伴引导语** | "坐了这么久，让身体换个姿势。跟着我活动一下。" |

---

## 1.4 热身动作按场景的快速索引

### 晨间在家（15min 场景）

| 顺序 | 动作ID | 动作名称 | 时长 | 用途 |
|:----:|--------|---------|:---:|------|
| 1 | WU-06 | 猫牛式脊柱活动 | 30s | 脊柱唤醒 |
| 2 | WU-15 | 腹式呼吸激活 | 60s | 核心启动（产后康复用户前置） |
| 3 | WU-03 | 肩关节绕环 | 30s | 上肢激活 |
| 4 | WU-04 | 髋关节环绕 | 30s | 下肢激活 |
| 5 | WU-05 | 踝关节激活 | 30s | 下肢激活 |
| 6 | WU-08 | 死虫式核心激活 | 45s | 核心稳定 |
| 7 | WU-07 | 世界最伟大拉伸 | 60s | 全身动态拉伸 |

**总热身时长：约 5 分钟（占 15min 的 33%）**

### 中午工位（10min 场景）

| 顺序 | 动作ID | 动作名称 | 时长 | 用途 |
|:----:|--------|---------|:---:|------|
| 1 | WU-18 | 对抗久坐激活系列 | 120s | 全面对抗久坐 |

**总激活时长：约 2 分钟（占 10min 的 20%）**

### 晚上球场（75min 场景）

| 顺序 | 动作ID | 动作名称 | 时长 | 用途 |
|:----:|--------|---------|:---:|------|
| 1 | WU-01 | 开合跳 | 60s | 有氧启动 |
| 2 | WU-03 | 肩关节绕环 | 30s | 上肢 |
| 3 | WU-04 | 髋关节环绕 | 30s | 下肢 |
| 4 | WU-05 | 踝关节激活 | 45s | 专项 |
| 5 | WU-07 | 世界最伟大拉伸 | 60s | 全身动态 |
| 6 | WU-09 | 弹力带肩部激活 | 45s | 上肢 |
| 7 | 按目标选择 | 专项热身（见下表） | 2-3min | 神经激活 |
| 8 | WU-11 | 空杆热身组（力量日） | 2min | 动作模式 |

**总热身时长：约 8-10 分钟（占 75min 的 12%）**

### 按专项目标的专项热身选择

| 专项目标 | 专项热身动作 | 时长 |
|---------|-------------|:---:|
| 篮球弹跳 | WU-12 踝关节弹跳预演 + WU-16 Plyo低强度预演 | 2min |
| 羽毛球 | WU-13 侧向移动预演 + WU-14 手腕激活 | 1.5min |
| 产后康复 | WU-15 腹式呼吸 + WU-17 骨盆稳定 | 2min |
| 大重量深蹲 | WU-11 空杆热身组（递增） | 2.5min |
| 上肢推/拉 | WU-09 弹力带肩部激活 + WU-03 肩关节绕环 | 1.5min |
| 下肢日 | WU-04 髋关节环绕 + WU-07 世界最伟大拉伸 | 1.5min |

---

# 第二部分：冷却与拉伸动作库 (Cool-Down & Stretching Library)

## 2.1 动作库结构说明

每个冷却/拉伸动作的属性字段：

| 字段 | 说明 | 示例 |
|------|------|------|
| `exercise_id` | 唯一标识 | `CD-01` |
| `name_zh` | 中文名称 | 腘绳肌静态拉伸 |
| `category` | 分类 | 静态拉伸 / 动态冷却 / 呼吸放松 / 筋膜放松 |
| `target_areas` | 目标肌群/关节 | ["腘绳肌", "臀大肌"] |
| `applicable_phases` | 适用阶段 | 训练后冷却 / 独立恢复 / 睡前放松 / 工位微恢复 |
| `applicable_sessions` | 适用训练类型 | 大重量力量 / 爆发力 / 上肢日 / 下肢日 |
| `duration_seconds` | 建议单侧/单次时长(秒) | 30-60 |
| `intensity` | 强度 | 极低 / 低 |
| `breathing_cue` | 呼吸引导 | "吸气准备，呼气加深拉伸" |
| `contraindications` | 禁忌症 | ["腘绳肌拉伤急性期"] |
| `fatigue_coefficient` | 疲劳系数(0-1) | 0.00 |
| `nvu_contribution` | 是否产生 NVU | false |
| `partner_cue` | 伙伴引导语 | "保持这个拉伸。呼吸——吸气4秒，呼气6秒。" |

---

## 2.2 训练后冷却动作（即时冷却 + 静态拉伸，12 个）

### CD-01 轻度步行/原地踏步 (Light Walk / March in Place)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 全身血液循环、心率下降 |
| **适用阶段** | 训练后即时冷却 |
| **适用训练类型** | 所有训练类型 |
| **建议时长** | 60-120 秒 |
| **强度** | 极低 |
| **呼吸引导** | "自然呼吸，让心率慢慢降下来。" |
| **禁忌症** | 无 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "走一走，让心跳慢慢回到正常。不用急。" |

### CD-02 腘绳肌静态拉伸 (Standing Hamstring Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 腘绳肌（股二头肌/半腱肌/半膜肌） |
| **适用阶段** | 训练后冷却 |
| **适用训练类型** | 下肢日、爆发力/弹跳、大重量力量（下肢） |
| **建议时长** | 每侧 30-45 秒 |
| **强度** | 低 |
| **呼吸引导** | "吸气保持，呼气时微微加深拉伸。" |
| **禁忌症** | 腘绳肌拉伤急性期 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "后腿伸直，从髋关节向前折叠。不是弯腰，是髋关节折叠。" |

### CD-03 股四头肌静态拉伸 (Standing Quad Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 股四头肌、髋屈肌 |
| **适用阶段** | 训练后冷却 |
| **适用训练类型** | 下肢日、大重量力量（深蹲后） |
| **建议时长** | 每侧 30-45 秒 |
| **强度** | 低 |
| **呼吸引导** | "保持骨盆中立。吸气稳定，呼气加深。" |
| **禁忌症** | 膝关节置换术后（需康复师许可） |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "抓住脚踝，不是脚尖。膝盖指向地面。" |

### CD-04 髋屈肌拉伸 (Kneeling Hip Flexor Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 髂腰肌、股直肌 |
| **适用阶段** | 训练后冷却、独立恢复 |
| **适用训练类型** | 下肢日、爆发力/弹跳（关键拉伸） |
| **建议时长** | 每侧 30-45 秒 |
| **强度** | 低-中 |
| **呼吸引导** | "吸气时骨盆后倾，呼气时前侧加深拉伸。" |
| **禁忌症** | 膝关节滑囊炎 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "后膝跪地，臀部往前推。感受大腿前侧的拉伸。" |

### CD-05 臀大肌拉伸（鸽式）(Seated Figure-Four / Pigeon Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 臀大肌、梨状肌、髋外旋肌群 |
| **适用阶段** | 训练后冷却、独立恢复 |
| **适用训练类型** | 下肢日、爆发力/弹跳、大重量力量 |
| **建议时长** | 每侧 30-45 秒 |
| **强度** | 低-中 |
| **呼吸引导** | "每次呼气，让臀部更多地沉向地面。" |
| **禁忌症** | 髋关节置换术后 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "一条腿横过来。感受臀部的深度拉伸。" |

### CD-06 胸部静态拉伸 (Doorway Chest Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 胸大肌、胸小肌、前三角肌 |
| **适用阶段** | 训练后冷却、工位微恢复 |
| **适用训练类型** | 上肢推日（卧推后） |
| **建议时长** | 每侧 30 秒 |
| **强度** | 低 |
| **呼吸引导** | "吸气扩胸，呼气时微微向前加深。" |
| **禁忌症** | 肩关节前脱位 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "手扶门框，身体微微向前。感受胸口的打开。" |

### CD-07 背阔肌/肩后侧拉伸 (Lat & Posterior Shoulder Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 背阔肌、大圆肌、后肩关节囊 |
| **适用阶段** | 训练后冷却、工位微恢复 |
| **适用训练类型** | 上肢拉日（引体/划船后） |
| **建议时长** | 每侧 30 秒 |
| **强度** | 低 |
| **呼吸引导** | "吸气稳定，呼气时拉伸侧手臂更远延伸。" |
| **禁忌症** | 肩袖撕裂 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "一只手抓柱子，身体向后坐。感受背部的拉伸。" |

### CD-08 肩关节绕环冷却 (Arm Circles Cool-Down)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 肩关节囊冷却 |
| **适用阶段** | 训练后即时冷却 |
| **适用训练类型** | 上肢推/拉日、羽毛球 |
| **建议时长** | 30 秒 |
| **强度** | 极低 |
| **呼吸引导** | "自然呼吸。幅度逐渐变小。" |
| **禁忌症** | 无 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "最后转几圈肩膀。从小圈到大圈，再慢慢回到小圈。" |

### CD-09 下背部放松（婴儿式）(Child's Pose)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 竖脊肌、背阔肌、脊柱伸展肌群 |
| **适用阶段** | 训练后冷却、睡前放松、独立恢复 |
| **适用训练类型** | 大重量力量（硬拉后）、下肢日 |
| **建议时长** | 30-60 秒 |
| **强度** | 极低 |
| **呼吸引导** | "深吸气到后背。呼气时让身体更沉向地面。" |
| **禁忌症** | 膝关节严重关节炎 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "跪坐，身体前倾，额头贴地。把今天的重量都交出去。" |

### CD-10 小腿/跟腱拉伸 (Calf & Achilles Stretch)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 腓肠肌、比目鱼肌、跟腱 |
| **适用阶段** | 训练后冷却 |
| **适用训练类型** | 爆发力/弹跳（关键拉伸）、下肢日 |
| **建议时长** | 每侧 30 秒（直膝+屈膝各15秒） |
| **强度** | 低 |
| **呼吸引导** | "直膝拉伸腓肠肌，屈膝拉伸比目鱼肌。" |
| **禁忌症** | 跟腱炎急性期 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "手扶墙，一条腿后撤。脚跟踩地。弹跳选手，这个不能省。" |

### CD-11 颈部放松拉伸 (Neck Release)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 斜方肌上束、胸锁乳突肌、斜角肌 |
| **适用阶段** | 工位微恢复、睡前放松 |
| **适用训练类型** | 所有训练后可选 |
| **建议时长** | 每侧 20-30 秒 |
| **强度** | 极低 |
| **呼吸引导** | "呼气时头部重量自然下沉，不用力。" |
| **禁忌症** | 颈椎间盘突出 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "头微微侧向一边。不用力，让重力帮你拉伸。" |

### CD-12 全身降温呼吸法 (Full-Body Cool-Down Breathing)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 副交感神经激活、心率下降 |
| **适用阶段** | 训练后冷却（收尾动作） |
| **适用训练类型** | 所有训练类型（收尾必备） |
| **建议时长** | 60-120 秒 |
| **强度** | 极低 |
| **呼吸引导** | "4-4-6 呼吸法：吸气4秒→屏息4秒→呼气6秒。重复5-8次。" |
| **禁忌症** | 无 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "闭上眼睛。吸气——1,2,3,4。屏住——1,2,3,4。呼气——1,2,3,4,5,6。你的身体今天完成了很棒的工作。" |

---

## 2.3 独立恢复动作（5 个）

### RC-01 泡沫轴滚压（通用）(Foam Rolling - General)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 根据目标肌群选择：股四头肌/腘绳肌/背部/小腿 |
| **适用阶段** | 休息日主动恢复、睡前放松 |
| **建议时长** | 每肌群 30-60 秒 |
| **强度** | 低-中 |
| **呼吸引导** | "滚到酸痛点停住，深呼吸3次再继续。" |
| **禁忌症** | 深静脉血栓、骨折未愈合 |
| **疲劳系数** | 0.02（极低） |
| **伙伴引导语** | "找到酸胀的点，停在那里。深呼吸，让它慢慢松开。" |

### RC-02 睡前全身扫描放松 (Bedtime Body Scan)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 全身渐进式放松 |
| **适用阶段** | 睡前放松（深夜模式自动推荐） |
| **建议时长** | 300 秒（5分钟） |
| **强度** | 极低 |
| **呼吸引导** | "从脚趾开始，逐一放松每一个部位。" |
| **禁忌症** | 无 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "躺下来。闭上眼睛。从脚趾开始——感受它们，然后让它们完全放松。现在是小腿……" |

### RC-03 肩颈工位微恢复 (Desk Shoulder-Neck Reset)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 斜方肌上束、肩胛提肌、枕下肌群 |
| **适用阶段** | 工位微恢复 |
| **建议时长** | 120 秒（2分钟） |
| **强度** | 极低 |
| **呼吸引导** | "每次转头配合呼气。" |
| **禁忌症** | 颈椎不稳 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "放下手机。低头看屏幕太久了。跟着我做——慢慢转头，找到紧绷的那一侧。" |

### RC-04 腰部工位微恢复 (Desk Lower Back Reset)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 竖脊肌、腰方肌、髋屈肌 |
| **适用阶段** | 工位微恢复 |
| **建议时长** | 120 秒（2分钟） |
| **强度** | 极低 |
| **呼吸引导** | "坐姿前屈，呼气时加深。" |
| **禁忌症** | 腰椎间盘突出急性期 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "坐太久了。站起来，或者坐着——身体慢慢向前折叠。让下背部放松。" |

### RC-05 休息日主动恢复方案 (Active Recovery Day Plan)

| 属性 | 内容 |
|------|------|
| **目标肌群/关节** | 全身轻度活动 |
| **适用阶段** | 休息日 |
| **建议时长** | 600-900 秒（10-15分钟） |
| **强度** | 极低 |
| **建议内容** | 5min 轻度步行/骑行 + 5min 动态拉伸（WU-06猫牛式 + CD-09婴儿式 + CD-04髋屈肌拉伸） + 5min 泡沫轴滚压（RC-01） |
| **禁忌症** | 按组成部分各自的禁忌症 |
| **疲劳系数** | 0.00 |
| **伙伴引导语** | "今天休息。恢复也是训练的一部分。来，我们做一个轻松的恢复方案。" |

---

## 2.4 冷却/拉伸动作按训练类型的快速索引

### 按训练类型的冷却方案

| 训练类型 | 即时冷却(3-5min) | 静态拉伸(5-8min) | 收尾 |
|---------|-----------------|-----------------|------|
| **大重量力量** | CD-01 轻度步行(2min) | CD-02 腘绳肌 + CD-03 股四头肌 + CD-05 臀大肌 + CD-09 婴儿式 | CD-12 呼吸法 |
| **爆发力/弹跳** | CD-01 轻度步行(1min) + CD-08 肩关节绕环(30s) | CD-02 腘绳肌 + CD-04 髋屈肌 + CD-05 臀大肌 + CD-10 小腿/跟腱 | CD-12 呼吸法 |
| **上肢推** | CD-08 肩关节绕环(1min) | CD-06 胸部拉伸 + CD-07 背阔肌拉伸 | CD-12 呼吸法 |
| **上肢拉** | CD-08 肩关节绕环(1min) | CD-07 背阔肌拉伸 + CD-09 婴儿式 | CD-12 呼吸法 |
| **下肢日** | CD-01 轻度步行(2min) | CD-02 腘绳肌 + CD-03 股四头肌 + CD-04 髋屈肌 + CD-05 臀大肌 | CD-12 呼吸法 |
| **全身/综合** | CD-01 轻度步行(2min) + CD-08 肩关节绕环(30s) | CD-02 腘绳肌 + CD-06 胸部 + CD-09 婴儿式 | CD-12 呼吸法 |

---

# 第三部分：修正后的多场景容量分配模型

## 3.1 修正后的日总容量分配

原 PRD 中多场景容量仅分配了"训练容量"，修正后需要将"热身容量"和"恢复容量"纳入：

```
修正后的日总容量分配（总时长 = 热身 + 训练 + 恢复）：

早上家(15min)：
  ├── 热身激活(5min, 热身容量) — 全身动态+关节唤醒
  │   └── 动作序列：WU-06→WU-15→WU-03→WU-04→WU-05→WU-08→WU-07
  ├── 微训练(8min, 训练容量12-15%) — 神经激活+灵活性
  └── 冷却(2min, 恢复容量) — CD-12 呼吸调整

中午工位(10min)：
  ├── 激活(2min, 热身容量) — WU-18 对抗久坐激活系列
  ├── 微训练(6min, 训练容量5-8%) — 静态拉伸+姿态纠正
  └── 放松(2min, 恢复容量) — RC-03 肩颈微恢复 + RC-04 腰部微恢复

晚上球场(75min)：
  ├── 热身(8-10min, 热身容量) — 通用+专项
  │   └── 动作序列：WU-01→WU-03→WU-04→WU-05→WU-07→WU-09→专项热身→(可选WU-11)
  ├── 正式训练(55-60min, 训练容量77-83%) — 主力训练
  └── 冷却拉伸(8-10min, 恢复容量) — 降心率+静态拉伸
      └── 动作序列：CD-01→按训练类型选择拉伸→CD-12
```

## 3.2 NVU 计算修正

热身和拉伸动作不产生"训练 NVU"，但计入总时长。修正规则：

| 动作类型 | 是否计入 NVU | 疲劳系数 | 计入总时长 |
|---------|:-----------:|:-------:|:--------:|
| 通用热身动作 | 否 | 0.01-0.03 | 是 |
| 专项热身动作 | 否（空杆热身组除外） | 0.04-0.08 | 是 |
| 空杆热身组 | 是（按实际重量计算） | 0.08 | 是 |
| 冷却动作 | 否 | 0.00 | 是 |
| 静态拉伸 | 否 | 0.00 | 是 |
| 独立恢复动作 | 否 | 0.00-0.02 | 是 |

**修正后的日容量计算**：

```
日总可用时长 = 用户配置的场景时长之和
日总训练NVU = 正式训练动作的NVU之和 + 空杆热身组NVU × 0.3
日总热身时长 = Σ 热身动作时长
日总恢复时长 = Σ 冷却/拉伸动作时长
日总时长 = 热身时长 + 正式训练时长 + 恢复时长
```

## 3.3 疲劳传递模型中的热身/恢复修正

热身和冷却动作参与疲劳传递但权重极低：

| 动作类别 | CNS 疲劳系数 | 局部疲劳系数 | 累积疲劳(ACWR)计入 |
|---------|:----------:|:----------:|:----------------:|
| 通用热身 | 0.02 | 0.01 | 否 |
| 专项热身（非负重） | 0.03 | 0.02 | 否 |
| 空杆热身组 | 0.05 | 0.05 | 是（×0.3 权重） |
| 冷却（有氧类） | 0.01 | 0.00 | 否 |
| 静态拉伸 | 0.00 | 0.00 | 否 |
| 独立恢复 | 0.00 | 0.00 | 否 |

---

# 第四部分：伙伴在热身/恢复中的陪伴设计

## 4.1 伙伴语气模式

伙伴在热身、正式训练、冷却三个阶段使用不同的语气模式：

| 阶段 | 语气模式 | 语速 | 音量 | 能量等级 | 典型话语 |
|------|---------|:---:|:---:|:------:|------|
| **热身** | 温和引导 | 0.9x | 标准 | 低-中 | "慢慢来。让关节润滑起来。" |
| **正式训练** | 热血驱动 | 1.0x | 标准 | 中-高 | "最后两个！咬牙！" |
| **冷却** | 柔和放松 | 0.8x | -15% | 低 | "深呼吸。你的身体今天完成了很棒的工作。" |
| **拉伸** | 呼吸引导 | 0.7x | -20% | 极低 | "吸气4秒，屏住，呼气6秒。" |
| **深夜恢复** | 耳语模式 | 0.6x | -30% | 极低 | "闭上眼睛。让今天的训练融进身体。" |

## 4.2 各阶段的伙伴陪伴交互

### 热身阶段

```
[训练开始，用户点击"开始热身"]
伙伴头像 → 从IDLE切换到GUIDE状态（温和微笑，手势引导）
伙伴语音 → "准备好了吗？先让身体醒过来。"

[热身进行中，每30秒]
伙伴语音 → 提示下一个热身动作
  "下一个，肩关节绕环。先转小圈，慢慢变大。"
  
[热身即将结束]
伙伴语音 → "身体热起来了吗？准备好了，我们进入正式训练。"
伙伴头像 → 从GUIDE切换到FOCUSED状态
Mode Shift → 热身→正式训练的过渡动画（1秒呼吸提示）
```

### 冷却阶段

```
[训练最后一组完成]
伙伴语音 → "辛苦了。最后两组做完了。现在让身体慢慢回来。"
伙伴头像 → 从FOCUSED切换到RELAXED状态

[进入冷却阶段]
伙伴语音 → "先走一走。不用急。"
  
[冷却进行中，每30-45秒]
伙伴语音 → 提示下一个冷却/拉伸动作，配合呼吸节奏
  "下一个拉伸，腘绳肌。吸气保持，呼气加深拉伸。"

[冷却结束]
伙伴语音 → "闭上眼睛。吸气——1,2,3,4。屏住——1,2,3,4。呼气——1,2,3,4,5,6。你的身体今天完成了很棒的工作。"
伙伴头像 → 微微鞠躬/点头
过渡 → 进入训练总结页（TR-11）
```

### 休息日主动恢复

```
[用户标记休息日 / 系统检测疲劳指数>70触发休息建议]
伙伴头像 → REST状态（放松姿势，坐姿/半躺）
伙伴语音 → "今天休息。恢复也是训练的一部分。来，我们做一个轻松的恢复方案。"

[首页展示替代活动推荐]
  ┌──────────────────────────────┐
  │  🧘 今天休息日               │
  │                              │
  │  推荐恢复活动：               │
  │  □ 5分钟呼吸放松 (RC-05)      │
  │  □ 10分钟轻度拉伸 (CD合集)     │
  │  □ 泡沫轴滚压 (RC-01)        │
  │  □ 出去散个步                │
  │                              │
  │  Alex: "今天不动，是为了明天  │
  │  动得更好。"                  │
  └──────────────────────────────┘
```

### 工位微恢复推送

```
[系统检测用户在工位场景 + 久坐 > 60分钟]
推送通知 → "[伙伴名]：坐了1小时了。起来活动2分钟？"
点击进入 → RC-03 肩颈微恢复 / RC-04 腰部微恢复

伙伴语音 → "低头看屏幕太久了。跟着我做——慢慢转头，找到紧绷的那一侧。"
```

### 睡前放松推送

```
[系统检测时间 22:00-23:00 + 用户今日有训练]
推送通知 → "[伙伴名]：睡前放松一下？5分钟就好。"
点击进入 → RC-02 睡前全身扫描放松

伙伴语音（耳语模式） → "躺下来。闭上眼睛。从脚趾开始——感受它们，然后让它们完全放松。"
```

---

# 第五部分：PRD 补充章节（EARS 规格）

## 5.X 热身与恢复体系 (Warm-Up & Recovery System)

### 5.X.1 热身嵌入训练计划

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall embed a mandatory warm-up module at the beginning of every training session. Warm-up is not optional — it is a forced component of every training plan. |
| Ubiquitous | The system shall select warm-up exercises from the warm-up exercise library (tagged `warmup`), matched to the user's training scenario, sport goal, and the day's primary training content. |
| Event-driven | When a training plan is generated, the system shall output `warm_up` as a mandatory section before `main_exercises`, containing: a sequence of warm-up exercises, each with duration, intensity, and partner voice cues. |
| Event-driven | When the user enters a training session, the system shall start in "热身模式" (Warm-Up Mode) by default, with the partner avatar in GUIDE state and a warm-up progress bar displayed. |
| Event-driven | When the warm-up phase completes (all warm-up exercises done), the system shall display a transition screen: "准备好了吗？" with partner voice cue, then enter the main training phase. |
| State-driven | While in warm-up mode, the system shall display: current warm-up exercise with illustration/GIF, countdown timer, next exercise preview, and partner guidance text. |
| Unwanted | If the user attempts to skip warm-up, then the system shall display a warning: "跳过热身会增加受伤风险。确定跳过吗？[继续热身] [确认跳过]" and record the skip event in the session log. |

**热身分层规则：**

| 层级 | 内容 | 时长 | 强制程度 |
|:---:|------|:---:|:------:|
| L1 通用热身 | 轻度有氧 + 动态拉伸 + 关节活动 | 5-8分钟 | 强制 |
| L2 专项热身 | 针对主训动作的神经激活和动作模式预热 | 3-5分钟 | 强制（根据训练类型自动选择） |
| L3 心理准备 | 伙伴热身阶段说辞 | 嵌入L1/L2 | 强制 |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| WU-AC01 | 训练计划包含热身 | 生成训练计划 | 查看计划 | 计划开头有 warm_up 字段，包含热身动作序列 |
| WU-AC02 | 训练从热身开始 | 进入训练执行 | 开始训练 | 自动进入热身模式，伙伴头像为 GUIDE 状态 |
| WU-AC03 | 跳过热身警告 | 热身进行中 | 点击跳过 | 显示受伤风险警告，记录跳过事件 |
| WU-AC04 | 热身完成过渡 | 完成所有热身动作 | 观察 | 过渡动画 + 伙伴"准备好了吗？" + 进入正式训练 |

### 5.X.2 按场景的热身编排

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Event-driven | When the training scenario is "晨间在家(15min)", the system shall allocate approximately 5 minutes (33% of session) to warm-up, including: 猫牛式脊柱活动 → 腹式呼吸激活 → 肩关节绕环 → 髋关节环绕 → 踝关节激活 → 死虫式核心激活 → 世界最伟大拉伸. |
| Event-driven | When the training scenario is "中午工位(10min)", the system shall allocate approximately 2 minutes (20% of session) to activation, using the WU-18 对抗久坐激活系列. |
| Event-driven | When the training scenario is "晚上球场(75min)", the system shall allocate 8-10 minutes (12% of session) to warm-up, including: general warm-up (开合跳→肩→髋→踝→世界最伟大拉伸→弹力带激活) + sport-specific warm-up (selected by sport goal). |
| Event-driven | When the user's sport goal is 篮球弹跳, the sport-specific warm-up shall include WU-12 踝关节弹跳预演 and WU-16 Plyometric低强度预演. |
| Event-driven | When the user's sport goal is 羽毛球, the sport-specific warm-up shall include WU-13 侧向移动预演 and WU-14 手腕/前臂激活. |
| Event-driven | When the user's sport goal is 产后康复, the warm-up shall prioritize WU-15 腹式呼吸激活 and WU-17 骨盆稳定激活 as the first warm-up exercises. |
| Event-driven | When the training session is a heavy strength day (大重量深蹲日), the system shall include WU-11 空杆热身组 with progressive loading (empty bar → 40% 1RM → 60% 1RM → 80% 1RM). |

### 5.X.3 冷却与拉伸嵌入训练计划

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall embed a mandatory cool-down and stretching module at the end of every training session. Cool-down is not optional. |
| Ubiquitous | The system shall select cool-down exercises from the cool-down exercise library (tagged `cooldown`), matched to the training type and the muscle groups trained in the session. |
| Event-driven | When a training plan is generated, the system shall output `cool_down` as a mandatory section after `main_exercises`, containing: immediate cool-down exercises (3-5 minutes) + static stretching exercises (5-8 minutes) + closing breathing exercise. |
| Event-driven | When the user completes the last set of the last exercise, the system shall automatically transition to cool-down mode, with the partner avatar switching to RELAXED state and the partner saying: "辛苦了。现在让身体慢慢回来。跟着我呼吸。" |
| Event-driven | When the cool-down phase completes, the system shall display a brief closing ceremony: partner says personalized closing words, then transitions to the training summary page (TR-11). |
| State-driven | While in cool-down mode, the system shall display: current cool-down/stretch exercise with illustration, hold timer (for static stretches), breathing rhythm indicator (inhale 4s / hold / exhale 6s), and partner guidance text. |
| State-driven | While in static stretching mode, the system shall prompt each stretch for 30 seconds with a breathing rhythm overlay, and auto-advance to the next stretch. |
| Unwanted | If the user attempts to skip cool-down, then the system shall display: "冷却拉伸帮助身体恢复，减少酸痛。确定跳过吗？[继续拉伸] [确认跳过]" and record the skip event. |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| CD-AC01 | 训练计划包含冷却 | 生成训练计划 | 查看计划 | 计划末尾有 cool_down 字段 |
| CD-AC02 | 训练后自动进入冷却 | 完成最后一组 | 点击完成 | 自动切换到冷却模式，伙伴头像为 RELAXED |
| CD-AC03 | 冷却完成过渡 | 完成所有冷却拉伸 | 观察 | 伙伴结束语 → 训练总结页 |
| CD-AC04 | 跳过冷却警告 | 冷却进行中 | 点击跳过 | 显示跳过提醒，记录事件 |

### 5.X.4 独立恢复模块

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall provide standalone recovery modules that can be accessed independently from training sessions. |
| Event-driven | When the user marks a rest day or the system detects fatigue index > 70, the system shall recommend an active recovery plan (RC-05) on the home screen: 10-15 minutes of light activity + stretching + foam rolling. |
| Event-driven | When the system detects it is bedtime hours (22:00-23:00) and the user had a training session today, the system shall recommend RC-02 睡前全身扫描放松 via push notification: "[伙伴名]：睡前放松一下？5分钟就好。" |
| Event-driven | When the system detects prolonged sitting (>60 minutes) in the office scenario, the system shall recommend RC-03 肩颈微恢复 or RC-04 腰部微恢复 via push notification. |
| State-driven | While the user is in a standalone recovery session, the system shall display the recovery exercise with timer, breathing guide, and partner guidance in a calm visual theme. |
| Unwanted | If the user dismisses the bedtime relaxation recommendation 3 times in a week, then the system shall stop recommending for the remainder of that week. |

**验收标准：**

| 编号 | 场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|------|---------|---------|------|
| RC-AC01 | 休息日恢复推荐 | 标记休息日 | 查看首页 | 显示恢复方案推荐卡片 |
| RC-AC02 | 睡前放松推荐 | 22:30 + 今日有训练 | 等待 | 收到睡前放松推送通知 |
| RC-AC03 | 久坐微恢复推送 | 工位场景 + 久坐60min | 等待 | 收到工位微恢复推送 |
| RC-AC04 | 连续拒绝后停止 | 已拒绝3次睡前推荐 | 本周后续 | 不再推送睡前放松 |

### 5.X.5 伙伴在热身/恢复阶段的语音策略

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall adjust the partner's voice tone, speed, volume, and energy level based on the training phase: warm-up (gentle guidance), main training (motivational drive), cool-down (soft relaxation). |
| Event-driven | When the training session enters warm-up phase, the partner's voice shall use: speed 0.9x, standard volume, low-medium energy, gentle tone. |
| Event-driven | When the training session enters cool-down phase, the partner's voice shall use: speed 0.8x, volume -15%, low energy, soft tone. |
| Event-driven | When the training session enters stretching phase, the partner's voice shall use: speed 0.7x, volume -20%, very low energy, breathing-guide tone. |
| Event-driven | During late-night recovery (22:00+), the partner's voice shall use whisper mode: speed 0.6x, volume -30%, very low energy. |

### 5.X.6 热身/恢复与训练编排引擎的集成

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The system shall extend the training plan output format to include mandatory `warm_up` and `cool_down` sections, in addition to the existing `main_exercises` and `auxiliary_exercises`. |
| Ubiquitous | Warm-up and cool-down exercises shall be selected from the exercise library using category tags: `warmup` for warm-up exercises, `cooldown` for cool-down exercises, and `recovery` for standalone recovery exercises. |
| Ubiquitous | Warm-up and cool-down exercises shall NOT contribute to training NVU (except empty-bar warm-up sets which contribute at 0.3× weight). Their fatigue coefficient shall be set to 0.00-0.08. |
| Event-driven | When the training plan generation engine runs, it shall: (1) determine scenario and sport goal, (2) select warm-up sequence, (3) select main exercises, (4) select cool-down sequence, (5) output the complete plan with all three sections. |

**修正后的训练计划输出格式：**

```
输出层：
├── 训练日列表：[{日期, 场地, 总时长}]
├── 每训练日：
│   ├── warm_up：[{动作ID, 动作名, 分类(通用/专项), 时长, 强度, 伙伴引导语, 跳过策略}]
│   ├── main_exercises：[{动作, 组数, 次数/时长, 目标RPE, 组间休息, NVU贡献}]
│   ├── auxiliary_exercises：[{动作, 组数, 次数, 目标RPE, 组间休息, NVU贡献}]
│   └── cool_down：[{动作ID, 动作名, 分类(即时冷却/静态拉伸/呼吸), 时长, 呼吸引导, 伙伴引导语}]
├── AI推理链：[{步骤, 决策, 依据}]  // 包含热身/冷却选择推理
└── 安全警告：[{类型, 描述}]
```

### 5.X.7 动作库扩展

**EARS 需求描述：**

| 类型 | 需求 |
|------|------|
| Ubiquitous | The exercise library shall be extended with three new categories: `warmup` (warm-up exercises), `cooldown` (cool-down and stretching exercises), and `recovery` (standalone recovery exercises). |
| Event-driven | When the exercise library is queried, exercises shall be filterable by category (`warmup`/`cooldown`/`recovery`), by applicable scenario, by applicable sport goal, and by target muscle group. |
| Event-driven | When a warm-up or cool-down exercise is displayed in the training execution page, the system shall render it differently from main exercises: lighter background color, no weight/reps input, only timer and partner guidance. |

**动作库新增分类统计：**

| 分类 | 标签 | 动作数量 | 说明 |
|------|------|:-----:|------|
| 通用热身 | `warmup.general` | 10 | WU-01 至 WU-10 |
| 专项热身 | `warmup.specific` | 8 | WU-11 至 WU-18 |
| 即时冷却 | `cooldown.immediate` | 3 | CD-01, CD-08, CD-12 |
| 静态拉伸 | `cooldown.static_stretch` | 8 | CD-02 至 CD-07, CD-09 至 CD-10 |
| 其他冷却 | `cooldown.other` | 1 | CD-11 |
| 独立恢复 | `recovery` | 5 | RC-01 至 RC-05 |

---

# 第六部分：功能蓝图补充

## 6.1 新增功能 ID

### 训练模块 (TR) 新增

| 功能ID | 功能名称 | 功能描述（一句话） | 依赖项 | 复杂度 | 优先级 |
|--------|---------|-------------------|--------|:------:|:------:|
| TR-29 | 热身自动编排引擎 | 根据训练场景、专项目标和当日主训内容，从热身动作库自动编排热身序列 | TR-03, TR-15 | 中 | P0 |
| TR-30 | 冷却自动编排引擎 | 根据训练类型和当日训练肌群，从冷却动作库自动编排冷却拉伸序列 | TR-03 | 中 | P0 |
| TR-31 | 热身执行页 | 训练执行中热身阶段专用视图：热身动作展示+计时器+伙伴引导+进度条 | TR-04 | 中 | P0 |
| TR-32 | 冷却执行页 | 训练执行中冷却阶段专用视图：拉伸动作展示+呼吸节奏指示器+伙伴引导 | TR-04 | 中 | P0 |
| TR-33 | 独立恢复模块 | 休息日/睡前/工位的独立恢复方案：呼吸放松+拉伸+泡沫轴 | TR-22, CP-02 | 中 | P0 |
| TR-34 | 热身/冷却动作库扩展 | 动作库新增 warmup/cooldown/recovery 三类标签，动作数量扩展至 50+（原30 → 新增20+） | TR-05, CS-04 | 中 | P0 |
| TR-35 | 久坐检测与微恢复推送 | 检测用户工位场景久坐>60分钟，自动推送2分钟微恢复方案 | TR-33 | 中 | P1 |
| TR-36 | 睡前放松自动推荐 | 检测22:00-23:00 + 今日有训练，推送5分钟睡前放松方案 | TR-33 | 低 | P1 |
| TR-37 | 热身/冷却跳过记录 | 记录用户跳过热身/冷却的次数和场景，用于数据分析和安全提示 | TR-29, TR-30 | 低 | P1 |

### 伙伴系统 (CP) 新增

| 功能ID | 功能名称 | 功能描述（一句话） | 依赖项 | 复杂度 | 优先级 |
|--------|---------|-------------------|--------|:------:|:------:|
| CP-18 | 伙伴热身引导语音 | 伙伴在热身阶段使用温和引导语气（语速0.9x/标准音量/低-中能量），每30秒提示下一个动作 | CP-04 | 低 | P0 |
| CP-19 | 伙伴冷却陪伴语音 | 伙伴在冷却阶段使用柔和放松语气（语速0.8x/音量-15%/低能量），配合呼吸节奏引导 | CP-04 | 低 | P0 |
| CP-20 | 伙伴休息日状态 | 休息日伙伴头像切换为REST状态（放松姿势），推荐恢复活动，语气温和 | CP-02 | 中 | P0 |
| CP-21 | 伙伴阶段过渡动画 | 热身→正式训练→冷却三个阶段的头像状态过渡动画（GUIDE→FOCUSED→RELAXED） | CP-02 | 中 | P1 |
| CP-22 | 伙伴拉伸呼吸同步 | 拉伸阶段伙伴头像显示呼吸动画（4秒吸气/6秒呼气），用户可跟随节奏 | CP-02 | 中 | P1 |

## 6.2 新增页面

在功能蓝图页面清单中新增以下页面：

| 序号 | 页面名称 | 所属模块 | 页面核心功能 | 页面状态 | 三端差异 |
|:----:|---------|---------|-------------|---------|---------|
| 80 | 热身执行页 | 训练 | 热身动作序列展示+计时器+伙伴GUIDE头像+进度条+动作插图 | 正常/加载 | iOS/Android:完整动画；小程序:简化 |
| 81 | 冷却执行页 | 训练 | 拉伸动作展示+呼吸节奏指示器+保持计时器+伙伴RELAXED头像 | 正常/加载 | iOS/Android:呼吸动画；小程序:静态呼吸提示 |
| 82 | 独立恢复页 | 训练 | 恢复方案选择（呼吸/拉伸/泡沫轴/散步）+执行计时器+伙伴REST头像 | 正常/加载 | iOS/Android:完整；小程序:简化 |
| 83 | 热身/冷却动作库浏览 | 训练 | 按分类（热身/冷却/恢复）浏览动作+搜索+详情查看 | 正常/加载 | 三端一致 |
| 84 | 恢复提醒设置页 | 训练 | 久坐提醒开关+睡前放松开关+提醒间隔设置+勿扰时段 | 正常 | 三端一致 |

## 6.3 新增数据模型

### WarmUpExercise（热身动作）

```json
{
  "exercise_id": "WU-01",
  "name_zh": "开合跳",
  "name_en": "Jumping Jacks",
  "category": "warmup.general",
  "subcategory": "cardio_activation",
  "target_areas": ["肩关节", "髋关节", "全身"],
  "applicable_scenarios": ["morning_home", "court_evening", "office_noon"],
  "applicable_goals": ["basketball_jump", "badminton", "heavy_strength"],
  "duration_seconds": 30,
  "intensity": "low_to_medium",
  "reps_or_time": "2组 × 30秒",
  "rest_between_sets": 15,
  "contraindications": ["ankle_sprain_acute", "knee_replacement_postop"],
  "fatigue_coefficient": 0.03,
  "nvu_contribution": false,
  "partner_cue": "开合跳，慢慢来。让心率慢慢升上去。",
  "illustration_url": "cdn://exercises/warmup/wu-01.gif",
  "video_url": "cdn://exercises/warmup/wu-01.mp4",
  "tags": ["全身", "有氧", "低冲击替代:原地踏步"],
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### CoolDownExercise（冷却/拉伸动作）

```json
{
  "exercise_id": "CD-02",
  "name_zh": "腘绳肌静态拉伸",
  "name_en": "Standing Hamstring Stretch",
  "category": "cooldown.static_stretch",
  "target_areas": ["腘绳肌", "股二头肌", "半腱肌", "半膜肌"],
  "applicable_phases": ["post_training", "standalone_recovery"],
  "applicable_sessions": ["lower_body_day", "explosive_power", "heavy_strength_lower"],
  "duration_seconds": 45,
  "intensity": "low",
  "hold_per_side_seconds": 30,
  "breathing_cue": "吸气保持，呼气时微微加深拉伸",
  "contraindications": ["hamstring_strain_acute"],
  "fatigue_coefficient": 0.00,
  "nvu_contribution": false,
  "partner_cue": "后腿伸直，从髋关节向前折叠。不是弯腰，是髋关节折叠。",
  "illustration_url": "cdn://exercises/cooldown/cd-02.gif",
  "video_url": "cdn://exercises/cooldown/cd-02.mp4",
  "tags": ["下肢", "后链", "静态拉伸"],
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### TrainingSession（训练会话 — 扩展字段）

在原有 `TrainingSession` 数据模型中新增：

```json
{
  "session_id": "sess_xxx",
  "warm_up": {
    "completed": true,
    "total_duration_seconds": 480,
    "exercises": [
      {
        "exercise_id": "WU-01",
        "name": "开合跳",
        "category": "warmup.general",
        "planned_duration_seconds": 60,
        "actual_duration_seconds": 58,
        "skipped": false,
        "rpe": 2
      }
    ]
  },
  "cool_down": {
    "completed": true,
    "total_duration_seconds": 520,
    "exercises": [
      {
        "exercise_id": "CD-01",
        "name": "轻度步行",
        "category": "cooldown.immediate",
        "planned_duration_seconds": 120,
        "actual_duration_seconds": 115,
        "skipped": false,
        "rpe": 1
      }
    ]
  },
  "phase_transitions": [
    {"from": "warm_up", "to": "main_training", "timestamp": "ISO8601"},
    {"from": "main_training", "to": "cool_down", "timestamp": "ISO8601"}
  ],
  "warm_up_skipped": false,
  "cool_down_skipped": false
}
```

---

# 第七部分：交互原型规格补充

## 7.1 热身执行页交互规格

### 页面进入
- 触发：用户从训练执行页点击"开始训练"，自动进入热身阶段
- 过渡动画：训练计划卡片展开 → 热身页淡入，伙伴头像从IDLE切换到GUIDE状态
- 伙伴开场白：根据伙伴性格生成热身引导语

### 页面布局

```
┌────────────────────────────────────┐
│  ← 退出热身  │   热身 (1/7)   │ Alex (GUIDE) │
├────────────────────────────────────┤
│                                    │
│        ┌──────────────────┐       │
│        │                  │       │
│        │  [动作示意图/GIF]  │       │  ← 当前热身动作展示
│        │                  │       │
│        └──────────────────┘       │
│                                    │
│         开合跳                     │
│         通用热身 · 第1个动作        │
│                                    │
│     ┌────────────────────┐        │
│     │     ████████░░░     │        │  ← 热身进度条
│     │     热身进度 1/7    │        │
│     └────────────────────┘        │
│                                    │
│          ⏱ 00:28 / 00:30          │  ← 倒计时（大字）
│                                    │
│  ┌─ Alex 说 ────────────────────┐ │
│  │ "开合跳，慢慢来。             │ │
│  │  让心率慢慢升上去。"          │ │  ← 伙伴引导语
│  └──────────────────────────────┘ │
│                                    │
│     ┌──────────────────────┐      │
│     │    [ 下一个动作 ]      │      │  ← 预览下一个动作
│     │    高抬腿原地跑        │      │
│     └──────────────────────┘      │
│                                    │
│  [ 跳过热身 ]  ← 小字，二次确认     │
└────────────────────────────────────┘
```

### 交互规格

| 交互行为 | 触发条件 | 响应 |
|---------|---------|------|
| 自动倒计时 | 进入当前热身动作 | 计时器从计划时长倒计时，每秒更新 |
| 动作完成 | 倒计时归零 | 自动切换到下一个动作 + 伙伴提示"下一个" |
| 手动跳过当前动作 | 用户点击"跳过"图标 | 立即切换到下一个动作，不记录为"跳过热身" |
| 跳过整个热身 | 用户点击底部"跳过热身" | 弹出确认弹窗"跳过热身会增加受伤风险。确定跳过吗？[继续热身] [确认跳过]" |
| 确认跳过 | 用户点击"确认跳过" | 记录 skip 事件 → 过渡动画 → 进入正式训练 |
| 热身全部完成 | 最后一个热身动作完成 | 过渡动画：伙伴"准备好了吗？"→ 屏幕亮起金色微光 → 进入正式训练 |
| 退出热身 | 用户点击左上角"退出" | 确认弹窗"确定退出训练？已完成的热身将被记录。[继续训练] [退出]" |

### 伙伴头像状态

| 阶段 | 状态 | 动画 |
|------|------|------|
| 热身开始 | GUIDE | 温和微笑，单手引导手势 |
| 热身进行中 | GUIDE | 轻微点头，跟随动作节奏 |
| 动作切换 | GUIDE | 手势切换（指向新动作） |
| 热身完成过渡 | GUIDE→FOCUSED | 1秒过渡：收起微笑→眼神专注→前倾 |

---

## 7.2 冷却执行页交互规格

### 页面进入
- 触发：用户完成最后一组正式训练动作 → 自动进入冷却阶段
- 过渡动画：LAST SET 效果消散 → 冷却页淡入，伙伴头像从FOCUSED切换到RELAXED
- 伙伴开场白："辛苦了。现在让身体慢慢回来。跟着我呼吸。"

### 页面布局

```
┌────────────────────────────────────┐
│  ← 退出冷却  │  冷却拉伸 (2/5)  │ Alex (RELAXED) │
├────────────────────────────────────┤
│                                    │
│        ┌──────────────────┐       │
│        │                  │       │
│        │  [动作示意图/GIF]  │       │  ← 当前拉伸动作展示
│        │                  │       │
│        └──────────────────┘       │
│                                    │
│         腘绳肌静态拉伸              │
│         每侧保持 30 秒 · 左侧       │
│                                    │
│     ┌────────────────────┐        │
│     │     ██████░░░░░░    │        │  ← 冷却进度条
│     │     冷却进度 2/5    │        │
│     └────────────────────┘        │
│                                    │
│         保持 ⏱ 00:18 / 00:30      │  ← 保持计时器
│                                    │
│  ┌─ 呼吸节奏 ──────────────────┐  │
│  │  吸 ◉◉◉◉○○○○○○  呼         │  │  ← 呼吸节奏指示器
│  │  ← 4秒 →  ← 6秒 →          │  │
│  └────────────────────────────┘  │
│                                    │
│  ┌─ Alex 说 ────────────────────┐ │
│  │ "保持这个拉伸。               │ │
│  │  吸气4秒，呼气6秒。"          │ │  ← 伙伴引导语
│  └──────────────────────────────┘ │
│                                    │
│     ┌──────────────────────┐      │
│     │    [ 下一个拉伸 ]      │      │  ← 预览
│     │    股四头肌拉伸        │      │
│     └──────────────────────┘      │
│                                    │
│  [ 跳过冷却 ]  ← 小字，二次确认     │
└────────────────────────────────────┘
```

### 呼吸节奏指示器

呼吸节奏指示器是一个动态的圆形呼吸动画：

```
状态1 - 吸气阶段（4秒）：
  ┌─────────┐
  │  ◉ → ○  │  圆从小变大，颜色从深蓝过渡到浅蓝
  │  吸气    │  文字显示"吸气"
  └─────────┘

状态2 - 屏息阶段（可选，2秒）：
  ┌─────────┐
  │    ○    │  圆保持最大，微微脉动
  │  屏住    │  文字显示"屏住"
  └─────────┘

状态3 - 呼气阶段（6秒）：
  ┌─────────┐
  │  ○ → ◉  │  圆从大变回小，颜色从浅蓝过渡到深蓝
  │  呼气    │  文字显示"呼气"
  └─────────┘
```

### 交互规格

| 交互行为 | 触发条件 | 响应 |
|---------|---------|------|
| 自动倒计时 | 进入当前拉伸动作 | 保持计时器倒计时 + 呼吸节奏循环 |
| 单侧完成提示 | 单侧保持倒计时归零 | 伙伴提示"换另一侧" + 计时器重置 |
| 动作完成 | 双侧/完整倒计时归零 | 自动切换到下一个冷却动作 |
| 跳过当前动作 | 用户点击"跳过" | 立即切换，不记录为"跳过冷却" |
| 跳过整个冷却 | 用户点击"跳过冷却" | 确认弹窗"冷却拉伸帮助身体恢复，减少酸痛。确定跳过吗？[继续拉伸] [确认跳过]" |
| 冷却全部完成 | 最后一个动作完成 | 伙伴结束语 + 过渡动画 → 训练总结页(TR-11) |
| 退出冷却 | 用户点击"退出" | 确认弹窗"确定退出？已完成的冷却将被记录。[继续] [退出]" |

---

## 7.3 独立恢复页交互规格

### 页面进入
- 触发途径1：休息日首页 → 点击恢复方案卡片
- 触发途径2：推送通知 → 点击进入（久坐提醒/睡前放松）
- 触发途径3：训练总结页 → "做个恢复？"入口

### 页面布局

```
┌────────────────────────────────────┐
│  ← 返回  │   主动恢复   │ Alex (REST) │
├────────────────────────────────────┤
│                                    │
│          🧘 主动恢复日              │
│         恢复也是训练的一部分         │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  ○ 轻度步行         05:00   │ │  ← 恢复动作列表
│  │     已完成 ✓                 │ │
│  ├──────────────────────────────┤ │
│  │  ● 动态拉伸         05:00   │ │  ← 当前动作
│  │     猫牛式脊柱活动   00:45   │ │
│  │     ████████░░░  进行中     │ │
│  ├──────────────────────────────┤ │
│  │  ○ 泡沫轴滚压       05:00   │ │  ← 待完成
│  └──────────────────────────────┘ │
│                                    │
│  ┌─ 当前动作 ──────────────────┐  │
│  │        [动作示意图]          │  │
│  │    猫牛式脊柱活动             │  │
│  │    ⏱ 00:32 / 00:45          │  │
│  └────────────────────────────┘  │
│                                    │
│  ┌─ Alex ──────────────────────┐  │
│  │ "像猫一样。吸气拱背，        │  │
│  │  呼气塌腰。慢慢来。"         │  │
│  └─────────────────────────────┘  │
│                                    │
└────────────────────────────────────┘
```

---

# 第八部分：补充开发任务清单

## 8.1 P0 开发任务（MVP 必做）

| 任务编号 | 任务名称 | 关联功能ID | 预估工作量 | 前置依赖 |
|:-------:|---------|:--------:|:-------:|---------|
| T-WU-01 | 热身动作库数据录入（18个动作） | TR-34 | 3人日 | CS-04 动作库基础 |
| T-WU-02 | 冷却动作库数据录入（15个动作） | TR-34 | 2人日 | CS-04 动作库基础 |
| T-WU-03 | 热身自动编排算法实现 | TR-29 | 5人日 | TR-03 计划生成引擎, TR-15 多场景编排 |
| T-WU-04 | 冷却自动编排算法实现 | TR-30 | 3人日 | TR-03 计划生成引擎 |
| T-WU-05 | 训练计划输出格式扩展（warm_up/cool_down字段） | TR-29, TR-30 | 2人日 | TR-03 |
| T-WU-06 | 热身执行页 UI 开发 | TR-31 | 5人日 | TR-04 训练执行页 |
| T-WU-07 | 冷却执行页 UI 开发 | TR-32 | 4人日 | TR-04 训练执行页 |
| T-WU-08 | 呼吸节奏指示器组件开发 | TR-32 | 2人日 | T-WU-07 |
| T-WU-09 | 伙伴热身引导语音资源制作（5伙伴 × 10句） | CP-18 | 2人日 | CP-04 语音系统 |
| T-WU-10 | 伙伴冷却陪伴语音资源制作（5伙伴 × 10句） | CP-19 | 2人日 | CP-04 语音系统 |
| T-WU-11 | 伙伴 GUIDE/RELAXED 状态动画制作 | CP-20, CP-21 | 3人日 | CP-02 头像系统 |
| T-WU-12 | 训练执行页阶段过渡动画（热身→训练→冷却） | CP-21 | 2人日 | CP-06 Mode Shift |
| T-WU-13 | NVU 计算修正（热身/冷却不计入训练NVU） | TR-13 | 1人日 | TR-13 NVU计算 |
| T-WU-14 | 独立恢复页 UI 开发 | TR-33 | 3人日 | TR-22 休息日模式 |
| T-WU-15 | 休息日恢复推荐集成 | TR-33 | 2人日 | TR-22, T-WU-14 |
| T-WU-16 | 热身/冷却跳过记录与统计 | TR-37 | 1人日 | T-WU-06, T-WU-07 |
| T-WU-17 | 动作库页面新增 warmup/cooldown 分类筛选 | TR-34 | 1人日 | TR-05, 动作库页面 |
| T-WU-18 | 集成测试：完整训练流程（热身→训练→冷却） | TR-29~32 | 3人日 | 所有以上任务 |
| **小计** | | | **46 人日** | |

## 8.2 P1 开发任务（Phase 2）

| 任务编号 | 任务名称 | 关联功能ID | 预估工作量 | 前置依赖 |
|:-------:|---------|:--------:|:-------:|---------|
| T-WU-19 | 久坐检测与微恢复推送 | TR-35 | 3人日 | TR-33 |
| T-WU-20 | 睡前放松自动推荐 | TR-36 | 2人日 | TR-33 |
| T-WU-21 | 恢复提醒设置页开发 | — | 2人日 | TR-35, TR-36 |
| T-WU-22 | 伙伴拉伸呼吸同步动画 | CP-22 | 2人日 | CP-02 |
| T-WU-23 | 热身/冷却动作视频制作（20个视频） | TR-34 | 5人日 | CS-04 |
| T-WU-24 | 热身/冷却模块 A/B 测试框架 | — | 2人日 | T-WU-18 |
| **小计** | | | **16 人日** | |

## 8.3 P2 开发任务（Phase 3）

| 任务编号 | 任务名称 | 关联功能ID | 预估工作量 |
|:-------:|---------|:--------:|:-------:|
| T-WU-25 | 用户自定义热身序列 | — | 3人日 |
| T-WU-26 | 用户自定义冷却序列 | — | 3人日 |
| T-WU-27 | 热身/冷却有效性分析（跳过 vs 不跳过的受伤率对比） | TR-37 | 3人日 |
| T-WU-28 | 社群分享恢复方案 | SC-06 | 2人日 |
| **小计** | | | **11 人日** |

## 8.4 总工作量估算

| 阶段 | 任务数 | 人日 |
|------|:-----:|:---:|
| P0 (MVP) | 18 | 46 |
| P1 (Phase 2) | 6 | 16 |
| P2 (Phase 3) | 4 | 11 |
| **总计** | **28** | **73** |

---

# 第九部分：总结与整合指南

## 9.1 需要修改的现有交付物

### PRD V2.0 修改点

1. **第4章功能清单**：TR 模块新增 TR-29 至 TR-37（8个功能ID）
2. **第5章 EARS 规格**：新增 5.X 节「热身与恢复体系」，包含 5.X.1 至 5.X.7
3. **第11章训练编排算法**：
   - 11.6 多场景容量分配 → 替换为修正后的容量分配模型
   - 新增 11.9 热身/冷却 NVU 计算规则
4. **训练计划输出格式**：output 结构增加 `warm_up` 和 `cool_down` 字段

### 完整功能蓝图修改点

1. **1.2 训练模块功能矩阵**：新增 TR-29 至 TR-37
2. **1.1 伙伴系统功能矩阵**：新增 CP-18 至 CP-22
3. **2.2 训练模块详细规格**：新增 TR-29~TR-37 详细规格
4. **3.1 页面清单**：新增第80-84号页面
5. **4.1 数据模型**：新增 WarmUpExercise / CoolDownExercise 实体，TrainingSession 扩展
6. **CS-04 核心动作视频库**：数量从 50+ 更新为 70+

### 训练编排引擎文档修改点

1. 计划输出格式增加 `warm_up` 和 `cool_down` 字段
2. NVU 计算规则增加热身/冷却排除逻辑
3. 疲劳传递模型增加热身/冷却的低权重系数

## 9.2 设计原则回顾

| 原则 | 实现方式 |
|------|---------|
| **热身不是可选** | 每个训练计划强制嵌入热身模块，跳过需二次确认 |
| **冷却不是可选** | 每个训练计划强制嵌入冷却模块，跳过需二次确认 |
| **场景自适应** | 热身内容根据场景（晨间/工位/球场）自动调整 |
| **目标自适应** | 专项热身根据运动目标（弹跳/羽毛球/康复）自动选择 |
| **训练类型自适应** | 冷却拉伸根据训练类型（力量/爆发力/上肢/下肢）自动匹配 |
| **伙伴全程陪伴** | 热身/训练/冷却三个阶段伙伴语气不同但人格一致 |
| **NVU 精确计算** | 热身和冷却不计入训练 NVU，空杆热身组单独计算 |
| **数据闭环** | 记录跳过行为，分析热身/冷却对受伤率和恢复质量的影响 |

---

> **文档结束**
> 
> 本文档可直接作为 PRD V2.1 的补充章节和功能蓝图 V1.1 的更新内容。
> 所有动作ID（WU-/CD-/RC-）已预留命名空间，后续可扩展。
> 动作库中的时长、强度等参数为初始设计值，需在用户测试中验证和调整。

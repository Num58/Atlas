# PrimeAtlas

> 不是管理任务，而是管理用户成为谁。
>
> Flutter · Android / iOS · 本地优先 · 云端同步钩子预留

PrimeAtlas 是以身份迁移为主轴的个人成长操作系统。产品主循环为：

```text
身份定义 → 目标与里程碑 → 专业计划 → 今日执行与反馈 → 成果证据 → 身份与目标重校准
```

## 当前阶段

- 产品理解与全量 PRD：产品层已评审通过；
- 主 Spec：`Draft for Freeze`，当前仍为 `NOT SPEC READY / NOT DEV READY`；
- 编码前原型：修正版已完成主代理第一层核验，独立 QA 与视觉门禁尚未最终关闭；
- Flutter：仅 `lib/core` S0 纯 Dart 基线已实现，正式移动端 UI 尚未进入编码；
- Android 设备实验室：工具链可用，system image 与 AVD 尚待完成。

用户评审通过前，不进入正式 Flutter 功能开发。

## 真源优先级

1. `docs/product/PrimeAtlas_完整需求蓝图_Final.md`：终局产品范围与铁律；
2. `docs/product-strategy/primeatlas-product-decision-confirmation-2026-07-20.md`：12 项 P0 产品裁决；
3. `docs/product-strategy/primeatlas-full-prd-review-2026-07-17.md`：全量 PRD；
4. `docs/spec/primeatlas-spec-v1.0.md`：当前规格契约草案；
5. `docs/prototype/primeatlas-prototype-plan-review-v1.0.md`：编码前原型方案；
6. `docs/prototype/primeatlas-review-prototype-v1.0.html`：可点击评审原型，不是业务实现真源；
7. `docs/prototype/primeatlas-prototype-v6.html`：v6 纵向原型（体能高密度锚点体验参考），不是当前导航或业务规则真源；
8. `docs/handoff/`：开发交接与后续专家团接续说明。

发生冲突时按以上顺序裁决，不得以旧原型、旧任务卡或现有代码反向覆盖产品真源。

## 目录结构

```text
docs/
  product/            完整蓝图与早期需求真源
  product-strategy/   产品理解、全量 PRD、追踪矩阵、P0 决策
  spec/               主 Spec 与架构、设计、QA 输入
  prototype/          原型方案、可点击评审原型、v6 纵向原型
  handoff/            专家团交接文档（本次同步后生成）
  status/             阶段状态与门禁说明
lib/core/             纯 Dart 核心层
lib/app/              正式 UI 层，尚未开始
test/                 核心层自动化测试
```

## 本地验证

```bash
flutter pub get
flutter analyze
flutter test
```

已知基线：Flutter 3.44.2、Dart 3.12.2。不要把本地 SDK、Android system image、AVD、缓存、截图或凭证提交到仓库。

## 三条绝对规则

- 禁止使用 emoji 作为 UI 功能图标，正式实现统一使用 Spec 锁定的一套 SVG 图标库；
- 禁止紫色到粉色渐变主视觉；
- 禁止占位文案、伪精确指标和 AI 模板味实现。

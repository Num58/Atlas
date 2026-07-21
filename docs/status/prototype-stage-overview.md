# PrimeAtlas 编码前原型阶段概览

## 当前完成

- 完成并复核《PrimeAtlas 完整原型方案评审稿 v1.0》；方案 A 为主验证候选，不是 Frozen IA。
- P-A0 完整定义 V0.2 的 11 页身份—目标闭环；P-A1 只用于终局 IA 结构承载验证；B/C 只做同内容导航对照。
- 明确现有 Flutter S0 的可复用边界、缺失领域对象、P-A0 11 页的 GoRouter/Riverpod/Use-case/Repository/SQLite 映射方向，以及 `rollback`、Noop 同步、普通冲突与 Safety 的语义纠正。
- 当前工程没有 `lib/app`、`lib/main.dart`、Router、Provider、Screen 或 Android/iOS 工程壳，因此 P-A0 的裁决是“架构可实施，但不可立即编码”；HTML 负责关闭 IA、交互和状态门禁。
- 建立原型 QA 门禁：A0/A1 全状态、七类高风险专项、16 类 P0、响应式与无障碍、D0–D5 证据规则。

## 正在进行

- 独立、无需安装的 HTML 评审原型正在实现，正式 Flutter 工程保持不动。
- HTML 完成后由独立 QA 执行关键点击路径、范围隔离、安全、Consent、Eligibility、离线、版本冲突、响应式和无障碍验证。

## 门禁与后续

- D0/D1/D2 且 P0 缺陷归零后，原型才可提交用户评审。
- 用户评审通过前不进入正式 Flutter 功能编码。
- 方案 A 最终冻结仍需真实目标用户 D3，以及核心无障碍旅程 D4 或 QA 接受的等价真实证据。

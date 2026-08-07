/// 此文件已被 T2-1 新版调性引擎取代。
///
/// 原 S0 状态机（`ToneStateMachine` / `HealthBandwidthConfig` / 旧 `Tone`
/// 类型）与 T2-1 规范冲突：新版以 `tone_types.dart` 的 [ToneId] / [ToneState]
/// 与 `tone_engine.dart` 的 [ToneEngine] 为准，状态机逻辑已并入 [ToneEngine]。
///
/// 本文件保留为空库，仅维持 `lib/core/core.dart` 的 re-export 路径有效；
/// 后续由集成者按需删除。请勿在此新增实现。
library;

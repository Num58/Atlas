# ADR-009: Lucide SVG allowlist 与单一 flutter_svg 渲染器

## Status
Accepted for dependency and rendering chain (2026-07-21); platform golden pending

## Context
功能图标必须统一为 SVG 图标库，不得使用 emoji 或混用 Material/Cupertino。当前仓库没有 Lucide 或 SVG 渲染依赖。

## Decision
唯一方向为官方 Lucide SVG upstream 固定 tag/commit、仓库 allowlist 资产、单一 `flutter_svg` 渲染器，并只通过 `AppIcon` 暴露。固定 pin：Lucide `1.25.0` / commit `5136572c10214634858fcf5f726b2a9d26683918`；`flutter_svg 2.3.0`。依赖已精确写入 pubspec/lockfile；首个 allowlist 资产 `target.svg` 与 LICENSE 已按 commit 归档。

官方 Lucide LICENSE 为 ISC；列明的 Feather 派生图标另附 MIT。分发资产必须保留完整许可证和 copyright notice：<https://lucide.dev/license>、<https://github.com/lucide-icons/lucide/blob/main/LICENSE>。`flutter_svg` 官方页面声明 SVG 1.1 asset 渲染与 semanticsLabel：<https://pub.dev/packages/flutter_svg>。

## Consequences
资产可审计且不依赖非官方 Flutter 图标封装；需维护 allowlist/hash/许可证。业务页面禁止直接 `SvgPicture`、`Icon(Icons.*)`、Cupertino、第二图标包及 emoji 功能图标。

## Verification
已通过：精确 lock；`target.svg` SHA-256 `96a6b16628825a1a207a77e9a5818f74c3e74ea3664783ff5c2a44e6347b90df`；LICENSE SHA-256 `b495047bd93a9b06913511076f504daba17d5bbeb3e0650f3bb53a4220329c57`；Flutter `3.44.2`/Dart `3.12.2` 的 widget asset 渲染、semantics、尺寸断言；`flutter analyze` 0 issue；lib 中仅 `AppIcon` 引用 `flutter_svg/SvgPicture.asset`。命令：`flutter test test/architecture`。

2026-07-21 Windows/Android 平台探测补充：正式仓库没有 `lib/main.dart`、`android/` 或 Gradle Wrapper，`flutter build apk --debug` 与 `flutter build apk --release` 均以 `Target file "lib\\main.dart" not found` 退出 1，未生成 APK。独立设备实验室的临时 harness 可解析正式 `AppIcon`，16/20/24 三种尺寸与 semantics widget 测试通过，但该 harness 不属于正式 runner，不能替代正式 APK、生产签名或真机证据。实验室已另行证明隔离 AVD `PrimeAtlas_API36_1` 可冷启动、ADB 可见且 `sys.boot_completed=1`，但没有正式 APK 可安装，因此没有应用级 logcat、semantics 或截图证据。Android 仍为 Pending，iOS 仍为 Pending。

仍待 QA/platform runner：正式 Android/iOS release build、APK/应用包内资产检查、设备运行证据、字体倍率/深浅高对比 golden 及像素阈值。`target.svg` 是普通 asset 而非字体 glyph；没有产物级机械对照时不得用字体 tree-shaking 日志推断 SVG 裁剪。因此依赖与渲染链 Accepted，但 Release 图标门尚不能称 Frozen。

## Related ADRs
ADR-001、ADR-008

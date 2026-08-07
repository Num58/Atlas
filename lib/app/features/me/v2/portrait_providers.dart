import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primeatlas/core/common/result.dart';
import 'package:primeatlas/core/portrait/portrait_engine.dart';
import 'package:primeatlas/core/portrait/portrait_types.dart';

/// 画像动态更新状态（P3-1）。
///
/// 内存态，不落库：初始为 null（尚无画像）。每次 [commit] 委托
/// [PortraitEngine.createSnapshot] 生成一个新版本；未经用户授权
/// (`consent == false`) 时不创建快照，直接把 [Failure] 透传给调用方。
final portraitProvider =
    StateNotifierProvider<PortraitNotifier, PortraitSnapshot?>(
  (ref) => PortraitNotifier(),
);

class PortraitNotifier extends StateNotifier<PortraitSnapshot?> {
  PortraitNotifier() : super(null);

  final PortraitEngine _engine = const PortraitEngine();

  /// 提交一次画像更新。
  ///
  /// 返回 [Success] 表示已创建并写入内存态；返回 [Failure] 表示被拒绝
  ///（当前仅 `consent_required` / `inactive_axis_value`），此时不改动状态。
  Result<PortraitSnapshot?> commit(
    List<PortraitAxis> axes,
    Map<String, double> values,
    bool consent,
  ) {
    final result = _engine.createSnapshot(
      axes: axes,
      rawValues: values,
      consent: consent,
      now: DateTime.now(),
      prevVersion: state?.version,
      prev: state,
    );
    if (result.isFailure) {
      return result;
    }
    final snapshot = result.valueOrNull!;
    state = snapshot;
    return Success(snapshot);
  }
}

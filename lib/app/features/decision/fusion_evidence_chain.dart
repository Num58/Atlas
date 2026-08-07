import 'package:flutter/material.dart';
import 'package:primeatlas/core/decision/decision_types.dart';

/// 融合证据链：透明展示一次决策组合的逐项依据。
///
/// 移动端优先；中性色块（无 emoji 图标、无紫粉渐变）；文案为事实陈述，无模板味。
class FusionEvidenceChain extends StatelessWidget {
  final List<DecisionEvidenceItem> items;

  const FusionEvidenceChain({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('决策依据', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: _dotColor(item.source),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.source.label} · ${item.label}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.detail,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 中性语义色（蓝/青/橙/灰），规避紫粉渐变。
  Color _dotColor(DecisionEvidenceSource source) {
    switch (source) {
      case DecisionEvidenceSource.safety:
        return const Color(0xFF1F6FB2);
      case DecisionEvidenceSource.conflict:
        return const Color(0xFFB26A1F);
      case DecisionEvidenceSource.fusion:
        return const Color(0xFF1F8F7A);
      case DecisionEvidenceSource.agents:
        return const Color(0xFF5B6470);
      case DecisionEvidenceSource.tone:
        return const Color(0xFF3A5A8C);
    }
  }
}

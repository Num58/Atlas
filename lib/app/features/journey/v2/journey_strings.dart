/// Shared Chinese copy + status-label helpers for the V0.2 journey UI.
///
/// Keeps product tone consistent ("专业成长手册 × 精密决策工具") and avoids
/// scattered hard-coded status strings across pages.

library;

/// Suggested growth-domain codes shown in activation / assignment pickers.
const Map<String, String> domainCatalog = {
  'career': '事业',
  'health': '健康',
  'relationship': '关系',
  'learning': '学习成长',
  'finance': '财务',
  'meaning': '意义与价值',
};

String domainLabel(String code) => domainCatalog[code] ?? code;

const Map<String, String> goalStatusLabels = {
  'draft': '草案',
  'active': '进行中',
  'paused': '已暂停',
  'completed': '已完成',
  'archived': '已归档',
  'recalibrating': '重新校准',
};

const Map<String, String> milestoneStatusLabels = {
  'pending': '待达成',
  'achieved': '已达成',
  'superseded': '已取代',
};

String goalStatusLabel(String status) =>
    goalStatusLabels[status] ?? status;

String milestoneStatusLabel(String status) =>
    milestoneStatusLabels[status] ?? status;

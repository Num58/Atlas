import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const html = fs.readFileSync(new URL('../primeatlas-prototype-v6.html', import.meta.url), 'utf8');
const scripts = [...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/gi)].map(match => match[1]);
assert.ok(scripts.length, 'V6 must contain executable scripts');
scripts.forEach((script, index) => assert.doesNotThrow(() => new vm.Script(script, { filename: `v6-approved#${index + 1}` })));

function functionBody(name) {
  const source = scripts.join('\n');
  const start = source.indexOf(`function ${name}(`);
  assert.notEqual(start, -1, `missing function ${name}`);
  const open = source.indexOf('{', start);
  let depth = 0;
  let quote = '';
  let escaped = false;
  for (let index = open; index < source.length; index += 1) {
    const char = source[index];
    if (quote) {
      if (escaped) escaped = false;
      else if (char === '\\') escaped = true;
      else if (char === quote) quote = '';
      continue;
    }
    if (char === "'" || char === '"' || char === '`') { quote = char; continue; }
    if (char === '{') depth += 1;
    if (char === '}') depth -= 1;
    if (depth === 0) return source.slice(start, index + 1);
  }
  throw new Error(`unterminated function ${name}`);
}

// F02: notes are rendered through DOM nodes and textContent, never n.text HTML interpolation.
const notesRenderer = functionBody('refreshNotesSummary');
assert.match(notesRenderer, /container\.replaceChildren\(\)/);
assert.match(notesRenderer, /appendReaderNoteText\(card,\s*'ns-text',\s*n\.text\)/);
assert.doesNotMatch(notesRenderer, /innerHTML/);
assert.doesNotMatch(notesRenderer, /\$\{n\.text\}/);

const attackPayloads = [
  '<img src=x onerror=globalThis.__v6Xss=1>',
  '<svg onload=globalThis.__v6Xss=1></svg>',
  '<script>globalThis.__v6Xss=1<\/script>',
];
class FakeNode {
  constructor(tag = 'div') { this.tagName = tag.toUpperCase(); this.children = []; this.textContent = ''; this.className = ''; this.type = ''; this.style = {}; }
  appendChild(child) { this.children.push(child); return child; }
  replaceChildren(...children) { this.children = children; this.textContent = ''; }
  addEventListener() {}
}
const noteContainer = new FakeNode();
const context = {
  document: {
    createElement: tag => new FakeNode(tag),
    getElementById: id => id === 'readerNotesSummary' ? noteContainer : null,
  },
  readerState: { book: '', notes: { 0: attackPayloads.map(text => ({ text, time: '2026-07-21' })) } },
  readerContentMap: {},
  showToast() {},
};
vm.createContext(context);
vm.runInContext(`${functionBody('appendReaderNoteText')}\n${notesRenderer}`, context);
context.refreshNotesSummary();
const renderedTags = [];
const renderedText = [];
(function walk(node) {
  renderedTags.push(node.tagName);
  renderedText.push(node.textContent);
  node.children.forEach(walk);
})(noteContainer);
for (const forbidden of ['IMG', 'SVG', 'SCRIPT']) assert.ok(!renderedTags.includes(forbidden), `attack must not create ${forbidden}`);
for (const payload of attackPayloads) assert.ok(renderedText.includes(payload), 'attack payload must remain literal text');
assert.equal(globalThis.__v6Xss, undefined);

// F10: Pulse remains an optional ritual and training is reachable before it runs.
assert.match(html, /Today's Training — always available; Pulse remains an optional ritual/);
assert.match(html, /class="training-unlock-target unlocked" id="trainingUnlockTarget"/);
assert.match(html, /可选启动仪式/);
assert.match(html, /长按开始/);
assert.doesNotMatch(html, /长按解锁|就绪 · 解锁训练|训练区域已解锁/);
assert.doesNotMatch(functionBody('handlePulseTap'), /trainingUnlockTarget|classList\.(?:add|remove)\(['"]locked/);
assert.match(functionBody('drawPulseCanvas'), /requestAnimationFrame\(drawPulseCanvas\)/, 'Q06 animation must remain intact');

// F01: all three quoted search examples are valid HTML attributes.
const expectedPlaceholders = [
  'placeholder="搜索动作… 如“深蹲”"',
  'placeholder="向资料库提问... 如“基于扣篮目标，如何避免髌腱炎？”"',
  'placeholder="搜索动作… 如“深蹲”"',
];
for (const placeholder of expectedPlaceholders) assert.ok(html.includes(placeholder), `missing valid placeholder: ${placeholder}`);
assert.equal((html.match(/placeholder="搜索动作… 如“深蹲”"/g) || []).length, 2);
assert.doesNotMatch(html, /placeholder="[^"]*如"/);

// F03: phone login rejects empty/invalid values and accepts only the explicit prototype code.
const loginContext = {};
vm.createContext(loginContext);
vm.runInContext(`${functionBody('isValidPhoneNumber')}\n${functionBody('validatePhoneLogin')}`, loginContext);
assert.equal(loginContext.validatePhoneLogin('', '').ok, false);
assert.equal(loginContext.validatePhoneLogin('13800138000', '').ok, false);
assert.equal(loginContext.validatePhoneLogin('13800138000', '000000').ok, false);
assert.deepEqual(JSON.parse(JSON.stringify(loginContext.validatePhoneLogin('13800138000', '246810'))), { ok:true });
assert.match(functionBody('submitPhoneLogin'), /if\s*\(!result\.ok\)[\s\S]*return false/);
assert.doesNotMatch(functionBody('showPhoneLogin'), /closeDetail\(\);onLoginSuccess\('手机号'\)/);

// F04/D04: state mutation is atomic, persisted locally, and save status is honest.
for (const token of ['status:\'not_saved\'', "status:'committed'", "status:'save_error'", '已保存到本机', '尚未保存', '保存失败']) assert.ok(html.includes(token), `missing local-save token ${token}`);
assert.match(functionBody('commitMutation'), /prototypeState\s*=\s*before/);
assert.match(functionBody('onLoginSuccess'), /commitMutation/);
assert.match(functionBody('doLogout'), /commitMutation/);
assert.doesNotMatch(html, /云端同步已开启/);

// F05: every training progress surface derives from one snapshot function.
const progress = functionBody('trainingProgressSnapshot');
assert.match(progress, /completedActions\s*\/\s*actions\.length/);
const updateProgress = functionBody('updateOverallProgress');
assert.match(updateProgress, /trainingProgressSnapshot\(\)/);
for (const id of ['trainingProgressBar', 'trainingProgressText', 'todayProgressBar', 'todayProgressText']) assert.ok(updateProgress.includes(id));
assert.match(functionBody('showTodayProgress'), /trainingProgressSnapshot\(\)/);
assert.doesNotMatch(functionBody('showTodayProgress'), /65%/);

// F06/F07: metrics and settings use prototypeState as the single source with reversible unit conversion and derived RPE options.
assert.match(html, /let bodyData\s*=\s*prototypeState\.bodyData/);
assert.match(html, /const allMetrics\s*=\s*new Proxy/);
const formatContext = { prototypeState: { settings:{ units:'metric', rpe:'1-10' }, metrics:{ weight:{ val:82, unit:'kg' }, height:{ val:180, unit:'cm' } } } };
vm.createContext(formatContext);
vm.runInContext(`${functionBody('metricRecord')}\n${functionBody('formatMetricValue')}\n${functionBody('parseMetricValue')}\n${functionBody('rpeOptions')}`, formatContext);
const pounds = Number(formatContext.formatMetricValue('weight', 'imperial').replace('lb', ''));
assert.ok(Math.abs(formatContext.parseMetricValue('weight', pounds, 'imperial') - 82) < 0.1);
const inches = Number(formatContext.formatMetricValue('height', 'imperial').replace('in', ''));
assert.ok(Math.abs(formatContext.parseMetricValue('height', inches, 'imperial') - 180) < 0.2);
assert.deepEqual(Array.from(formatContext.rpeOptions('1-10')), [1,2,3,4,5,6,7,8,9,10]);
assert.deepEqual(Array.from(formatContext.rpeOptions('6-20')), [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]);
assert.match(functionBody('toggleUnits'), /commitMutation/);
assert.match(functionBody('toggleRPE'), /commitMutation/);

// F08: custom date is a real date input and invalid custom dates block save.
assert.match(html, /<input type="date" id="drCustomDate"/);
assert.match(functionBody('setDRDate'), /date === 'custom'/);
assert.match(functionBody('resolveDRDate'), /drCustomDate/);
assert.match(html, /function saveDataRecord\(\)[\s\S]*if\s*\(!recordDate\)[\s\S]*return false/);
assert.doesNotMatch(html, /const dateLabel\s*=\s*drSelectedDate[\s\S]*:\s*'已'/);

// F09: all seven AI tests require bounded input and commit their values only after the final step.
assert.match(html, /const aiTestSteps\s*=\s*\[/);
const validateContext = {};
vm.createContext(validateContext);
vm.runInContext(functionBody('validateAITestValue'), validateContext);
assert.equal(validateContext.validateAITestValue({ min:1, max:150, unit:'cm' }, '').ok, false);
assert.equal(validateContext.validateAITestValue({ min:1, max:150, unit:'cm' }, '0').ok, false);
assert.equal(validateContext.validateAITestValue({ min:1, max:150, unit:'cm' }, '58').ok, true);
assert.match(functionBody('saveAITestStep'), /if\s*\(!result\.ok\)[\s\S]*return false/);
assert.match(functionBody('saveAITestStep'), /commitMutation/);
assert.match(functionBody('saveAITestStep'), /source:'AI 引导测试'/);
assert.doesNotMatch(functionBody('showAITestStep'), /全部完成/);

// D03: delete routes to pause; pause/archive statuses are committed and preserve history.
assert.match(functionBody('deleteGoal'), /pauseGoal\(n\)/);
assert.match(functionBody('setGoalStatus'), /commitMutation/);
assert.ok(functionBody('setGoalStatus').includes("status === 'paused'"));
assert.match(functionBody('archiveGoal'), /setGoalStatus/);

// F11: the raw HTML contains no Unicode pictographs in the P0 scan ranges; no whitelist or source rewriting is allowed.
const emojiPattern = /[\u{1F300}-\u{1F9FF}\u2600-\u26FF\u2700-\u27BF]/gu;
assert.doesNotMatch(html, emojiPattern, 'raw HTML must contain zero Unicode pictographs');
const emotionContractMatch = html.match(/<div[^>]*data-content-emoji="emotion-expression"[\s\S]*?<\/div>/);
const emotionContract = emotionContractMatch?.[0] || '';
assert.match(emotionContract, /aria-label="今日能量表达"/);
for (const icon of ['moon','leaf','sun','dumbbell','flame']) assert.ok(emotionContract.includes(`[icon:${icon}]`), `missing Lucide energy expression ${icon}`);
assert.match(functionBody('svgIcon'), /\[16,20,24\]\.includes\(Number\(size\)\)/);
assert.match(functionBody('hydrateLucideIcons'), /svgIcon\(match\[1\], size\)/);
assert.doesNotMatch(functionBody('svgIcon'), /font-size:'\+\(size\|\|16\)/);

// Q01: non-native click targets gain role, tab stop, and Enter/Space activation.
const accessibleInteractive = functionBody('makeInteractiveAccessible');
assert.match(accessibleInteractive, /setAttribute\('role','button'\)/);
assert.match(accessibleInteractive, /el\.tabIndex\s*=\s*0/);
const keyboardActivation = functionBody('handleAccessibleActivation');
assert.match(keyboardActivation, /event\.key !== 'Enter'/);
assert.match(keyboardActivation, /event\.key !== ' '/);
assert.match(keyboardActivation, /target\.click\(\)/);
assert.match(html, /document\.addEventListener\('keydown', handleAccessibleActivation\)/);

// Q02: detail dialogs expose semantics, trap focus, close on Escape, and restore focus.
assert.match(functionBody('showDetail'), /role="dialog"/);
assert.match(functionBody('showDetail'), /aria-modal="true"/);
assert.match(functionBody('showDetail'), /aria-labelledby="detailModalTitle"/);
assert.match(functionBody('showDetail'), /requestAnimationFrame[\s\S]*\.focus\(\)/);
assert.match(functionBody('handleDetailModalKeydown'), /event\.key === 'Escape'/);
assert.match(functionBody('handleDetailModalKeydown'), /event\.key !== 'Tab'/);
assert.match(functionBody('closeDetail'), /detailModalReturnFocus/);
assert.match(functionBody('closeDetail'), /returnTarget\.focus\(\)/);
assert.match(functionBody('initializeAccessibleModals'), /setAttribute\('role','dialog'\)/);
assert.match(functionBody('initializeAccessibleModals'), /setAttribute\('aria-modal','true'\)/);

// Q03/Q04/Q05: visible focus, higher-contrast muted/navigation tokens, and live-region feedback.
assert.match(html, /:where\(button, \[role="button"\], input, select, textarea, \[tabindex\]\):focus-visible/);
assert.match(html, /--tab-inactive:\s*rgba\(240, 240, 245, 0\.62\)/);
assert.match(html, /--text-tertiary:\s*rgba\(240, 240, 245, 0\.58\)/);
const toast = functionBody('showToast');
assert.match(toast, /setAttribute\('aria-live','polite'\)/);
assert.match(toast, /setAttribute\('aria-atomic','true'\)/);
assert.match(toast, /isError \? 'alert' : 'status'/);

// Q07/Q08: enlarged text stays in viewport; transparent targets reach 44px without resizing visible icons.
assert.match(html, /\.detail-modal \{ width: min\(340px, calc\(100vw - 24px\)\); max-height: min\(78vh, 680px\); overflow-y: auto; overflow-x:hidden; \}/);
assert.match(html, /\.toast \{ max-width: min\(340px, calc\(100vw - 24px\)\); white-space: normal; overflow-wrap: anywhere;/);
assert.match(html, /\.icon-button::after \{ content:""; position:absolute; width:44px; height:44px;/);
assert.match(html, /\.emotion-expression \{ min-width:44px; min-height:44px;/);
assert.match(html, /\.lucide-icon \{ display:inline-flex; width:1em; height:1em;/);

// D01: the state supports no more than three active growth domains, with multiple goals in the current domain and no fake empty-slot card.
assert.match(html, /domains:\s*\[\{ id:'physical', name:'体能', active:true \}\]/);
assert.match(functionBody('activeGrowthDomainCount'), /domains\.filter\(domain => domain\.active\)\.length/);
assert.match(functionBody('goalCountForDomain'), /goal\.domainId === domainId/);
assert.match(functionBody('openGoalSwitcher'), /最多3个活跃成长域；每个成长域可包含多个目标/);
assert.doesNotMatch(html, /新增目标（已达上限，请先删除）/);
assert.doesNotMatch(html, /告诉我你想提升什么，AI 帮你理清方向/);

// D02: goal evidence is collapsed by default and includes baseline source, update time, completion rule, and change impact.
assert.equal((html.match(/<details class="goal-evidence">/g) || []).length, 3);
for (const contract of ['为何设定 / 查看依据', '基线来源：', '更新时间：', '完成规则：', '影响摘要：']) assert.ok(html.includes(contract), `missing D02 contract: ${contract}`);
assert.doesNotMatch(html, /<details class="goal-evidence" open/);

// D05: only detailed training completion asks for safety context; RPE stores pain and quality and acute pain pauses the action with reason/alternative/review.
assert.match(html, /id="rpePainLevel" type="number" min="0" max="10"/);
assert.match(html, /id="rpeQuality"/);
assert.match(functionBody('readSafetyInputs'), /pain/);
const completion = functionBody('completePendingAction');
assert.match(completion, /acute\s*=\s*safety\.pain\s*>=\s*7/);
assert.match(completion, /safetyOverrides/);
for (const safetyText of ['已暂停危险动作', '原因：', '替代：', '复评：']) assert.ok(completion.includes(safetyText), `missing safety intervention ${safetyText}`);
assert.match(completion, /commitMutation/);

// D06: users can always edit time, scene, and real-world constraints; Atlas autonomously rearranges the plan without adoption/approval actions.
const goalConstraints = functionBody('saveGoalConstraints');
for (const field of ['egTime', 'egScene', 'egConstraint']) assert.ok(functionBody('editGoal').includes(field), `missing constraint field ${field}`);
assert.match(goalConstraints, /state\.plan\.constraint/);
assert.match(goalConstraints, /Atlas 将自动重排训练计划/);
assert.doesNotMatch(functionBody('editGoal'), /采纳|审批/);
assert.doesNotMatch(functionBody('sendAIMsg'), /确认，创建目标|确认后即可开始训练/);

// D08: metric detail includes source/window/update/sufficiency and explicitly exposes a learning state when evidence is insufficient.
const evidenceRows = functionBody('metricEvidenceRows');
for (const label of ['来源', '数据窗口', '更新时间', '充分度']) assert.ok(evidenceRows.includes(label), `missing metric evidence label ${label}`);
assert.match(evidenceRows, /学习态（仍需更多样本）|学习态（尚无历史样本）/);
assert.match(functionBody('showSnapshotDetail'), /metricEvidenceRows\(d\.key/);

// D07: the user only initiates injection; Atlas decides each item and explains its rationale with source version and sufficiency, without per-item approval controls.
assert.match(functionBody('requestKnowledgeInjection'), /commitMutation/);
assert.match(functionBody('requestKnowledgeInjection'), /requested:true/);
const injection = functionBody('showKnowledgeInjection');
assert.match(injection, /if \(!request\?\.requested\)/);
for (const token of ['v2026.06', 'sufficiency', 'Atlas 为何', '未进入计划']) assert.ok(injection.includes(token), `missing D07 token ${token}`);
assert.doesNotMatch(injection, /onclick="[^"]*(?:采纳|拒绝)|逐条确认/);
assert.match(html, /发起知识注入/);

// D09: ordinary completion never randomly impersonates a PR; celebration requires baseline, evidence record, and deduplication.
const qualification = functionBody('qualifyPREvidence');
assert.match(qualification, /baselineId/);
assert.match(qualification, /recordId/);
assert.match(qualification, /该成果已庆祝过/);
const celebration = functionBody('showPRCelebration');
assert.match(celebration, /qualifyPREvidence\(evidence\)/);
assert.match(celebration, /commitMutation/);
assert.doesNotMatch(celebration, /Math\.random/);
assert.match(celebration, /训练已完成；暂无新的 PR 证据/);

// D10: Atlas executes adjustments without approval; detail records source, evidence, before/after, impact, version, and immutable safety authority.
const adjustment = functionBody('showAdjustDetail');
for (const token of ['触发来源：', '依据：', '影响：', '调整前：', '调整后：', '版本记录：', '安全调整由规则独立执行']) assert.ok(adjustment.includes(token), `missing D10 token ${token}`);
assert.doesNotMatch(adjustment, /采纳建议|我自己调整|确认调整|撤销安全/);
assert.match(adjustment, /修改目标时间、场景或现实约束/);

// D11: the product forms goals from user wording and constraints; it does not define identity, roles, or a profile confirmation gate.
for (const forbidden of ['我现在是', '我想成为', '身份差距', '成长画像', '画像确认', '确认后开始旅程']) assert.ok(!html.includes(forbidden), `forbidden identity flow token ${forbidden}`);
const goalFlow = functionBody('sendAIMsg');
assert.match(goalFlow, /原话、现实约束和已有证据/);
assert.match(goalFlow, /可修改、可拒绝的目标候选/);
assert.match(functionBody('showOnboardDone'), /目标候选/);
assert.match(functionBody('showOnboardDone'), /修改目标/);
assert.match(functionBody('showOnboardDone'), /保存目标/);

console.log('v6-approved-remediation: PASS');

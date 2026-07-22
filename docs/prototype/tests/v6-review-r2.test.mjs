import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const html = fs.readFileSync(new URL('../primeatlas-prototype-v6-review-r2.html', import.meta.url), 'utf8');
const scripts = [...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/gi)].map(match => match[1]);
assert.ok(scripts.length, 'HTML must contain a script');
scripts.forEach((script, index) => assert.doesNotThrow(() => new vm.Script(script, { filename: `v6-review-r2#${index + 1}` })));

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

assert.match(html, /r0:\[\['A01'/);
assert.match(html, /r1:\[\['A04'/);
assert.match(html, /r2:\[\['F01'/);
const nav = functionBody('navItems');
assert.match(nav, /state\.mode==='r0'\)return\[\]/);
assert.match(nav, /\['journey','route','旅程'\],\['mine','user','我的'\]/);
assert.match(nav, /\['today','sun','今日'\],\['journey','route','旅程'\],\['domains','layers','成长域'\],\['mine','user','我的'\]/);
const navContext = { state: { mode: 'r0' } };
vm.createContext(navContext);
vm.runInContext(nav, navContext);
assert.equal(vm.runInContext('navItems().length', navContext), 0);
navContext.state.mode = 'r1';
assert.equal(vm.runInContext('navItems().length', navContext), 2);
navContext.state.mode = 'r2';
assert.equal(vm.runInContext('navItems().length', navContext), 4);

for (const id of ['A01','A02','A03','A04','A05','A06','A07','F01','F02','F03','F04','F05','F06','F07','F08','F09','F10','F11','F12']) {
  assert.ok(html.includes(`'${id}'`) || html.includes(`>${id} `), `missing reachable fixture ${id}`);
  assert.ok(html.includes(`function render${id}(`), `missing renderer ${id}`);
}

assert.match(functionBody('renderF01'), /direct-action/);
assert.match(functionBody('renderF04'), /直接开始行动/);
const pulseCase = functionBody('handleAction').match(/case'complete-pulse':[\s\S]*?break;/)?.[0] || '';
assert.match(pulseCase, /pulseCompleted=true/);
assert.doesNotMatch(pulseCase, /exerciseCompleted|fixture='F09'|go\('F09'\)/);
assert.match(functionBody('handleAction'), /case'skip-rpe':state\.r2\.rpe=\{status:'missing',value:null\}/);
assert.match(functionBody('handleAction'), /case'save-rpe':if\(state\.r2\.rpe\.value===null\)/);
assert.match(html, /const KNOWLEDGE_SOURCE=Object\.freeze\(\{id:'KS-014'/);
assert.match(html, /knowledgeSource:KNOWLEDGE_SOURCE/);
assert.match(functionBody('renderF10'), /state\.r2\.knowledgeSource/);
assert.match(functionBody('renderF11'), /state\.r2\.knowledgeSource/);
assert.match(functionBody('renderF10'), /未确认不会改计划/);
assert.match(functionBody('renderF11'), /Consent 已撤回/);

const userHydration = functionBody('hydrateUserText');
assert.match(userHydration, /textContent=state\.r0\.current/);
assert.match(userHydration, /textContent=state\.r0\.target/);
assert.doesNotMatch(userHydration, /innerHTML/);
assert.doesNotMatch(functionBody('bindDynamic'), /innerHTML/);

assert.match(html, /@container product \(min-width:600px\)/);
assert.match(html, /@container product \(min-width:840px\)/);
assert.match(html, /grid-template-columns:88px minmax\(0,1fr\)/);
assert.match(html, /adaptive-detail\{grid-template-columns/);
assert.match(html, /prefers-reduced-motion:reduce/);
assert.match(html, /maximum-scale=5/);
assert.match(html, /200% 文字/);

const emoji = /[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/u;
assert.doesNotMatch(html, emoji);
assert.doesNotMatch(html, /purple|pink|from-purple|to-pink/i);
assert.doesNotMatch(html, /Lorem ipsum|Welcome to|Sign up/i);
assert.doesNotMatch(html, /bounce|elastic/i);
assert.doesNotMatch(html, /backdrop-filter|background-clip\s*:\s*text/i);
assert.doesNotMatch(html, /linear-gradient|radial-gradient/i);

const css = html.match(/<style>([\s\S]*?)<\/style>/i)?.[1] || '';
const withoutTokens = css.replace(/:root\{[\s\S]*?\}\n\*/m, '*');
assert.doesNotMatch(withoutTokens, /#[0-9a-f]{3,8}/i, 'component CSS must use design tokens, not hex');
assert.doesNotMatch(withoutTokens, /rgba?\(/i, 'component CSS must use design tokens, not raw rgba');

assert.match(html, /<nav class="product-nav"/);
assert.match(html, /aria-live="polite"/);
assert.match(html, /focus-visible/);
assert.match(html, /min-height:44px/);
assert.match(functionBody('renderF08'), /图表等价列表/);
assert.match(functionBody('renderF09'), /文本步骤|<ol class="steps">/);

console.log('v6-review-r2: PASS');

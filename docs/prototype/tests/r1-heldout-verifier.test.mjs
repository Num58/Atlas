import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const v6 = fs.readFileSync(new URL('../primeatlas-prototype-v6.html', import.meta.url), 'utf8');
const review = fs.readFileSync(new URL('../primeatlas-review-prototype-v1.0.html', import.meta.url), 'utf8');

function functionSource(source, name) {
  const start = source.indexOf(`function ${name}(`);
  assert.notEqual(start, -1, `missing function ${name}`);
  const open = source.indexOf('{', start);
  let depth = 0;
  let quote = '';
  let escaped = false;
  for (let i = open; i < source.length; i += 1) {
    const c = source[i];
    if (quote) {
      if (escaped) escaped = false;
      else if (c === '\\') escaped = true;
      else if (c === quote) quote = '';
      continue;
    }
    if (c === "'" || c === '"' || c === '`') { quote = c; continue; }
    if (c === '{') depth += 1;
    if (c === '}') depth -= 1;
    if (depth === 0) return source.slice(start, i + 1);
  }
  throw new Error(`unterminated function ${name}`);
}

function context(extra = {}) {
  const sandbox = { console, structuredClone, Set, Date, JSON, Object, Error, ...extra };
  vm.createContext(sandbox);
  return sandbox;
}

function run(ctx, source) { return vm.runInContext(source, ctx); }
function json(value) { return JSON.stringify(value); }

const results = [];
async function test(name, fn) {
  try { await fn(); results.push({ name, ok: true }); }
  catch (error) { results.push({ name, ok: false, error }); }
}

await test('P0-02 actual appendAITextBubble treats held-out payload as text', () => {
  class Element {
    constructor(tag) { this.tagName = tag.toUpperCase(); this.children = []; this.style = {}; this.attributes = {}; this._text = ''; this.scrollTop = 0; this.scrollHeight = 0; }
    set textContent(value) { this._text = String(value); this.children = []; }
    get textContent() { return this._text + this.children.map(x => x.textContent).join(''); }
    appendChild(child) { this.children.push(child); return child; }
    addEventListener(type, handler) { this.attributes[`listener:${type}`] = handler; }
  }
  const container = new Element('div');
  const document = { getElementById: id => id === 'aich' ? container : null, createElement: tag => new Element(tag), createTextNode: text => { const node = new Element('#text'); node.textContent = text; return node; } };
  const ctx = context({ document });
  run(ctx, functionSource(v6, 'appendAITextBubble'));
  const payload = '<img src=x onerror=globalThis.__xss=1><script>globalThis.__xss=2</script>';
  run(ctx, `appendAITextBubble(${JSON.stringify(payload)}, true)`);
  const all = [];
  const walk = node => { all.push(node); node.children.forEach(walk); };
  walk(container);
  assert.equal(container.textContent, payload);
  assert.equal(ctx.__xss, undefined);
  assert.equal(all.some(x => ['IMG', 'SCRIPT'].includes(x.tagName)), false);
  assert.equal(all.some(x => Object.keys(x.attributes).some(k => /^on/i.test(k))), false);
});

for (const errorName of ['QuotaExceededError', 'SecurityError']) {
  await test(`P0-04 actual persist handles ${errorName} without input/savedAt loss`, () => {
    const state = { identityDraft: { current: 'held-out input' }, localSave: { status: 'committed', savedAt: '2026-01-01T00:00:00Z', error: null }, research: { events: [] } };
    const localStorage = { setItem() { const e = new Error(errorName); e.name = errorName; throw e; } };
    const ctx = context({ localStorage, renderStatus() {} });
    run(ctx, `var prototypeState=${json(state)}; const STORAGE_KEY='held-out'; const clone=x=>JSON.parse(JSON.stringify(x)); ${functionSource(review, 'persistedState')} ${functionSource(review, 'persistenceError')} ${functionSource(review, 'persist')}`);
    const beforeInput = run(ctx, 'prototypeState.identityDraft.current');
    const result = run(ctx, `persist('committed')`);
    assert.equal(result.ok, false);
    assert.equal(run(ctx, 'prototypeState.identityDraft.current'), beforeInput);
    assert.equal(run(ctx, 'prototypeState.localSave.savedAt'), '2026-01-01T00:00:00Z');
    assert.equal(run(ctx, 'prototypeState.localSave.status'), 'save_error');
  });
}

await test('P0-04 actual startup recovery isolates malformed JSON and keeps initial input', () => {
  const startup = review.match(/try\{const raw=localStorage\.getItem\(STORAGE_KEY\)[\s\S]*?\}\s*catch\(error\)\{prototypeState\.localSave=[\s\S]*?\}\s*(?=parseHash\(\))/)?.[0];
  assert.ok(startup, 'startup recovery statement not found');
  const ctx = context({ localStorage: { getItem: () => '{bad json' } });
  run(ctx, `var prototypeState={identityDraft:{current:'initial input'},localSave:{status:'committed',savedAt:'before',error:null}}; const STORAGE_KEY='held-out'; ${functionSource(review, 'persistenceError')}`);
  assert.doesNotThrow(() => run(ctx, startup));
  assert.equal(run(ctx, 'prototypeState.identityDraft.current'), 'initial input');
  assert.equal(run(ctx, 'prototypeState.localSave.savedAt'), 'before');
  assert.equal(run(ctx, 'prototypeState.localSave.status'), 'save_error');
});

for (const fixture of ['timeout', 'limit', 'invalid-response']) {
  await test(`P0-05 actual runAssistedFailure ${fixture} preserves formal state`, () => {
    const state = { identityDraft: { current: `input-${fixture}`, answer: '<held-out>' }, portraitVersions: [{ id: 'v1', status: 'active' }], dependency: { audit: [{ id: 'a1' }], operationLedger: [{ id: 'o1' }], assistedFixture: null } };
    const ctx = context({ persist: () => ({ ok: true }), toast() {}, log() {}, renderA0() {} });
    run(ctx, `var prototypeState=${json(state)}; ${functionSource(review, 'runAssistedFailure')}`);
    const before = run(ctx, `JSON.stringify({input:prototypeState.identityDraft,versions:prototypeState.portraitVersions,audit:prototypeState.dependency.audit,ledger:prototypeState.dependency.operationLedger})`);
    run(ctx, `runAssistedFailure('${fixture}')`);
    const after = run(ctx, `JSON.stringify({input:prototypeState.identityDraft,versions:prototypeState.portraitVersions,audit:prototypeState.dependency.audit,ledger:prototypeState.dependency.operationLedger})`);
    assert.equal(after, before);
    assert.equal(run(ctx, 'prototypeState.dependency.assistedFixture.formalDelta'), 0);
  });
}

await test('P0-06 actual resolve transaction rolls all formal/conflict state back on persist failure', () => {
  const state = {
    portraitVersions: [{ id: 'v1', kind: 'confirmed', status: 'historical' }, { id: 'v2', kind: 'current', status: 'active' }],
    localVersionConflict: { baseVersionId: 'v1', currentVersionId: 'v2', status: 'conflict' },
    route: { selectedVersionId: 'v1' },
    dependency: { audit: [{ id: 'a1' }], operationLedger: [{ id: 'o1' }], versionSequence: 2, conflictFailureFixture: false }
  };
  const toasts = [];
  const ctx = context({ clone: x => structuredClone(x), persist: () => ({ ok: false }), toast: x => toasts.push(x), log() {}, renderA0() {} });
  run(ctx, `var prototypeState=${json(state)}; ${functionSource(review, 'runVersionTransaction')} ${functionSource(review, 'resolveVersionConflict')}`);
  const before = run(ctx, `JSON.stringify({versions:prototypeState.portraitVersions,audit:prototypeState.dependency.audit,ledger:prototypeState.dependency.operationLedger,sequence:prototypeState.dependency.versionSequence,selected:prototypeState.route.selectedVersionId,conflict:prototypeState.localVersionConflict})`);
  const result = run(ctx, `resolveVersionConflict('merge')`);
  const after = run(ctx, `JSON.stringify({versions:prototypeState.portraitVersions,audit:prototypeState.dependency.audit,ledger:prototypeState.dependency.operationLedger,sequence:prototypeState.dependency.versionSequence,selected:prototypeState.route.selectedVersionId,conflict:prototypeState.localVersionConflict})`);
  assert.equal(result.ok, false);
  assert.equal(after, before);
  assert.equal(toasts.some(x => /已按用户选择创建|active/.test(x)), false);
});

await test('P0-04/P0-06 actual atomicConfirm rolls back and does not announce success on persist failure', () => {
  const state = { identityDraft: { status: 'editing', confirmedVersionId: null }, portraitVersions: [], dependency: { audit: [], operationLedger: [], versionSequence: 0, maxA0Step: 5, transactionStatus: 'idle', atomicFailureFixture: false } };
  const toasts = [];
  const ctx = context({ clone: x => structuredClone(x), persist: () => ({ ok: false }), toast: x => toasts.push(x), log() {}, renderA0() {}, unlock(step) { ctx.prototypeState.dependency.maxA0Step = Math.max(ctx.prototypeState.dependency.maxA0Step, step); } });
  run(ctx, `var prototypeState=${json(state)}; ${functionSource(review, 'atomicConfirm')}`);
  const before = run(ctx, `JSON.stringify({identity:prototypeState.identityDraft,versions:prototypeState.portraitVersions,audit:prototypeState.dependency.audit,ledger:prototypeState.dependency.operationLedger,sequence:prototypeState.dependency.versionSequence,max:prototypeState.dependency.maxA0Step})`);
  run(ctx, 'atomicConfirm()');
  const after = run(ctx, `JSON.stringify({identity:prototypeState.identityDraft,versions:prototypeState.portraitVersions,audit:prototypeState.dependency.audit,ledger:prototypeState.dependency.operationLedger,sequence:prototypeState.dependency.versionSequence,max:prototypeState.dependency.maxA0Step})`);
  assert.equal(after, before);
  assert.equal(toasts.some(x => /已原子提交/.test(x)), false);
});

await test('P0-07 actual repository fixture removes inactive domain everywhere and preserves other-domain hashes', () => {
  const state = {
    domains: [{ id: 'physical', active: true }, { id: 'language', active: true }, { id: 'inactive', active: false }],
    goals: [{ id: 'gp', domainId: 'physical' }, { id: 'gl', domainId: 'language' }, { id: 'gx', domainId: 'inactive' }],
    milestones: [{ id: 'mp', goalId: 'gp' }, { id: 'ml', goalId: 'gl' }, { id: 'mx', goalId: 'gx' }],
    metrics: [{ id: 'kp', domainId: 'physical' }, { id: 'kl', domainId: 'language' }, { id: 'kx', domainId: 'inactive' }],
    agentContext: [{ id: 'ap', domainId: 'physical' }, { id: 'al', domainId: 'language' }, { id: 'ax', domainId: 'inactive' }]
  };
  const ctx = context({ clone: x => structuredClone(x) });
  run(ctx, `var prototypeState=${json(state)}; ${['activeDomainIds','filterActiveDomains','activeDomains','activeGoals','activeMilestones','activeMetrics','activeAgentContext','activeResearchExport','activeRepositoryFixture'].map(n => functionSource(review,n)).join('\n')}`);
  const fixture = run(ctx, 'activeRepositoryFixture()');
  for (const [name, items] of Object.entries(fixture)) {
    assert.equal(items.some(x => x.domainId === 'inactive' || x.id?.endsWith('x')), false, `${name} leaked inactive`);
  }
  assert.deepEqual(JSON.parse(json(fixture.goals.map(x => x.id))), ['gp', 'gl']);
  assert.deepEqual(JSON.parse(json(fixture.milestones.map(x => x.id))), ['mp', 'ml']);
  assert.deepEqual(JSON.parse(json(fixture.metrics.map(x => x.id))), ['kp', 'kl']);
  assert.deepEqual(JSON.parse(json(fixture.agentContext.map(x => x.id))), ['ap', 'al']);
  assert.deepEqual(JSON.parse(json(fixture.researchExport.map(x => x.id))), ['ap', 'al']);
});

await test('P0-04 goA0 must not advance or report route change when persist fails', () => {
  const logs = [];
  const ctx = context({ persist: () => ({ ok: false }), render() {}, log: (...x) => logs.push(x), a0Page: () => ({ key: 'step-4' }) });
  run(ctx, `var prototypeState={route:{a0Step:3,view:'root'}}; ${functionSource(review, 'goA0')}`);
  run(ctx, 'goA0(4)');
  assert.equal(run(ctx, 'prototypeState.route.a0Step'), 3, 'route advanced despite persistence failure');
  assert.equal(logs.some(x => x[0] === 'route_changed'), false, 'route success was logged despite persistence failure');
});

await test('P0-04 confirm-milestones must roll back/unlock nothing when persist fails', () => {
  const state = { route: { a0Step: 8 }, domains: [{ id: 'physical', active: true }], goals: [{ id: 'g1', domainId: 'physical', status: 'candidate' }], milestones: [{ id: 'm1', goalId: 'g1', status: 'candidate' }], dependency: { maxA0Step: 8 } };
  const logs = [];
  const ctx = context({
    persist: () => ({ ok: false }), toast() {}, renderA0() {}, render() {},
    log: (...x) => logs.push(x),
    activeDomains: () => ctx.prototypeState.domains.filter(x => x.active),
    unlock: step => { ctx.prototypeState.dependency.maxA0Step = Math.max(ctx.prototypeState.dependency.maxA0Step, step); },
    goA0: step => { ctx.prototypeState.route.a0Step = step; return { ok: false }; },
    $: () => null
  });
  run(ctx, `var prototypeState=${json(state)}; ${functionSource(review, 'handleAction')}`);
  run(ctx, `handleAction({currentTarget:{dataset:{action:'confirm-milestones'}}})`);
  assert.equal(run(ctx, 'prototypeState.goals[0].status'), 'candidate');
  assert.equal(run(ctx, 'prototypeState.milestones[0].status'), 'candidate');
  assert.equal(run(ctx, 'prototypeState.dependency.maxA0Step'), 8);
  assert.equal(run(ctx, 'prototypeState.route.a0Step'), 8);
  assert.equal(logs.some(x => x[0] === 'milestones' && x[1] === 'confirmed'), false);
});

await test('P0-04 save-draft does not toast success when persist fails', () => {
  const toasts = [];
  const ctx = context({ persist: () => ({ ok: false }), toast: x => toasts.push(x), log() {}, renderA0() {}, $: () => null });
  run(ctx, `var prototypeState={}; ${functionSource(review, 'handleAction')}`);
  run(ctx, `handleAction({currentTarget:{dataset:{action:'save-draft'}}})`);
  assert.equal(toasts.some(x => /草稿已保存/.test(x)), false);
});

for (const result of results) {
  console.log(`${result.ok ? 'PASS' : 'FAIL'} ${result.name}`);
  if (!result.ok) console.log(`  ${result.error?.stack || result.error}`);
}
const failures = results.filter(x => !x.ok);
console.log(`heldout-verifier: ${results.length - failures.length}/${results.length} passed`);
if (failures.length) process.exitCode = 1;

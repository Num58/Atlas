import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const files = {
  v6: path.resolve(here, '..', 'primeatlas-prototype-v6.html'),
  review: path.resolve(here, '..', 'primeatlas-review-prototype-v1.0.html'),
};
const html = Object.fromEntries(Object.entries(files).map(([key, value]) => [key, fs.readFileSync(value, 'utf8')]));

function scripts(source) {
  return [...source.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/gi)].map(match => match[1]);
}

function functionBody(source, name) {
  const start = source.indexOf(`function ${name}(`);
  assert.notEqual(start, -1, `missing function ${name}`);
  const open = source.indexOf('{', start);
  let depth = 0;
  for (let index = open; index < source.length; index += 1) {
    if (source[index] === '{') depth += 1;
    if (source[index] === '}') depth -= 1;
    if (depth === 0) return source.slice(start, index + 1);
  }
  throw new Error(`unterminated function ${name}`);
}

for (const [name, source] of Object.entries(html)) {
  const blocks = scripts(source);
  assert.ok(blocks.length > 0, `${name} must contain script`);
  blocks.forEach((script, index) => assert.doesNotThrow(() => new vm.Script(script, { filename: `${name}#script-${index + 1}` })));
}

const userBubble = functionBody(html.v6, 'appendAITextBubble');
const sendAI = functionBody(html.v6, 'sendAIMsg');
assert.match(userBubble, /bubble\.textContent\s*=\s*msg/);
assert.match(userBubble, /appendChild\(bubble\)/);
assert.doesNotMatch(userBubble, /innerHTML/);
assert.match(sendAI, /appendAITextBubble\(userMsg,\s*true\)/);
assert.doesNotMatch(sendAI, /innerHTML\s*=.*userMsg/);
const xssPayload = '<img src=x onerror=globalThis.__xss=1>';
const bubble = { textContent: '', children: [], appendChild(child) { this.children.push(child); } };
bubble.textContent = xssPayload;
assert.equal(bubble.textContent, xssPayload);
assert.equal(globalThis.__xss, undefined);

assert.match(html.v6, /let selectedRPE\s*=\s*null/);
assert.match(functionBody(html.v6, 'confirmRPE'), /if\s*\(selectedRPE\s*===\s*null\)[\s\S]*return/);
assert.match(functionBody(html.v6, 'skipRPE'), /\{\s*status:\s*'missing',\s*value:\s*null\s*\}/);

const persist = functionBody(html.review, 'persist');
assert.match(persist, /catch\s*\(error\)/);
assert.match(persist, /status:\s*'save_error'/);
assert.match(persist, /savedAt:\s*previous\.savedAt/);
assert.match(persist, /return\s*\{\s*ok:false/);
for (const fixture of [
  Object.assign(new Error('quota'), { name: 'QuotaExceededError' }),
  Object.assign(new Error('security'), { name: 'SecurityError' }),
]) {
  const memory = { value: 'kept', localSave: { status: 'committed', savedAt: 'before', error: null } };
  const previous = structuredClone(memory.localSave);
  try { throw fixture; } catch (error) {
    memory.localSave = { status: 'save_error', savedAt: previous.savedAt, error: { name: error.name } };
  }
  assert.equal(memory.value, 'kept');
  assert.equal(memory.localSave.savedAt, 'before');
  assert.equal(memory.localSave.status, 'save_error');
}
assert.throws(() => JSON.parse('{bad json'));
assert.match(html.review, /persistenceError/);
assert.match(html.review, /JSON\.parse\(raw\)[\s\S]*catch\s*\(error\)[\s\S]*save_error/);
const saveDraftCase = html.review.match(/case'save-draft':[\s\S]*?break\}/)?.[0] || '';
assert.match(saveDraftCase, /if\s*\(saved\.ok\)\s*\{toast\('草稿已保存到本机'\)/);

const assisted = functionBody(html.review, 'runAssistedFailure');
for (const fixture of ['timeout', 'limit', 'invalid-response']) assert.ok(assisted.includes(`'${fixture}'`));
assert.match(assisted, /inputHash:before/);
assert.match(assisted, /versions:[^,]+,audit:[^,]+,operationLedger:/);
assert.match(assisted, /formalDelta:0/);
assert.match(html.review, /data-action="manual-draft"/);
assert.match(html.review, /case'manual-draft':unlock\(4\);goA0\(4\)/);

const conflictSeed = functionBody(html.review, 'seedVersionConflict');
const conflictResolve = functionBody(html.review, 'resolveVersionConflict');
const versionTx = functionBody(html.review, 'runVersionTransaction');
assert.match(conflictSeed, /Object\.freeze\(clone\(active\)\)/);
assert.match(conflictSeed, /baseVersion:Object\.freeze\(base\)/);
assert.match(conflictSeed, /currentVersion:Object\.freeze/);
assert.match(conflictSeed, /staleWriteStatus:'rejected'/);
assert.match(conflictResolve, /status:'active'/);
assert.doesNotMatch(conflictResolve, /last[-_ ]?write|LWW/i);
for (const token of ['portraitVersions', 'audit', 'operationLedger', 'versionSequence']) assert.ok(versionTx.includes(token));
assert.match(versionTx, /if\(!saved\.ok\)throw/);
assert.match(versionTx, /prototypeState\.portraitVersions=before\.portraitVersions/);
assert.match(versionTx, /prototypeState\.dependency\.audit=before\.audit/);
assert.match(versionTx, /prototypeState\.dependency\.operationLedger=before\.operationLedger/);

for (const name of ['activeGoals', 'activeMilestones', 'activeMetrics', 'activeAgentContext', 'activeResearchExport']) {
  assert.ok(html.review.includes(`function ${name}(`), `${name} must exist`);
}
const filter = items => {
  const ids = new Set(['physical', 'language']);
  return items.filter(item => ids.has(item.domainId));
};
assert.deepEqual(filter([{ domainId: 'physical' }, { domainId: 'inactive' }]), [{ domainId: 'physical' }]);
assert.match(functionBody(html.review, 'activeRepositoryFixture'), /goals:activeGoals\(\),milestones:activeMilestones\(\),metrics:activeMetrics\(\),agentContext:activeAgentContext\(\),researchExport:activeResearchExport\(\)/);

assert.match(html.review, /const A0_RELEASE_REGISTRY=/);
assert.match(html.review, /const FUTURE_RESEARCH_REGISTRY=/);
const releaseRegion = html.review.slice(html.review.indexOf('const A0_RELEASE_REGISTRY='), html.review.indexOf('const A1_TASKS='));
assert.doesNotMatch(releaseRegion, /outbox|sync|toggle-sync|待同步|tombstone|worker|cursor/i);
for (const status of ['committed', 'rejected', 'conflict', 'action_required']) assert.ok(html.review.includes(status), `missing local status ${status}`);
assert.ok(html.review.includes('operationLedger'));
assert.ok(html.review.includes('localVersionConflict'));
const reviewScript = scripts(html.review).join('\n');
assert.doesNotMatch(reviewScript, /outbox|toggle-sync|tombstone|\bworker\b|\bcursor\b/i);

console.log('r1-regression: PASS');

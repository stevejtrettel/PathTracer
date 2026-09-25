// Render comparison: renders every scene small and short, and compares the
// result with a baked reference image in render-tests/baselines/.
//
//   node scripts/render-diff.mjs                  compare every scene
//   node scripts/render-diff.mjs glassball gem    compare just these
//   node scripts/render-diff.mjs --bake [...]     (re)write the references from the current code
//   options: --frames N (default 32)   --size WxH (default 160x120)
//
// Each scene gets a verdict:
//   identical   same bytes as the reference
//   rounding    a handful of pixels differ (<2%), brightness unchanged: float
//               rounding moved, nothing real did
//   CHANGED     the render differs; brightness and structure deltas are printed
//               and a side-by-side (reference | now | 4x difference) is written
//               to render-tests/diff/<scene>.png. "(looks like noise)" means the
//               same picture with different samples: brightness and 8x8 block
//               averages barely moved (a recompile can reorder float ops)
//   unstable    the scene doesn't render the same twice on this machine (checked
//               by rendering it again), so it can't be compared
//   FAILED      shader/JS error or timeout
//
// Why this works: the tracer is deterministic — the same code on the same
// machine renders the same bytes every time (seed = pixel + frame). So an
// engine change that shouldn't alter anything must come back `identical` or
// `rounding`, and anything else is a real change to look at. The references
// are only meaningful on the machine (GPU + Chrome) that baked them; the
// script warns when that differs. Rebake deliberately, after looking.
//
// No dependencies: it drives your installed Chrome (CHROME_BIN overrides the
// path) over the DevTools protocol with Node's built-in WebSocket, and serves
// the scenes with the project's own vite config.
import { spawn } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { createServer } from 'vite';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const baseDir = path.join(root, 'render-tests', 'baselines');
const diffDir = path.join(root, 'render-tests', 'diff');
const machineFile = path.join(baseDir, 'machine.txt');

const chrome =
  process.env.CHROME_BIN ??
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

//---- arguments -----------------------------------------------------------
const args = process.argv.slice(2);
let bake = false, frames = 32, W = 160, H = 120;
const wanted = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--bake') bake = true;
  else if (args[i] === '--frames') frames = parseInt(args[++i], 10);
  else if (args[i] === '--size') [W, H] = args[++i].split('x').map((n) => parseInt(n, 10));
  else wanted.push(args[i]);
}
if (!(frames > 0) || !(W > 0) || !(H > 0)) {
  console.error('usage: node scripts/render-diff.mjs [--bake] [--frames N] [--size WxH] [scene...]');
  process.exit(1);
}

const allScenes = readdirSync(path.join(root, 'scenes'), { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(path.join(root, 'scenes', d.name, 'main.js')))
  .map((d) => d.name)
  .sort();
for (const s of wanted) {
  if (!allScenes.includes(s)) { console.error(`Scene not found: ${s}`); process.exit(1); }
}
const scenes = wanted.length ? wanted : allScenes;
if (!existsSync(chrome)) { console.error(`Chrome not found at ${chrome} (set CHROME_BIN)`); process.exit(1); }


//---- runs in each page before its scripts: hold the render loop until the
//---- sky image has loaded (its onload restarts accumulation), then let
//---- exactly `frames` frames through and stop. Only the loop named
//---- `animate` (createScene.js) is counted; the UI's refresh loop runs free.
const pageSetup = (frames) => `(() => {
  const realRAF = window.requestAnimationFrame.bind(window);
  const RealImage = window.Image;
  let pending = 0, started = false, n = 0;
  const held = [];
  window.Image = function (...a) {
    const img = new RealImage(...a);
    pending++;
    const done = () => { pending--; };
    img.addEventListener('load', done);
    img.addEventListener('error', done);
    return img;
  };
  window.Image.prototype = RealImage.prototype;
  window.__rd = { done: false };
  window.requestAnimationFrame = (cb) => {
    if (cb.name !== 'animate') return realRAF(cb);
    if (!started) { held.push(cb); return 0; }
    if (n >= ${frames}) { window.__rd.done = true; return 0; }
    n++;
    return realRAF(cb);
  };
  const tryStart = () => {
    if (document.readyState !== 'complete' || pending > 0) { setTimeout(tryStart, 50); return; }
    started = true;
    held.splice(0).forEach((cb) => { n++; realRAF(cb); });
  };
  setTimeout(tryStart, 50);
})();`;

//---- runs in a page: compare two PNG data URLs; returns stats (and the
//---- side-by-side as a data URL when they differ)
async function comparePngs(refUrl, nowUrl) {
  const load = (u) => new Promise((res, rej) => { const i = new Image(); i.onload = () => res(i); i.onerror = rej; i.src = u; });
  const [a, b] = await Promise.all([load(refUrl), load(nowUrl)]);
  if (a.width !== b.width || a.height !== b.height) {
    return { size: `${a.width}x${a.height} vs ${b.width}x${b.height}` };
  }
  const w = a.width, h = a.height;
  const c = document.createElement('canvas');
  c.width = 3 * w; c.height = h;
  const g = c.getContext('2d', { willReadFrequently: true });
  g.drawImage(a, 0, 0); g.drawImage(b, w, 0);
  const A = g.getImageData(0, 0, w, h).data, B = g.getImageData(w, 0, w, h).data;
  const D = g.createImageData(w, h);
  const blk = 8, bw = Math.ceil(w / blk), bh = Math.ceil(h / blk);
  const ba = new Float64Array(bw * bh), bb = new Float64Array(bw * bh), bn = new Float64Array(bw * bh);
  let diffPx = 0, sumA = 0, sumB = 0;
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
    const i = 4 * (y * w + x);
    let d = 0, la = 0, lb = 0;
    for (let k = 0; k < 3; k++) {
      d = Math.max(d, Math.abs(A[i + k] - B[i + k]));
      la += A[i + k]; lb += B[i + k];
      D.data[i + k] = Math.min(255, 4 * Math.abs(A[i + k] - B[i + k]));
    }
    D.data[i + 3] = 255;
    if (d > 0) diffPx++;
    sumA += la; sumB += lb;
    const j = Math.floor(y / blk) * bw + Math.floor(x / blk);
    ba[j] += la; bb[j] += lb; bn[j] += 3;
  }
  //structure: mean |difference| of 8x8 block averages, as % of full scale.
  //Reshuffled noise mostly averages out here; moved or re-lit geometry doesn't.
  let s = 0;
  for (let j = 0; j < ba.length; j++) s += Math.abs(ba[j] - bb[j]) / bn[j];
  const n = w * h;
  const out = {
    diffPct: 100 * diffPx / n,
    meanRef: sumA / (3 * n),
    meanNow: sumB / (3 * n),
    structure: 100 * s / ba.length / 255,
  };
  if (diffPx > 0) { g.putImageData(D, 2 * w, 0); out.image = c.toDataURL('image/png'); }
  return out;
}


//---- minimal DevTools-protocol client ----------------------------------------
async function launchChrome() {
  const profile = mkdtempSync(path.join(tmpdir(), 'render-diff-'));
  const flags = [
    '--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars', '--mute-audio',
    '--enable-gpu', '--ignore-gpu-blocklist', '--enable-unsafe-swiftshader',
    ...(process.platform === 'darwin' ? ['--use-angle=metal'] : []),
    'about:blank',
  ];
  const proc = spawn(chrome, flags, { stdio: ['ignore', 'ignore', 'pipe'] });
  const wsUrl = await new Promise((resolve, reject) => {
    let err = '';
    const t = setTimeout(() => reject(new Error('Chrome did not start: ' + err.slice(-500))), 20000);
    proc.stderr.on('data', (d) => {
      err += d;
      const m = err.match(/DevTools listening on (ws:\/\/\S+)/);
      if (m) { clearTimeout(t); resolve(m[1]); }
    });
    proc.on('exit', (code) => reject(new Error(`Chrome exited (${code}): ` + err.slice(-500))));
  });
  const ws = new WebSocket(wsUrl);
  await new Promise((res, rej) => { ws.onopen = res; ws.onerror = () => rej(new Error('DevTools connection failed')); });
  let nextId = 1;
  const waiting = new Map(), listeners = [];
  ws.onmessage = (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && waiting.has(msg.id)) {
      const { resolve, reject } = waiting.get(msg.id);
      waiting.delete(msg.id);
      msg.error ? reject(new Error(msg.error.message)) : resolve(msg.result);
    } else if (msg.method) {
      for (const fn of listeners) fn(msg);
    }
  };
  const send = (method, params = {}, sessionId) => new Promise((resolve, reject) => {
    const id = nextId++;
    waiting.set(id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params, ...(sessionId ? { sessionId } : {}) }));
  });
  const close = () => {
    try { ws.close(); } catch {}
    proc.kill();
    try { rmSync(profile, { recursive: true, force: true }); } catch {}
  };
  return { send, listeners, close };
}

//evaluate an expression in a page session and return its value
async function evaluate(cdp, sessionId, expression) {
  const r = await cdp.send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }, sessionId);
  if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description ?? r.exceptionDetails.text);
  return r.result.value;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const png = (dataUrl) => Buffer.from(dataUrl.split(',')[1], 'base64');
const dataUrl = (file) => 'data:image/png;base64,' + readFileSync(file).toString('base64');


//---- main ---------------------------------------------------------------------
//a private vite cache, so a dev server you have running is left alone
const server = await createServer({
  root, configFile: path.join(root, 'vite.config.js'), logLevel: 'error',
  cacheDir: path.join(root, 'render-tests', '.vite'),
  server: { port: 0, host: '127.0.0.1' },
});
await server.listen();
const port = server.httpServer.address().port;
const cdp = await launchChrome();

let failed = 0, changed = 0, unstable = 0, machine = null;
mkdirSync(baseDir, { recursive: true });
if (!bake) rmSync(diffDir, { recursive: true, force: true });

//render one scene in a fresh tab; resolves to the canvas as a PNG data URL,
//rejects on a shader/JS error or a timeout
async function renderScene(scene) {
  const { targetId } = await cdp.send('Target.createTarget', { url: 'about:blank' });
  const { sessionId } = await cdp.send('Target.attachToTarget', { targetId, flatten: true });
  const errors = [];
  const onEvent = (msg) => {
    if (msg.sessionId !== sessionId) return;
    if (msg.method === 'Runtime.exceptionThrown') {
      errors.push(msg.params.exceptionDetails.exception?.description ?? msg.params.exceptionDetails.text);
    } else if (msg.method === 'Runtime.consoleAPICalled' && msg.params.type === 'error') {
      errors.push(msg.params.args.map((a) => a.value ?? a.description ?? '').join(' '));
    }
  };
  cdp.listeners.push(onEvent);
  try {
    await cdp.send('Runtime.enable', {}, sessionId);
    await cdp.send('Page.enable', {}, sessionId);
    await cdp.send('Emulation.setDeviceMetricsOverride', { width: W, height: H, deviceScaleFactor: 1, mobile: false }, sessionId);
    await cdp.send('Page.addScriptToEvaluateOnNewDocument', { source: pageSetup(frames) }, sessionId);
    await cdp.send('Page.navigate', { url: `http://127.0.0.1:${port}/scenes/${scene}/` }, sessionId);

    const deadline = Date.now() + 180000;
    while (!(await evaluate(cdp, sessionId, 'window.__rd && window.__rd.done')) && !errors.length) {
      if (Date.now() > deadline) throw new Error(`timed out rendering ${frames} frames`);
      await sleep(100);
    }
    if (errors.length) throw new Error(errors[0].split('\n').slice(0, 4).join(' | '));

    machine ??= product + ' | ' + await evaluate(cdp, sessionId, `(() => {
      const gl = document.createElement('canvas').getContext('webgl2');
      const ext = gl && gl.getExtension('WEBGL_debug_renderer_info');
      return ext ? gl.getParameter(ext.UNMASKED_RENDERER_WEBGL) : 'unknown GPU';
    })()`);
    return await evaluate(cdp, sessionId, `document.querySelector('body > canvas').toDataURL('image/png')`);
  } finally {
    cdp.listeners.splice(cdp.listeners.indexOf(onEvent), 1);
    await cdp.send('Target.closeTarget', { targetId }).catch(() => {});
  }
}

//comparisons run in one blank tab of their own
const { product } = await cdp.send('Browser.getVersion');
const cmpTarget = (await cdp.send('Target.createTarget', { url: 'about:blank' })).targetId;
const cmpSession = (await cdp.send('Target.attachToTarget', { targetId: cmpTarget, flatten: true })).sessionId;
const compare = (a, b) => evaluate(cdp, cmpSession, `(${comparePngs.toString()})(${JSON.stringify(a)}, ${JSON.stringify(b)})`);

try {
  for (const scene of scenes) {
    const t0 = Date.now();
    let verdict, detail = '';
    try {
      const now = await renderScene(scene);
      const ref = path.join(baseDir, `${scene}.png`);

      if (bake) {
        writeFileSync(ref, png(now));
        verdict = 'baked';
      } else if (!existsSync(ref)) {
        verdict = 'NEW'; detail = 'no reference yet (run with --bake)';
      } else {
        const r = await compare(dataUrl(ref), now);
        const bright = r.meanRef > 0 ? 100 * (r.meanNow - r.meanRef) / r.meanRef : 0;
        if (r.size) {
          verdict = 'CHANGED'; detail = `size ${r.size}`;
        } else if (r.diffPct === 0) {
          verdict = 'identical';
        } else if (r.diffPct < 2 && Math.abs(bright) < 0.5) {
          verdict = 'rounding'; detail = `${r.diffPct.toFixed(2)}% of pixels`;
        } else {
          verdict = 'CHANGED';
          detail = `${r.diffPct.toFixed(1)}% of pixels, brightness ${bright >= 0 ? '+' : ''}${bright.toFixed(1)}%, structure ${r.structure.toFixed(2)}`;
          //the same picture drawn with different random samples: many pixels
          //move, but block averages and overall brightness don't. (A changed
          //compile can do this with no real change — float ops get reordered
          //and paths diverge.) Only a hint: tiny real changes look like this too.
          if (r.structure < 0.05 && Math.abs(bright) < 0.3) detail += '  (looks like noise)';

          //a scene that doesn't render the same twice can't be compared at all:
          //render it again and check against itself before calling it a change
          const again = await compare(now, await renderScene(scene));
          if (again.diffPct > 0) {
            verdict = 'unstable';
            detail = `renders differently every run (${again.diffPct.toFixed(1)}% of pixels between two runs), so this comparison means nothing`;
          }
        }
        if (verdict === 'CHANGED') {
          changed++;
          if (r.image) {
            mkdirSync(diffDir, { recursive: true });
            writeFileSync(path.join(diffDir, `${scene}.png`), png(r.image));
          }
        }
        if (verdict === 'unstable') unstable++;
      }
    } catch (err) {
      verdict = 'FAILED'; detail = err.message; failed++;
    }
    const secs = ((Date.now() - t0) / 1000).toFixed(1).padStart(5);
    console.log(`${verdict.padEnd(9)} ${secs}s  ${scene.padEnd(24)} ${detail}`);
  }

  if (bake && machine) {
    writeFileSync(machineFile, `${machine}\n${W}x${H}, ${frames} frames\n`);
  } else if (machine && existsSync(machineFile)) {
    const bakedOn = readFileSync(machineFile, 'utf8').split('\n')[0];
    if (bakedOn !== machine) {
      console.log(`\nnote: the references were baked on\n  ${bakedOn}\nbut this run used\n  ${machine}\nso differences may just be the machine.`);
    }
  }
} finally {
  cdp.close();
  await server.close();
}

if (!bake) {
  console.log(`\n${scenes.length} scenes: ${changed} changed, ${failed} failed` + (unstable ? `, ${unstable} unstable` : '') +
    (changed ? ` (side-by-sides in render-tests/diff/)` : ''));
}
if (failed || changed) process.exitCode = 1;

// Render comparison: renders every scene small and short, and compares the
// result with a baked reference image in render-tests/baselines/.
//
//   node scripts/render-diff.mjs                  compare every scene
//   node scripts/render-diff.mjs glassball gem    compare just these
//   node scripts/render-diff.mjs --bake [...]     (re)write the references from the current code
//   node scripts/render-diff.mjs --smoke [...]    only check every scene RUNS (CI): no compare
//   node scripts/render-diff.mjs --energy [...]   the white-sky energy test (render-tests/energy/)
//   options: --frames N (default 32; 2 with --smoke; 64 with --energy)
//            --size WxH (default 160x120; 128x128 with --energy)
//            --software   render with SwiftShader (Chrome's CPU renderer), as on a
//                         GPU-less CI machine
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
//   BLANK       (--smoke) the canvas came out all black: nothing was drawn
//
// --smoke is what CI runs (.github/workflows/ci.yml): a CI machine has no GPU,
// so its pixels can never match references baked on yours, but it can still
// catch a scene that no longer compiles or throws. Every scene gets `ok`,
// FAILED or BLANK, and nothing is written.
//
// --energy runs the cases in render-tests/energy/cases.js instead of the scenes:
// lossless objects under a white sky, where every pixel must average to exactly
// 1 (see that file). It reads the average out of the accumulation buffer as
// floats, and each case is `ok` or FAILED on its own — no references, so it
// means the same on every machine and runs in CI too.
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
let bake = false, smoke = false, energy = false, software = false, frames = null, W = null, H = null;
const wanted = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--bake') bake = true;
  else if (args[i] === '--smoke') smoke = true;
  else if (args[i] === '--energy') energy = true;
  else if (args[i] === '--software') software = true;
  else if (args[i] === '--frames') frames = parseInt(args[++i], 10);
  else if (args[i] === '--size') [W, H] = args[++i].split('x').map((n) => parseInt(n, 10));
  else wanted.push(args[i]);
}
frames ??= smoke ? 2 : energy ? 64 : 32;
W ??= energy ? 128 : 160;
H ??= energy ? 128 : 120;
if (!(frames > 0) || !(W > 0) || !(H > 0) || [bake, smoke, energy].filter(Boolean).length > 1) {
  console.error('usage: node scripts/render-diff.mjs [--bake | --smoke | --energy] [--software] [--frames N] [--size WxH] [scene...]');
  process.exit(1);
}

//the scenes — or, with --energy, the energy cases (listed once the vite server
//is up: cases.js builds scenegen descriptions, which only load through vite)
const pickScenes = (all, kind) => {
  for (const s of wanted) {
    if (!all.includes(s)) { console.error(`${kind} not found: ${s} (have: ${all.join(', ')})`); process.exit(1); }
  }
  return wanted.length ? wanted : all;
};
let scenes = energy ? null : pickScenes(readdirSync(path.join(root, 'scenes'), { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(path.join(root, 'scenes', d.name, 'main.js')))
  .map((d) => d.name)
  .sort(), 'Scene');
if (!existsSync(chrome)) { console.error(`Chrome not found at ${chrome} (set CHROME_BIN)`); process.exit(1); }


//---- runs in each page before its scripts: hold the render loop until it has
//---- started and the sky is final (PathTracer fires 'pt-sky-ready' once its
//---- image or .hdr has loaded — which restarts accumulation — or at once for
//---- a solid/gradient sky), then let exactly `frames` frames through and
//---- stop. Only the loop named `animate` (createScene.js) is counted; the
//---- UI's refresh loop and other rAF waits run free.
const pageSetup = (frames) => `(() => {
  const realRAF = window.requestAnimationFrame.bind(window);
  let skyReady = false, started = false, n = 0;
  const held = [];
  window.addEventListener('pt-sky-ready', () => { skyReady = true; });
  window.__rd = { done: false };
  window.requestAnimationFrame = (cb) => {
    if (cb.name !== 'animate') return realRAF(cb);
    if (!started) { held.push(cb); return 0; }
    if (n >= ${frames}) { window.__rd.done = true; return 0; }
    n++;
    return realRAF(cb);
  };
  const tryStart = () => {
    if (document.readyState !== 'complete' || !skyReady || held.length === 0) { setTimeout(tryStart, 50); return; }
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


//---- runs in a page: the brightest channel value in a PNG data URL (0 = blank)
async function maxChannel(url) {
  const i = new Image();
  await new Promise((res, rej) => { i.onload = res; i.onerror = rej; i.src = url; });
  const c = document.createElement('canvas');
  c.width = i.width; c.height = i.height;
  const g = c.getContext('2d', { willReadFrequently: true });
  g.drawImage(i, 0, 0);
  const d = g.getImageData(0, 0, i.width, i.height).data;
  let m = 0;
  for (let k = 0; k < d.length; k += 4) m = Math.max(m, d[k], d[k + 1], d[k + 2]);
  return m;
}

//---- runs in an energy-test page: the accumulated average, read as FLOATS
//---- straight from the accumulation target (the true linear values: no tone
//---- map, no 8-bit rounding), reduced to the numbers the verdict needs
function energyStats() {
  const pt = window.__pt, gl = pt.gl, t = pt.accumulate.b;   //b: the target drawn last
  gl.bindFramebuffer(gl.FRAMEBUFFER, t.fbo);
  const px = new Float32Array(t.w * t.h * 4);
  gl.readPixels(0, 0, t.w, t.h, gl.RGBA, gl.FLOAT, px);
  gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  let sum = 0, off = 0, lo = Infinity, hi = -Infinity;
  const n = t.w * t.h;
  for (let i = 0; i < px.length; i += 4) {
    const v = (px[i] + px[i + 1] + px[i + 2]) / 3;
    sum += v;
    if (!(Math.abs(v - 1) <= 0.05)) off++;       //(NaN counts as off)
    lo = Math.min(lo, v); hi = Math.max(hi, v);
  }
  return { mean: sum / n, off: off / n, lo, hi, noisy: !!(pt.settings.energy && pt.settings.energy.noisy) };
}


//---- minimal DevTools-protocol client ----------------------------------------
async function launchChrome() {
  const profile = mkdtempSync(path.join(tmpdir(), 'render-diff-'));
  const flags = [
    '--headless=new', '--remote-debugging-port=0', `--user-data-dir=${profile}`,
    '--no-first-run', '--no-default-browser-check', '--hide-scrollbars', '--mute-audio',
    '--enable-gpu', '--ignore-gpu-blocklist', '--enable-unsafe-swiftshader',
    ...(software ? ['--use-angle=swiftshader'] : process.platform === 'darwin' ? ['--use-angle=metal'] : []),
    //GitHub's Ubuntu runners restrict the user namespaces Chrome's sandbox needs;
    //CI only ever loads our own pages from localhost
    ...(process.env.CI ? ['--no-sandbox'] : []),
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
if (energy) {
  const cases = (await server.ssrLoadModule('/render-tests/energy/cases.js')).default;
  scenes = pickScenes(Object.keys(cases), 'Energy case');
}
const cdp = await launchChrome();

let failed = 0, changed = 0, unstable = 0, machine = null;
if (!smoke && !energy) {
  mkdirSync(baseDir, { recursive: true });
  if (!bake) rmSync(diffDir, { recursive: true, force: true });
}

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
    const page = energy ? `render-tests/energy/?case=${scene}` : `scenes/${scene}/`;
    await cdp.send('Page.navigate', { url: `http://127.0.0.1:${port}/${page}` }, sessionId);

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
    return await evaluate(cdp, sessionId, energy
      ? `(${energyStats.toString()})()`
      : `document.querySelector('body > canvas').toDataURL('image/png')`);
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

      if (energy) {
        //EXACT cases: every path returns exactly 1, so the mean is 1 to rounding
        //and (almost) no pixel strays — a one-pixel dark rim fails. NOISY cases
        //(per-sample weights that only average to 1) are judged on the mean.
        const r = now;
        const meanOk = Math.abs(r.mean - 1) <= (r.noisy ? 0.01 : 0.002);
        const offOk  = r.noisy || r.off <= 0.002;
        verdict = meanOk && offOk ? 'ok' : 'FAILED';
        detail = `mean ${r.mean.toFixed(4)}, ${(100 * r.off).toFixed(2)}% of pixels off by > 5% `
               + `(range ${r.lo.toFixed(3)}..${r.hi.toFixed(3)})${r.noisy ? ', noisy: mean only' : ''}`;
        if (verdict === 'FAILED') failed++;
      } else if (smoke) {
        const m = await evaluate(cdp, cmpSession, `(${maxChannel.toString()})(${JSON.stringify(now)})`);
        if (m > 0) verdict = 'ok';
        else { verdict = 'BLANK'; detail = 'the canvas is all black'; failed++; }
      } else if (bake) {
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

  if (smoke || energy) {
    if (machine) console.log(`\n(rendered with ${machine})`);
  } else if (bake && machine) {
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

if (energy) {
  console.log(`${scenes.length} energy cases: ${scenes.length - failed} ok, ${failed} failed`);
} else if (smoke) {
  console.log(`${scenes.length} scenes: ${scenes.length - failed} ran, ${failed} failed`);
} else if (!bake) {
  console.log(`\n${scenes.length} scenes: ${changed} changed, ${failed} failed` + (unstable ? `, ${unstable} unstable` : '') +
    (changed ? ` (side-by-sides in render-tests/diff/)` : ''));
}
if (failed || changed) process.exitCode = 1;

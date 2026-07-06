// Headless render test: boots the dev server for each scene, screenshots it,
// and writes render-tests/<scene>.png. A black/empty canvas means the shader
// failed to compile; compare shots against a known-good run when refactoring.
//
// usage: node scripts/render-test.mjs [--budget ms] <scene> [<scene>...]
import { spawn, execFileSync } from 'node:child_process';
import { existsSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const outDir = path.join(root, 'render-tests');

const chrome =
  process.env.CHROME_BIN ??
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

const args = process.argv.slice(2);
let budget = 15000;
const scenes = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--budget') budget = parseInt(args[++i], 10);
  else scenes.push(args[i]);
}

if (!scenes.length) {
  console.error('usage: node scripts/render-test.mjs [--budget ms] <scene> [<scene>...]');
  process.exit(1);
}
if (!existsSync(chrome)) {
  console.error(`Chrome not found at ${chrome} (set CHROME_BIN)`);
  process.exit(1);
}
mkdirSync(outDir, { recursive: true });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function waitForServer(url, tries = 40) {
  for (let i = 0; i < tries; i++) {
    try { await fetch(url); return true; } catch { await sleep(500); }
  }
  return false;
}

for (const scene of scenes) {
  const server = spawn('node', ['scripts/run-example.mjs', 'dev', scene], {
    cwd: root, stdio: 'ignore', detached: true,
  });
  try {
    if (!(await waitForServer('http://127.0.0.1:5173/'))) {
      console.error(`${scene}: dev server never came up`);
      continue;
    }
    const shot = path.join(outDir, `${scene}.png`);
    execFileSync(chrome, [
      '--headless=new', '--enable-unsafe-swiftshader',
      '--window-size=400,300', `--virtual-time-budget=${budget}`,
      `--screenshot=${shot}`, 'http://127.0.0.1:5173/',
    ], { stdio: 'ignore' });
    console.log(`${scene}: ${shot}`);
  } finally {
    try { process.kill(-server.pid); } catch {}
    await sleep(500);
  }
}

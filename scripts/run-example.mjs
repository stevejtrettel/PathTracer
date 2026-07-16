import { spawn } from 'node:child_process';
import { existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

// Thin vite wrapper — no more rewriting index.html. Each scene is its own Vite
// page (scenes/<name>/index.html).
//   npm run dev            serve the whole array (/ is the gallery)
//   npm run dev <name>     serve the array and open /scenes/<name>/
//   npm run build <name>   build just that scene into dist/<name>/  (SCENE env -> vite.config)
//   npm run preview <name> preview dist/<name>/
const [, , mode, scene] = process.argv;
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const scenesList = () =>
  readdirSync(path.join(root, 'scenes'), { withFileTypes: true })
    .filter((d) => d.isDirectory() && existsSync(path.join(root, 'scenes', d.name, 'main.js')))
    .map((d) => `  ${d.name}`)
    .join('\n');

if ((mode === 'build' || mode === 'preview') && !scene) {
  console.error(`Usage: npm run ${mode} <scene>\n\nScenes:\n${scenesList()}`);
  process.exit(1);
}
if (scene && !existsSync(path.join(root, 'scenes', scene, 'main.js'))) {
  console.error(`Scene not found: scenes/${scene}\n\nScenes:\n${scenesList()}`);
  process.exit(1);
}

const env = { ...process.env };
let viteArgs;
if (mode === 'build') { viteArgs = ['build']; env.SCENE = scene; }
else if (mode === 'preview') { viteArgs = ['preview']; env.SCENE = scene; }
else { // dev: serve the whole array; open the scene if one was named
  viteArgs = ['--host', '127.0.0.1'];
  if (scene) viteArgs.push('--open', `/scenes/${scene}/`);
}

const child = spawn('npx', ['vite', ...viteArgs], { stdio: 'inherit', cwd: root, env });
child.on('exit', (code) => process.exit(code ?? 0));

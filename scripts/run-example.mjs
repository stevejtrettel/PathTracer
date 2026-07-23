import { spawn } from 'node:child_process';
import { existsSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

// Thin vite wrapper — no more rewriting index.html. Each scene is its own Vite
// page (scenes/<name>/index.html, or demos/<kind>/<name>/index.html — demos/
// holds reference/test pages, not art; see demos/README.md).
//   npm run dev            serve the whole array (/ is the gallery)
//   npm run dev <name>     serve the array and open that scene's page
//   npm run build <name>   build just that scene into dist/<name>/  (SCENE env -> vite.config)
//   npm run preview <name> preview dist/<name>/
const [, , mode, scene] = process.argv;
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

// demos/ is split by subject (materials/, objects/); scene names stay unique
// across every root, so `npm run dev <name>` never needs the folder.
const SCENE_ROOTS = ['scenes'];   // legacy/ is deliberately excluded: not built, not crawled

// which folder holds this scene (scene names are unique across roots)
const sceneRoot = (name) =>
  SCENE_ROOTS.find((r) => existsSync(path.join(root, r, name, 'main.js')));

const scenesList = () =>
  SCENE_ROOTS.flatMap((r) =>
    existsSync(path.join(root, r))
      ? readdirSync(path.join(root, r), { withFileTypes: true })
          .filter((d) => d.isDirectory() && existsSync(path.join(root, r, d.name, 'main.js')))
          .map((d) => `  ${d.name}${r.startsWith('demos') ? `  (${r.split('/')[1]} demo)` : ''}`)
      : []
  ).join('\n');

if ((mode === 'build' || mode === 'preview') && !scene) {
  console.error(`Usage: npm run ${mode} <scene>\n\nScenes:\n${scenesList()}`);
  process.exit(1);
}
if (scene && !sceneRoot(scene)) {
  console.error(`Scene not found: ${scene} (looked in ${SCENE_ROOTS.join('/, ')}/)\n\nScenes:\n${scenesList()}`);
  process.exit(1);
}

const env = { ...process.env };
let viteArgs;
if (mode === 'build') { viteArgs = ['build']; env.SCENE = scene; env.SCENE_ROOT = sceneRoot(scene); }
else if (mode === 'preview') { viteArgs = ['preview']; env.SCENE = scene; env.SCENE_ROOT = sceneRoot(scene); }
else { // dev: serve the whole array; open the scene if one was named
  viteArgs = ['--host', '127.0.0.1'];
  if (scene) viteArgs.push('--open', `/${sceneRoot(scene)}/${scene}/`);
}

const child = spawn('npx', ['vite', ...viteArgs], { stdio: 'inherit', cwd: root, env });
child.on('exit', (code) => process.exit(code ?? 0));

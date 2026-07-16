// Generate the per-scene index.html pages + the root gallery.
// Each scenes/<name>/ becomes a Vite page (its index.html loads ./main.js); the
// root index.html links to them all. Re-run after adding/removing a scene:
//   node scripts/gen-pages.mjs
import { existsSync, readdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const scenesDir = path.join(root, 'scenes');

const scenes = readdirSync(scenesDir, { withFileTypes: true })
  .filter((d) => d.isDirectory() && existsSync(path.join(scenesDir, d.name, 'main.js')))
  .map((d) => d.name)
  .sort();

// per-scene page (CSS is imported from JS, so the page itself is minimal)
for (const name of scenes) {
  writeFileSync(path.join(scenesDir, name, 'index.html'),
`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>PathTracer · ${name}</title>
</head>
<body>
  <script type="module" src="./main.js"></script>
</body>
</html>
`);
}

// root gallery
const links = scenes.map((n) => `      <li><a href="./scenes/${n}/">${n}</a></li>`).join('\n');
writeFileSync(path.join(root, 'index.html'),
`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>PathTracer — scenes</title>
  <style>
    body { margin: 0; padding: 2rem; background: #111; color: #eaeaea;
           font: 15px/1.5 ui-sans-serif, system-ui, sans-serif; }
    h1 { font-weight: 600; }
    ul.scenes { columns: 4; list-style: none; padding: 0; max-width: 900px; }
    ul.scenes a { color: #6ea8fe; text-decoration: none; }
    ul.scenes a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>PathTracer scenes</h1>
  <ul class="scenes">
${links}
  </ul>
</body>
</html>
`);

console.log(`generated ${scenes.length} scene pages + root gallery`);

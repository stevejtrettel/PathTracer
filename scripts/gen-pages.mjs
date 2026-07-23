// Generate the per-scene index.html pages + the root gallery.
// Each scenes/<name>/ (art) and demos/<kind>/<name>/ (reference/test pages —
// material charts, parameter sweeps, object references; not art) becomes a Vite
// page (its index.html loads ./main.js); the root index.html links to them all.
// Re-run after adding/removing a scene:
//   node scripts/gen-pages.mjs
import { existsSync, readdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const scan = (dirName) => {
  const dir = path.join(root, dirName);
  if (!existsSync(dir)) return [];
  return readdirSync(dir, { withFileTypes: true })
    .filter((d) => d.isDirectory() && existsSync(path.join(dir, d.name, 'main.js')))
    .map((d) => d.name)
    .sort();
};

const scenes = scan('scenes');
// demos/ is split by subject; each subfolder is its own gallery section.
// (demos/_studio holds shared environments and has no main.js, so scan skips it.)
const DEMO_KINDS = [
  ['demos/materials',      'material demos',       'the material system — catalogs, parameter sweeps, playground'],
  ['demos/objects',        'object demos',         'the object/SDF library — one shape per page'],
  ['demos/multi-material', 'multi-material demos', 'composites with internal boundaries — nested media, liquids, inclusions'],
];
const demoGroups = DEMO_KINDS
  .map(([dir, title, blurb]) => [dir, title, blurb, scan(dir)])
  .filter(([, , , names]) => names.length);
const demoCount = demoGroups.reduce((n, g) => n + g[3].length, 0);

// per-scene page (CSS is imported from JS, so the page itself is minimal)
for (const [dirName, names] of [['scenes', scenes], ...demoGroups.map((g) => [g[0], g[3]])]) {
  for (const name of names) {
    writeFileSync(path.join(root, dirName, name, 'index.html'),
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
}

// root gallery: scenes, then one section per demo kind (reference/test pages)
const linkList = (dirName, names) =>
  names.map((n) => `      <li><a href="./${dirName}/${n}/">${n}</a></li>`).join('\n');
const demosSection = demoGroups
  .map(([dir, title, blurb, names]) =>
`  <h2>${title} <span class="sub">(${blurb})</span></h2>
  <ul class="scenes">
${linkList(dir, names)}
  </ul>
`)
  .join('');
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
    h2 { font-weight: 600; margin-top: 2rem; }
    h2 .sub { font-weight: 400; font-size: 0.8em; color: #888; }
    ul.scenes { columns: 4; list-style: none; padding: 0; max-width: 900px; }
    ul.scenes a { color: #6ea8fe; text-decoration: none; }
    ul.scenes a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>PathTracer scenes</h1>
  <ul class="scenes">
${linkList('scenes', scenes)}
  </ul>
${demosSection}</body>
</html>
`);

console.log(`generated ${scenes.length} scene + ${demoCount} demo pages + root gallery`);

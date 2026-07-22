// Generate the per-scene index.html pages + the root gallery.
// Each scenes/<name>/ (art) and demos/<name>/ (reference/test scenes — material
// configuration charts, A/B comparisons; not art) becomes a Vite page (its
// index.html loads ./main.js); the root index.html links to them all.
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
const demos = scan('demos');

// per-scene page (CSS is imported from JS, so the page itself is minimal)
for (const [dirName, names] of [['scenes', scenes], ['demos', demos]]) {
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

// root gallery: scenes, then a demos section (reference/test pages)
const linkList = (dirName, names) =>
  names.map((n) => `      <li><a href="./${dirName}/${n}/">${n}</a></li>`).join('\n');
const demosSection = demos.length
  ? `  <h2>demos <span class="sub">(reference &amp; parameter tests — not art)</span></h2>
  <ul class="scenes">
${linkList('demos', demos)}
  </ul>
`
  : '';
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

console.log(`generated ${scenes.length} scene + ${demos.length} demo pages + root gallery`);

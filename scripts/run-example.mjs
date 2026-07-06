import { spawn } from 'node:child_process';
import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const [, , mode, example] = process.argv;
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const listExamples = () =>
  readdirSync(path.join(root, 'example'), { withFileTypes: true })
    .filter((d) => d.isDirectory() && existsSync(path.join(root, 'example', d.name, 'main.js')))
    .map((d) => `  ${d.name}`)
    .join('\n');

if (!example) {
  console.error(`Usage: npm run ${mode ?? '<dev|build|preview>'} <example-name>\n\nAvailable examples:\n${listExamples()}`);
  process.exit(1);
}

const exampleEntry = path.join(root, 'example', example, 'main.js');
if (!existsSync(exampleEntry)) {
  console.error(`Example not found: example/${example}/main.js\n\nAvailable examples:\n${listExamples()}`);
  process.exit(1);
}

// Rewrite the script-tag line in index.html on disk, then run vite.
// Vite reads the file fresh, so this behaves identically to editing it by hand.
const indexPath = path.join(root, 'index.html');
const html = readFileSync(indexPath, 'utf8');
const scriptTagRe = /<script\s+type=["']module["']\s+src=["']\.?\/example\/[^"']+["']><\/script>/;
if (!scriptTagRe.test(html)) {
  console.error("Could not find <script type='module' src='./example/...'> in index.html");
  process.exit(1);
}
writeFileSync(
  indexPath,
  html.replace(scriptTagRe, `<script type='module' src='./example/${example}/main.js'></script>`)
);

const viteArgs =
  mode === 'build' ? ['build', '--outDir', `dist/${example}`]
  : mode === 'preview' ? ['preview', '--outDir', `dist/${example}`]
  : ['--host', '127.0.0.1'];
const child = spawn('npx', ['vite', ...viteArgs], { stdio: 'inherit', cwd: root });
child.on('exit', (code) => process.exit(code ?? 0));

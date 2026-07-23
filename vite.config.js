import glsl from 'vite-plugin-glsl';
import { defineConfig } from 'vite';
import { existsSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const projectRoot = path.dirname(fileURLToPath(import.meta.url));

// `npm run build/preview <name>` sets SCENE (+ SCENE_ROOT = scenes |
// demos/materials | demos/objects); then vite's root becomes that scene's folder
// so its index.html is THE entry and the output flattens straight into
// dist/<name>/. With no SCENE (dev), root is the project and vite serves the
// whole array — scenes/ (art) and demos/<kind>/ (reference tests); open
// /scenes/<name>/ or /demos/<kind>/<name>/ for a specific one; / is the gallery.
const SCENE_ROOTS = ['scenes', 'demos/materials', 'demos/objects', 'demos/multi-material'];

const scene = process.env.SCENE;
const sceneRoot = process.env.SCENE_ROOT
    ?? (scene && SCENE_ROOTS.find((r) => existsSync(path.join(projectRoot, r, scene, 'main.js'))))
    ?? 'scenes';


// Dev-only endpoint for the GUI's "Save to Scene" button: writes the posted
// settings.js contents to <scene root>/<name>/src/settings.js. The scene is a
// single validated path segment (no slashes / dots / traversal); the root it
// lives under is resolved here, never taken from the request.
function saveSettingsPlugin(){
    return {
        name: 'save-settings',
        configureServer(server){
            server.middlewares.use('/__save-settings', (req, res, next) => {
                if(req.method !== 'POST') return next();
                let body = '';
                req.on('data', (chunk) => { body += chunk; });
                req.on('end', () => {
                    try {
                        let { scene, contents } = JSON.parse(body);
                        if(!/^[A-Za-z0-9_-]+$/.test(scene ?? '')) throw new Error('invalid scene name');
                        if(typeof contents !== 'string')          throw new Error('missing contents');
                        let root = SCENE_ROOTS.find((r) => existsSync(path.join(projectRoot, r, scene, 'main.js'))) ?? 'scenes';
                        writeFileSync(path.join(projectRoot, root, scene, 'src', 'settings.js'), contents, 'utf8');
                        res.statusCode = 200;
                        res.end(JSON.stringify({ ok: true, path: `${root}/${scene}/src/settings.js` }));
                    } catch(err){
                        res.statusCode = 400;
                        res.end(JSON.stringify({ ok: false, error: String(err.message ?? err) }));
                    }
                });
            });
        },
    };
}


export default defineConfig({
    root:      scene ? path.join(projectRoot, sceneRoot, scene) : projectRoot,
    publicDir: path.join(projectRoot, 'public'),                    // shared assets, copied into every build
    build:     scene ? { outDir: path.join(projectRoot, 'dist', scene), emptyOutDir: true } : {},
    server:    { fs: { allow: [projectRoot] } },                    // a scene page imports ../../js
    //scope dev dep-scanning to the real scene pages, so it doesn't crawl (and
    //choke on) the archived pre-refactor pages in final/ (which still import three).
    optimizeDeps: scene ? undefined : { entries: ['index.html', 'scenes/*/index.html', 'demos/*/*/index.html'] },
    plugins:   [glsl(), saveSettingsPlugin()],
});

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
const SCENE_ROOTS = ['scenes'];   // legacy/ is deliberately excluded: not built, not crawled

const scene = process.env.SCENE;
const sceneRoot = process.env.SCENE_ROOT
    ?? (scene && SCENE_ROOTS.find((r) => existsSync(path.join(projectRoot, r, scene, 'main.js'))))
    ?? 'scenes';


// Dev-only endpoint for the GUI's "Save to Scene" button: writes the posted
// settings.js contents to <scene root>/<name>/src/settings.js. The scene is a
// single validated path segment (no slashes / dots / traversal); the root it
// lives under is resolved here, never taken from the request.
//
// Only the GUI's own page may write. Without these checks ANY web page open
// while `npm run dev` runs could POST here — a text/plain body is a "simple"
// request that needs no CORS preflight — and replace a scene's settings.js,
// which then runs as code when the scene opens:
//   - JSON only: a cross-site page can only send JSON after a CORS preflight,
//     which this handler never approves
//   - a local Host: stops DNS rebinding (a hostile name pointed at 127.0.0.1)
//   - Origin (when the browser sends one) must be this same host
// (So Save to Scene only works from localhost / 127.0.0.1, which is how
// `npm run dev` serves.)
function isOwnPage(req){
    let host   = req.headers.host ?? '';
    let local  = /^(localhost|127\.0\.0\.1|\[::1\])(:\d+)?$/.test(host);
    let json   = /^application\/json\b/.test(req.headers['content-type'] ?? '');
    let origin = req.headers.origin;
    let same   = !origin || origin === `http://${host}` || origin === `https://${host}`;
    return local && json && same;
}

function saveSettingsPlugin(){
    return {
        name: 'save-settings',
        configureServer(server){
            server.middlewares.use('/__save-settings', (req, res, next) => {
                if(req.method !== 'POST') return next();
                if(!isOwnPage(req)){
                    res.statusCode = 403;
                    res.end(JSON.stringify({ ok: false, error: 'refused: not a same-origin JSON request from localhost' }));
                    return;
                }
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

import glsl from 'vite-plugin-glsl';
import { defineConfig } from 'vite';
import { writeFileSync } from 'node:fs';
import path from 'node:path';


// Dev-only endpoint powering the GUI's "Save to Scene" button: writes the posted
// settings.js contents to example/<scene>/src/settings.js. The scene is a single
// validated path segment (no slashes / dots / traversal), so this can only ever
// write a scene's own settings file under the project. In a build there is no
// dev server, so "Save to Scene" is hidden and Download Settings is used instead.
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
                        let target = path.join(server.config.root, 'example', scene, 'src', 'settings.js');
                        writeFileSync(target, contents, 'utf8');
                        res.statusCode = 200;
                        res.end(JSON.stringify({ ok: true, path: `example/${scene}/src/settings.js` }));
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
    plugins: [glsl(), saveSettingsPlugin()]
});

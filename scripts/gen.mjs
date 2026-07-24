// scenegen dump / check tool. Loads a scene's description through vite (so
// import.meta.glob and ?raw imports behave exactly as in the browser), emits
// the GLSL chunk, and either prints it or checks it against the hand-written
// reference.
//
// usage:
//   node scripts/gen.mjs <scene>              print the emitted chunk
//   node scripts/gen.mjs <scene> --out <f>    write it to a file
//   node scripts/gen.mjs <scene> --check      compare against src/scene.glsl
//                                             (includes expanded, comments
//                                             stripped, whitespace normalized)
//   node scripts/gen.mjs --catalogue          print the parsed shape catalogue
import { createServer } from 'vite';
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const args = process.argv.slice(2);
const flag = (f) => {
    const i = args.indexOf(f);
    if(i === -1) return null;
    args.splice(i, 1);
    return true;
};
const opt = (f) => {
    const i = args.indexOf(f);
    if(i === -1) return null;
    return args.splice(i, 2)[1];
};

const wantCatalogue = flag('--catalogue');
const wantCheck     = flag('--check');
const outFile       = opt('--out');
const sceneName     = args[0];

if(!wantCatalogue && !sceneName){
    console.error('usage: node scripts/gen.mjs <scene> [--check | --out <file>]  |  --catalogue');
    process.exit(1);
}


//---- text normalization for --check ---------------------------------------
//strip comments, then collapse whitespace so only the code tokens compare

function stripComments(src){
    return src.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/\/\/[^\n]*/g, ' ');
}

function normalize(src){
    return stripComments(src)
        .replace(/\s+/g, ' ')
        .replace(/\s*([^\w\s])\s*/g, '$1')
        .trim();
}

//expand `#include <relative>` lines the way the vite glsl plugin does (one
//level is all the scene files use; recurse anyway for safety)
function expandIncludes(src, fileDir, depth = 0){
    if(depth > 8) throw new Error('gen: #include recursion too deep');
    return src.split('\n').map(line => {
        const m = line.match(/^\s*#include\s+(\S+)\s*$/);
        if(!m) return line;
        const target = path.resolve(fileDir, m[1]);
        return expandIncludes(readFileSync(target, 'utf8'), path.dirname(target), depth + 1);
    }).join('\n');
}

//first point of divergence, with context — the actual debugging tool
function reportDiff(a, b){
    let i = 0;
    while(i < a.length && i < b.length && a[i] === b[i]) i++;
    const ctx = (s) => s.slice(Math.max(0, i - 60), i + 80);
    console.error('MISMATCH at normalized offset ' + i);
    console.error('  emitted:  ...' + ctx(a) + '...');
    console.error('  handfile: ...' + ctx(b) + '...');
}


//---- load through vite ----------------------------------------------------

const server = await createServer({
    root,
    server: {middlewareMode: true},
    logLevel: 'error',
    optimizeDeps: {noDiscovery: true},
});

try{
    if(wantCatalogue){
        const {catalogueInfo} = await server.ssrLoadModule('/js/scenegen/catalogue.js');
        console.log(catalogueInfo());
    }
    else{
        const sceneDir = path.join(root, 'scenes', sceneName);
        if(!existsSync(path.join(sceneDir, 'src', 'scene.js'))){
            console.error(`gen: no scenes/${sceneName}/src/scene.js`);
            process.exit(1);
        }

        const description = (await server.ssrLoadModule(`/scenes/${sceneName}/src/scene.js`)).default;
        const settings    = (await server.ssrLoadModule(`/scenes/${sceneName}/src/settings.js`)).default;
        const {emit}      = await server.ssrLoadModule('/js/scenegen/index.js');

        const {scene} = emit(description, settings);

        if(wantCheck){
            const refPath = path.join(sceneDir, 'src', 'scene.glsl');
            if(!existsSync(refPath)){
                console.error(`${sceneName}: no src/scene.glsl to check against — the hand-written references `
                    + `were deleted after conversion (git history has them; \`npm run gen ${sceneName}\` shows the live output)`);
                process.exit(1);
            }
            const ref = expandIncludes(readFileSync(refPath, 'utf8'), path.dirname(refPath));
            const a = normalize(scene);
            const b = normalize(ref);
            if(a === b){
                console.log(`${sceneName}: OK — emitted chunk is code-equal to src/scene.glsl (${a.length} normalized chars)`);
            }
            else{
                reportDiff(a, b);
                process.exitCode = 1;
            }
        }
        else if(outFile){
            writeFileSync(outFile, scene, 'utf8');
            console.log(`${sceneName}: wrote ${outFile}`);
        }
        else{
            console.log(scene);
        }
    }
}
finally{
    await server.close();
}

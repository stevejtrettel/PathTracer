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
//   node scripts/gen.mjs --materials          print the parsed material catalogue
//   node scripts/gen.mjs --goldens            BYTE-compare every scene's chunk
//                                             against render-tests/goldens/
//   node scripts/gen.mjs --goldens --write    (re)bake the goldens
//
// The goldens are the emitter's regression gate: they pin the exact output of
// every generated scene, so an emitter change shows its full blast radius as
// a git diff of render-tests/goldens/. Bake deliberately, after eyeballing.
import { createServer } from 'vite';
import { readFileSync, writeFileSync, existsSync, readdirSync, mkdirSync } from 'node:fs';
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
const wantMaterials = flag('--materials');
const wantCheck     = flag('--check');
const wantGoldens   = flag('--goldens');
const wantWrite     = flag('--write');
const outFile       = opt('--out');
const sceneName     = args[0];

if(!wantCatalogue && !wantMaterials && !wantGoldens && !sceneName){
    console.error('usage: node scripts/gen.mjs <scene> [--check | --out <file>]  |  --catalogue  |  --materials  |  --goldens [--write]');
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

//every scene that has a description (variety etc. stay hand-written)
function generatedScenes(){
    return readdirSync(path.join(root, 'scenes'))
        .filter(s => existsSync(path.join(root, 'scenes', s, 'src', 'scene.js')))
        .sort();
}

async function emitScene(name){
    const description = (await server.ssrLoadModule(`/scenes/${name}/src/scene.js`)).default;
    const settings    = (await server.ssrLoadModule(`/scenes/${name}/src/settings.js`)).default;
    const {emit}      = await server.ssrLoadModule('/js/scenegen/index.js');
    return emit(description, settings).scene;
}

try{
    if(wantCatalogue){
        const {catalogueInfo} = await server.ssrLoadModule('/js/scenegen/catalogue.js');
        console.log(catalogueInfo());
    }
    else if(wantMaterials){
        const {materialInfo} = await server.ssrLoadModule('/js/scenegen/materials.js');
        console.log(materialInfo());
    }
    else if(wantGoldens){
        const goldenDir = path.join(root, 'render-tests', 'goldens');
        mkdirSync(goldenDir, {recursive: true});
        let failed = 0;
        for(const name of generatedScenes()){
            const chunk  = await emitScene(name);
            const golden = path.join(goldenDir, `${name}.glsl`);
            if(wantWrite){
                writeFileSync(golden, chunk, 'utf8');
                console.log(`${name}: baked render-tests/goldens/${name}.glsl`);
            }
            else if(!existsSync(golden)){
                console.error(`${name}: NO GOLDEN — bake with \`npm run gen -- --goldens --write\``);
                failed++;
            }
            else{
                const ref = readFileSync(golden, 'utf8');
                if(chunk === ref){ console.log(`${name}: OK`); }
                else{ console.error(`${name}: DIFFERS from its golden`); reportDiff(chunk, ref); failed++; }
            }
        }
        if(failed) process.exitCode = 1;
    }
    else{
        const sceneDir = path.join(root, 'scenes', sceneName);
        if(!existsSync(path.join(sceneDir, 'src', 'scene.js'))){
            console.error(`gen: no scenes/${sceneName}/src/scene.js`);
            process.exit(1);
        }

        const scene = await emitScene(sceneName);

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

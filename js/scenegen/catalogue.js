//-------------------------------------------------
// THE CATALOGUE — glsl/shapes/ parsed into shape builders
//
// There are NO companion JS files: the .glsl file is the single source of
// truth, and this parser reads the facts out of it (docs/generator.md §2.7):
//
//   <stem>Distance(vec3 p, ...params)            required   p LOCAL
//   <stem>Trace(Vector tv, vec3 centre, ...)     optional   world
//   <stem>Bound(vec3 p, ...params)               optional
//   //@shape <stem> -> <returnName>, <outName>,...   names multi-outputs
//   //@noshape                                   helpers-only file: not a
//                                                shape builder, but still a
//                                                library reference — legal in
//                                                uses:, an error to CALL
//
// File name == stem. Anything unparseable is a LOUD load error — the parser
// is load-bearing, so it must never silently skip a file.
//
// `lib` is the scene-facing face: lib.sphere({radius: 1.2}) returns a shape
// reference; a typo throws immediately, with the real names listed.
//
// FOLDERS ARE ORGANISATION ONLY (docs/shape-library.md §2). The stem is the
// BASENAME, so a scene writes lib.torus wherever the file sits; two files with
// the same basename are a loud error. Two subtrees are not shapes and are
// skipped wholesale:
//   ops/        the operators — no <stem>Distance, never a lib.<x>, and
//               ALWAYS COMPILED (glsl/shapes/_vocabulary.glsl), so the emitter
//               must not inline them either
//   varieties/  the formula catalogue, parsed separately by varieties.js
//-------------------------------------------------

const RAW = import.meta.glob(['../../glsl/shapes/**/*.glsl',
                              '!../../glsl/shapes/ops/**',
                              '!../../glsl/shapes/varieties/**'],
                             {query: '?raw', import: 'default', eager: true});

//a shape under primitives/ is part of the ALWAYS-COMPILED vocabulary: it is
//already in the shader via _vocabulary.glsl, so the emitter includes it by
//reference only and must never inline its source (duplicate definitions).
const isVocabulary = (file) => file.startsWith('glsl/shapes/primitives/');


//---------------------------------------------------------------- parsing

//signatures are scanned with comments removed — a signature QUOTED in a
//comment ("call sphereDistance(p, r) like so") must never win over the real
//definition below it. Annotations (//@shape, //@noshape) read the raw source.
function stripComments(src){
    return src.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/\/\/[^\n]*/g, ' ');
}

//find `<type> <name>(...)` and return its raw comma-split argument strings.
//type-agnostic: Distance/Trace/Bound all return float, but a data output may
//return vec4/int/etc.
function findArgs(code, name){
    const m = code.match(new RegExp(`(?:float|vec[234]|int|bool)\\s+${name}\\s*\\(([\\s\\S]*?)\\)`));
    if(!m) return null;
    return m[1].replace(/\s+/g, ' ').split(',').map(s => s.trim()).filter(s => s !== '');
}

//the return type of `<type> <name>(`
function returnType(code, name){
    const m = code.match(new RegExp(`(float|vec[234]|int|bool)\\s+${name}\\s*\\(`));
    return m ? m[1] : null;
}

//parse `[out] <type> <name>` argument strings
function parseArgs(raws, file, fnName){
    return raws.map(raw => {
        const m = raw.match(/^(out\s+)?(float|vec2|vec3|vec4|int)\s+(\w+)$/);
        if(!m) throw new Error(`scenegen catalogue: ${file}: cannot parse parameter '${raw}' of ${fnName}()`);
        return {out: !!m[1], type: m[2], name: m[3]};
    });
}

function parseShapeFile(stem, file, src){
    const code = stripComments(src);

    //---- <stem>Distance: required ---------------------------------------
    const distRaw = findArgs(code, `${stem}Distance`);
    if(!distRaw){
        throw new Error(`scenegen catalogue: ${file} has no ${stem}Distance() and no //@noshape opt-out — `
            + `every shapes/ file must declare one or the other`);
    }
    if(distRaw[0] !== 'vec3 p'){
        throw new Error(`scenegen catalogue: ${file}: ${stem}Distance must take (vec3 p, ...), got (${distRaw.join(', ')})`);
    }
    const distArgs = parseArgs(distRaw.slice(1), file, `${stem}Distance`);
    const params   = distArgs.filter(a => !a.out).map(a => ({name: a.name, type: a.type}));
    const outs     = distArgs.filter(a => a.out).map(a => a.name);
    const isParam  = (name) => params.some(p => p.name === name);

    //---- //@shape annotation: names multi-outputs ------------------------
    //the first name is the RETURN value's, the rest map to out params in order
    let outputs = null;
    const ann = src.match(/^\/\/@shape\s+(\w+)\s*->\s*(.+)$/m);
    if(ann){
        if(ann[1] !== stem) throw new Error(`scenegen catalogue: ${file}: //@shape names '${ann[1]}', expected '${stem}'`);
        outputs = ann[2].split(',').map(s => s.trim());
        if(outputs.length !== outs.length + 1){
            throw new Error(`scenegen catalogue: ${file}: //@shape names ${outputs.length} outputs, `
                + `but ${stem}Distance returns 1 + ${outs.length} out params`);
        }
    }
    else if(outs.length > 0){
        throw new Error(`scenegen catalogue: ${file}: ${stem}Distance has out params — add `
            + `'//@shape ${stem} -> <returnName>, <outNames...>' to name them`);
    }

    //---- <stem>Trace: optional, world, (Vector tv, vec3 centre, ...) -----
    let trace = null;
    const traceRaw = findArgs(code, `${stem}Trace`);
    if(traceRaw){
        if(traceRaw[0] !== 'Vector tv' || traceRaw[1] !== 'vec3 centre'){
            throw new Error(`scenegen catalogue: ${file}: ${stem}Trace must take (Vector tv, vec3 centre, ...), `
                + `got (${traceRaw.join(', ')})`);
        }
        trace = parseArgs(traceRaw.slice(2), file, `${stem}Trace`).map(a => a.name);
        for(const name of trace){
            if(!isParam(name)){
                throw new Error(`scenegen catalogue: ${file}: ${stem}Trace parameter '${name}' `
                    + `does not match any ${stem}Distance parameter`);
            }
        }
    }

    //---- <stem>Bound: optional, (vec3 p, ...) ----------------------------
    let bound = null;
    const boundRaw = findArgs(code, `${stem}Bound`);
    if(boundRaw){
        if(boundRaw[0] !== 'vec3 p'){
            throw new Error(`scenegen catalogue: ${file}: ${stem}Bound must take (vec3 p, ...), got (${boundRaw.join(', ')})`);
        }
        bound = parseArgs(boundRaw.slice(1), file, `${stem}Bound`).map(a => a.name);
        for(const name of bound){
            if(!isParam(name)){
                throw new Error(`scenegen catalogue: ${file}: ${stem}Bound parameter '${name}' `
                    + `does not match any ${stem}Distance parameter`);
            }
        }
    }

    //---- data outputs: <stem><Name>Data(vec3 q, ...params ⊆ Distance) ----
    //auto-detected by the `Data` suffix (self-identifying, no annotation). A
    //material that reads the injected name <name>Data gets it emitted with the
    //object's consts baked in — the shape-data channel (docs/shape-data.md).
    const dataOutputs = [];
    const seenData = new Set();
    for(const m of code.matchAll(new RegExp(`\\b(?:float|vec[234]|int|bool)\\s+(${stem}\\w*Data)\\s*\\(`, 'g'))){
        const fn = m[1];
        if(seenData.has(fn)) continue;
        seenData.add(fn);
        const raw = findArgs(code, fn);
        if(raw[0] !== 'vec3 p' && raw[0] !== 'vec3 q'){
            throw new Error(`scenegen catalogue: ${file}: ${fn} must take (vec3 q, ...), got (${raw.join(', ')})`);
        }
        const dparams = parseArgs(raw.slice(1), file, fn).map(a => a.name);
        for(const name of dparams){
            if(!isParam(name)){
                throw new Error(`scenegen catalogue: ${file}: ${fn} parameter '${name}' `
                    + `does not match any ${stem}Distance parameter`);
            }
        }
        //injected name: the suffix after the stem, first letter lowered
        const suffix = fn.slice(stem.length);
        const inject = suffix[0].toLowerCase() + suffix.slice(1);
        dataOutputs.push({fn, type: returnType(code, fn), params: dparams, inject});
    }

    return {stem, src, file, vocabulary: isVocabulary(file),
            params, outs, outputs, trace, bound, dataOutputs};
}


//---------------------------------------------------------------- the catalogue

function build(){
    const shapes = new Map();
    for(const [path, src] of Object.entries(RAW)){
        const file = path.replace(/^(\.\.\/)+/, '');
        const stem = file.split('/').pop().replace(/\.glsl$/, '');
        //the stem is the BASENAME, so two files sharing one is ambiguous
        const prev = shapes.get(stem);
        if(prev){
            throw new Error(`scenegen catalogue: two files share the basename '${stem}.glsl' `
                + `(${prev.file} and ${file}) — a stem names ONE file, wherever it sits`);
        }
        if(/^\s*\/\/@noshape/m.test(src)){
            //include-only: no signatures to parse, just the source to inline
            shapes.set(stem, {stem, src, file, vocabulary: isVocabulary(file), noshape: true});
            continue;
        }
        shapes.set(stem, parseShapeFile(stem, file, src));
    }
    return shapes;
}

export const catalogue = build();


function makeBuilder(entry){
    const builder = function(values = {}){
        if(entry.noshape){
            throw new Error(`scenegen: lib.${entry.stem} is a helpers-only file (//@noshape) — `
                + `reference it in uses: [lib.${entry.stem}], call its functions from authored GLSL`);
        }
        const names = entry.params.map(p => p.name);
        for(const key of Object.keys(values)){
            if(!names.includes(key)){
                throw new Error(`scenegen: lib.${entry.stem}: unknown parameter '${key}' `
                    + `(takes: ${names.join(', ')})`);
            }
        }
        for(const name of names){
            if(values[name] === undefined){
                throw new Error(`scenegen: lib.${entry.stem}: missing parameter '${name}'`);
            }
        }
        return {__shape: true, stem: entry.stem, entry, values};
    };
    //an UNCALLED builder is also a valid library reference: `uses: [lib.x]`
    //on a node declares that an authored body calls into that file, so the
    //emitter inlines the include
    builder.entry = entry;
    return builder;
}

export const lib = new Proxy({}, {
    get(_, prop){
        if(typeof prop !== 'string' || prop === 'then' || prop.startsWith('__')) return undefined;
        const entry = catalogue.get(prop);
        if(!entry){
            throw new Error(`scenegen: no shape '${prop}' in glsl/shapes/ `
                + `(have: ${[...catalogue.keys()].sort().join(', ')})`);
        }
        return makeBuilder(entry);
    },
});


//human-readable dump, for `npm run gen -- --catalogue`
export function catalogueInfo(){
    return [...catalogue.values()].map(e => {
        if(e.noshape) return `${e.stem} [helpers only — uses:]`;
        const parts = [`${e.stem}(${e.params.map(p => p.name).join(', ')})`];
        if(e.outputs) parts.push(`-> ${e.outputs.join(', ')}`);
        if(e.trace)   parts.push('[trace]');
        if(e.bound)   parts.push('[bound]');
        return parts.join(' ');
    }).join('\n');
}

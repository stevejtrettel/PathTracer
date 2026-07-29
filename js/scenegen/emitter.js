//-------------------------------------------------
// THE EMITTER — a scene description -> the GLSL scene chunk
//
// Emits glue and structure only, never math (docs/generator.md). The output
// follows the settled conventions of §2.7 exactly; the regression gate is the
// committed goldens (`npm run gen -- --goldens`).
//
// The work splits in two: plan.js turns each node into a plain UNIT record,
// and this file validates the plan, prints the sections in the fixed order of
// the hand files, and merges settings.
//
// emit(description, settings) returns {scene, settings} — exactly the input
// createScene() wants. The description is SELF-CONTAINED (scene() drained the
// knob/field registries onto it), so emit is pure: same inputs, same chunk,
// any number of times. Knob DECLARATIONS come from the description; current
// VALUES come from settings (the file Save-to-Scene writes).
//-------------------------------------------------

import {pad, commentLines, indent} from './fmt.js';
import {isGlsl, resolveGlsl, bodyText, qLine, valueText} from './glslTag.js';
import {isMat, matKind, matIsMedium, SURF_FIELDS, MEDIUM_FIELDS} from './materials.js';
import {planNode} from './plan.js';


//-------------------------------------------------
// text helpers
//-------------------------------------------------

//a sheet face given as an authored glsl`` expression returning a Material
//(a bundle face is emitted by bundleBody instead, never routed here)
function matExprText(x, where){
    if(isGlsl(x)) return resolveGlsl(x);
    throw new Error(`scenegen: ${where}: expected a material bundle or a glsl\`\` expression`);
}

function sectionHeader(title){
    const lines = title.split('\n').map(l => `// ${l}`.trimEnd()).join('\n');
    return `//---------------------------------------------------------------------\n${lines}\n//---------------------------------------------------------------------`;
}

//the 4-tap: always the numerical gradient of the region's own SIGNED sdf, in
//world coordinates — transforms baked in the sdf are handled by the chain rule
const norm4tap = (name) =>
`Vector normal_${name}(vec3 p){
    vec2 k = vec2(1.0,-1.0)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_${name}(p + k.xyy*NRM_E) + k.yyx*sdf_${name}(p + k.yyx*NRM_E)
                              + k.yxy*sdf_${name}(p + k.yxy*NRM_E) + k.xxx*sdf_${name}(p + k.xxx*NRM_E) ));
}`;


//-------------------------------------------------
// sections — printed in the fixed order of the hand files:
// includes, authored blocks, ids, consts, fields, sdfs, [insideOf],
// [bounds], normals, materials, [traces], dispatchers, entry points
//-------------------------------------------------

function idsSection(regions){
    const w = Math.max(...regions.map(r => `ID_${r.NAME}`.length));
    const ids = regions.map((r, i) => `const int ${pad(`ID_${r.NAME}`, w)} = ${i};`).join('\n');
    return `//--- the objects, in declaration order (= containment priority, inner to outer)\n`
         + `${ids}\n\nconst int N_OBJ = ${regions.length};\nfloat gSDF[N_OBJ];`;
}

function constsSection(units){
    const blocks = units.map(u => {
        const tw = Math.max(...u.consts.map(c => c.type.length));
        const nw = Math.max(...u.consts.map(c => c.name.length));
        let block = u.consts.map(c => `const ${pad(c.type, tw)} ${pad(c.name, nw)} = ${c.text};`).join('\n');
        if(u.constsExtra) block += '\n' + u.constsExtra;
        return block;
    });
    return `//--- placement and shape parameters ----------------------------------\n` + blocks.join('\n\n');
}

function fieldsSection(fields){
    return sectionHeader('the fields — shared functions of a local point,\n'
        + ' usable by sdfs (displacement) and materials (colour) alike')
        + '\n\n' + fields.map(f => f.body).join('\n\n');
}

function sdfsSection(units){
    //shared defs (a variety formula's transpiled twins) print ONCE, however
    //many objects reference the formula — first declaration order, keyed;
    //the same key must always carry the same text
    const shared = [];
    const seen   = new Map();
    for(const u of units){
        for(const s of (u.sharedDefs ?? [])){
            const prev = seen.get(s.key);
            if(prev === undefined){ seen.set(s.key, s.text); shared.push(s.text); }
            else if(prev !== s.text){
                throw new Error(`scenegen: shared def '${s.key}' emitted with two different bodies`);
            }
        }
    }
    return sectionHeader('the region sdfs') + '\n\n'
        + (shared.length ? shared.join('\n\n') + '\n\n' : '')
        + units.map(u => u.sdfDefs).join('\n\n');
}

//the curved-light media (docs/curved-light-scenegen.md). A medium is an object
//whose interior IOR is a position-varying field; each such region contributes
//    float indexField_<name>(vec3 q)      the index n, in the object's own frame
// and the two id-keyed dispatchers the ODE marcher reads off path.region:
//    bool  isMedium(int id)               is this region a curved medium?
//    float indexFieldOf(int id, vec3 p)   -> indexField_<name>(p - <NAME>_P)
// The field function is the SINGLE source: indexFieldOf calls it (odeMarch), and
// the region's own medium_ IOR is emitted as the same call (the dynamic wall, so
// Snell at the surface matches the interior eikonal — one field, no duplication).
// Emitted BEFORE the sdfs/materials so both dispatchers and the wall can call it.
function mediumSection(media){
    //q is the object's own local frame — the field is authored in it, same as a
    //material body. A single-expression field: `return <expr>;`
    const fieldFns = media.map(r =>
        `float indexField_${r.name}(vec3 q){\n    return ${r.fieldBody};\n}`);

    const isMedium = `bool isMedium(int id){ return ${media.map(r => `id == ID_${r.NAME}`).join(' || ')}; }`;

    const rows = media.map(r =>
        `    if(id == ID_${r.NAME}){ return indexField_${r.name}(p - ${r.NAME}_P); }`).join('\n');
    const indexFieldOf = `float indexFieldOf(int id, vec3 p){\n${rows}\n    return 1.0;   //not a medium: vacuum\n}`;

    return sectionHeader('the media — a per-region varying index the ODE marcher bends light through')
        + '\n\n' + fieldFns.join('\n\n') + '\n\n' + isMedium + '\n\n' + indexFieldOf;
}

//"is p inside region k" — NOT sdf < 0 when regions nest: the shell's solid
//contains the core, so its interior must EXCLUDE it (declared via nestedIn,
//never inferred). Emitted only when the scene scatters: this is the medium
//walk's hottest query, and non-scattering scenes compile the walk away.
function insideSection(regions){
    const rows = regions.map(r => {
        if(r.sheet) return `bool inside_${r.name}(vec3 p){ return false; }   //a sheet has no interior`;
        const excl = regions.filter(x => x.nestedIn === r.name)
            .map(x => ` && sdf_${x.name}(p) >= 0.0`).join('');
        return `bool inside_${r.name}(vec3 p){ return sdf_${r.name}(p) < 0.0${excl}; }`;
    });
    return sectionHeader('which region contains a point\n'
        + ' needed only because this scene scatters (SCENE_SUBSURFACE): each test\n'
        + ' names only the regions actually nested inside it')
        + '\n\n' + rows.join('\n');
}

function boundsSection(units){
    const bounded = units.filter(u => u.boundDef);
    if(!bounded.length) return null;
    return sectionHeader('the bounds — the acceleration structure (sdf_Scene only; sdfAll stays exact)')
        + '\n\n' + bounded.map(u => u.boundDef).join('\n\n');
}

function normalsSection(regions){
    return sectionHeader('the normals — the 4-tap of each region\'s own sdf, in world coordinates')
        + '\nconst float NRM_E = 0.0002;\n\n'
        + regions.map(r => norm4tap(r.name)).join('\n\n');
}

//aligned `<lhs>.<field> = <value>;` rows for the fields a bundle sets, in
//the struct's own declaration order
function assignLines(lhs, order, fields){
    const keys = order.filter(k => fields[k] !== undefined);
    const w = Math.max(...keys.map(k => `${lhs}.${k}`.length));
    return keys.map(k => `    ${pad(`${lhs}.${k}`, w)} = ${valueText(fields[k])};`).join('\n');
}

//a bundle emitted as one material function body: defaultMaterial() + the
//assignments. `interiorFrom` is the medium_ call for a real interior, null
//for a surface material (whose stray interior fields — plastic's ior — are
//assigned inline: they shape the Fresnel, but the far side stays open air).
//localPoint gives `q` its value, but only when a field expression reads it — a
//bundle field may be a glsl`` expression of the local point (the foam gradient),
//exactly as an interior IOR may be (the curved-media field).
function bundleBody(m, interiorFrom, localPoint){
    const stamp = m.name ? `      //${m.name}` : '';
    const lines = [`    Material m = defaultMaterial();${stamp}`];
    if(interiorFrom) lines.push(`    m.interior = ${interiorFrom};`);
    if(Object.keys(m.surf).length) lines.push(assignLines('m.surf', SURF_FIELDS, m.surf));
    if(!interiorFrom && Object.keys(m.interior).length) lines.push(assignLines('m.interior', MEDIUM_FIELDS, m.interior));
    lines.push('    return m;');
    const body = lines.join('\n');
    return qLine(body, localPoint) + body;
}

function materialFns(r){
    const matName = `material_${r.name}`;
    const medName = `medium_${r.name}`;
    const comment = r.comment ? commentLines(r.comment) + '\n' : '';

    //a sheet: two faces, one infinitely thin surface. No interior, so medium_
    //is never consulted — the classifier uses the CONTAINING region's medium.
    if(r.sheet){
        const checkFace = (side, which) => {
            if(isMat(side) && matKind(side) !== 'surface'){
                throw new Error(`scenegen: sheet '${r.name}' ${which}: a sheet face has no interior — `
                    + `use a surface material`);
            }
        };
        checkFace(r.front, 'front');
        checkFace(r.back, 'back');
        const frontTxt = isMat(r.front)
            ? `    if(front){\n${indent(bundleBody(r.front, null, r.localPoint), 4)}\n    }`
            : `    if(front){ return ${matExprText(r.front, `sheet '${r.name}' front`)}; }`;
        const backTxt = isMat(r.back)
            ? bundleBody(r.back, null, r.localPoint)
            : `    return ${matExprText(r.back, `sheet '${r.name}' back`)};`;
        return comment
             + `Material ${matName}(vec3 p, inout Vector n, bool front){\n${frontTxt}\n${backTxt}\n}\n`
             + `Medium ${medName}(vec3 p){ return defaultMedium(); }`;
    }

    //a BUNDLE: each value emitted exactly once, factored on the model's seam —
    //Medium fields in medium_, Surface fields in material_, which composes
    //m.interior = medium_<name>(p). (docs/generator.md §5)
    const m = r.material;
    if(isMat(m)){
        const kind = matKind(m);
        if(kind === 'surface'){
            return comment
                 + `Material ${matName}(vec3 p, inout Vector n){\n${bundleBody(m, null, r.localPoint)}\n}\n`
                 + `Medium   ${pad(medName, matName.length)}(vec3 p){ return defaultMedium(); }`;
        }
        //real interior: medium_ first (material_ calls it). Its fields may vary
        //with position (foam), so q is provided when an assignment reads it.
        const medAssign = assignLines('m', MEDIUM_FIELDS, m.interior);
        const medFn = `Medium ${medName}(vec3 p){\n`
            + `    Medium m = defaultMedium();\n`
            + qLine(medAssign, r.localPoint)
            + medAssign + '\n'
            + `    return m;\n}`;
        return comment + medFn + '\n'
             + `Material ${matName}(vec3 p, inout Vector n){\n${bundleBody(m, `${medName}(p)`, r.localPoint)}\n}`;
    }

    //a FIELD: an authored body. In scope: p (world), q (local), n, plus any
    //shape-data output the body reads (<name>Data), injected with the object's
    //consts baked in (docs/shape-data.md). q is emitted whenever the body reads q
    //OR a data output is injected (the data call reads q).
    const body  = bodyText(m);
    const data  = (r.dataOutputs ?? []).filter(d => new RegExp(`\\b${d.inject}\\b`).test(body));
    const qL    = (/\bq\b/.test(body) || data.length) ? `    vec3 q = ${r.localPoint};\n` : '';
    const dataL = data.map(d => `    ${d.type} ${d.inject} = ${d.call};\n`).join('');
    const matFn = `${comment}Material ${matName}(vec3 p, inout Vector n){\n${qL}${dataL}${indent(body, 4)}\n}`;

    if(!r.medium){
        return matFn + `\nMedium ${medName}(vec3 p){ return defaultMedium(); }`;
    }
    return matFn + `\nMedium ${medName}(vec3 p){\n${indent(bodyText(r.medium), 4)}\n}`;
}

function materialsSection(regions){
    return sectionHeader('the materials\n'
        + ' material_ gives the Surface plus this object\'s own Medium; medium_ gives\n'
        + ' only the Medium, for when the object is merely the far side')
        + '\n\n' + regions.map(materialFns).join('\n\n');
}

//the ambient medium: open air (region ID_NONE) as a scattering medium. Emitted
//as one argless Medium that mediumOf returns for ID_NONE, so a ray in open air
//carries it as path.medium and ambientTransport (engine) reads it — no separate
//ambient vocabulary (docs/curved-light-scenegen.md sibling: the ID_NONE medium).
function ambientSection(ambient){
    return sectionHeader('the ambient medium — open air (ID_NONE) as a scattering medium')
        + '\n\n'
        + `Medium ambientMedium(){\n    Medium m = defaultMedium();\n`
        + assignLines('m', MEDIUM_FIELDS, ambient) + '\n'
        + `    return m;\n}`;
}

function tracesSection(units){
    const traced = units.filter(u => u.traceDef);
    if(!traced.length) return null;
    return sectionHeader('the analytic intersections') + '\n\n'
        + traced.map(u => u.traceDef).join('\n\n');
}

function dispatchersSection(units, regions, scatters, airMedium){
    const idW  = Math.max(...regions.map(r => `ID_${r.NAME}`.length));
    const last = regions[regions.length - 1];
    const row  = (r, body) => `    if(id == ${pad(`ID_${r.NAME}`, idW)}){ return ${body}; }`;

    //the last region falls through as the bare else; mediumOf and insideOf
    //instead cover every id explicitly, with an ID_NONE default
    const chain = (call) =>
        regions.slice(0, -1).map(r => row(r, call(r))).join('\n') + `\n    return ${call(last)};`;

    const insideOf = scatters
        ? `bool insideOf(int id, vec3 p){\n`
          + regions.map(r => row(r, `inside_${r.name}(p)`)).join('\n')
          + `\n    return false;                //ID_NONE: open air\n}\n\n`
        : '';

    const sheets = regions.filter(r => r.sheet);
    const isSheetTxt = sheets.length
        ? `//sheets: two-sided surfaces with no interior, excluded from containment\n`
          + `bool isSheet(int id){ return ${sheets.map(s => `id == ID_${s.NAME}`).join(' || ')}; }`
        : `//no sheets in this scene: every object is a region with an interior\n`
          + `bool isSheet(int id){ return false; }`;

    return sectionHeader('the dispatchers') + '\n\n'
        + `void sdfAll(vec3 p){\n${units.map(u => u.sdfAllLine(idW)).join('\n')}\n}\n\n`
        + insideOf
        + `Vector normalOf(int id, vec3 p){\n${chain(r => `normal_${r.name}(p)`)}\n}\n\n`
        + isSheetTxt + '\n\n'
        + `Material materialOf(int id, vec3 p, inout Vector n, bool front){\n${chain(r => r.sheet ? `material_${r.name}(p, n, front)` : `material_${r.name}(p, n)`)}\n}\n\n`
        + `Medium mediumOf(int id, vec3 p){\n${regions.map(r => row(r, `medium_${r.name}(p)`)).join('\n')}\n    return ${airMedium};      //ID_NONE: open air\n}`;
}

function entrySection(units){
    const marched = units.filter(u => u.marchedBlock);
    const traced  = units.filter(u => u.traceDef);

    const sdfScene = marched.length
        ? `float sdf_Scene(Vector tv){\n    vec3 p = tv.pos;\n    float d = maxDist;\n\n`
          + marched.map(u => u.marchedBlock).join('\n\n') + `\n\n    return d;\n}`
        : `//nothing marches: every surface here has a closed-form intersection\n`
          + `float sdf_Scene(Vector tv){\n    return maxDist;\n}`;

    const traceScene = traced.length
        ? `float trace_Scene(Vector tv){\n    float d = maxDist;\n`
          + traced.map(u => `    d = min(d, trace_${u.name}(tv));`).join('\n')
          + `\n    return d;\n}`
        : `float trace_Scene(Vector tv){\n    return maxDist;\n}`;

    return sectionHeader('the entry points') + '\n\n'
        + `void buildScene(){}\n\n${sdfScene}\n\n${traceScene}`;
}


//-------------------------------------------------
// validation — every check over the assembled plan
//-------------------------------------------------

//every unit and region name is one entry in a single scene-wide namespace
//(an object IS its own region, so the shared name counts once). A collision
//would otherwise surface as a confusing duplicate-symbol shader error.
function validateNames(units, knobs, fields){
    const seen = new Map();     //UPPERCASE -> original, so case-collisions in ID_/const names are caught too
    for(const u of units){
        const names = [u.name, ...u.regions.map(r => r.name).filter(n => n !== u.name)];
        for(const n of names){
            const prev = seen.get(n.toUpperCase());
            if(prev !== undefined){
                throw new Error(`scenegen: the name '${n}' is used twice (as '${prev}' and '${n}') — `
                    + `every object, group, and region name must be unique in the scene`);
            }
            seen.set(n.toUpperCase(), n);
        }
    }

    //knobs and fields are the two BARE symbol families (uniforms, functions):
    //a shared name is one GLSL symbol declared twice
    const knobNames = new Set(knobs.map(k => k.name));
    for(const f of fields){
        if(knobNames.has(f.name)){
            throw new Error(`scenegen: '${f.name}' is both a knob and a field — one symbol, `
                + `two GLSL declarations; rename one`);
        }
    }
}

//a declared `uses:` must be USED: at least one name the file defines has to
//appear in the emitted body (authored code lands there resolved) or in some
//other included library file. Catches a stale uses: before it silently ships
//a dead include in every chunk. (A name mentioned only in a comment passes —
//the check is deliberately permissive, erring toward never blocking a scene.)
function validateUses(units, includes, bodyPool){
    for(const u of units){
        for(const entry of u.usesEntries){
            const names = [
                ...[...entry.src.matchAll(/(?:float|int|bool|void|vec[234]|mat[234]|T)\s+(\w+)\s*\(/g)].map(m => m[1]),
                ...[...entry.src.matchAll(/\bconst\s+\w+\s+(\w+)\s*=/g)].map(m => m[1]),
            ];
            const pool = bodyPool + includes.filter(e => e.stem !== entry.stem).map(e => e.src).join('\n');
            if(!names.some(n => new RegExp(`\\b${n}\\b`).test(pool))){
                throw new Error(`scenegen: '${u.name}' declares uses: [lib.${entry.stem}], but nothing references `
                    + `that file (looked for: ${names.join(', ')}) — remove the stale uses:`);
            }
        }
    }
}

//the names of every region that is a medium (interior IOR is a varying field),
//read off the description nodes before planning — object regions and group slots
function mediumNames(objects){
    const names = new Set();
    for(const node of objects){
        if(node.material && matIsMedium(node.material)) names.add(node.name);
        for(const [rn, spec] of Object.entries(node.regions ?? {})){
            if(spec.material && matIsMedium(spec.material)) names.add(rn);
        }
    }
    return names;
}

//nesting is declared, and declaration order is containment priority: a nested
//region must come BEFORE its container (inner to outer)
function validateNesting(regions){
    regions.forEach((r, i) => {
        if(!r.nestedIn) return;
        const container = regions.findIndex(x => x.name === r.nestedIn);
        if(container === -1){
            throw new Error(`scenegen: '${r.name}' is nestedIn '${r.nestedIn}', which does not exist`);
        }
        if(i > container){
            throw new Error(`scenegen: '${r.name}' is nestedIn '${r.nestedIn}' but declared after it — `
                + `objects are declared INNER TO OUTER`);
        }
    });
}


//-------------------------------------------------
// emit
//-------------------------------------------------

export function emit(description, settings = {}){
    if(!description || !description.__scene){
        throw new Error('scenegen: emit() takes the default export of scene.js (a scene({...}))');
    }

    const knobs    = description.knobs  ?? [];
    const fields   = description.fields ?? [];

    //open air (region ID_NONE) may be given a scattering medium — that is all
    //"ambient fog" is. Validate its fields against the Medium model, exactly like
    //a material's interior.
    const ambient  = description.ambient ?? null;
    if(ambient){
        if(typeof ambient !== 'object' || Array.isArray(ambient) || !Object.keys(ambient).length){
            throw new Error('scenegen: ambient: must be a set of Medium fields (e.g. fog({mfp: 12}))');
        }
        for(const k of Object.keys(ambient)){
            if(!MEDIUM_FIELDS.includes(k)){
                throw new Error(`scenegen: ambient: no field '${k}' in the Medium model (have: ${MEDIUM_FIELDS.join(', ')})`);
            }
        }
    }

    //a MEDIUM is any region whose interior IOR is a position-varying field (a
    //bundle with a glsl`` ior). Its boundary is forced to march — odeMarch finds
    //the wall by an sdf_Scene sign change, never a trace — decided up front, before
    //planning, from the materials on the description nodes.
    const forceMarch = mediumNames(description.objects);
    const units    = description.objects.map(node => planNode(node, forceMarch));
    const regions  = units.flatMap(u => u.regions);
    const scatters = regions.some(r => r.scatters);
    validateNames(units, knobs, fields);
    validateNesting(regions);

    //resolve each medium region's field ONCE into indexField_<name>(q), and point
    //its own interior IOR at that same function (the dynamic wall) — one source for
    //odeMarch and Snell. Mutates the fresh region record, not the description.
    const media = regions.filter(r => matIsMedium(r.material));
    for(const r of media){
        if(r.sheet) throw new Error(`scenegen: '${r.name}' is a sheet with a varying IOR — a sheet has no interior; a medium needs a solid region`);
        r.fieldBody = resolveGlsl(r.material.interior.ior);
        r.material  = {...r.material, interior: {...r.material.interior,
            ior: {__expr: true, text: `indexField_${r.name}(p - ${r.NAME}_P)`}}};
    }

    //library includes, inlined (the chunk is a runtime string, so no #include):
    //a unit needs its shape's file, plus anything its authored code `uses:`.
    //
    //VOCABULARY IS SKIPPED: primitives/ and ops/ are already compiled into every
    //shader by glsl/shapes/_vocabulary.glsl, so inlining them here would be a
    //duplicate definition. lib.sphere still works — the entry supplies the
    //signature, the shader already has the body (docs/shape-library.md §1).
    const includes = [];
    const seen = new Set();
    for(const u of units){
        for(const entry of [...u.usesEntries, ...(u.entry ? [u.entry] : [])]){
            if(entry.vocabulary || seen.has(entry.stem)) continue;
            seen.add(entry.stem);
            includes.push(entry);
        }
    }

    //---- the chunk ------------------------------------------------------
    const sections = [];

    //scene-level authored GLSL blocks, verbatim
    for(const block of description.glsl ?? []){
        sections.push(bodyText(block));
    }

    sections.push(idsSection(regions));
    sections.push(constsSection(units));
    if(fields.length) sections.push(fieldsSection(fields));
    if(media.length)  sections.push(mediumSection(media));
    sections.push(sdfsSection(units));
    if(scatters) sections.push(insideSection(regions));
    const bounds = boundsSection(units);
    if(bounds) sections.push(bounds);
    sections.push(normalsSection(regions));
    sections.push(materialsSection(regions));
    if(ambient) sections.push(ambientSection(ambient));
    const traces = tracesSection(units);
    if(traces) sections.push(traces);
    sections.push(dispatchersSection(units, regions, scatters, ambient ? 'ambientMedium()' : 'defaultMedium()'));
    sections.push(entrySection(units));

    validateUses(units, includes, sections.join('\n'));

    const parts = [
        `//=====================================================================\n`
      + `// generated by scenegen from src/scene.js — do not edit by hand\n`
      + `//=====================================================================`,
        ...includes.map(e => `//--- library: ${e.file} ---\n` + e.src.trimEnd()),
        ...sections,
    ];
    const chunk = parts.join('\n\n\n') + '\n';

    //---- settings merge -------------------------------------------------
    //declarations from scene.js; current values from settings (either the
    //saved params array Save-to-Scene writes today, or a plain values map)
    const saved = settings.values
        ?? (settings.params ? Object.fromEntries(settings.params.map(p => [p.name, p.value])) : {});
    const params = knobs.map(({__knob, ...decl}) => ({...decl, value: saved[decl.name] ?? decl.value}));

    const defines = [...new Set([
        ...(settings.defines ?? []),
        ...(scatters ? ['SCENE_SUBSURFACE'] : []),
        ...(media.length ? ['SCENE_HAS_MEDIA'] : []),      //stands the engine isMedium/indexFieldOf defaults down
        ...(ambient ? ['SCENE_AMBIENT_MEDIUM'] : []),      //compiles ambientTransport in (derived, not hand-#defined)
    ])];

    const outSettings = {...settings, params};
    if(defines.length) outSettings.defines = defines;
    if(description.sky !== undefined) outSettings.sky = description.sky;

    return {scene: chunk, settings: outSettings};
}

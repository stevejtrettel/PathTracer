//-------------------------------------------------
// THE EMITTER — a scene description -> the GLSL scene chunk
//
// Emits glue and structure only, never math (docs/generator.md). The output
// follows the settled conventions of §2.7 exactly: the normalized hand-written
// scenes in scenes/ are what this reproduces, checked by comment-stripped code
// equality (scripts/gen.mjs --check).
//
// Planning happens at two levels, mirroring §2.2:
//
//   UNIT    one shape evaluation — an object()/sheet(), or a group() feeding
//           several region slots. Owns the consts, the sdf function(s), the
//           bound, the trace, and its sdfAll / sdf_Scene contributions.
//   REGION  one entry in the id space. Owns the normal, the material pair,
//           and its dispatcher rows. An object is a unit with one region.
//
// A plan unit is a plain record:
//
//   { name, NAME, entry,                    catalogue entry (null: custom group)
//     consts, constsExtra,                  const rows + optional authored block
//     regions,                              [{name, NAME, frameNAME, sheet,
//                                             material, medium, front/back,
//                                             nestedIn, scatters}]
//     analytic,                             true -> traced; false -> marched
//     sdfDefs, boundDef, traceDef,          emitted function text
//     sdfAllLine(idW), marchedBlock }       dispatcher / sdf_Scene pieces
//
// emit(description, settings) returns {scene, settings} — exactly the input
// createScene() wants. Knob DECLARATIONS come from the description; current
// VALUES come from settings (the file Save-to-Scene writes).
//-------------------------------------------------

import {fnum, fvec2, fvec3, dedent, indent} from './fmt.js';
import {isGlsl, resolveGlsl} from './glslTag.js';
import {isMat} from './materials.js';
import {drainKnobs} from './knobs.js';
import {drainFields, fieldDef} from './fields.js';


//-------------------------------------------------
// text helpers
//-------------------------------------------------

const pad = (s, w) => s + ' '.repeat(Math.max(0, w - s.length));

function constText(type, v){
    if(v && v.__knob) throw new Error('scenegen: knobs are uniforms — they never become consts');
    if(isGlsl(v))        return resolveGlsl(v);
    if(type === 'vec3')  return fvec3(v);
    if(type === 'vec2')  return fvec2(v);
    if(type === 'float') return fnum(v);
    if(type === 'int'){
        if(!Number.isInteger(v)) throw new Error(`scenegen: expected an int, got ${v}`);
        return String(v);
    }
    throw new Error(`scenegen: no const formatting for type ${type}`);
}

//an authored glsl`` body (or a raw string from a ?raw import), dedented
function bodyText(x){
    if(isGlsl(x)) return dedent(resolveGlsl(x));
    if(typeof x === 'string') return dedent(x);
    throw new Error(`scenegen: expected a glsl\`\` fragment or raw source string`);
}

//a material slot as one EXPRESSION (a constructor mirror, or authored glsl)
function matExprText(x){
    if(isMat(x))  return x.text;
    if(isGlsl(x)) return resolveGlsl(x);
    throw new Error('scenegen: expected a material constructor or a glsl`` expression');
}

//a knob or a plain number, as text
function refText(v){
    if(v && v.__knob) return v.name;
    if(typeof v === 'number') return fnum(v);
    throw new Error(`scenegen: expected a knob or a number, got ${JSON.stringify(v)}`);
}

function commentLines(text){
    return text.split('\n').map(l => `//${l}`).join('\n');
}

function sectionHeader(title){
    const lines = title.split('\n').map(l => `// ${l}`.trimEnd()).join('\n');
    return `//---------------------------------------------------------------------\n${lines}\n//---------------------------------------------------------------------`;
}


//-------------------------------------------------
// shared emission pieces
//-------------------------------------------------

//the 4-tap: always the numerical gradient of the region's own SIGNED sdf, in
//world coordinates — transforms baked in the sdf are handled by the chain rule
const norm4tap = (name) =>
`Vector normal_${name}(vec3 p){
    vec2 k = vec2(1.0,-1.0)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_${name}(p + k.xyy*NRM_E) + k.yyx*sdf_${name}(p + k.yyx*NRM_E)
                              + k.yxy*sdf_${name}(p + k.yxy*NRM_E) + k.xxx*sdf_${name}(p + k.xxx*NRM_E) ));
}`;

//consts + per-parameter argument text for one shape reference. Description-
//supplied values become named consts `<NAME>_<PARAM>`; knobs stay bare (they
//are uniforms already); glsl`` fragments are inlined.
function shapeArgs(NAME, shape, consts){
    const argFor = {};
    for(const p of shape.entry.params){
        const v = shape.values[p.name];
        if(v && v.__knob){ argFor[p.name] = v.name; }
        else if(isGlsl(v)){ argFor[p.name] = resolveGlsl(v); }
        else{
            const cname = `${NAME}_${p.name.toUpperCase()}`;
            consts.push({type: p.type, name: cname, text: constText(p.type, v)});
            argFor[p.name] = cname;
        }
    }
    return argFor;
}

//an authored bound: a single expression, with q provided if the body reads it
function authoredBound(name, NAME, src){
    const bexpr = bodyText(src);
    const qLine = /\bq\b/.test(bexpr) ? `    vec3 q = p - ${NAME}_P;\n` : '';
    return `float bound_${name}(vec3 p){\n${qLine}    return ${bexpr};\n}`;
}

//the Lipschitz divisor of amp*field(q): 1 + amp*gradBound(field), with the
//field's DECLARED gradBound expression kept intact, parenthesized
function divisorText(f, ampT){
    return `1.0 + ${ampT}*(${resolveGlsl(f.gradBound)})`;
}


//-------------------------------------------------
// planning — objects and sheets (units with one region)
//-------------------------------------------------

function makeRegion(name, spec, frameNAME){
    return {
        name, NAME: name.toUpperCase(), frameNAME, sheet: false,
        material: spec.material,
        medium:   spec.medium ?? null,
        comment:  spec.comment ?? null,
        nestedIn: spec.nestedIn ?? null,
        scatters: isMat(spec.material) && spec.material.kind === 'subsurface',
    };
}

//the four sdf forms of a simple shape. Each returns {sdfDef, boundDef};
//boundDef is null when nothing useful can be derived (an authored `bound:`
//on the node overrides either way). ctx: {name, NAME, entry, args, argFor,
//comment} — the resolved naming of one shape reference.

function sdfPlain(node, c){
    return {
        sdfDef: `${c.comment}float sdf_${c.name}(vec3 p){\n    return ${c.entry.stem}Distance(p - ${c.NAME}_P, ${c.args.join(', ')});\n}`,
        boundDef: c.entry.bound
            ? `float bound_${c.name}(vec3 p){\n    return ${c.entry.stem}Bound(p - ${c.NAME}_P, ${c.entry.bound.map(n => c.argFor[n]).join(', ')});\n}`
            : null,
    };
}

function sdfDisplaced(node, c){
    const f    = node.shape.by;
    const ampT = refText(node.shape.amp);
    //the bound is the undisplaced shape pushed out by the largest possible
    //displacement — without the inflation it would shave off the peaks
    const maxAbs = Math.max(Math.abs(f.range[0]), Math.abs(f.range[1]));
    return {
        sdfDef: `${c.comment}float sdf_${c.name}(vec3 p){\n`
            + `    vec3  q = p - ${c.NAME}_P;\n`
            + `    float d = ${c.entry.stem}Distance(q, ${c.args.join(', ')});\n`
            + `    d += ${ampT}*${f.name}(q);\n`
            + `    return d/(${divisorText(f, ampT)});\n}`,
        boundDef: `float bound_${c.name}(vec3 p){\n`
            + `    return ${c.entry.stem}Distance(p - ${c.NAME}_P, ${c.args.join(', ')}) - ${fnum(maxAbs)}*${ampT};\n}`,
    };
}

function sdfRepLim(node, c){
    //one region, many copies: fold the grid onto a single cell. No derived
    //bound — a lattice bound (one box over the whole grid) is authored.
    return {
        sdfDef: `${c.comment}float sdf_${c.name}(vec3 p){\n`
            + `    vec3 q = opRepLim(p - ${c.NAME}_P, ${c.NAME}_SPACING, ${c.NAME}_LIMIT);\n`
            + `    return ${c.entry.stem}Distance(q, ${c.args.join(', ')});\n}`,
        boundDef: null,
    };
}

function sdfTransformed(node, c){
    //world -> local: undo the placement, then the rotation (GLSL's v*M is the
    //rotation's inverse), then the scale
    const rotLn = node.rotate
        ? `    mat3 rot = rot3AxisAngle(normalize(${c.NAME}_AXIS), ${refText(node.rotate.angle)});\n`
        : '';
    let back;
    if(node.rotate && node.scale) back = `((p - ${c.NAME}_P) * rot) / ${c.NAME}_SCALE`;
    else if(node.rotate)          back = `(p - ${c.NAME}_P) * rot`;
    else                          back = `(p - ${c.NAME}_P) / ${c.NAME}_SCALE`;
    const toLocal = `vec3 toLocal_${c.name}(vec3 p){\n${rotLn}    return ${back};\n}`;

    //a non-uniform scale makes the local sdf overestimate world distance by
    //the largest singular value; multiplying by the smallest component
    //restores a conservative underestimate. The 4-tap normal needs NO fixup —
    //it differentiates the world function (chain rule).
    const S   = `${c.NAME}_SCALE`;
    const lip = node.scale ? ` * min(${S}.x, min(${S}.y, ${S}.z))` : '';
    return {
        sdfDef: toLocal + '\n\n'
            + `${c.comment}float sdf_${c.name}(vec3 p){\n`
            + `    float d = ${c.entry.stem}Distance(toLocal_${c.name}(p), ${c.args.join(', ')});\n`
            + `    return d${lip};\n}`,
        boundDef: null,       //no derived bound: a transformed body's bound is authored
    };
}


function planObject(node){
    const name = node.name;
    const NAME = name.toUpperCase();
    if(!node.shape || !node.shape.__shape){
        throw new Error(`scenegen: ${node.__node}('${name}'): shape must come from lib.<stem>({...})`);
    }
    const entry = node.shape.entry;
    if(entry.outputs){
        throw new Error(`scenegen: object('${name}'): ${entry.stem} yields several outputs (${entry.outputs.join(', ')}) — `
            + `call it from a group's authored sdf body (with uses: [lib.${entry.stem}])`);
    }

    const kind        = node.shape.kind ?? 'plain';
    const transformed = !!(node.scale || node.rotate);
    if(transformed && kind !== 'plain'){
        throw new Error(`scenegen: object('${name}'): rotate/scale cannot combine with ${kind} yet`);
    }
    if(node.rotate && (!node.rotate.axis || node.rotate.angle === undefined)){
        throw new Error(`scenegen: object('${name}'): rotate needs {axis: [x,y,z], angle}`);
    }

    //consts: placement, then transform data, then wrapper params, then the
    //shape's own parameters — matching the hand files' block order
    const consts = [{type: 'vec3', name: `${NAME}_P`, text: fvec3(node.at)}];
    if(node.scale)  consts.push({type: 'vec3', name: `${NAME}_SCALE`, text: fvec3(node.scale)});
    if(node.rotate) consts.push({type: 'vec3', name: `${NAME}_AXIS`,  text: fvec3(node.rotate.axis)});
    if(kind === 'repLim'){
        consts.push({type: 'float', name: `${NAME}_SPACING`, text: constText('float', node.shape.spacing)});
        consts.push({type: 'vec3',  name: `${NAME}_LIMIT`,   text: fvec3(node.shape.limit)});
    }
    const argFor = shapeArgs(NAME, node.shape, consts);
    const args   = entry.params.map(p => argFor[p.name]);

    //trace routing: a displaced, repeated, or transformed shape has no closed
    //form any more, so it loses its trace and marches
    const analytic = !!entry.trace && kind === 'plain' && !transformed;
    const comment  = node.comment ? commentLines(node.comment) + '\n' : '';

    const ctx = {name, NAME, entry, args, argFor, comment};
    const build = kind === 'displaced' ? sdfDisplaced
                : kind === 'repLim'    ? sdfRepLim
                : transformed          ? sdfTransformed
                :                        sdfPlain;
    let {sdfDef, boundDef} = build(node, ctx);

    //an authored bound is authored knowledge: it beats anything derived
    if(node.bound) boundDef = authoredBound(name, NAME, node.bound);

    //a sheet is the same unit with a two-faced region instead of a material.
    //(node.comment belongs to the sdf; region comments come from group specs)
    const region = (node.__node === 'sheet')
        ? {name, NAME, frameNAME: NAME, sheet: true, front: node.front, back: node.back,
           medium: null, comment: null, nestedIn: null, scatters: false}
        : makeRegion(name, {material: node.material, medium: node.medium, nestedIn: node.nestedIn}, NAME);

    return {
        name, NAME, entry, usesEntries: (node.uses ?? []).map(u => u.entry), consts, constsExtra: null, analytic,
        regions: [region],
        sdfDefs: sdfDef,
        boundDef,
        sdfAllLine: (idW) => `    gSDF[${pad(`ID_${NAME}`, idW)}] = sdf_${name}(p);`,
        marchedBlock: analytic ? null : (boundDef
            ? `    float b_${name} = bound_${name}(p);\n    d = min(d, (b_${name} > BOUND_MARGIN) ? b_${name} : sdf_${name}(p));`
            : `    d = min(d, sdf_${name}(p));`),
        traceDef: analytic
            ? `float trace_${name}(Vector tv){\n    return ${entry.stem}Trace(tv, ${NAME}_P, ${entry.trace.map(n => argFor[n]).join(', ')});\n}`
            : null,
    };
}


//-------------------------------------------------
// planning — groups (one shape evaluation, several region slots)
//-------------------------------------------------

const WRAPPER_NOTE = '//single-region entry points, for the 4-tap normals';

//per-region sdf wrappers: a 4-tap normal has to differentiate one region at a
//time, so each region gets a single-output entry point over the group call
function regionWrappers(name, regionNames){
    const paramList = regionNames.join(', ');
    return regionNames.map(r =>
        `float sdf_${r}(vec3 p){ float ${paramList}; sdf_${name}(p, ${paramList}); return ${r}; }`
    ).join('\n');
}

function groupSdfAllLine(name, regionNames){
    return () => `    sdf_${name}(p, ${regionNames.map(r => `gSDF[ID_${r.toUpperCase()}]`).join(', ')});`;
}

//sdf_Scene form: the group bound guards ONE evaluation of the shape,
//min-ing every region it produced
function groupMarchedBlock(name, regionNames, hasBound){
    const paramList = regionNames.join(', ');
    const evalAll = `        float ${paramList};\n        sdf_${name}(p, ${paramList});\n`
                  + `        d = min(d, ${regionNames.reduce((a, b) => `min(${a}, ${b})`)});`;
    return hasBound
        ? `    float b_${name} = bound_${name}(p);\n`
          + `    if(b_${name} > BOUND_MARGIN){ d = min(d, b_${name}); }\n`
          + `    else{\n${evalAll}\n    }`
        : `    {\n${evalAll}\n    }`;
}


//a group: one AUTHORED sdf evaluation feeding several region slots. In
//scope: p (world), q (local, provided), and the region names as out params
//the body assigns. The optional consts block sits with the placement const;
//library calls inside the body declare their file via `uses:`.
function planGroup(node){
    const name  = node.name;
    const NAME  = name.toUpperCase();
    const regionNames = Object.keys(node.regions);
    const regions = regionNames.map(r => makeRegion(r, node.regions[r], NAME));

    const consts  = [{type: 'vec3', name: `${NAME}_P`, text: fvec3(node.at)}];
    const comment = node.comment ? commentLines(node.comment) + '\n' : '';
    const sig     = regionNames.map(r => `out float ${r}`).join(', ');
    const groupFn = `${comment}void sdf_${name}(vec3 p, ${sig}){\n`
        + `    vec3  q = p - ${NAME}_P;\n${indent(bodyText(node.sdf), 4)}\n}`;

    const boundDef = node.bound ? authoredBound(name, NAME, node.bound) : null;

    return {
        name, NAME, entry: null, usesEntries: (node.uses ?? []).map(u => u.entry), consts,
        constsExtra: node.consts ? bodyText(node.consts) : null,
        analytic: false, regions,
        sdfDefs: groupFn + `\n\n${WRAPPER_NOTE}\n` + regionWrappers(name, regionNames),
        boundDef,
        sdfAllLine: groupSdfAllLine(name, regionNames),
        marchedBlock: groupMarchedBlock(name, regionNames, !!boundDef),
        traceDef: null,
    };
}


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
        + '\n\n' + fields.map(fieldDef).join('\n\n');
}

function sdfsSection(units){
    return sectionHeader('the region sdfs') + '\n\n' + units.map(u => u.sdfDefs).join('\n\n');
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

function materialFns(r){
    const matName = `material_${r.name}`;
    const medName = `medium_${r.name}`;
    const comment = r.comment ? commentLines(r.comment) + '\n' : '';

    //a sheet: two faces, one infinitely thin surface. No interior, so medium_
    //is never consulted — the classifier uses the CONTAINING region's medium.
    if(r.sheet){
        return comment
             + `Material ${matName}(vec3 p, inout Vector n, bool front){\n`
             + `    if(front){ return ${matExprText(r.front)}; }\n`
             + `    return ${matExprText(r.back)};\n}\n`
             + `Medium ${medName}(vec3 p){ return defaultMedium(); }`;
    }

    //a constant material: the constructor emitted twice — the Surface side and
    //the Medium side — with no shared helper (docs/generator.md §2.7)
    const m = r.material;
    if(isMat(m)){
        const interior = (m.kind === 'volume' || m.kind === 'subsurface')
            ? `${m.text}.interior`
            : 'defaultMedium()';
        //pad medium_'s name so its ( aligns under material_'s
        return comment
             + `Material ${matName}(vec3 p, inout Vector n){ return ${m.text}; }\n`
             + `Medium   ${pad(medName, matName.length)}(vec3 p){ return ${interior}; }`;
    }

    //a FIELD: an authored body. In scope: p (world), q (local), n. The q line
    //is emitted only when the body actually reads it.
    const body  = bodyText(m);
    const qLine = /\bq\b/.test(body) ? `    vec3 q = p - ${r.frameNAME}_P;\n` : '';
    const matFn = `${comment}Material ${matName}(vec3 p, inout Vector n){\n${qLine}${indent(body, 4)}\n}`;

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

function tracesSection(units){
    const traced = units.filter(u => u.traceDef);
    if(!traced.length) return null;
    return sectionHeader('the analytic intersections') + '\n\n'
        + traced.map(u => u.traceDef).join('\n\n');
}

function dispatchersSection(units, regions, scatters){
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
        + `Medium mediumOf(int id, vec3 p){\n${regions.map(r => row(r, `medium_${r.name}(p)`)).join('\n')}\n    return defaultMedium();      //ID_NONE: open air\n}`;
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
// emit
//-------------------------------------------------

function planNode(node){
    if(node.__node === 'object' || node.__node === 'sheet') return planObject(node);
    if(node.__node === 'group') return planGroup(node);
    throw new Error(`scenegen: node kind '${node.__node}' is not emittable yet`);
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


export function emit(description, settings = {}){
    if(!description || !description.__scene){
        throw new Error('scenegen: emit() takes the default export of scene.js (a scene({...}))');
    }

    const knobs    = drainKnobs();
    const fields   = drainFields();
    const units    = description.objects.map(planNode);
    const regions  = units.flatMap(u => u.regions);
    const scatters = regions.some(r => r.scatters);
    validateNesting(regions);

    //---- the chunk ------------------------------------------------------
    const parts = [];
    parts.push(`//=====================================================================\n`
             + `// generated by scenegen from src/scene.js — do not edit by hand\n`
             + `//=====================================================================`);

    //library includes, inlined (the chunk is a runtime string, so no #include):
    //a unit needs its shape's file, plus anything its authored code `uses:`
    const seen = new Set();
    for(const u of units){
        for(const entry of [...u.usesEntries, ...(u.entry ? [u.entry] : [])]){
            if(seen.has(entry.stem)) continue;
            seen.add(entry.stem);
            parts.push(`//--- library: ${entry.file} ---\n` + entry.src.trimEnd());
        }
    }

    //scene-level authored GLSL blocks, verbatim
    for(const block of description.glsl ?? []){
        parts.push(bodyText(block));
    }

    parts.push(idsSection(regions));
    parts.push(constsSection(units));
    if(fields.length) parts.push(fieldsSection(fields));
    parts.push(sdfsSection(units));
    if(scatters) parts.push(insideSection(regions));
    const bounds = boundsSection(units);
    if(bounds) parts.push(bounds);
    parts.push(normalsSection(regions));
    parts.push(materialsSection(regions));
    const traces = tracesSection(units);
    if(traces) parts.push(traces);
    parts.push(dispatchersSection(units, regions, scatters));
    parts.push(entrySection(units));

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
    ])];

    const outSettings = {...settings, params};
    if(defines.length) outSettings.defines = defines;
    if(description.sky !== undefined) outSettings.sky = description.sky;

    return {scene: chunk, settings: outSettings};
}

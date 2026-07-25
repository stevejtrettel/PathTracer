//-------------------------------------------------
// PLANNING — a description node -> a plan unit
//
// Planning happens at two levels, mirroring docs/generator.md §2.2:
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
//     regions,                              [{name, NAME, localPoint, sheet,
//                                             material, medium, front/back,
//                                             nestedIn, scatters}]
//     analytic,                             true -> traced; false -> marched
//     sdfDefs, boundDef, traceDef,          emitted function text
//     sdfAllLine(idW), marchedBlock }       dispatcher / sdf_Scene pieces
//
// The emitter (emitter.js) never looks inside a node — everything it prints
// comes off these records.
//-------------------------------------------------

import {fnum, fvec2, fvec3, indent, pad, commentLines} from './fmt.js';
import {isGlsl, resolveGlsl, bodyText, qLine} from './glslTag.js';
import {isMat, matKind} from './materials.js';


//-------------------------------------------------
// shared pieces
//-------------------------------------------------

//a description value as a typed const's text; knobs are refused (uniforms)
function constText(type, v, where){
    if(v && v.__knob) throw new Error(`scenegen: ${where}: knobs are uniforms — they never become consts`);
    if(isGlsl(v))        return resolveGlsl(v);
    if(type === 'vec3')  return fvec3(v);
    if(type === 'vec2')  return fvec2(v);
    if(type === 'float') return fnum(v);
    if(type === 'int'){
        if(!Number.isInteger(v)) throw new Error(`scenegen: ${where}: expected an int, got ${v}`);
        return String(v);
    }
    throw new Error(`scenegen: ${where}: no const formatting for type ${type}`);
}

//a knob or a plain number, as text
function refText(v, where){
    if(v && v.__knob) return v.name;
    if(typeof v === 'number') return fnum(v);
    throw new Error(`scenegen: ${where}: expected a knob or a number, got ${JSON.stringify(v)}`);
}

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
            consts.push({type: p.type, name: cname, text: constText(p.type, v, `lib.${shape.entry.stem} parameter '${p.name}'`)});
            argFor[p.name] = cname;
        }
    }
    return argFor;
}

//an authored bound: a single expression, with q provided if the body reads it.
//a bound always encloses in the PLACEMENT frame (p - NAME_P) — even on a
//transformed node, where the bound is a world-space volume around the object,
//not something in its squashed local frame (docs/generator.md §2.7)
function authoredBound(name, NAME, src){
    const bexpr = bodyText(src);
    return `float bound_${name}(vec3 p){\n${qLine(bexpr, `p - ${NAME}_P`)}    return ${bexpr};\n}`;
}

//the Lipschitz divisor of amp*field(q): 1 + amp*gradBound(field), with the
//field's DECLARED gradBound expression kept intact, parenthesized
function divisorText(f, ampT){
    return `1.0 + ${ampT}*(${resolveGlsl(f.gradBound)})`;
}


//-------------------------------------------------
// objects and sheets (units with one region)
//-------------------------------------------------

//localPoint: the GLSL expression a material body reads as `q` — the object's
//OWN local frame, so a texture rides the transform. `p - NAME_P` for a plain
//or displaced object (placement-local == fully-local when there is no
//rotate/scale), `toLocal_<name>(p)` for a transformed one.
function makeRegion(name, spec, localPoint){
    //a bundle DERIVES its medium — an explicit medium: goes with an authored
    //material body, never with a bundle (one source of truth per material)
    if(isMat(spec.material) && spec.medium){
        throw new Error(`scenegen: '${name}': a bundle material derives its own medium — `
            + `remove medium: (authored material bodies may still pair with an authored medium)`);
    }
    return {
        name, NAME: name.toUpperCase(), localPoint, sheet: false,
        material: spec.material,
        medium:   spec.medium ?? null,
        comment:  spec.comment ?? null,
        nestedIn: spec.nestedIn ?? null,
        scatters: isMat(spec.material) && matKind(spec.material) === 'subsurface',
    };
}

//the four sdf forms of a simple shape. Each returns {sdfDef, boundDef};
//boundDef is null when nothing useful can be derived (an authored `bound:`
//on the node overrides either way). ctx: {name, NAME, entry, args, argFor,
//comment} — the resolved naming of one shape reference.

//"<local>" or "<local>, a, b" — no trailing comma when a shape (or its bound)
//takes no parameters beyond the point (e.g. apollonianBound(vec3 p))
function withArgs(local, extra){ return extra.length ? `${local}, ${extra.join(', ')}` : local; }

function sdfPlain(node, c){
    return {
        sdfDef: `${c.comment}float sdf_${c.name}(vec3 p){\n    return ${c.entry.stem}Distance(${withArgs(`p - ${c.NAME}_P`, c.args)});\n}`,
        boundDef: c.entry.bound
            ? `float bound_${c.name}(vec3 p){\n    return ${c.entry.stem}Bound(${withArgs(`p - ${c.NAME}_P`, c.entry.bound.map(n => c.argFor[n]))});\n}`
            : null,
    };
}

function sdfDisplaced(node, c){
    const f    = node.shape.by;
    const ampT = refText(node.shape.amp, `displace amp of '${c.name}'`);
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
        ? `    mat3 rot = rot3AxisAngle(normalize(${c.NAME}_AXIS), ${refText(node.rotate.angle, `rotate angle of '${c.name}'`)});\n`
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


function planObject(node, forceMarch){
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
        consts.push({type: 'float', name: `${NAME}_SPACING`, text: constText('float', node.shape.spacing, `repLim spacing of '${name}'`)});
        consts.push({type: 'vec3',  name: `${NAME}_LIMIT`,   text: fvec3(node.shape.limit)});
    }
    const argFor = shapeArgs(NAME, node.shape, consts);
    const args   = entry.params.map(p => argFor[p.name]);

    //trace routing: a displaced, repeated, or transformed shape has no closed
    //form any more, so it loses its trace and marches. A medium boundary is
    //FORCED to march even when it has a trace: odeMarch finds the confining wall
    //only by an sdf_Scene sign change, never trace_Scene (docs/curved-light-scenegen.md)
    const forced   = !!(forceMarch && forceMarch.has(name));
    const analytic = !!entry.trace && kind === 'plain' && !transformed && !forced;
    const comment  = node.comment ? commentLines(node.comment) + '\n' : '';

    const ctx = {name, NAME, entry, args, argFor, comment};
    const build = kind === 'displaced' ? sdfDisplaced
                : kind === 'repLim'    ? sdfRepLim
                : transformed          ? sdfTransformed
                :                        sdfPlain;
    let {sdfDef, boundDef} = build(node, ctx);

    //an authored bound is authored knowledge: it beats anything derived
    if(node.bound) boundDef = authoredBound(name, NAME, node.bound);

    //an analytic object never marches, so a bound would never run: drop a
    //derived one silently, refuse an authored one loudly (it is author error)
    if(analytic){
        if(node.bound){
            throw new Error(`scenegen: ${node.__node}('${name}') is analytic (traced, never marched) — `
                + `its bound: would never run; remove it`);
        }
        boundDef = null;
    }

    //a transformed object's material reads q in its OWN frame (toLocal_); a
    //plain/displaced one has no rotate/scale, so placement-local IS fully-local
    const localPoint = transformed ? `toLocal_${name}(p)` : `p - ${NAME}_P`;

    //a sheet is the same unit with a two-faced region instead of a material.
    //(node.comment belongs to the sdf; region comments come from group specs)
    const region = (node.__node === 'sheet')
        ? {name, NAME, localPoint, sheet: true, front: node.front, back: node.back,
           medium: null, comment: null, nestedIn: null, scatters: false}
        : makeRegion(name, {material: node.material, medium: node.medium, nestedIn: node.nestedIn}, localPoint);

    //shape-data outputs available to this region's material: <name>Data injected
    //with the object's own consts baked in (docs/shape-data.md). The call reads q
    //(the material's local point), so the emitter emits it after the q line.
    region.dataOutputs = (entry.dataOutputs ?? []).map(d => ({
        inject: d.inject,
        type:   d.type,
        call:   `${d.fn}(q${d.params.length ? ', ' + d.params.map(p => argFor[p]).join(', ') : ''})`,
    }));

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
// groups (one shape evaluation, several region slots)
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
    //a group is never transformed (rotate/scale live on plain objects), so a
    //region's material reads q as the group's placement-local point
    const regions = regionNames.map(r => makeRegion(r, node.regions[r], `p - ${NAME}_P`));

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


export function planNode(node, forceMarch){
    if(node.__node === 'object' || node.__node === 'sheet') return planObject(node, forceMarch);
    if(node.__node === 'group') return planGroup(node);   //groups already march (never analytic)
    throw new Error(`scenegen: node kind '${node.__node}' is not emittable yet`);
}

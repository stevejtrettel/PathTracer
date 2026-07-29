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
//
// A shape is a base plus an ordered MODIFIER CHAIN (combinators.js), folded
// here into one sdf: the transform gives the local point, the domain mods
// fold it, the base is evaluated, the field mods act on the distance, and
// the divisor/scale factors close the return. The bound is folded alongside
// by the same chain (docs/shape-modifiers.md). chainBody renders a chain as
// statements, chainBoundExpr as its bound; a clip/subtract CUTTER is the
// same fold again, planned by planCutter.
//-------------------------------------------------

import {fnum, fvec2, fvec3, indent, pad, commentLines} from './fmt.js';
import {isGlsl, resolveGlsl, bodyText, qLine} from './glslTag.js';
import {isMat, matKind} from './materials.js';
import {planVariety} from './varieties.js';


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
//are uniforms already); glsl`` fragments are inlined. NAME is the const-name
//prefix (a cutter passes its own `<NAME>_<tok>`); `where` labels errors.
function shapeArgs(NAME, shape, consts, where = `lib.${shape.entry.stem}`){
    const argFor = {};
    for(const p of shape.entry.params){
        const v = shape.values[p.name];
        if(v && v.__knob){ argFor[p.name] = v.name; }
        else if(isGlsl(v)){ argFor[p.name] = resolveGlsl(v); }
        else{
            const cname = `${NAME}_${p.name.toUpperCase()}`;
            consts.push({type: p.type, name: cname, text: constText(p.type, v, `${where} parameter '${p.name}'`)});
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

//"<local>" or "<local>, a, b" — no trailing comma when a shape (or its bound)
//takes no parameters beyond the point (e.g. apollonianBound(vec3 p))
function withArgs(local, extra){ return extra.length ? `${local}, ${extra.join(', ')}` : local; }

//a shape's own bound as text: its Bound if the catalogue has one, else its
//Distance — the starting point of every derived-bound fold
const boundBaseOf = (entry, argFor, args) => (pt) => entry.bound
    ? `${entry.stem}Bound(${withArgs(pt, entry.bound.map(n => argFor[n]))})`
    : `${entry.stem}Distance(${withArgs(pt, args)})`;


//-------------------------------------------------
// the fold — one shape chain -> sdf text + derived bound
//-------------------------------------------------

//the fold context handed to each modifier's plan(): how a modifier turns its
//description values into emitted text. The one rule (shared with carve's
//original cv): a knob stays a bare uniform (an int knob in a float slot is
//cast at the call); anything else becomes a const, named <NAME>_<SUFFIX> —
//with a numeric suffix if a repeated modifier already claimed the name
//(<NAME>_SPACING, <NAME>_SPACING2, ...; tokens CLIP, CLIP2, ... likewise).
//
//`local` is the node's PRE-FOLD local point — what clip/subtract evaluate
//their cutter at (a cutter is a placed volume, so it lives in the placement
//frame, not the folded one; docs/shape-modifiers.md). `child(prefix)` is the
//same context with every const it allocates prefixed — a cutter's values
//land as <NAME>_<tok>_* beside the unit's own rows.
function makeFoldCtx(name, NAME, consts, local){
    const used   = new Set();
    const tokens = new Set();
    const claim = (set, base) => {
        let t = base, i = 2;
        while(set.has(t)) t = base + i++;
        set.add(t);
        return t;
    };

    function value(type, suffix, v, where){
        if(v && v.__knob){
            return (type === 'float' && v.type === 'int') ? `float(${v.name})` : v.name;
        }
        const cname = `${NAME}_${claim(used, suffix)}`;
        consts.push({type, name: cname, text: constText(type, v, where)});
        return cname;
    }

    const child = (parent, prefix) => {
        const c = {...parent, cpfx: `${parent.cpfx}_${prefix}`,
                   value: (t, s, v, w) => parent.value(t, `${prefix}_${s}`, v, w)};
        c.child  = (p) => child(c, p);
        c.cutter = (shape, tok, at, where) => planCutter(shape, c, tok, at, where);
        return c;
    };

    const fx = {
        name, NAME, cpfx: NAME, consts, local, value,
        num:    (v, where) => refText(v, where),
        glsl:   (frag) => resolveGlsl(frag),
        token:  (base) => claim(tokens, base),
        child:  (prefix) => child(fx, prefix),
        cutter: (shape, tok, at, where) => planCutter(shape, fx, tok, at, where),
    };
    return fx;
}

//fold a planned chain's BOUND: the base's bound at the domain-folded point
//(a fold is 1-Lipschitz, so the folded bound stays conservative), then each
//field mod KEEPS it (carve/subtract erode into the base), INFLATES it
//(displace/round/shell push the surface out), or REPLACES it (clip).
//Inflations accumulate as subtractions; a replacement resets them.
function chainBoundExpr(planned, boundBase, pt){
    const domain = planned.filter(m => m.fold);
    const fields = planned.filter(m => m.line || m.expr);
    let running  = boundBase(domain.reduce((acc, m) => m.fold(acc), pt));
    let inflates = [];
    for(const f of fields){
        const e = f.boundEffect;
        if(!e || e === 'keep') continue;
        if(e.inflate) inflates.push(e.inflate);
        else if(e.replace){ running = e.replace(pt); inflates = []; }
    }
    return running + inflates.map(t => ` - ${t}`).join('');
}

//render a planned chain as the statement body of a float-returning function
//of one point. The collapse rules keep simple chains reading like the hand
//files: no q/d locals unless something needs them, the first domain fold
//inlines the local point, a trailing field mod's expression form folds into
//the return, a divisor closes it as d/(1 + Σ terms).
//
//opts: local      the pre-fold local point ('p - <NAME>_P',
//                 'toLocal_<name>(p)', or a cutter helper's own 'p')
//      bindLocal  bind `local` to a variable when placed-volume mods reuse
//                 it — a transformed node's cutter must not run toLocal_
//                 twice per evaluation
//      forceD     introduce `float d` even with no field mods (the
//                 transformed form the goldens pin)
//      lip        factor appended to the final distance (non-uniform scale)
function chainBody(planned, baseCall, {local, bindLocal = false, forceD = false, lip = ''}){
    const domain    = planned.filter(m => m.fold);
    const fields    = planned.filter(m => m.line || m.expr);
    const localMods = fields.filter(f => f.frame === 'local');

    const needQ = domain.length > 0 || fields.some(f => f.readsQ);
    const needD = fields.length > 0 || forceD;

    //where the placed-volume mods read the local point: bound to a variable
    //when it is expensive and reused — q itself IS the binding when nothing
    //folds it, q0 (the pre-fold point) when a domain mod does
    let localRef = local, qInit = local, bindQ0 = false;
    if(bindLocal && localMods.length){
        if(domain.length === 0){ localRef = 'q'; }
        else{ bindQ0 = true; localRef = 'q0'; qInit = 'q0'; }
    }

    const lines = [];
    const vec   = needD ? pad('vec3', 5) : 'vec3';
    if(bindQ0) lines.push(`    ${vec} q0 = ${local};`);
    const useQ = needQ || localRef === 'q';
    if(useQ){
        lines.push(`    ${vec} q = ${domain.length ? domain[0].fold(qInit) : qInit};`);
        lines.push(...domain.slice(1).map(m => `    q = ${m.fold('q')};`));
    }
    const basePt   = useQ ? 'q' : local;
    const baseText = baseCall(basePt);
    if(needD) lines.push(`    float d = ${baseText};`);

    const ptFor = (f) => f.frame === 'local' ? localRef : basePt;
    const divisorTerms = fields.map(f => f.divisor).filter(Boolean);
    let stmts = fields.map(f => `    ${f.expr ? `d = ${f.expr('d', ptFor(f))};` : f.line}`);
    let ret;
    if(!needD){
        ret = `    return ${baseText};`;
    }
    else if(divisorTerms.length){
        //the Lipschitz divisor of every displacement in the chain, summed;
        //dividing a conservative distance by >= 1 stays conservative
        ret = `    return d/(1.0 + ${divisorTerms.join(' + ')})${lip};`;
    }
    else{
        const last = fields[fields.length - 1];
        if(last && last.expr){ stmts = stmts.slice(0, -1); ret = `    return ${last.expr('d', ptFor(last))}${lip};`; }
        else                 { ret = `    return d${lip};`; }
    }
    return [...lines, ...stmts, ret].join('\n');
}

//plan the OPERAND of clip/subtract: a called lib shape, or a modifier chain
//over one, used purely as a cutting volume. Its consts land on the unit as
//<NAME>_<tok>_*. A plain cutter stays one inline Distance call; a MODIFIED
//cutter becomes its own small function (`clip_<name>`, `cut_<name>`, ...) so
//its folds and field mods evaluate once per call. The bound side folds the
//cutter's chain through the same keep/inflate/replace rules as the unit's —
//a carved cutter donates its UNCARVED base, never the full erosion.
function planCutter(shape, fx, tok, at, where){
    const zero = Array.isArray(at) && at.every(x => x === 0);
    let P = null;
    if(!zero){
        P = `${fx.cpfx}_${tok}_P`;
        fx.consts.push({type: 'vec3', name: P, text: fvec3(at)});
    }
    const off = (pt) => P ? `${pt} - ${P}` : pt;

    const planned = (shape.mods ?? []).map(m => m.plan(fx.child(tok)));
    const bad = planned.find(f => f.divisor);
    if(bad) throw new Error(`scenegen: ${where}: a cutter cannot carry a displacement divisor`);

    const argFor = shapeArgs(`${fx.cpfx}_${tok}`, shape, fx.consts, where);
    const args   = shape.entry.params.map(p => argFor[p.name]);

    const boundExpr  = (pt) => chainBoundExpr(planned, boundBaseOf(shape.entry, argFor, args), off(pt));
    const helperDefs = planned.flatMap(m => m.helperDefs ?? []);

    if(!planned.length){
        return {call: (pt) => `${shape.entry.stem}Distance(${withArgs(off(pt), args)})`, boundExpr, helperDefs};
    }
    const cutBase = (pt) => `${shape.entry.stem}Distance(${withArgs(pt, args)})`;
    const fnName = `${tok.toLowerCase()}_${fx.name}`;
    helperDefs.push(`float ${fnName}(vec3 p){\n${chainBody(planned, cutBase, {local: 'p'})}\n}`);
    return {call: (pt) => `${fnName}(${off(pt)})`, boundExpr, helperDefs};
}

//fold one planned chain into {sdfDef, boundDef}.
//ctx: {name, NAME, entry, args, argFor, comment, transformed, planned, local}
//plus the node for rotate/scale.
function buildChain(node, c){
    //world -> local: undo the placement, then the rotation (GLSL's v*M is
    //the rotation's inverse), then the scale
    let toLocal = '';
    if(c.transformed){
        const rotLn = node.rotate
            ? `    mat3 rot = rot3AxisAngle(normalize(${c.NAME}_AXIS), ${refText(node.rotate.angle, `rotate angle of '${c.name}'`)});\n`
            : '';
        let back;
        if(node.rotate && node.scale) back = `((p - ${c.NAME}_P) * rot) / ${c.NAME}_SCALE`;
        else if(node.rotate)          back = `(p - ${c.NAME}_P) * rot`;
        else                          back = `(p - ${c.NAME}_P) / ${c.NAME}_SCALE`;
        toLocal = `vec3 toLocal_${c.name}(vec3 p){\n${rotLn}    return ${back};\n}\n\n`;
    }

    //a non-uniform scale makes the local sdf overestimate world distance by
    //the largest singular value; multiplying by the smallest component
    //restores a conservative underestimate — applied to the FINAL distance,
    //after every field mod. The 4-tap normal needs NO fixup: it
    //differentiates the world function (chain rule).
    const S   = `${c.NAME}_SCALE`;
    const lip = node.scale ? ` * min(${S}.x, min(${S}.y, ${S}.z))` : '';

    const body = chainBody(c.planned, c.baseCall,
        {local: c.local, bindLocal: c.transformed, forceD: c.transformed, lip});
    const helpers = c.planned.flatMap(m => m.helperDefs ?? []);
    const sdfDef = toLocal
        + (c.prefixDefs ? c.prefixDefs + '\n\n' : '')
        + (helpers.length ? helpers.join('\n\n') + '\n\n' : '')
        + `${c.comment}float sdf_${c.name}(vec3 p){\n${body}\n}`;

    //the derived bound, folded alongside the sdf by chainBoundExpr. Emitted
    //only when it differs from the sdf itself: a bound textually equal to
    //the sdf accelerates nothing. A transformed node derives no bound (a
    //placement-frame expression cannot enclose a rotated body) — its bound
    //is authored, as today. An authored bound: overrides either way.
    let boundDef = null;
    if(!c.transformed){
        const fields = c.planned.filter(m => m.line || m.expr);
        if(fields.length > 0 || (c.entry && c.entry.bound)){
            const expr = chainBoundExpr(c.planned, c.boundBase, `p - ${c.NAME}_P`);
            boundDef = `float bound_${c.name}(vec3 p){\n    return ${expr};\n}`;
        }
    }

    return {sdfDef, boundDef};
}


//-------------------------------------------------
// objects and sheets (units with one region)
//-------------------------------------------------

//localPoint: the GLSL expression a material body reads as `q` — the object's
//OWN local frame, so a texture rides the transform. `p - NAME_P` for an
//untransformed object (placement-local == fully-local when there is no
//rotate/scale), `toLocal_<name>(p)` for a transformed one. A domain fold
//does NOT change it: materials read the UNFOLDED point (docs/shape-modifiers.md).
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


function planObject(node, forceMarch){
    const name = node.name;
    const NAME = name.toUpperCase();
    if(!node.shape || !node.shape.__shape){
        throw new Error(`scenegen: ${node.__node}('${name}'): shape must come from lib.<stem>({...}) or variety(...)`);
    }
    const isVariety = !!node.shape.__variety;
    const entry = isVariety ? null : node.shape.entry;
    if(entry && entry.outputs){
        throw new Error(`scenegen: object('${name}'): ${entry.stem} yields several outputs (${entry.outputs.join(', ')}) — `
            + `call it from a group's authored sdf body (with uses: [lib.${entry.stem}])`);
    }

    const mods        = node.shape.mods ?? [];
    const transformed = !!(node.scale || node.rotate);
    if(node.rotate && (!node.rotate.axis || node.rotate.angle === undefined)){
        throw new Error(`scenegen: object('${name}'): rotate needs {axis: [x,y,z], angle}`);
    }

    //the node's local frame, computed ONCE: the fold (cutters), the sdf
    //renderer, and the material slot all read this same expression
    const local = transformed ? `toLocal_${name}(p)` : `p - ${NAME}_P`;

    //consts: placement, then transform data, then each modifier's rows in
    //chain order, then the shape's own parameters — matching the hand files'
    //block order
    const consts = [{type: 'vec3', name: `${NAME}_P`, text: fvec3(node.at)}];
    if(node.scale)  consts.push({type: 'vec3', name: `${NAME}_SCALE`, text: fvec3(node.scale)});
    if(node.rotate) consts.push({type: 'vec3', name: `${NAME}_AXIS`,  text: fvec3(node.rotate.axis)});

    const fx      = makeFoldCtx(name, NAME, consts, local);
    const planned = mods.map(m => m.plan(fx));

    //a variety base: its data_ helpers, its varietyDistance base call, and
    //NO derivable bound of its own — a clip in the chain (bound donation) or
    //an authored bound: is REQUIRED (docs/variety-builder.md §9)
    const vplan = isVariety ? planVariety(node.shape.__variety, name, fx) : null;
    if(isVariety && !node.bound && !mods.some(m => m.kind === 'clip')){
        throw new Error(`scenegen: ${node.__node}('${name}'): a variety has no derivable bound — clip it to `
            + `a shape (clip(..., {to: ...}) donates its bound) or author a bound: on the node `
            + `(docs/variety-builder.md §9)`);
    }

    const argFor = isVariety ? {} : shapeArgs(NAME, node.shape, consts);
    const args   = isVariety ? [] : entry.params.map(p => argFor[p.name]);

    //trace routing: a modified or transformed shape has no closed form any
    //more, so it loses its trace and marches. A medium boundary is FORCED to
    //march even when it has a trace: odeMarch finds the confining wall only
    //by an sdf_Scene sign change, never trace_Scene (docs/curved-light-scenegen.md)
    const forced   = !!(forceMarch && forceMarch.has(name));
    const analytic = !isVariety && !!entry.trace && mods.length === 0 && !transformed && !forced;
    const comment  = node.comment ? commentLines(node.comment) + '\n' : '';

    const baseCall = isVariety
        ? vplan.call
        : (pt) => `${entry.stem}Distance(${withArgs(pt, args)})`;
    const boundBase = isVariety
        ? (() => 'VARIETY_UNBOUNDED')      //never ships: the validation above guarantees a clip replaces it or an authored bound overrides
        : boundBaseOf(entry, argFor, args);

    const ctx = {name, NAME, entry, args, argFor, comment, transformed, planned, local,
                 baseCall, boundBase, prefixDefs: vplan ? vplan.defs : null};
    let {sdfDef, boundDef} = buildChain(node, ctx);

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

    //THE MARCHED-SHEET RULE (docs/variety-builder.md §7, from the hand
    //variety scene): the marcher stops on {s=0} and passes through {s<0} —
    //abs on the pre-cutter value, cutters HARD-maxed outside the abs so the
    //clip cap over {s<0} is not drawn. The signed sdf_<name> stays what the
    //classifier and normals read. Until now every sheet was analytic; this
    //is the first marched form.
    let marchDef = null;
    if(node.__node === 'sheet' && !analytic){
        if(transformed){
            throw new Error(`scenegen: sheet('${name}'): a marched sheet cannot carry rotate/scale yet — `
                + `place it with at: only`);
        }
        const bad = mods.find(m => m.phase !== 'domain' && m.kind !== 'clip');
        if(bad){
            throw new Error(`scenegen: sheet('${name}'): a marched sheet's chain may carry domain mods and `
                + `clip only — ${bad.kind}() gives it an interior; use object() (docs/variety-builder.md §7)`);
        }
        const domain = planned.filter(m => m.fold);
        const cuts   = planned.filter(m => m.cutCall);
        const lines  = [];
        if(domain.length){
            lines.push(`    ${pad('vec3', 5)}q = ${domain[0].fold(local)};`);
            lines.push(...domain.slice(1).map(m => `    q = ${m.fold('q')};`));
        }
        lines.push(`    float d = ${baseCall(domain.length ? 'q' : local)};`);
        let stop = 'abs(d)';
        for(const c of cuts) stop = `max(${stop}, ${c.cutCall(local)})`;
        lines.push(`    return ${stop};`);
        marchDef = `//the marched form: abs stops the ray on {s=0}; the hard max keeps the\n`
                 + `//cut cap over {s<0} undrawn. sdf_${name} stays signed for faces/normals.\n`
                 + `float march_${name}(vec3 p){\n${lines.join('\n')}\n}`;
    }

    //a sheet is the same unit with a two-faced region instead of a material.
    //(node.comment belongs to the sdf; region comments come from group specs)
    const region = (node.__node === 'sheet')
        ? {name, NAME, localPoint: local, sheet: true, front: node.front, back: node.back,
           medium: null, comment: null, nestedIn: null, scatters: false}
        : makeRegion(name, {material: node.material, medium: node.medium, nestedIn: node.nestedIn}, local);

    //shape-data outputs available to this region's material: <name>Data injected
    //with the object's own consts baked in (docs/shape-data.md). The call reads q
    //(the material's local point), so the emitter emits it after the q line.
    region.dataOutputs = ((entry && entry.dataOutputs) ?? []).map(d => ({
        inject: d.inject,
        type:   d.type,
        call:   `${d.fn}(q${d.params.length ? ', ' + d.params.map(p => argFor[p]).join(', ') : ''})`,
    }));

    const marchName = marchDef ? `march_${name}` : `sdf_${name}`;
    return {
        name, NAME, entry,
        //a modifier that calls into a library file (a cutter's shape) rides
        //the include list like a declared uses: — except these can never be
        //stale, the emitted sdf calls them
        usesEntries: [...(node.uses ?? []).map(u => u.entry), ...mods.flatMap(m => m.uses ?? []),
                      ...(vplan ? vplan.usesEntries : [])],
        consts, constsExtra: null, analytic,
        regions: [region],
        sdfDefs: sdfDef + (marchDef ? '\n\n' + marchDef : ''),
        boundDef,
        sdfAllLine: (idW) => `    gSDF[${pad(`ID_${NAME}`, idW)}] = sdf_${name}(p);`,
        marchedBlock: analytic ? null : (boundDef
            ? `    float b_${name} = bound_${name}(p);\n    d = min(d, (b_${name} > BOUND_MARGIN) ? b_${name} : ${marchName}(p));`
            : `    d = min(d, ${marchName}(p));`),
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

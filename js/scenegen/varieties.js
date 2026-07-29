//-------------------------------------------------
// VARIETIES — equations as first-class bases (docs/variety-builder.md)
//
// A variety is authored as an EQUATION whose zero set is the surface;
// everything downstream rides the existing machinery: clip() bounds it (and
// donates the acceleration volume), shell() thickens it, and the node kind
// picks the mode — object() = solid region {s < 0}, sheet() = the zero set
// as an infinitely thin two-faced surface (abs at the marcher only).
//
// Sources, the rungs of §5:
//   varieties.<name>                     the CATALOGUE, parsed from
//                                        glsl/shapes/varieties/ (standard
//                                        float GLSL — transpiler input,
//                                        never included)
//   {eqn: 'x^2*y - c', params: {c: …}}   the transpiler string rung
//   {fns: 'float f(float x, …){…}'}      the transpiler statement rung
//   {data: glsl`…`}                      the escape hatch: an authored body
//                                        returning vec4(grad, value)
//
// Capability is the SIGNATURE (§4): a 3-ary source has the affine view
// only; a 4-ary source defaults to stereo (the S³ double cover) and may opt
// into the generated w = 1 patch. There is no automatic lift.
//
// planVariety() is the plan.js hook: given the fold context it returns the
// emitted data_ helper text, the base-call closure the chain folds, and the
// library entries to include.
//-------------------------------------------------

import {lib} from './catalogue.js';
import {isGlsl, bodyText} from './glslTag.js';
import {indent} from './fmt.js';
import {parseEquation, parseFunctions, checkParams, emitEquation, emitFunctions} from './equations.js';


//---------------------------------------------------------------- catalogue

const RAW = import.meta.glob('../../glsl/shapes/varieties/*.glsl',
                             {query: '?raw', import: 'default', eager: true});

const stripComments = (s) => s.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/\/\/[^\n]*/g, ' ');

//a formula file is standard float GLSL (transpiler input, never included —
//only generated code ships). Trailing-parameter defaults are annotated:
//  //@default <fn>.<param> <value>
//a scene may then omit the parameter (the default bakes) or override it
//(a number, or a knob — live moduli).
function parseFormulaFile(stem, file, src){
    const entry = {stem, file, src};
    const found = [];
    const defaults = {};
    for(const m of src.matchAll(/^\s*\/\/@default\s+(\w+)\.(\w+)\s+(-?[\d.eE+]+)\s*$/gm)){
        (defaults[m[1]] ??= {})[m[2]] = parseFloat(m[3]);
    }
    for(const d of parseFunctions(src).values()){
        if(!d.formula) continue;
        found.push({name: d.name, arity: d.arity, trailing: d.trailing,
                    defaults: defaults[d.name] ?? {}, float: true, entry});
    }
    if(!found.length){
        throw new Error(`scenegen varieties: ${file} defines no formula `
            + `(a formula's leading params are float x, y, z[, w])`);
    }
    return found;
}

function buildVarieties(){
    const byName = {};
    for(const [path, src] of Object.entries(RAW)){
        const stem = path.split('/').pop().replace(/\.glsl$/, '');
        const file = path.replace(/^(\.\.\/)+/, '');
        for(const f of parseFormulaFile(stem, file, src)){
            const prev = byName[f.name];
            if(prev){
                throw new Error(`scenegen varieties: formula '${f.name}' is defined in both `
                    + `${prev.entry.file} and ${f.entry.file}`);
            }
            byName[f.name] = {__varietyFormula: true, ...f};
        }
    }
    return byName;
}

export const varieties = buildVarieties();

//the --catalogue dump: what variety(varieties.<name>, {...}) can name,
//grouped by file, with the capability the SIGNATURE grants (§4)
export function varietiesInfo(){
    const byFile = new Map();
    for(const f of Object.values(varieties)){
        const list = byFile.get(f.entry.file) ?? [];
        list.push(f);
        byFile.set(f.entry.file, list);
    }
    const lines = [`variety formulas — variety(varieties.<name>, {scale, view, params}):`];
    for(const [file, list] of [...byFile.entries()].sort()){
        lines.push(`  ${file}`);
        for(const f of list.sort((a, b) => a.name.localeCompare(b.name))){
            const ps = (f.trailing ?? []).map(t =>
                `${t.name}${t.name in (f.defaults ?? {}) ? ` = ${f.defaults[t.name]}` : ''}`).join(', ');
            lines.push(`    ${f.name}${ps ? `(${ps})` : ''}`
                + `${f.arity === 4 ? '   (projective: stereo | affine patch)' : ''}`);
        }
    }
    return lines.join('\n');
}


//---------------------------------------------------------------- the base

//the view rule (§4): capability is the signature, never the body
function resolveView(name, arity, view){
    if(arity === 3){
        if(view === 'stereo'){
            throw new Error(`scenegen: variety('${name}'): the stereo view needs the homogeneous 4-ary `
                + `form — author it (there is no automatic lift); docs/variety-builder.md §4`);
        }
        return 'affine';
    }
    view = view ?? 'stereo';
    if(view !== 'stereo' && view !== 'affine'){
        throw new Error(`scenegen: variety('${name}'): unknown view '${view}' — 'affine' or 'stereo'`);
    }
    return view;
}

export function variety(source, {scale = 1.0, view = null, params = {}} = {}){
    const kinds = ['a varieties.<name> reference', '{eqn: \'…\'}', '{fns: \'…\'}', '{data: glsl`…`}'];
    if(!source || typeof source !== 'object'){
        throw new Error(`scenegen: variety() needs a source — ${kinds.join(', ')}`);
    }
    const kind = source.__varietyFormula ? 'formula'
               : typeof source.eqn === 'string' ? 'eqn'
               : typeof source.fns === 'string' ? 'fns'
               : isGlsl(source.data) ? 'data'
               : null;
    if(!kind){
        throw new Error(`scenegen: variety(): unrecognized source — expected ${kinds.join(', ')}`);
    }
    if(scale && scale.__knob){
        if(scale.type !== 'float' || scale.min <= 0){
            throw new Error(`scenegen: variety(): a scale knob must be type float with min > 0 `
                + `(the DE divides by it) — got '${scale.name}'`);
        }
    }
    else if(!(typeof scale === 'number' && Number.isFinite(scale) && scale > 0)){
        throw new Error(`scenegen: variety(): scale must be a number > 0 or a float knob, got ${JSON.stringify(scale)}`);
    }
    //a catalogue reference knows its arity now — validate the view early
    if(kind === 'formula') resolveView(source.name, source.arity, view);
    if(kind === 'data' && view !== null){
        throw new Error(`scenegen: variety(): an authored data: body owns its own math — view: does not apply`);
    }
    return {__shape: true, __variety: {kind, source, scale, view, params: source.params ?? params}, mods: []};
}


//---------------------------------------------------------------- planning

//resolve a params map into GLSL reference texts: knobs stay bare, numbers
//become named consts — the same rule as everywhere else. `list` entries are
//names (the eqn rung) or {name, type} (function trailing params, where int
//is legal — a Chebyshev order).
function paramRefs(list, values, fx, what){
    const refs = {};
    for(const p of list){
        const name = typeof p === 'string' ? p : p.name;
        const type = typeof p === 'string' ? 'float' : p.type;
        refs[name] = fx.value(type, name.toUpperCase(), values[name], `${what} parameter '${name}'`);
    }
    return refs;
}

//the base call: varietyDistance(data(scale*q), scale) — the chain rule
//puts the scale on the gradient, keeping distances in local units
function makeCall(v, name, fx){
    const one = typeof v.scale === 'number' && v.scale === 1;
    const S   = one ? null : fx.value('float', 'VSCALE', v.scale, `variety scale of '${name}'`);
    const at  = (pt) => (/^[A-Za-z_]\w*$/.test(pt) ? pt : `(${pt})`);
    return (pt) => one
        ? `varietyDistance(data_${name}(${pt}), 1.0)`
        : `varietyDistance(data_${name}(${S}*${at(pt)}), ${S})`;
}

//plan one variety base: emitted helper text (defs, per-object), shared defs
//(twins, deduped chunk-wide by the emitter), the base-call closure the
//chain renders, and the include entries. `fx` is the fold context.
export function planVariety(v, name, fx){
    let defs, usesEntries = [lib.variety.entry];

    if(v.kind === 'formula' && v.source.float){
        //a FLOAT catalogue formula: transpiler input, nothing included —
        //only generated code ships. Defaults fill omitted trailing params.
        //The TWINS are shared chunk-wide (two objects naming one formula
        //emit them once); the data_ wrapper is the per-object piece.
        const f = v.source;
        const merged = {...f.defaults, ...v.params};
        checkParams({params: f.trailing.map(t => t.name)}, merged);
        const refs = paramRefs(f.trailing, merged, fx, `variety '${name}'`);
        const out  = emitFunctions({name, src: f.entry.src, formula: f.name, refs, view: v.view, split: true});
        return {defs: out.wrapper, call: makeCall(v, name, fx), usesEntries,
                shared: [{key: `variety twins: ${f.name}`, text: out.twins}]};
    }
    else if(v.kind === 'eqn'){
        const eq = parseEquation(v.source.eqn);
        checkParams(eq, v.params);
        const refs = paramRefs(eq.params, v.params, fx, `variety '${name}'`);
        defs = emitEquation({name, src: v.source.eqn, refs, view: v.view}).trimEnd();
    }
    else if(v.kind === 'fns'){
        const fdefs    = parseFunctions(v.source.fns);
        const formulas = [...fdefs.values()].filter(d => d.formula);
        if(formulas.length !== 1){
            throw new Error(`scenegen: variety('${name}'): expected exactly one formula in fns: — `
                + `found ${formulas.length ? formulas.map(f => f.name).join(', ') : 'none'}`);
        }
        checkParams({params: formulas[0].trailing.map(t => t.name)}, v.params);
        const refs = paramRefs(formulas[0].trailing, v.params, fx, `variety '${name}'`);
        defs = emitFunctions({name, src: v.source.fns, refs, view: v.view}).trimEnd();
    }
    else{      //'data' — the escape hatch: the author owns the math AND the contract
        defs = `//authored data body: returns vec4(grad, value) — the author's contract\n`
             + `vec4 data_${name}(vec3 p){\n${indent(bodyText(v.source.data), 4)}\n}`;
    }

    return {defs, call: makeCall(v, name, fx), usesEntries, shared: []};
}

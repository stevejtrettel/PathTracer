//-------------------------------------------------
// MATERIALS — the value-bundle PRIMITIVES over the one material model
//
// Many sdfs, one material model (docs/generator.md §5): a material is not
// code, it is a point in the parameter space of the fixed Surface/Medium
// model in 3Materials/material.glsl. This file holds ONLY the primitives the
// emitter reasons about — it names no particular material. Every named
// material (matte, gloss, glass, terracotta, ...) is a PRESET over these, in
// js/presets/materials.js.
//
//   material({surf:{...}, interior:{...}})   make a bundle from real struct fields
//   withSurface / withMedium / named          merge / label a bundle
//   matKind / isMat                           how the emitter reads a bundle
//   absorbFor                                 the one GLSL-expression helper
//   checkArgs                                 arg validation, for preset authors
//
// A bundle is plain data: {__mat:true, name, surf:{field:value,...},
// interior:{field:value,...}}. Field names are the STRUCT'S OWN (validated
// against SURF_FIELDS/MEDIUM_FIELDS) — NO RENAMES: an authored scene and the
// emitted chunk both speak the model's real field names.
//
// KIND derives structurally from which fields are SET (never values, so knobs
// stay live): mfp → subsurface; transmit + any interior field → volume; else
// surface.
//-------------------------------------------------

import {valueText, isGlsl} from './glslTag.js';


//the settable fields, PARSED from the model's own structs — no hand-maintained
//mirror to drift. Declaration order is preserved, and emission order follows
//it. An unparseable model is a loud load error (the parse is load-bearing).
const MODEL = import.meta.glob('../../glsl/tracer/3Materials/material.glsl',
                              {query: '?raw', import: 'default', eager: true});

function structFields(src, name){
    const m = src.match(new RegExp(`struct\\s+${name}\\s*\\{([^}]*)\\}`));
    if(!m) throw new Error(`scenegen materials: cannot find 'struct ${name}' in material.glsl`);
    const body   = m[1].replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/\/\/[^\n]*/g, ' ');
    const fields = [...body.matchAll(/\b(?:float|int|bool|vec[234]|mat[234])\s+(\w+)\s*;/g)].map(x => x[1]);
    if(!fields.length) throw new Error(`scenegen materials: parsed no fields from 'struct ${name}'`);
    return fields;
}

const modelSrc = Object.values(MODEL)[0];
if(!modelSrc) throw new Error('scenegen materials: 3Materials/material.glsl not found for the struct parse');

export const SURF_FIELDS   = structFields(modelSrc, 'Surface');
export const MEDIUM_FIELDS = structFields(modelSrc, 'Medium');

function checkFields(where, fields, allowed){
    for(const key of Object.keys(fields)){
        if(!allowed.includes(key)){
            throw new Error(`scenegen: ${where}: no field '${key}' in the material model `
                + `(have: ${allowed.join(', ')})`);
        }
    }
}

//drop keys whose value is undefined, so optional fields vanish instead of
//emitting garbage
function set(fields){
    return Object.fromEntries(Object.entries(fields).filter(([, v]) => v !== undefined));
}

//the escape hatch: a bundle from raw struct fields, exactly as sdfs have the
//authored-glsl escape hatch. Everything named is a preset over this.
export function material({surf = {}, interior = {}} = {}, name = null){
    checkFields(`material(${name ?? ''})`, surf, SURF_FIELDS);
    checkFields(`material(${name ?? ''})`, interior, MEDIUM_FIELDS);
    return {__mat: true, name, surf: set(surf), interior: set(interior)};
}

export function isMat(x){
    return !!(x && x.__mat === true);
}

//kind, derived from which fields are set (docs/generator.md §5)
export function matKind(m){
    if(m.interior.mfp !== undefined) return 'subsurface';
    if(m.surf.transmit !== undefined && Object.keys(m.interior).length > 0) return 'volume';
    return 'surface';
}

//a MEDIUM (curved-light region): an interior whose IOR is a position-varying
//field, i.e. a glsl`` expression rather than a constant. That one structural fact
//— derived, like matKind, from HOW a field is set, not its value — is what makes
//the object a region the ODE marcher bends light through (docs/curved-light-scenegen.md).
export function matIsMedium(m){
    return isMat(m) && isGlsl(m.interior.ior);
}


//---------------------------------------------------------------- merges

export function withSurface(base, fields){
    if(!isMat(base)) throw new Error('scenegen: withSurface(base, {...}) wraps a material bundle');
    checkFields('withSurface', fields, SURF_FIELDS);
    return {...base, surf: {...base.surf, ...set(fields)}};
}

export function withMedium(base, fields){
    if(!isMat(base)) throw new Error('scenegen: withMedium(base, {...}) wraps a material bundle');
    checkFields('withMedium', fields, MEDIUM_FIELDS);
    return {...base, interior: {...base.interior, ...set(fields)}};
}

//rename a bundle: presets stamp their own name into the emitted comment
export function named(name, base){
    if(!isMat(base)) throw new Error('scenegen: named(name, bundle) wraps a material bundle');
    return {...base, name};
}


//---------------------------------------------------------------- helpers

//validate a preset's exposed named arguments: typos loud, required present.
//exported for preset authors (js/presets/materials.js).
export function checkArgs(fn, spec, required, optional = []){
    if(!spec || typeof spec !== 'object'){
        throw new Error(`scenegen: ${fn}({...}) takes named arguments (${[...required, ...optional].join(', ')})`);
    }
    for(const key of Object.keys(spec)){
        if(!required.includes(key) && !optional.includes(key)){
            throw new Error(`scenegen: ${fn}(): unknown argument '${key}' `
                + `(takes: ${[...required, ...optional].join(', ')})`);
        }
    }
    for(const key of required){
        if(spec[key] === undefined) throw new Error(`scenegen: ${fn}() needs '${key}'`);
    }
}

//the extinction that shows `tint` after `depth` of travel — mirrors the GLSL
//helper, emitted as a call so the arithmetic stays in the library
export function absorbFor(tint, depth){
    return {__expr: true, text: `absorbFor(${valueText(tint)}, ${valueText(depth)})`};
}


//dump for `npm run gen -- --materials`: the model's fields + where materials live
export function materialInfo(){
    return [
        'material model — settable fields (primitives in js/scenegen/materials.js):',
        '  Surface: ' + SURF_FIELDS.join(', '),
        '  Medium:  ' + MEDIUM_FIELDS.join(', '),
        '',
        '  material({surf, interior})  the escape hatch: a bundle from raw fields',
        '  withSurface / withMedium / named / absorbFor',
        '  kind: matKind (sets mfp -> subsurface; transmit+interior -> volume; else surface)',
        '',
        'named materials are PRESETS over these — js/presets/materials.js:',
        '  archetypes: matte, gloss, metal, plastic, glass, subsurface, light, glow, withCoat',
        '  looks:      terracotta, tile, rubber, carPaint, mirror, gold..chrome,',
        '              liquid, honey, diamond, neon, soapFilm, oilSlick,',
        '              jade, porcelain, wax, milk, marble',
    ].join('\n');
}

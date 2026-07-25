//-------------------------------------------------
// THE glsl`` TAG — authored GLSL inside a scene description
//
// A fragment is inert until the emitter resolves it. Interpolations are how
// authored code references scene values: a Knob resolves to its uniform name,
// a Field to its function name, a number to a formatted literal. Interpolation
// is REQUIRED for fields (the emitter needs the dependency); knobs may also be
// referenced by bare name, since they are global uniforms either way.
//
// Also home to the two rules every authored BODY goes through: bodyText
// (resolve + dedent) and qLine (provide q only when the body reads it).
//-------------------------------------------------

import {fnum, fvec3, dedent} from './fmt.js';


export function glsl(strings, ...values){
    return {__glsl: true, strings, values};
}

export function isGlsl(x){
    return !!(x && x.__glsl === true);
}


//any interpolatable value, as GLSL text. Also the formatter for material
//constructor arguments (materials.js) — one rule for what a "value" is.
//
//A single-key object is a NAMED value: `${{latticeHalf}}` (JS shorthand)
//emits `/*latticeHalf*/vec3(...)`, so folded constants keep their meaning
//in the generated code.
export function valueText(v){
    if(typeof v === 'number') return fnum(v);
    if(Array.isArray(v))      return fvec3(v);
    if(v && v.__knob)         return v.name;
    if(v && v.__field)        return v.name;
    if(v && v.__expr)         return v.text;      //expression mirrors (absorbFor)
    if(isGlsl(v))             return resolveGlsl(v);
    if(v && typeof v === 'object' && Object.keys(v).length === 1){
        const key = Object.keys(v)[0];
        return `/*${key}*/` + valueText(v[key]);
    }
    throw new Error(`scenegen: cannot interpolate ${JSON.stringify(v)} into glsl\`\` — `
        + `use knobs, fields, numbers, [x,y,z] vectors, named values ({name: value}), `
        + `or nested glsl\`\` fragments`);
}

export function resolveGlsl(frag){
    let out = frag.strings[0];
    for(let i = 0; i < frag.values.length; i++){
        out += valueText(frag.values[i]) + frag.strings[i + 1];
    }
    return out;
}


//an authored glsl`` body (or a raw string from a ?raw import), dedented
export function bodyText(x){
    if(isGlsl(x)) return dedent(resolveGlsl(x));
    if(typeof x === 'string') return dedent(x);
    throw new Error(`scenegen: expected a glsl\`\` fragment or raw source string`);
}

//the local-point line of an emitted wrapper, only when the body reads q. The
//caller supplies the local-point EXPRESSION, because the right frame depends
//on the slot (docs/generator.md §2.7): a bound encloses in the placement frame
//(p - <NAME>_P), but a transformed object's material textures in the object's
//own frame (toLocal_<name>(p)), matching the frame its sdf sees.
export function qLine(body, localExpr){
    return /\bq\b/.test(body) ? `    vec3 q = ${localExpr};\n` : '';
}

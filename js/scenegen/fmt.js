//-------------------------------------------------
// FORMATTING — JS values -> GLSL source text
//
// The one number rule (docs/generator.md §2.7): integer-valued floats are
// written `X.0`, everything else the SHORTEST decimal that is exact at
// float32 — GLSL floats are float32, so `0.1 + 0.2` emits `0.3`, not the
// float64 noise `String()` would print, and nothing the GPU sees changes.
// Anything that can't be formatted losslessly is a loud error, never a
// silent approximation.
//-------------------------------------------------


export function fnum(x){
    if(typeof x !== 'number' || !Number.isFinite(x)){
        throw new Error(`scenegen: expected a finite number, got ${JSON.stringify(x)}`);
    }
    if(Number.isInteger(x)){
        const s = String(x);
        if(s.includes('e')){
            throw new Error(`scenegen: ${x} formats to exponent notation — write it as a glsl\`\` fragment instead`);
        }
        return `${s}.0`;
    }
    //shortest decimal that survives the trip through the GPU's float32.
    //(few significant digits of a LARGE number format exponentially — skip
    //those and keep adding digits; only a number with no plain form at all
    //falls through to the error)
    const f = Math.fround(x);
    for(let digits = 1; digits <= 17; digits++){
        const s = x.toPrecision(digits);
        if(s.includes('e')) continue;
        if(Math.fround(Number(s)) === f) return s;
    }
    throw new Error(`scenegen: ${x} has no plain decimal form — write it as a glsl\`\` fragment instead`);
}

//vec3 literal; equal components collapse to the one-argument form (vec3(0.9))
export function fvec3(v){
    if(!Array.isArray(v) || v.length !== 3){
        throw new Error(`scenegen: expected [x, y, z], got ${JSON.stringify(v)}`);
    }
    if(v[0] === v[1] && v[1] === v[2]) return `vec3(${fnum(v[0])})`;
    return `vec3(${fnum(v[0])}, ${fnum(v[1])}, ${fnum(v[2])})`;
}

//vec4 literal; equal components collapse to the one-argument form, as vec3 does
export function fvec4(v){
    if(!Array.isArray(v) || v.length !== 4){
        throw new Error(`scenegen: expected [x, y, z, w], got ${JSON.stringify(v)}`);
    }
    if(v[0] === v[1] && v[1] === v[2] && v[2] === v[3]) return `vec4(${fnum(v[0])})`;
    return `vec4(${fnum(v[0])}, ${fnum(v[1])}, ${fnum(v[2])}, ${fnum(v[3])})`;
}

export function fvec2(v){
    if(!Array.isArray(v) || v.length !== 2){
        throw new Error(`scenegen: expected [x, y], got ${JSON.stringify(v)}`);
    }
    return `vec2(${fnum(v[0])}, ${fnum(v[1])})`;
}


//right-pad to a column, for aligned const/dispatcher rows
export const pad = (s, w) => s + ' '.repeat(Math.max(0, w - s.length));

//names no scene-authored thing (node, region, knob, field) may take: the
//emitter's own locals (a region named 'd' would SILENTLY shadow the sdf_Scene
//accumulator — GLSL allows the nested redeclaration) and GLSL keywords that
//pass the identifier regexes. Everything else dies later as a confusing
//shader error; refusing here keeps the message good.
const RESERVED = new Set([
    'd', 'p', 'q', 'n', 'm', 'k', 'id', 'tv', 'front', 'rot', 'face',
    'in', 'out', 'inout', 'uniform', 'const', 'void', 'float', 'int', 'bool',
    'true', 'false', 'if', 'else', 'for', 'while', 'do', 'return', 'break',
    'continue', 'discard', 'struct', 'switch', 'case', 'default',
    'sample', 'filter', 'smooth', 'flat', 'patch', 'precise', 'invariant',
    'layout', 'buffer', 'shared', 'coherent', 'volatile', 'restrict',
    'readonly', 'writeonly', 'lowp', 'mediump', 'highp', 'precision',
]);

export function checkReserved(kind, name){
    if(RESERVED.has(name) || name.startsWith('b_')){
        throw new Error(`scenegen: ${kind} name '${name}' would collide with an emitter local `
            + `or a GLSL keyword — pick another name`);
    }
}

//an authored comment: every line //-prefixed
export function commentLines(text){
    return text.split('\n').map(l => `//${l}`).join('\n');
}

//strip the common indentation of a template-literal block and trim blank
//first/last lines, so authored GLSL bodies can be indented naturally in JS
export function dedent(text){
    let lines = text.split('\n');
    while(lines.length && lines[0].trim() === '') lines.shift();
    while(lines.length && lines[lines.length - 1].trim() === '') lines.pop();
    let indents = lines.filter(l => l.trim() !== '').map(l => l.match(/^\s*/)[0].length);
    let cut = indents.length ? Math.min(...indents) : 0;
    return lines.map(l => l.slice(cut)).join('\n');
}

//indent every non-blank line by `pad` spaces
export function indent(text, pad){
    let sp = ' '.repeat(pad);
    return text.split('\n').map(l => (l.trim() === '' ? '' : sp + l)).join('\n');
}

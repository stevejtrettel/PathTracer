//-------------------------------------------------
// FIELDS — named scalar functions of a LOCAL point, shared between slots
//
// A field exists so that ONE function can drive several things at once — the
// rock's height field displaces the sdf AND colours the surface, and the two
// can never drift apart because they are the same function.
//
// There is exactly ONE kind of field: a GLSL function you wrote (a glsl``
// fragment, a ?raw file import, or a preset-built source string), plus the
// facts the emitter cannot derive from it — gradBound and range, required
// only if the field displaces geometry. The emitter never infers metadata
// from code; presets that KNOW their math (fbm2Height in presets.js) fill
// the declarations in for you.
//
// Fields self-register (like knobs, drained by scene() onto the description)
// and are emitted in declaration order, in their own section before the sdfs.
// Reference a field inside authored GLSL by interpolation — `${rockHeight}(q)`
// — which is also how the emitter learns the dependency.
//-------------------------------------------------

import {bodyText} from './glslTag.js';
import {checkReserved} from './fmt.js';

const registry = [];


export function field(src, {name, gradBound, range} = {}){
    const body = bodyText(src);
    const parsed = body.match(/float\s+(\w+)\s*\(\s*vec3\s+q\s*\)/);
    const fname = name ?? parsed?.[1];
    if(!fname){
        throw new Error(`scenegen: field(): cannot find 'float <name>(vec3 q)' in the source — `
            + `name it explicitly with {name}`);
    }
    checkReserved('field', fname);
    const f = {
        __field: true,
        name: fname, body,
        gradBound: gradBound ?? null,     //glsl`` expression; required to displace
        range: range ?? null,             //[lo, hi]; required to displace
    };
    registry.push(f);
    return f;
}

export function isField(x){
    return !!(x && x.__field === true);
}

export function drainFields(){
    const byName = new Map();
    for(const f of registry){
        const prev = byName.get(f.name);
        if(prev && JSON.stringify(prev) !== JSON.stringify(f)){
            const differs = Object.keys(f).filter(k => JSON.stringify(f[k]) !== JSON.stringify(prev[k]));
            throw new Error(`scenegen: field '${f.name}' declared twice with different ${differs.join('/')}`);
        }
        byName.set(f.name, f);
    }
    registry.length = 0;
    return [...byName.values()];
}

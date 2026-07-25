//-------------------------------------------------
// KNOBS — tunable controls declared at their point of use
//
// knob() returns a JS binding usable anywhere a number goes (shape params,
// material args, glsl`` interpolations) and SELF-REGISTERS: scene() drains
// the registry onto the description it returns, so declarations live in
// scene.js while current VALUES come from settings.js (Save-to-Scene writes
// only settings). Two knobs with the same name are one knob if their
// declarations agree, and a loud error if not — module re-evaluation (HMR)
// makes exact duplicates normal.
//-------------------------------------------------

import {checkReserved} from './fmt.js';

const registry = [];

//the widget kinds js/gui/widgets.js dispatches on — anything else would fall
//through to a (wrong) slider silently, so refuse it here
const KNOB_TYPES = new Set(['float', 'int', 'bool', 'color', 'vec2']);


export function knob(name, opts = {}){
    if(typeof name !== 'string' || !/^[A-Za-z_]\w*$/.test(name)){
        throw new Error(`scenegen: knob name must be a valid GLSL identifier, got ${JSON.stringify(name)}`);
    }
    checkReserved('knob', name);
    if(opts.value === undefined){
        throw new Error(`scenegen: knob '${name}' needs a default value`);
    }
    if(opts.type !== undefined && !KNOB_TYPES.has(opts.type)){
        throw new Error(`scenegen: knob '${name}': unknown type '${opts.type}' `
            + `(have: ${[...KNOB_TYPES].join(', ')})`);
    }
    const k = {
        __knob: true,
        name:  name,
        type:  opts.type ?? 'float',
        label: opts.label ?? name,
        min:   opts.min ?? 0,
        max:   opts.max ?? 1,
        step:  opts.step ?? 0.01,
        //copy array defaults: authors may share one [r,g,b] between knobs,
        //and a live value must never alias another knob's
        value: Array.isArray(opts.value) ? [...opts.value] : opts.value,
        group: opts.group ?? 'scene',
    };
    registry.push(k);
    return k;
}


//collect the knobs a scene declared, collapsing duplicates and refusing
//conflicts. Called once, by scene(), which stores the result on the
//description — emit() reads it from there.
export function drainKnobs(){
    const byName = new Map();
    for(const k of registry){
        const prev = byName.get(k.name);
        if(!prev){ byName.set(k.name, k); continue; }
        if(JSON.stringify(prev) !== JSON.stringify(k)){
            const differs = Object.keys(k).filter(key => JSON.stringify(k[key]) !== JSON.stringify(prev[key]));
            throw new Error(`scenegen: knob '${k.name}' declared twice with different ${differs.join('/')}`);
        }
    }
    registry.length = 0;
    return [...byName.values()];
}

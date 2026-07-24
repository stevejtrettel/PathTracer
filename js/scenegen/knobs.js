//-------------------------------------------------
// KNOBS — tunable controls declared at their point of use
//
// knob() returns a JS binding usable anywhere a number goes (shape params,
// material args, glsl`` interpolations) and SELF-REGISTERS: emit() drains the
// registry, so declarations live in scene.js while current VALUES come from
// settings.js (Save-to-Scene writes only settings). Two knobs with the same
// name are one knob if their declarations agree, and a loud error if not —
// module re-evaluation (HMR) makes exact duplicates normal.
//-------------------------------------------------

const registry = [];


export function knob(name, opts = {}){
    if(typeof name !== 'string' || !/^[A-Za-z_]\w*$/.test(name)){
        throw new Error(`scenegen: knob name must be a valid GLSL identifier, got ${JSON.stringify(name)}`);
    }
    if(opts.value === undefined){
        throw new Error(`scenegen: knob '${name}' needs a default value`);
    }
    const k = {
        __knob: true,
        name:  name,
        type:  opts.type ?? 'float',
        label: opts.label ?? name,
        min:   opts.min ?? 0,
        max:   opts.max ?? 1,
        step:  opts.step ?? 0.01,
        value: opts.value,
        group: opts.group ?? 'scene',
    };
    registry.push(k);
    return k;
}


//collect the knobs a scene declared, collapsing duplicates and refusing
//conflicts. Called once, by emit().
export function drainKnobs(){
    const byName = new Map();
    for(const k of registry){
        const prev = byName.get(k.name);
        if(!prev){ byName.set(k.name, k); continue; }
        if(JSON.stringify(prev) !== JSON.stringify(k)){
            throw new Error(`scenegen: knob '${k.name}' declared twice with different settings`);
        }
    }
    registry.length = 0;
    return [...byName.values()];
}

//-------------------------------------------------
// NODES — the three kinds of scene entry
//
//   object  one region of space
//   group   one AUTHORED sdf evaluation feeding several region slots
//   sheet   a two-sided surface with no interior
//
// A node is plain data; all reasoning happens in the emitter. Every node may
// carry `uses: [lib.x, ...]` — uncalled catalogue references declaring that
// its authored GLSL calls into those library files (the emitter inlines the
// includes).
//
// scene() also drains the knob/field registries onto the description, so the
// returned value is SELF-CONTAINED: emit(description) depends on nothing
// module-global, and can run any number of times.
//-------------------------------------------------

import {drainKnobs} from './knobs.js';
import {drainFields} from './fields.js';
import {checkReserved} from './fmt.js';

function checkName(kind, name){
    if(typeof name !== 'string' || !/^[a-z]\w*$/i.test(name)){
        throw new Error(`scenegen: ${kind} name must be an identifier, got ${JSON.stringify(name)}`);
    }
    checkReserved(kind, name);
}

function checkUses(name, uses){
    if(uses === undefined) return;
    if(!Array.isArray(uses) || uses.some(u => !u || !u.entry)){
        throw new Error(`scenegen: '${name}': uses must be a list of lib references (uses: [lib.cocktailGlass])`);
    }
}


const OBJECT_KEYS = new Set(['at', 'scale', 'rotate', 'shape', 'material', 'medium', 'bound', 'uses', 'comment', 'nestedIn']);

export function object(name, spec){
    checkName('object', name);
    for(const key of Object.keys(spec)){
        if(!OBJECT_KEYS.has(key)){
            throw new Error(`scenegen: object('${name}'): unknown key '${key}' (have: ${[...OBJECT_KEYS].join(', ')})`);
        }
    }
    if(!spec.shape)    throw new Error(`scenegen: object('${name}') needs a shape`);
    if(!spec.material) throw new Error(`scenegen: object('${name}') needs a material`);
    if(!spec.at)       throw new Error(`scenegen: object('${name}') needs a placement (at: [x,y,z])`);
    checkUses(name, spec.uses);
    return {__node: 'object', name, ...spec};
}


const GROUP_KEYS  = new Set(['at', 'sdf', 'consts', 'regions', 'bound', 'uses', 'comment']);
const REGION_KEYS = new Set(['material', 'medium', 'comment', 'nestedIn']);

//one AUTHORED evaluation feeding several region slots (+ the shared bound):
//the sdf body assigns each region name directly, with q (local) in scope and
//the region names as out params. Region declaration order is containment
//priority, like everything else.
//
//This is the one deliberately rich mechanism in the schema — the design of
//multi-material/component objects may still be refined.
export function group(name, spec){
    checkName('group', name);
    for(const key of Object.keys(spec)){
        if(!GROUP_KEYS.has(key)){
            throw new Error(`scenegen: group('${name}'): unknown key '${key}' (have: ${[...GROUP_KEYS].join(', ')})`);
        }
    }
    if(!spec.sdf) throw new Error(`scenegen: group('${name}') needs an authored sdf body that assigns its regions`);
    if(!spec.at)  throw new Error(`scenegen: group('${name}') needs a placement (at: [x,y,z])`);
    const regionNames = Object.keys(spec.regions ?? {});
    if(regionNames.length < 2){
        throw new Error(`scenegen: group('${name}') needs at least two regions — one region is just an object()`);
    }
    for(const [rname, region] of Object.entries(spec.regions)){
        checkName(`group('${name}') region`, rname);
        for(const key of Object.keys(region)){
            if(!REGION_KEYS.has(key)){
                throw new Error(`scenegen: group('${name}').${rname}: unknown key '${key}' (have: ${[...REGION_KEYS].join(', ')})`);
            }
        }
        if(!region.material) throw new Error(`scenegen: group('${name}').${rname} needs a material`);
    }
    checkUses(name, spec.uses);
    return {__node: 'group', name, ...spec};
}


const SHEET_KEYS = new Set(['at', 'scale', 'rotate', 'shape', 'front', 'back', 'bound', 'uses', 'comment']);

//a two-sided surface with NO interior: both sides open onto whatever region
//contains it (index-matched crossing), and all it contributes is a Surface —
//two of them, front and back. Its sdf stays SIGNED like everyone else's; what
//makes it a sheet is isSheet(), not the shape of its sdf.
export function sheet(name, spec){
    checkName('sheet', name);
    for(const key of Object.keys(spec)){
        if(!SHEET_KEYS.has(key)){
            throw new Error(`scenegen: sheet('${name}'): unknown key '${key}' (have: ${[...SHEET_KEYS].join(', ')})`);
        }
    }
    if(!spec.shape) throw new Error(`scenegen: sheet('${name}') needs a shape`);
    if(!spec.at)    throw new Error(`scenegen: sheet('${name}') needs a placement (at: [x,y,z])`);
    if(!spec.front || !spec.back){
        throw new Error(`scenegen: sheet('${name}') needs BOTH faces (front + back) — `
            + `a one-faced sheet has no meaning; make them equal for a symmetric membrane`);
    }
    checkUses(name, spec.uses);
    return {__node: 'sheet', name, ...spec};
}


//`ambient:` is the medium of open air (region ID_NONE) — fog/god rays; its
//fields are validated in emit() against the Medium model. (A curved-light medium,
//by contrast, is an OBJECT with a position-varying interior IOR, not a scene key.)
const SCENE_KEYS = new Set(['objects', 'sky', 'glsl', 'ambient']);

export function scene(spec){
    //drain FIRST: if validation throws, the registries are still clean for the
    //next (HMR) evaluation of the module
    const knobs  = drainKnobs();
    const fields = drainFields();
    for(const key of Object.keys(spec)){
        if(!SCENE_KEYS.has(key)){
            //indexField is a reserved name (a curved medium is an object, not a
            //scene key); everything else is a typo.
            throw new Error(`scenegen: scene(): unknown key '${key}' `
                + `(have: ${[...SCENE_KEYS].join(', ')}; reserved: indexField)`);
        }
    }
    if(!Array.isArray(spec.objects) || spec.objects.length === 0){
        throw new Error('scenegen: scene() needs a non-empty objects array');
    }
    for(const node of spec.objects){
        if(!node || !node.__node){
            throw new Error('scenegen: scene(): every entry in objects must be an object()/group()/sheet() node '
                + '(a preset that forgot to return one?)');
        }
    }
    return {__scene: true, knobs, fields, ...spec};
}

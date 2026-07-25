//-------------------------------------------------
// STUDIO PRESETS — the room and the light every scene shares
//
// A preset is CONTENT, not mechanism: plain JS over the public scenegen
// schema, written once, imported everywhere. Nothing in js/scenegen/ knows
// these exist — presets import FROM the generator, never the reverse.
//-------------------------------------------------

import {object, knob, glsl, lib} from '../scenegen/index.js';
import {light} from './materials.js';


//open-air fog: the medium of region ID_NONE (mfp = scatter mean free path,
//blur = phase width 0..1, absorb/emit optional [r,g,b]). Field names are the
//Medium model's own (no renames). Pass to a scene's `ambient:` key.
export function fog({mfp, blur = 0.7, absorb, emit} = {}){
    if(mfp === undefined) throw new Error('scenegen: fog() needs mfp (the scatter mean free path)');
    const m = {mfp, blur};
    if(absorb !== undefined) m.absorb = absorb;
    if(emit   !== undefined) m.emit   = emit;
    return m;
}


//a spherical emitter. The knobless studio light every scene shares.
export function sphereLight({at, radius, color = [0.9, 0.9, 0.9], power = 100, name = 'light'} = {}){
    return object(name, {
        at,
        shape: lib.sphere({radius}),
        material: light({emit: glsl`${power}*${color}`}),
    });
}


//the closed room, seen from inside: ONE region whose solid is everything
//outside the box, with the six walls as a material field over it (roomFace
//picks the wall). Declares the shared room knobs; per-scene values come from
//settings.js as usual. The name is fixed — the material body references the
//object's own ROOM_HALFSIZE const.
export function room({center, half, knobs = {}} = {}){
    //declaration overrides per knob name (ranges, defaults): a scene that
    //wants a hotter ceiling passes knobs: {roomLight: {max: 3}}
    const k = (name, defaults) => knob(name, {...defaults, ...(knobs[name] ?? {})});

    const slate = [0.1006, 0.1194, 0.1412];      //the default wall colour, everywhere
    k('roomLight',  {label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5});
    k('floorColor', {type: 'color', label: 'Floor',      value: slate});
    k('warmColor',  {type: 'color', label: 'Left Wall',  value: slate});
    k('coolColor',  {type: 'color', label: 'Right Wall', value: slate});
    k('wallColor',  {type: 'color', label: 'Walls',      value: slate});
    k('wallRough',  {label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.1});

    return object('room', {
        at: center,
        shape: lib.room({halfSize: half}),
        comment: 'the room SOLID is everything outside the box, so its interior is open air and\n'
               + 'regionAt() returns ID_NONE there',
        //faceData is a shape DATA output (room.glsl): the emitter injects it,
        //baking in the room's own halfSize — no re-passing (docs/shape-data.md)
        material: glsl`
            if(faceData == ROOM_CEILING){ return makeLight(vec3(1.0), roomLight); }
            if(faceData == ROOM_FLOOR)  { return makeGloss(floorColor, 0.0, wallRough); }
            if(faceData == ROOM_LEFT)   { return makeGloss(warmColor,  0.0, wallRough); }
            if(faceData == ROOM_RIGHT)  { return makeGloss(coolColor,  0.0, wallRough); }
            return makeGloss(wallColor, 0.0, wallRough);
        `,
    });
}

//-------------------------------------------------
// PRESETS — plain JS functions returning node descriptions
//
// Nothing here is an engine concept: a preset is ordinary schema use, written
// once. This is where the blocks that used to be copied into every scene
// (the six-wall room, the studio key light) actually live now.
//-------------------------------------------------

import {object} from './nodes.js';
import {knob} from './knobs.js';
import {glsl, valueText} from './glslTag.js';
import {lib} from './catalogue.js';
import {field} from './fields.js';
import {makeLight} from './materials.js';


//-------------------------------------------------
// field presets — canonical height fields with their metadata filled in.
// This is where the noise gradient bounds LIVE: |grad fbm(f*q)| <= 3.26*f,
// |grad fbm2(f*q)| <= 2.01*f (derivation in glsl/tracer/3Materials/fields.glsl).
// The core field() mechanism knows none of this — a preset is just a field
// with the declarations already written.
//-------------------------------------------------

//centered noise height in [-0.5, 0.5]: the standard displacement driver.
//fbm2 (2 octaves) — displacement pays at every march step, and extra octaves
//cost hashes AND gradient (a longer Lipschitz divisor). freq: knob or number.
export function fbm2Height(name, freq){
    return field(`float ${name}(vec3 q){\n    return fbm2(${valueText(freq)}*q) - 0.5;\n}`,
                 {gradBound: glsl`2.01*${freq}`, range: [-0.5, 0.5]});
}

//4-octave version: finer detail, ~1.6x more gradient — fine for colour, pay
//attention to the march cost when displacing with it
export function fbmHeight(name, freq){
    return field(`float ${name}(vec3 q){\n    return fbm(${valueText(freq)}*q) - 0.5;\n}`,
                 {gradBound: glsl`3.26*${freq}`, range: [-0.5, 0.5]});
}


//a spherical emitter. The knobless studio light every scene shares.
export function sphereLight({at, radius, color = [0.9, 0.9, 0.9], power = 100, name = 'light'} = {}){
    return object(name, {
        at,
        shape: lib.sphere({radius}),
        material: makeLight(color, power),
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

    k('roomLight',  {label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5});
    k('floorColor', {type: 'color', label: 'Floor',      value: [0.1006, 0.1194, 0.1412]});
    k('warmColor',  {type: 'color', label: 'Left Wall',  value: [0.1006, 0.1194, 0.1412]});
    k('coolColor',  {type: 'color', label: 'Right Wall', value: [0.1006, 0.1194, 0.1412]});
    k('wallColor',  {type: 'color', label: 'Walls',      value: [0.1006, 0.1194, 0.1412]});
    k('wallRough',  {label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.1});

    return object('room', {
        at: center,
        shape: lib.room({halfSize: half}),
        comment: 'the room SOLID is everything outside the box, so its interior is open air and\n'
               + 'regionAt() returns ID_NONE there',
        material: glsl`
            int face = roomFace(q, ${{half}});

            if(face == ROOM_CEILING){ return makeLight(vec3(1.0), roomLight); }
            if(face == ROOM_FLOOR)  { return makeGloss(floorColor, 0.0, wallRough); }
            if(face == ROOM_LEFT)   { return makeGloss(warmColor,  0.0, wallRough); }
            if(face == ROOM_RIGHT)  { return makeGloss(coolColor,  0.0, wallRough); }
            return makeGloss(wallColor, 0.0, wallRough);
        `,
    });
}

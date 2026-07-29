//=====================================================================
// VARIETY-TANGLE — a custom equation living in its own .glsl file.
//
// The defining function is NOT in this file and NOT in the catalogue: it
// is src/tangle.glsl, standard float GLSL in the scene folder, imported
// raw and handed to variety({fns: ...}). The generator transpiles it (and
// cross-checks the dual arithmetic against the float original). Compare
// variety-pencil, where the equations live INLINE — same rung, two
// authoring homes.
//
// The tangle cube is a closed surface, so it is drawn as a SOLID — glass,
// with the {s < 0} interior refracting and absorbing. `c` is the
// equation's constant term, live on a knob.
//=====================================================================

import {scene, object, lib, knob, absorbFor, variety, clip} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';

import TANGLE from './tangle.glsl?raw';


//the constant term of the equation — 11.8 is the classic tangle
const c = knob('c', {label: 'Tangle', min: 8.0, max: 14.0, step: 0.01, value: 11.8});

const tangleScale = knob('tangleScale', {label: 'Scale', min: 0.6, max: 2.5, step: 0.01, value: 1.2});


export default scene({
    objects: [

        object('tangle', {
            at:    [0.0, 1.9, -0.5],
            shape: clip(variety({fns: TANGLE, params: {c}}, {scale: tangleScale}),
                        {to: lib.sphere({radius: 1.9}), blend: 0.05}),
            material: glass({absorb: absorbFor([0.72, 0.9, 0.8], 1.2), ior: 1.5}),
        }),

        sphereLight({
            name: 'lamp',
            at: [-4.0, 8.5, 5.0], radius: 1.4,
            color: [1.0, 0.95, 0.88],
            power: knob('lampPower', {label: 'Lamp Power', min: 0, max: 90, step: 0.5, value: 30}),
        }),

        room({
            center: [0.0, 6.0, 0.0], half: [10.0, 6.0, 10.0],
            knobs: {roomLight: {max: 3, value: 1.0}},
        }),
    ],
});

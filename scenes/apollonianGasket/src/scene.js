//=====================================================================
// APOLLONIAN GASKET — the fract-fold gasket, and the scene that makes it
// visible at all.
//
// THE FIX IS foldOffset = 0.5. The legacy saved 0.877, where the fract-fold
// fills in and ~98% of the ball reads as a wall — so the port rendered as a
// smooth sphere, at any epsilon. Near 0.5 the original maths shows the packing
// at the default marcher settings; see glsl/shapes/fractals/apollonianGasket.glsl
// for the measurements. The knob stops at 0.4..0.6, where it still morphs the
// packing rather than dissolving it into dust.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


//the morph: shifts the fold each iteration, reshaping the packing
const foldOffset = knob('foldOffset', {label: 'Fold Offset', min: 0.4, max: 0.6, step: 0.001, value: 0.5});


export default scene({

    objects: [

        object('gasket', {
            at:       [0.0, 1.8, 0.0],
            shape:    lib.apollonianGasket({radius: 1.0, foldOffset}),
            //the legacy's glass: a green-cyan absorbing dielectric
            material: glass({absorb: [1.0, 0.415, 0.685], ior: 1.2, transmit: 0.8}),
        }),

        sphereLight({name: 'key', at: [-8.0, 9.0, 5.0], radius: 2.0, power: 260}),

        room({center: [0.0, 5.75, -5.0], half: [20.0, 8.25, 15.0],
              knobs: {roomLight: {value: 0.5}}}),
    ],
});

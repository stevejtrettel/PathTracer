//=====================================================================
// APOLLONIAN — a gasket fractal, coloured by its orbit trap.
//
// The first scene on the SHAPE-DATA channel (docs/shape-data.md): the fractal
// shape exposes `orbitTrapData` (a vec4 the distance-estimator produces), and the
// material reads it — injected automatically, with the object's `r2` baked in —
// then maps it to colour with an authored palette. The `morph` knob (r2) deforms
// the gasket live.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {sphereLight} from '../../../js/presets/index.js';


const morph = knob('morph', {label: 'Morph (inversion r²)', min: 0.9, max: 1.3, step: 0.001, value: 1.2});


export default scene({
    objects: [

        object('gasket', {
            at:    [0.0, 0.0, 0.0],
            shape: lib.apollonian({r2: morph}),
            //orbitTrapData is injected (the shape exposes it); the palette is ours
            //— a white/red base with cyan accents carved out by the trap
            material: glsl`
                float c0   = pow(clamp(orbitTrapData.w, 0.0, 1.0), 2.0);
                vec3  col1 = mix(vec3(1.0), vec3(0.4, 0.0, 0.0), clamp(3.5*orbitTrapData.y, 0.0, 1.0));
                vec3  col0 = c0 * vec3(0.0, 1.0, 1.0);
                vec3  c    = clamp(col1 - col0, 0.0, 1.0);
                return makeGloss(c, 0.15, 0.1);
            `,
        }),

        sphereLight({at: [-3.4, 0.56, -2.0], radius: 0.6, color: [1.0, 0.9, 0.7], power: 24}),
    ],

    //a darker gradient sky makes the colourful gasket pop
    sky: {type: 'gradient', top: [0.35, 0.45, 0.58], bottom: [0.04, 0.05, 0.09]},
});

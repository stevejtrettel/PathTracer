//=====================================================================
// BOTTLETORUS — a ring-shaped decanter in dense purple glass.
//
// The torus+cone profile shape (the port that exercises the new torusDistance and
// coneDistance primitives). A single glass shell with a DENSE scattering interior
// (small mfp → porcelain-like translucency). Colour is raw absorb, verbatim from
// the original (Beer extinction) — the vec3 looks purple as a swatch but reads as
// its complement through the glass, which is the legacy look.
//=====================================================================

import {scene, object, lib, glsl, knob, withSurface} from '../../../js/scenegen/index.js';
import {room, sphereLight, subsurface} from '../../../js/presets/index.js';


const sssScatter = knob('sssScatter', {label: 'Scatter', min: 0, max: 1, step: 0.01, value: 0.368});


export default scene({
    objects: [

        object('donut', {
            at:    [0.0, 1.0, 0.0],
            shape: lib.bottleTorus({
                outer: 2.0, inner: 1.2, height: 2.5,
                base: 0.3, flare: 6.0, smoothing: 2.75, thickness: 0.08,
            }),
            material: withSurface(
                subsurface({absorb: glsl`0.3*vec3(0.3, 0.05, 0.2)`, ior: 1.6,
                            mfp: glsl`0.02`, blur: sssScatter}),
                {roughness: 0.0}),
        }),

        sphereLight({at: [-12.0, 8.0, 2.0], radius: 1.5, color: [1.0, 1.0, 1.0], power: 60}),

        room({
            center: [-5.75, 5.75, -5.0], half: [14.25, 8.25, 15.0],
            knobs: {roomLight: {value: 0.1}},
        }),
    ],
});

//=====================================================================
// BLACKHOLEMULTI — three black holes in static equilibrium.
//
// The Majumdar–Papapetrou solution: extremal holes sit in equilibrium at any
// positions, and their optical index SUMS, n = (1 + Σ Mᵢ/rᵢ)². The per-region
// field model makes this trivial — one medium sphere whose interior IOR is the
// summed field. (With the OLD single-global-field engine this needed a
// hand-written loop; now it is one expression, and two DIFFERENT holes in one
// scene would just be two medium objects.)
//
// mass = 0 turns them all off (flat, undistorted sky) — a clean A/B baseline.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {glass} from '../../../js/presets/index.js';


const mass = knob('mass', {label: 'Mass', min: 0, max: 0.5, step: 0.005, value: 0.25});


export default scene({
    objects: [

        //n = (1 + Σ M/rᵢ)² over three holes in a triangle. q is the sphere's own
        //frame (centred at the origin, so q = world here).
        object('space', {
            at:    [0.0, 0.0, 0.0],
            shape: lib.sphere({radius: 40.0}),
            material: glass({
                ior: glsl`pow(1.0
                    + ${mass}/max(length(q - vec3( 0.00,  2.50, 0.0)), 1e-4)
                    + ${mass}/max(length(q - vec3(-2.17, -1.25, 0.0)), 1e-4)
                    + ${mass}/max(length(q - vec3( 2.17, -1.25, 0.0)), 1e-4), 2.0)`,
                absorb: glsl`vec3(0.0)`,
            }),
        }),
    ],

    sky: {type: 'image', src: '/assets/office.jpg'},
});

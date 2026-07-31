//=====================================================================
// APOLLONIAN GASKET — the fract-fold gasket, and the scene that makes it
// visible at all.
//
// THE FIX IS `march:`. This estimator is unusually pessimistic: its `res` term
// carries a +0.2 floor and its `scale` diverges over ten iterations, so the
// returned value is TINY almost everywhere inside the unit ball rather than only
// near the gasket. Measured over 200k interior points at foldOffset 0.877:
//
//     percentile     value          epsilon    fraction of the ball it "hits"
//     0.01%          9.3e-10        1e-3       97.1%   <- the engine default
//     1%             7.1e-08        1e-5       30.7%
//     25%            6.7e-06        1e-6        7.7%
//     50%            3.1e-05        1e-7        1.3%   <- chosen
//     90%            3.7e-04        1e-8        0.15%
//
// At the default epsilon the marcher counts 97% of the ball as a hit and the
// object renders as a smooth SPHERE — which is exactly what it did before this
// scene existed. 1e-7 keeps the hit band down to the ~1% nearest the gasket,
// which is where the structure is. Drop to 1e-8 for finer filigree at the cost
// of march steps; raise to 1e-6 and it fattens back toward a blob.
//
// The cost is contained: the room and the light are ANALYTIC (both have Trace
// functions), so nothing but the fractal pays for the fine epsilon.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


//the morph: shifts the fold each iteration, reshaping the packing
const foldOffset = knob('foldOffset', {label: 'Fold Offset', min: 0.0, max: 1.0, step: 0.001, value: 0.877});


export default scene({

    //see the header: without this the gasket is a sphere. maxSteps is raised
    //because a 1e-7 hit band means many more short steps near the surface.
    march: {epsilon: 1e-7, maxSteps: 4000},

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

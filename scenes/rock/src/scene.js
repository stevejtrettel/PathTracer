//=====================================================================
// ROCK — one height field driving BOTH geometry and colour.
//
// The displacement scene. `rockHeight` is declared ONCE and used twice —
// displace() moves the surface by it, the material body colours by it — so
// the pale peaks and rusty valleys line up by construction. The emitter
// derives what an author would forget: the Lipschitz divisor from the field's
// gradient bound (fbm2: 2.01*freq), the bound inflation from its range, and
// the trace routing (displaced -> marched).
//=====================================================================

import {scene, object, lib, glsl, knob, displace} from '../../../js/scenegen/index.js';
import {room, sphereLight, fbm2Height} from '../../../js/presets/index.js';


//--- knobs: declared once, shared by geometry and colour --------------
const rockAmp   = knob('rockAmp',   {label: 'Displacement', min: 0, max: 0.6, step: 0.005, value: 0.28});
const rockFreq  = knob('rockFreq',  {label: 'Feature Size', min: 0.3, max: 6, step: 0.05, value: 2.2});
const tintDepth = knob('tintDepth', {label: 'Colour follows Height', min: 0, max: 1, step: 0.01, value: 1.0});

//--- the height field: a PRESET — a field() with its Lipschitz metadata
//    already declared. Write field(glsl`...`, {gradBound, range}) instead
//    for a custom function.
const rockHeight = fbm2Height('rockHeight', rockFreq);


export default scene({
    objects: [

        object('rock', {
            at:    [0.0, 2.3, 0.0],
            shape: displace(lib.sphere({radius: 2.0}), {by: rockHeight, amp: rockAmp}),

            //THE CORRELATION: h is the same value that moved this piece of
            //surface — valleys dark iron red and rough, peaks pale and worn
            material: glsl`
                float h = ${rockHeight}(q);
                float t = clamp(h + 0.5, 0.0, 1.0);

                float grain = fbm(9.0*q);
                float w = clamp(mix(0.5, smoothstep(0.3, 0.72, t), ${tintDepth}) + 0.12*(grain-0.5), 0.0, 1.0);

                vec3 valley = vec3(0.40, 0.13, 0.07);
                vec3 peak   = vec3(0.80, 0.76, 0.70);
                vec3 col    = mix(valley, peak, w);

                return makeGloss(col, 0.02, mix(0.70, 0.32, w));
            `,
        }),

        sphereLight({
            name: 'lamp',
            at: [-3.5, 8.5, 4.5], radius: 1.0,
            color: [1.0, 0.95, 0.88],
            power: knob('lampPower', {label: 'Lamp Power', min: 0, max: 90, step: 0.5, value: 25}),
        }),

        room({
            center: [0.0, 6.0, 0.0], half: [10.0, 6.0, 10.0],
            knobs: {roomLight: {max: 3, value: 1.1}},
        }),
    ],
});

//=====================================================================
// KLEINIAN — the Kleinian-group explorer.
//
// The FIRST scene on the one `kleinian` estimator (glsl/shapes/kleinian.glsl),
// in its STANDARD BOX: the (R, I) generators are live knobs, so sweeping them
// morphs the limit set through that box's parameter space. Colour comes from
// the shape's `orbitTrapData` (injected — docs/shape-data.md) through a cosine
// palette. Other scenes reuse this SAME estimator in another box, or at fixed
// R/I with another material — the scenes are its parameter space, not shapes.
//=====================================================================

import {scene, object, glsl, knob} from '../../../js/scenegen/index.js';
import {sphereLight, kleinianStandardBox} from '../../../js/presets/index.js';


const kleinR = knob('kleinR', {label: 'Klein R',            min: 1.4, max: 2.2, step: 0.001, value: 1.8});
const kleinI = knob('kleinI', {label: 'Klein I',            min: 0.0, max: 2.0, step: 0.001, value: 1.8});
const detail = knob('detail', {label: 'Detail (iterations)', type: 'int', min: 10, max: 22, step: 1, value: 17});


export default scene({
    objects: [

        object('klein', {
            at:    [0.0, 0.0, 0.0],
            shape: kleinianStandardBox({kleinR, kleinI, iterations: detail, offset: [0.9, 0.8, 0.0]}),
            //orbitTrapData (vec3, injected) → a cosine palette over one channel
            material: glsl`
                float t = clamp(0.5 + 0.5*orbitTrapData.y, 0.0, 1.0);
                vec3  c = 0.5 + 0.5*cos(6.2831*(t + vec3(0.0, 0.33, 0.67)));
                return makeGloss(c, 0.15, 0.1);
            `,
        }),

        sphereLight({at: [6.0, 6.0, -4.0], radius: 0.9, color: [1.0, 0.92, 0.8], power: 26}),
    ],

    sky: {type: 'gradient', top: [0.42, 0.46, 0.55], bottom: [0.06, 0.04, 0.03]},
});

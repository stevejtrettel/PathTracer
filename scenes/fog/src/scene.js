//=====================================================================
// FOG — open air as a scattering medium.
//
// The ambient scene. `ambient:` gives open air (region ID_NONE) a medium; the
// engine's ambientTransport scatters rays travelling through it, softening the
// light into a haze around the lamp. There is no ambient vocabulary — it is just
// the medium of ID_NONE, set with the same `fog()`/Medium fields a material uses
// (mfp = scatter mean free path, blur = phase width). mfp → ∞ = clear air.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, fog, glass} from '../../../js/presets/index.js';


const fogMfp = knob('fogMfp', {label: 'Fog mean free path', min: 2, max: 40, step: 0.5, value: 8});


export default scene({

    //open air scatters: the whole visible volume is a soft medium
    ambient: fog({mfp: fogMfp, blur: 0.7}),

    objects: [

        //a clear glass ball, so the haze reads against a hard refractive edge
        object('ball', {
            at:       [-1.0, 1.1, -1.2],
            shape:    lib.sphere({radius: 1.2}),
            material: glass({absorb: glsl`0.1*vec3(0.3, 0.05, 0.2)`, ior: 1.5}),
        }),

        sphereLight({at: [-7.0, 4.0, 2.0], radius: 1.5, color: [0.9, 0.9, 0.9], power: 100}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0]}),
    ],
});

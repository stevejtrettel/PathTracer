//=====================================================================
// BLACKHOLE — a single Majumdar–Papapetrou black hole.
//
// The first curved-light scene. A medium is now just an OBJECT whose interior
// IOR varies with position: here one big sphere of graded index n = (1 + M/r)²
// centred on the hole. The sphere is large enough that n ≈ 1 at its wall
// (index-matched, seamless) and it contains the camera, so every ray curves
// from the eye. The shadow is the ODE marcher's own capture — pure dynamics, no
// drawn sphere. Escaped rays sample the image sky in their bent direction,
// lensing it into an Einstein ring. mass = 0 → n = 1 everywhere (flat sky).
//
// No scene-level hooks, no flags: the field-valued `ior` is the whole signal
// (docs/curved-light-scenegen.md). `q` is the object's own local frame.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {glass} from '../../../js/presets/index.js';


const mass = knob('mass', {label: 'Mass', min: 0, max: 0.5, step: 0.005, value: 0.25});


export default scene({
    objects: [

        //the medium filling the visible space. Its interior IOR is a field, so the
        //emitter makes it a curved medium: n = (1 + M/r)², M = the mass knob. Floor
        //r at the singularity (NaN guard). Radius 40 keeps the far wall inside the
        //marcher's arc budget and its index within ~1% of vacuum.
        object('space', {
            at:    [0.0, 0.0, 0.0],
            shape: lib.sphere({radius: 40.0}),
            material: glass({
                ior:    glsl`pow(1.0 + ${mass}/max(length(q), 1e-4), 2.0)`,
                absorb: glsl`vec3(0.0)`,
            }),
        }),
    ],

    //a busy equirectangular sky so the lensing reads as an Einstein ring
    sky: {type: 'image', src: '/assets/office.jpg'},
});

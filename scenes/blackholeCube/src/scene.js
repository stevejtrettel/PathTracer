//=====================================================================
// BLACKHOLECUBE — a black hole's optics packed into a glass cube.
//
// A transformation-optics analog: a REAL dielectric block in ordinary flat
// space, whose refractive index follows the black-hole profile n = (1 + M/r)²
// inside the cube. Light through it lenses exactly like light near a black hole
// — but this is a genuine object with a surface, not curved spacetime.
//
// It is just an object with a field-valued interior IOR. That one fact makes it a
// curved medium AND supplies the DYNAMIC-IOR WALL for free: the emitter wires the
// cube's own surface Snell IOR to the same field, so the wall refracts by
// n_wall = n(hit) and Snell at the surface matches the eikonal inside — the field
// is one n(p) governing surface and interior (docs/curved-light-scenegen.md).
//
// Unlike the black-hole SPHERE, the field is ≫ 1 at the cube wall, so the wall
// genuinely refracts (and can TIR). mass = 0 → n = 1 everywhere → invisible cube.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {glass} from '../../../js/presets/index.js';


const mass = knob('mass', {label: 'Mass', min: 0, max: 0.5, step: 0.005, value: 0.25});


export default scene({
    objects: [

        //the block. Interior IOR = (1 + M/r)², r = |q| in the cube's own frame
        //(cube centred on the hole). Field-valued ior ⇒ curved medium + dynamic wall.
        object('cube', {
            at:    [0.0, 0.0, 0.0],
            shape: lib.box({halfSize: [1.8, 1.8, 1.8]}),
            material: glass({
                ior:    glsl`pow(1.0 + ${mass}/max(length(q), 1e-4), 2.0)`,
                absorb: glsl`vec3(0.0)`,
            }),
        }),
    ],

    //the block floats in the image sky, so the lensing acts on the background
    sky: {type: 'image', src: '/assets/office.jpg'},
});

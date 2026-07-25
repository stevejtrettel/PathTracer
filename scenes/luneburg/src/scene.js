//=====================================================================
// LUNEBURG — a graded-index lens.
//
// n(r) = √(2 − (r/R)²): 2 at the centre, exactly 1 at the rim. Because the field
// reaches 1 at the boundary, the wall is index-matched (no edge refraction) and
// ALL the bending is the curved geodesic through the graded interior — a Luneburg
// lens focuses parallel rays to the point on the far surface.
//
// A medium is just an object with a field-valued interior IOR: the lens sphere's
// `ior` is the field. The emitter reads that one fact, makes it a curved medium
// (isMedium + indexFieldOf), force-marches it so odeMarch finds the wall by an sdf
// sign change, and wires the wall's own Snell IOR to the SAME field — which here
// equals 1 at the rim, so the exit is seamless (docs/curved-light-scenegen.md).
//
// The field must stay smooth PAST the rim (it is real out to r = R√2): the max()
// floor keeps it real, and the region's sdf, not a clamp, confines the curving.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


const lightPower = knob('lightPower', {label: 'Light Power', min: 0, max: 400, step: 1, value: 22});

const lensAt = [0.0, 3.0, 0.0];
const lensR  = 3.0;


export default scene({
    objects: [

        //the lens: interior IOR = √(2 − (r/R)²), r = |q| in the lens's own frame.
        //R² = 9. Field-valued ior ⇒ this is the medium; the wall IOR is the field
        //at the rim (= 1), so the boundary is seamless.
        object('lens', {
            at:    lensAt,
            shape: lib.sphere({radius: lensR}),
            material: glass({
                ior:    glsl`sqrt(max(2.0 - dot(q, q)/9.0, 0.0))`,
                absorb: glsl`vec3(0.0)`,
            }),
        }),

        //back-lit: a bright sphere behind the lens makes its bending legible; the
        //pale floor catches the focused caustic
        sphereLight({name: 'backlight', at: [6.0, 4.0, -14.0], radius: 6.0,
                     color: [1.0, 1.0, 1.0], power: lightPower}),

        //a big dark room, pale floor, no ceiling light — isolates the lens
        room({
            center: [0.0, 13.0, -6.0], half: [30.0, 15.0, 24.0],
            knobs: {
                roomLight:  {value: 0.0},
                floorColor: {value: [0.55, 0.55, 0.55]},
                wallColor:  {value: [0.015, 0.015, 0.015]},
                warmColor:  {value: [0.015, 0.015, 0.015]},
                coolColor:  {value: [0.015, 0.015, 0.015]},
                wallRough:  {value: 0.25},
            },
        }),
    ],
});

//=====================================================================
// PRISM — a glass triangular prism splitting light into a spectrum.
//
// The dispersion scene. A single colourless glass prism (the `triangle` shape,
// tilted 12°); all the colour comes from SPECTRAL rendering — settings ship with
// spectral ON and a dispersion strength, so the IOR shifts per wavelength and the
// refracted light fans into a rainbow caustic on the pale floor. Higher ior =
// stronger bending AND stronger dispersion.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


const ior        = knob('ior',        {label: 'Index of Refraction', min: 1.0, max: 2.5,  step: 0.001, value: 1.52});
const lightPower = knob('lightPower', {label: 'Light Power',         min: 0,   max: 2500, step: 5,     value: 320});


export default scene({
    objects: [

        //near-colourless, highly refractive glass; the tilt aims the fan at the floor
        object('prism', {
            at:       [0.0, 2.0, 0.0],
            rotate:   {axis: [0.0, 0.0, 1.0], angle: 12},
            shape:    lib.triangle({side: 4.0, thickness: 2.5}),
            material: glass({absorb: glsl`vec3(0.0)`, ior}),
        }),

        //small + very bright + BEHIND the prism (from the camera): a tight source
        //keeps the spectral bands crisp
        sphereLight({at: [9.0, 4.0, -12.0], radius: 1.5, color: [1.0, 1.0, 1.0], power: lightPower}),

        //a big dark room with a pale floor to catch the rainbow caustic
        room({
            center: [0.0, 12.0, -7.0], half: [30.0, 14.0, 23.0],
            knobs: {
                roomLight:  {value: 0.0},
                floorColor: {value: [0.55, 0.55, 0.55]},
                wallColor:  {value: [0.012, 0.012, 0.012]},
                warmColor:  {value: [0.012, 0.012, 0.012]},
                coolColor:  {value: [0.012, 0.012, 0.012]},
                wallRough:  {value: 0.3},
            },
        }),
    ],
});

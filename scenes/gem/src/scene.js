//=====================================================================
// GEM — a brilliant-cut stone at diamond IOR, throwing fire.
//
// The other dispersion scene: a colourless faceted stone (the `gem` shape), so
// with SPECTRAL on all the colour is dispersion — total internal reflection
// bounces light around the facets and splashes rainbow caustics on the pale
// floor. Small, bright lights are the whole game (a big source washes the
// spectrum out). The knobs that matter: ior (2.42 = diamond), gemTilt, and the
// dispersion strength (Render tab).
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


const ior        = knob('ior',        {label: 'Index of Refraction', min: 1.0, max: 2.6,  step: 0.001, value: 2.42});
const gemTilt    = knob('gemTilt',    {label: 'Gem Tilt',            min: -90, max: 90,   step: 1,     value: 12});
const lightPower = knob('lightPower', {label: 'Light Power',         min: 0,   max: 6000, step: 5,     value: 400});


export default scene({
    objects: [

        //colourless, highly refractive; tilted so the camera sees crown and
        //pavilion facets at once, culet clearing the floor
        object('stone', {
            at:       [0.0, 2.3, 0.0],
            rotate:   {axis: [0.0, 0.0, 1.0], angle: gemTilt},
            shape:    lib.gem({size: 2.0}),
            material: glass({absorb: glsl`vec3(0.0)`, ior}),
        }),

        //two SMALL bright lights: a key and a dimmer rim
        sphereLight({name: 'keyLight', at: [6.0, 10.0, -7.0], radius: 0.7,
                     color: [1.0, 1.0, 1.0], power: lightPower}),
        sphereLight({name: 'rimLight', at: [-8.0, 6.0, 4.0], radius: 0.5,
                     color: [1.0, 1.0, 1.0], power: glsl`0.4*${lightPower}`}),

        //a big near-black room, pale floor to catch the fire
        room({
            center: [0.0, 11.0, 0.0], half: [16.0, 11.0, 16.0],
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

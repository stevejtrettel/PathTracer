//=====================================================================
// BOTTLE — a green glass bottle with a scattering interior.
//
// The first profile-shape port: the `bottle` shape (rounded-cylinder base + neck,
// smooth-unioned, hollowed to a shell). One glass region whose interior SCATTERS
// — setting `mfp` (via subsurface) is what compiles the medium walk in, so light
// entering the wall diffuses through the green glass. Smooth exit (roughness 0)
// keeps it read as polished glass, not frosted.
//=====================================================================

import {scene, object, lib, glsl, knob, withSurface} from '../../../js/scenegen/index.js';
import {room, sphereLight, subsurface} from '../../../js/presets/index.js';


const sssScatter = knob('sssScatter', {label: 'Scatter Phase',   min: 0, max: 1, step: 0.01, value: 0.73});
const sssDensity = knob('sssDensity', {label: 'Scatter Density', min: 0, max: 2, step: 0.01, value: 0.84});


export default scene({
    objects: [

        object('bottle', {
            at:    [1.0, 0.48, 2.0],
            shape: lib.bottle({
                baseRadius: 1.25, baseHeight: 1.5,
                neckRadius: 0.3,  neckHeight: 1.0,
                thickness:  0.1,  rounded: 0.1, smoothJoin: 0.3, bump: 1.0,
            }),
            //raw absorb, verbatim from the original (Beer extinction, 1/length):
            //green is the strongest channel, so green is absorbed most and the
            //glass reads magenta — faithful to the legacy scene, not "green"
            material: withSurface(
                subsurface({absorb: glsl`1.5*vec3(0.25, 0.65, 0.4)`, ior: 1.5,
                            mfp: glsl`0.5*${sssDensity}`, blur: sssScatter}),
                {roughness: 0.0}),
        }),

        sphereLight({at: [-6.0, 3.0, 0.0], radius: 1.0, color: [0.9, 0.9, 0.9], power: 150}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0], knobs: {roomLight: {value: 0.5}}}),
    ],
});

//=====================================================================
// BUNNY — the Stanford bunny fitted into four layers of 4x4 matrices.
//
// The interesting thing about this one is not the silhouette but the DOMAIN
// GUARD: outside the unit ball the fitted network is not an approximation of
// anything, so bunnyDistance() clips it to a sphere INLINE, and that guard cannot
// be demoted to bunnyBound() (a bound only fires when a ray is far; the marcher
// still evaluates the real sdf inside the bound's margin band). Sweep `bunnySize`
// and the guard has to keep scaling correctly with it — that is what this page tests.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, matte} from '../../../js/presets/index.js';


const bunnySize = knob('bunnySize', {label: 'Bunny Size', min: 0.5, max: 6.0, step: 0.05, value: 3.4});


export default scene({
    objects: [
        object('bun', {
            at:       [0.0, 1.4, 0.0],
            shape:    lib.bunny({size: bunnySize}),
            material: matte({diffuse: [0.76, 0.72, 0.66]}),
        }),

        sphereLight({name: 'key', at: [6.0, 12.0, 9.0], radius: 2.6, power: 2600}),
        room({center: [0.0, 9.0, 0.0], half: [12.0, 9.0, 22.0], knobs: {roomLight: {value: 1.8}}}),
    ],
});

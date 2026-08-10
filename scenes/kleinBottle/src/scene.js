//=====================================================================
// KLEIN BOTTLE — the figure-8 immersion, as a hollow surface.
//
// Four pieces unioned and each hollowed by the same abs(d) - thickness shell:
// a side handle, the open mouth, the mid base, and the upper handle. `thickness`
// is RELATIVE to the unit bottle, so it scales with `size` rather than fighting
// it — which is the fix this port made (the legacy divided by size without
// scaling the distance back, so small bottles could tunnel).
//
// Turn the wall thin and the immersion's self-intersection becomes legible.
//=====================================================================

import {scene, object, lib, knob, glsl} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


const bottleSize = knob('bottleSize', {label: 'Bottle Size',    min: 0.2, max: 1.6,  step: 0.01,  value: 0.9});
const wallThick  = knob('wallThick',  {label: 'Wall Thickness', min: 0.01, max: 0.2, step: 0.005, value: 0.05});


export default scene({
    objects: [
        object('klein', {
            //the immersion's baked axis permutation leaves the form off its own
            //origin, so this offset centres it in frame (not a shape parameter)
            at:       [-1.4, 3.0, 0.0],
            //turned so the HANDLE faces the camera: straight on, the immersion
            //reads as a plain vase and the self-intersection is hidden
            rotate:   {axis: [0.0, 1.0, 0.0], angle: 60},
            shape:    lib.kleinBottle({size: bottleSize, thickness: wallThick}),
            material: glass({absorb: glsl`0.1*vec3(0.3, 0.05, 0.2)`, ior: 1.5}),
        }),

        sphereLight({name: 'key', at: [7.0, 13.0, 10.0], radius: 3.0, power: 400}),
        room({center: [0.0, 10.0, 0.0], half: [14.0, 10.0, 22.0]}),
    ],
});

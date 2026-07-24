//=====================================================================
// GLASSBALL — one glass sphere in a room. The speed baseline.
//
// The first generated scene: this description emits exactly the GLSL that
// used to be hand-written in scene.glsl (kept alongside as the reference —
// `npm run gen glassball -- --check` proves code equality).
//=====================================================================

import {scene, object, lib, glsl, makeGlass,
        room, sphereLight} from '../../../js/scenegen/index.js';


export default scene({
    objects: [

        object('ball', {
            at:       [-1.0, 1.1, -1.2],
            shape:    lib.sphere({radius: 1.2}),
            material: makeGlass(glsl`0.1*vec3(0.3, 0.05, 0.2)`, 1.5),
        }),

        sphereLight({at: [-7.0, 4.0, 2.0], radius: 1.5, color: [0.9, 0.9, 0.9], power: 100}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0]}),
    ],
});

//=====================================================================
// LENSES — the camera models, made visible (docs/camera-plan.md).
//
// A reference page more than art: a checker floor and a row of balls ACROSS the
// frame, all at the focus distance, plus a few nearer and farther. Switch the
// Camera tab's Lens and watch what is sharp:
//
//   Thin Lens     a flat plane: the whole row is sharp, and so is a STRAIGHT
//                 band across the floor
//   Sphere Focus  a sphere around the camera: the band on the floor bends into
//                 an arc, and the balls toward the edges soften (they sit
//                 farther than the focus distance, measured along the ray)
//   Pinhole       everything sharp
//   Orthographic  parallel rays: the row keeps its size however far it is, and
//                 the checker squares don't shrink into the distance
//=====================================================================

import {scene, object, lib, glsl} from '../../../js/scenegen/index.js';
import {room, sphereLight, gloss} from '../../../js/presets/index.js';


//the row across the frame, 14 units ahead of the camera (the focus distance)
const ROW_Z  = -6.0;
const colors = [[0.75, 0.25, 0.2], [0.8, 0.55, 0.2], [0.75, 0.7, 0.25], [0.35, 0.65, 0.3],
                [0.25, 0.55, 0.7], [0.35, 0.35, 0.75], [0.6, 0.3, 0.65]];
const ROW_X  = [-7.2, -4.8, -2.4, 0.0, 2.4, 4.8, 7.2];
const row = colors.map((c, i) => object(`ball${i}`, {
    at:       [ROW_X[i], 0.7, ROW_Z],
    shape:    lib.sphere({radius: 0.7}),
    material: gloss({diffuse: c, gloss: 0.04, roughness: 0.2}),
}));

//and a depth ladder down the middle: nearer and farther than the row
const ladder = [[-1.2, 3.0], [1.2, -1.5], [-1.2, -11.0], [1.2, -16.0]].map(([x, z], i) => object(`deep${i}`, {
    at:       [x, 0.5, z],
    shape:    lib.sphere({radius: 0.5}),
    material: gloss({diffuse: [0.85, 0.85, 0.82], gloss: 0.04, roughness: 0.2}),
}));


export default scene({
    objects: [
        ...row,
        ...ladder,

        //the checker floor: a thin slab on the room's floor, one-unit squares
        object('floor', {
            at:       [0.0, -0.049, -6.0],
            shape:    lib.box({halfSize: [16.0, 0.05, 22.0]}),
            material: glsl`return makeMatte(mod(floor(q.x) + floor(q.z), 2.0) < 1.0 ? vec3(0.7) : vec3(0.1));`,
        }),

        sphereLight({name: 'key', at: [-6.0, 10.0, 4.0], radius: 1.5, power: 160}),
        room({center: [0.0, 8.0, -6.0], half: [16.0, 8.0, 22.0], knobs: {roomLight: {value: 0.4}}}),
    ],
});

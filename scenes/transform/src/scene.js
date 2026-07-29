//=====================================================================
// TRANSFORM — a rotated, non-uniformly scaled body, and a lattice.
//
// The placement scene. `rotate`/`scale` on a node emit toLocal_<name> and
// the min-singular-value Lipschitz factor; the 4-tap normal needs no fixup
// anywhere (chain rule — the body is polished metal precisely so a wrong
// normal would show in its reflection). The rotation angle is a live knob.
// The beads are ONE region made of many copies via repLim.
//
// The authored bounds reference nothing magical: shared values are plain JS
// consts, interpolated as named values (`${{latticeHalf}}` emits the folded
// vec3 with its name as a comment).
//=====================================================================

import {scene, object, lib, glsl, knob, repLim} from '../../../js/scenegen/index.js';
import {room, sphereLight, metal, gloss} from '../../../js/presets/index.js';


const spin      = knob('spin',      {label: 'Body Spin',   min: 0, max: 360, step: 1, value: 35});
const bodyRough = knob('bodyRough', {label: 'Body Polish', min: 0, max: 0.5, step: 0.005, value: 0.04});

//the body: a unit sphere scaled anisotropically, then rotated, then placed
const bodyRadius = 1.0;
const bodyScale  = [1.5, 0.65, 1.0];

//the lattice: a 5 x 1 x 3 grid of beads sitting on the floor (y = -1)
const beadRadius  = 0.32;
const spacing     = 1.0;
const limit       = [2.0, 0.0, 1.0];
const latticeHalf = limit.map(l => spacing*l + beadRadius);


export default scene({
    objects: [

        object('body', {
            at:     [-1.0, 1.2, -1.2],
            scale:  bodyScale,
            rotate: {axis: [0.25, 1.0, 0.15], angle: spin},
            shape:  lib.sphere({radius: bodyRadius}),
            //a sphere of the largest semi-axis encloses the body whatever the rotation
            bound: glsl`sphereDistance(q, ${{maxSemiAxis: bodyRadius*Math.max(...bodyScale)}})`,
            material: metal({specular: [0.92, 0.8, 0.52], roughness: bodyRough}),
        }),

        object('beads', {
            at:    [2.6, -0.68, 0.5],
            shape: repLim(lib.sphere({radius: beadRadius}), {spacing, limit}),
            //one box over the whole lattice: the outermost cell centre plus a bead radius
            bound: glsl`boxDistance(q, ${{latticeHalf}})`,
            material: gloss({diffuse: [0.78, 0.26, 0.22], gloss: 0.1, roughness: 0.2}),
        }),

        sphereLight({at: [-7.0, 4.0, 2.0], radius: 1.5, color: [0.9, 0.9, 0.9], power: 100}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0]}),
    ],
});

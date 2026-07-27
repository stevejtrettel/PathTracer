//=====================================================================
// CARVE — erosion as an operator: the SAME carve, over three different bases.
//
// carve() is the structural opposite of displace(). Displacement ADDS a height
// field, which is not a distance field, so scenes/rock pays a Lipschitz divisor
// at every march step and has to inflate its bound. This SUBTRACTS a distance
// field — an fbm of sphere lattices, smooth-maxed out of the solid (IQ's
// fbmSDF) — and stays a distance field, so the detail marches at full speed and
// the UNCARVED base is still a valid bound.
//
// The demo is the generality: one wrapper, a sphere / a box / a gem, each eaten
// by the same erosion. `gain` is live because it is the honest dial — at 0.5 and
// below every octave is 1-Lipschitz and the field is a true distance function;
// above it the operator starts dividing, which is the marcher's speed.
//=====================================================================

import {scene, object, lib, glsl, knob, carve} from '../../../js/scenegen/index.js';
import {room, sphereLight} from '../../../js/presets/index.js';


const erosion = knob('erosion', {label: 'Erosion',      min: 0.0, max: 1.0, step: 0.005, value: 0.85});
const gain    = knob('gain',    {label: 'Octave Gain',  min: 0.3, max: 0.7, step: 0.005, value: 0.5});
const blend   = knob('blend',   {label: 'Bite Softness', min: 0.02, max: 0.4, step: 0.005, value: 0.15});
const detail  = knob('detail',  {label: 'Octaves', type: 'int', min: 1, max: 9, step: 1, value: 6});

//the same erosion on every base — only the seed and the base differ
const eaten = (seed) => ({octaves: detail, erosion, gain, blend, seed});

const stoneCol  = [0.52, 0.47, 0.40];
const ironCol   = [0.31, 0.16, 0.10];
const copperCol = [0.62, 0.35, 0.18];


export default scene({
    objects: [

        //a carved SPHERE: the asteroid case
        object('rock', {
            at:    [-2.9, 2.0, 0.4],
            shape: carve(lib.sphere({radius: 1.9}), eaten(0.0)),
            //the crevices are where the material should darken; with no data
            //channel yet, the local point does the job by hand
            material: glsl`
                float grain = fbm(6.0*q);
                vec3  col   = mix(${{ironCol}}, ${{stoneCol}}, smoothstep(0.35, 0.7, grain));
                return makeGloss(col, 0.02, mix(0.75, 0.45, grain));
            `,
        }),

        //a carved BOX: IQ's own case, and the one that shows the flat faces
        //surviving between the bites
        object('block', {
            at:    [1.4, 1.7, -0.6],
            shape: carve(lib.box({halfSize: [1.6, 1.6, 1.6]}), eaten(17.0)),
            material: glsl`
                float grain = fbm(5.0*q);
                return makeGloss(mix(${{stoneCol}}, vec3(0.72, 0.70, 0.66), grain), 0.03, 0.5);
            `,
        }),

        //a carved BOTTLE: a shape with no business being erodible, eroded anyway
        //— and the silhouette that makes the point, since you can still read it
        object('nugget', {
            at:    [4.0, 0.0, 2.4],
            shape: carve(lib.bottle({
                baseRadius: 1.25, baseHeight: 1.5,
                neckRadius: 0.3,  neckHeight: 1.0,
                thickness:  0.1,  rounded: 0.1, smoothJoin: 0.3, bump: 1.0,
            }), eaten(93.0)),
            material: glsl`
                float grain = fbm(8.0*q);
                return makeMetal(mix(${{copperCol}}, vec3(0.75, 0.55, 0.35), grain), 1.0, mix(0.45, 0.2, grain));
            `,
        }),

        sphereLight({
            name: 'lamp',
            at: [-4.0, 8.5, 5.0], radius: 1.4,
            color: [1.0, 0.95, 0.88],
            power: knob('lampPower', {label: 'Lamp Power', min: 0, max: 90, step: 0.5, value: 30}),
        }),

        room({
            center: [0.0, 6.0, 0.0], half: [10.0, 6.0, 10.0],
            knobs: {roomLight: {max: 3, value: 1.0}},
        }),
    ],
});

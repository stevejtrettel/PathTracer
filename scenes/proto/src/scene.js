//=====================================================================
// PROTO — the first scene of the region system, now GENERATED.
//
// The kitchen sink: a CUSTOM group (the tumbler's hand-written cylinder
// carve, assigning cup/drink directly, with its own consts and bound), a
// library-shape field material (marble), a knob-less displaced rock, a
// traced lamp, and the room — marched and analytic mixed in one scene.
//=====================================================================

import {scene, object, group, lib, glsl, knob, displace,
        absorbFor} from '../../../js/scenegen/index.js';
import {room, sphereLight, fbm2Height, glass} from '../../../js/presets/index.js';


const polish = knob('polish', {label: 'Marble Polish', min: 0, max: 1, step: 0.01, value: 0.25});

//knob-less: proto's rock is frozen — the live-knob version lives in scenes/rock
const rockHeight = fbm2Height('rockHeight', 2.5);


export default scene({
    objects: [

        //one AUTHORED evaluation feeding two region slots: the body assigns
        //cup and drink itself (q local, out params in scope). cup first, so
        //the glass owns the finish of the shared cavity wall.
        group('tumbler', {
            at: [-2.9, 1.3, 0.0],
            consts: glsl`
                const float CUP_R   = 1.1;             //outer radius
                const float CUP_H   = 1.3;             //outer half-height
                const float CAV_R   = 0.95;            //cavity radius  -> 0.15 wall
                const float CAV_H   = 1.15;            //cavity half-height
                const float CAV_Y   = 0.3;             //cavity centre, raised to leave a base
                const float WATER_Y = 0.5;             //waterline, in cup-local y
            `,
            sdf: glsl`
                float outer  = cylinderDistance(q, CUP_R, CUP_H, 0.08);
                float cavity = cylinderDistance(q - vec3(0.0, CAV_Y, 0.0), CAV_R, CAV_H, 0.05);
                cup   = max(outer, -cavity);
                drink = max(cavity, q.y - WATER_Y);
            `,
            bound: glsl`cylinderSlab(q, CUP_R + 0.15, CUP_H + 0.15)`,
            regions: {
                cup:   {material: glass({absorb: absorbFor([0.86, 0.9, 0.88], 1.2), ior: 1.5})},
                drink: {material: glass({absorb: absorbFor([0.75, 0.22, 0.12], 0.8), ior: 1.34})},
            },
        }),

        object('marble', {
            at:    [0.0, 1.3, 0.0],
            shape: lib.sphere({radius: 1.3}),
            //a FIELD, not a constant: the veining is sampled fresh at every hit
            material: glsl`
                return marbleField(q, 3.5, ${polish});
            `,
        }),

        object('rock', {
            at:    [2.9, 1.35, 0.0],
            shape: displace(lib.sphere({radius: 1.05}), {by: rockHeight, amp: 0.18}),
            material: glsl`
                vec3 tone = mix(vec3(0.38,0.35,0.32), vec3(0.55,0.52,0.47), fbm(4.0*q));
                return makeGloss(tone, 0.03, 0.55);
            `,
        }),

        sphereLight({
            name: 'lamp',
            at: [-1.5, 8.2, 3.5], radius: 0.9,
            color: [1.0, 0.94, 0.86],
            power: knob('lampPower', {label: 'Lamp Power', min: 0, max: 80, step: 0.5, value: 30}),
        }),

        room({
            center: [0.0, 6.0, 0.0], half: [10.0, 6.0, 10.0],
            knobs: {roomLight: {max: 3, value: 0.35}},
        }),
    ],
});

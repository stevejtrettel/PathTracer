//=====================================================================
// BOTTLELIQUID — a liquor bottle with gin in it.
//
// The first glass+liquid GROUP over a profile shape: one authored evaluation of
// the `bottle` shape feeds two regions — the glass `cup` (the shell) and the
// `drink` (the cavity, cut off at the fill line). cup is declared first, so the
// glass owns the finish of the wall they share; the classifier works out every
// interface (air/glass, glass/gin, gin/air) from the sdfs at each hit. Colours
// are raw absorb, verbatim from the original.
//=====================================================================

import {scene, group, lib, glsl} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


export default scene({
    objects: [

        group('bottleLiquid', {
            at:   [1.0, 0.48, 2.0],
            uses: [lib.bottle],
            consts: glsl`
                const float B_BASE_R = 1.25;
                const float B_BASE_H = 1.5;
                const float B_NECK_R = 0.3;
                const float B_NECK_H = 1.0;
                const float B_THICK  = 0.1;
                const float B_ROUND  = 0.1;
                const float B_JOIN   = 0.3;
                const float B_BUMP   = 1.0;
                const float FILL     = 0.6;     //drink level, as a fraction of the base height
            `,
            //one shape, two regions: the glass shell, and its cavity capped at the
            //waterline. bottleCavity is the same profile inset by the wall.
            sdf: glsl`
                cup   = bottleDistance(q, B_BASE_R, B_BASE_H, B_NECK_R, B_NECK_H, B_THICK, B_ROUND, B_JOIN, B_BUMP);
                drink = max(bottleCavity(q, B_BASE_R, B_BASE_H, B_NECK_R, B_NECK_H, B_THICK, B_ROUND, B_JOIN, B_BUMP),
                            q.y - B_BASE_H*FILL);
            `,
            bound: glsl`bottleBound(q, B_BASE_R, B_BASE_H, B_NECK_H, B_THICK, B_ROUND, B_JOIN)`,
            regions: {
                cup:   {material: glass({absorb: glsl`0.5*vec3(0.3, 0.05, 0.08)`, ior: 1.5})},
                drink: {material: glass({absorb: glsl`vec3(0.1, 0.05, 0.0)`, ior: 1.3})},
            },
        }),

        sphereLight({at: [-6.0, 3.0, 0.0], radius: 1.0, color: [0.9, 0.9, 0.9], power: 150}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0], knobs: {roomLight: {value: 0.5}}}),
    ],
});

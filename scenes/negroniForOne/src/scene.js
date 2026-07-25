//=====================================================================
// NEGRONIFORONE — a cocktail and its three bottles.
//
// The multi-vessel scene: FOUR independent glass+liquid groups in one scene — the
// mixed negroni in a cocktail glass, and the gin / campari / vermouth bottles it
// came from, each with its own profile, fill line, and liquor colour. Every group
// is the same "one shape -> cup + drink regions" pattern as bottleLiquid; nothing
// new, just more of it. Region names are unique scene-wide. Colours are raw
// absorb, verbatim from the original (the vec3 reads as its complement).
//=====================================================================

import {scene, group, lib, glsl} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


//the negroni drink: brown vermouth base + a touch of red campari (raw absorb)
const negroniDrink = glsl`3.0*(vec3(1.0) - vec3(204.0, 142.0, 105.0)/255.0 + 0.25*vec3(0.2, 1.0, 0.6))`;


export default scene({
    objects: [

        //-------- the mixed cocktail: a coupe glass, filled a third ----------
        group('negroni', {
            at:   [-1.0, -0.15, -1.2],
            uses: [lib.cocktailGlass],
            consts: glsl`
                const float N_RADIUS    = 1.0;
                const float N_HEIGHT    = 1.0;
                const float N_THICKNESS = 0.1;
                const float N_BASE      = 0.3;
                const float N_LEVEL     = N_HEIGHT/3.0;
            `,
            sdf: glsl`
                float cavity;
                negroniGlass = cocktailGlassDistance(q, N_RADIUS, N_HEIGHT, N_THICKNESS, N_BASE, cavity);
                negroni      = max(cavity, q.y - N_LEVEL);
            `,
            bound: glsl`cocktailGlassBound(q, N_RADIUS, N_HEIGHT, N_BASE)`,
            regions: {
                negroniGlass: {material: glass({absorb: glsl`0.1*vec3(0.3, 0.05, 0.2)`, ior: 1.5})},
                negroni:      {material: glass({absorb: negroniDrink, ior: 1.2})},
            },
        }),

        //-------- gin: a squat bottle, 60% full ------------------------------
        group('ginBottle', {
            at:   [2.0, 0.48, 1.0],
            uses: [lib.bottle],
            consts: glsl`
                const float G_BASE_R = 1.25;
                const float G_BASE_H = 1.5;
                const float G_NECK_R = 0.3;
                const float G_NECK_H = 1.0;
                const float G_THICK  = 0.1;
                const float G_ROUND  = 0.1;
                const float G_JOIN   = 0.3;
                const float G_BUMP   = 1.0;
                const float G_FILL   = 0.6;
            `,
            sdf: glsl`
                ginGlass = bottleDistance(q, G_BASE_R, G_BASE_H, G_NECK_R, G_NECK_H, G_THICK, G_ROUND, G_JOIN, G_BUMP);
                gin      = max(bottleCavity(q, G_BASE_R, G_BASE_H, G_NECK_R, G_NECK_H, G_THICK, G_ROUND, G_JOIN, G_BUMP),
                               q.y - G_BASE_H*G_FILL);
            `,
            bound: glsl`bottleBound(q, G_BASE_R, G_BASE_H, G_NECK_H, G_THICK, G_ROUND, G_JOIN)`,
            regions: {
                ginGlass: {material: glass({absorb: glsl`0.5*vec3(0.3, 0.05, 0.08)`, ior: 1.5})},
                gin:      {material: glass({absorb: glsl`vec3(0.1, 0.05, 0.0)`, ior: 1.3})},
            },
        }),

        //-------- campari: a tall thin bottle, half full, deep red -----------
        group('campariBottle', {
            at:   [3.0, 2.4, -6.0],
            uses: [lib.bottle],
            consts: glsl`
                const float C_BASE_R = 1.0;
                const float C_BASE_H = 3.5;
                const float C_NECK_R = 0.3;
                const float C_NECK_H = 0.75;
                const float C_THICK  = 0.02;
                const float C_ROUND  = 0.1;
                const float C_JOIN   = 0.5;
                const float C_BUMP   = 0.0;
                const float C_FILL   = 0.5;
            `,
            sdf: glsl`
                campariGlass = bottleDistance(q, C_BASE_R, C_BASE_H, C_NECK_R, C_NECK_H, C_THICK, C_ROUND, C_JOIN, C_BUMP);
                campari      = max(bottleCavity(q, C_BASE_R, C_BASE_H, C_NECK_R, C_NECK_H, C_THICK, C_ROUND, C_JOIN, C_BUMP),
                                   q.y - C_BASE_H*C_FILL);
            `,
            bound: glsl`bottleBound(q, C_BASE_R, C_BASE_H, C_NECK_H, C_THICK, C_ROUND, C_JOIN)`,
            regions: {
                campariGlass: {material: glass({absorb: glsl`0.1*vec3(0.3, 0.05, 0.05)`, ior: 1.5})},
                campari:      {material: glass({absorb: glsl`2.5*vec3(0.2, 1.0, 0.6)`, ior: 1.3})},
            },
        }),

        //-------- vermouth: a tall bottle with a long neck, brown ------------
        group('vermouthBottle', {
            at:   [5.0, 1.32, -3.0],
            uses: [lib.bottle],
            consts: glsl`
                const float V_BASE_R = 0.75;
                const float V_BASE_H = 2.5;
                const float V_NECK_R = 0.3;
                const float V_NECK_H = 2.25;
                const float V_THICK  = 0.05;
                const float V_ROUND  = 0.1;
                const float V_JOIN   = 1.5;
                const float V_BUMP   = 1.0;
                const float V_FILL   = 0.6;
            `,
            sdf: glsl`
                vermouthGlass = bottleDistance(q, V_BASE_R, V_BASE_H, V_NECK_R, V_NECK_H, V_THICK, V_ROUND, V_JOIN, V_BUMP);
                vermouth      = max(bottleCavity(q, V_BASE_R, V_BASE_H, V_NECK_R, V_NECK_H, V_THICK, V_ROUND, V_JOIN, V_BUMP),
                                    q.y - V_BASE_H*V_FILL);
            `,
            bound: glsl`bottleBound(q, V_BASE_R, V_BASE_H, V_NECK_H, V_THICK, V_ROUND, V_JOIN)`,
            regions: {
                vermouthGlass: {material: glass({absorb: glsl`0.5*vec3(0.3, 0.05, 0.08)`, ior: 1.5})},
                vermouth:      {material: glass({absorb: glsl`5.0*(vec3(1.0) - vec3(204.0, 142.0, 105.0)/255.0)`, ior: 1.3})},
            },
        }),

        sphereLight({at: [-7.0, 3.0, 2.0], radius: 0.75, color: [1.0, 1.0, 1.0], power: 200}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0], knobs: {roomLight: {value: 0.5}}}),
    ],
});

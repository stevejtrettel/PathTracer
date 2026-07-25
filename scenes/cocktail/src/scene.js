//=====================================================================
// COCKTAIL — a glass with a drink in it.
//
// The group scene: one AUTHORED evaluation (cocktailGlassDistance hands back
// its cavity) feeds TWO region slots, assigned directly by the body. `cup`
// is declared before `drink`, so the glass owns the finish of the wall they
// share; the whole above/below-waterline system is the one max() below —
// the classifier works out every interface from the sdfs at the hit.
//
// The drink's absorb keeps its hand-written mixing math as authored GLSL (a
// by-eye decision deferred to a render-gated pass) — but ONE bundle now feeds
// both the Surface and the Medium side, so the old material/medium copy is
// gone.
//=====================================================================

import {scene, group, lib, glsl} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


export default scene({
    objects: [

        group('cocktail', {
            at:   [-1.0, 0.1, -1.2],
            uses: [lib.cocktailGlass],
            consts: glsl`
                const float COCKTAIL_RADIUS    = 1.0;
                const float COCKTAIL_HEIGHT    = 1.0;
                const float COCKTAIL_THICKNESS = 0.1;
                const float COCKTAIL_BASE      = 0.3;
                const float DRINK_LEVEL        = COCKTAIL_HEIGHT/3.0;   //in the glass's own coordinates
            `,
            //one shape, two outputs: the wall, and the cavity it hands back —
            //the drink is that cavity cut off at the waterline
            sdf: glsl`
                float cavity;
                cup   = cocktailGlassDistance(q, COCKTAIL_RADIUS, COCKTAIL_HEIGHT, COCKTAIL_THICKNESS, COCKTAIL_BASE, cavity);
                drink = max(cavity, q.y - DRINK_LEVEL);
            `,
            bound: glsl`cocktailGlassBound(q, COCKTAIL_RADIUS, COCKTAIL_HEIGHT, COCKTAIL_BASE)`,
            regions: {

                cup: {
                    material: glass({absorb: glsl`0.1*vec3(0.3, 0.05, 0.2)`, ior: 1.5}),
                },

                drink: {
                    material: glass({
                        absorb: glsl`3.0*(vec3(1.0) - vec3(204.0, 142.0, 105.0)/255.0 + 0.25*vec3(0.2, 1.0, 0.6))`,
                        ior: 1.2,
                    }),
                },
            },
        }),

        sphereLight({at: [-7.0, 4.0, 2.0], radius: 1.5, color: [0.9, 0.9, 0.9], power: 100}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0]}),
    ],
});

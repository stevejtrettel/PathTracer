//=====================================================================
// HYPERBOLICHONEYCOMB — the {4,4,5} regular honeycomb of hyperbolic 3-space,
// seen in the upper half-space model along straight Euclidean sightlines.
//
// DATA-COLOURED: `regionData` says which piece of the Coxeter chamber the hit
// landed on — four edge segments, the vertex, the face, or the ideal-boundary
// floor — and the switch below paints them. `floorData` carries the boundary
// grid as (checker cell, distance to the nearest chamber wall), so the checker
// colours AND the line weight are authored here, not in the math.
//
// The FLOOR stays part of the marched DE: it is what caps the half-space, and
// pulling it out into a separate plane makes rays fall through it into
// infinitely fine honeycomb instead.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {sphereLight} from '../../../js/presets/index.js';


//how deep toward the ideal boundary the honeycomb resolves (~20 snappy preview)
const foldDepth = knob('foldDepth', {label: 'Fold Depth', type: 'int', min: 10, max: 200, step: 1, value: 146});

//--- the palette: one colour per chamber feature -----------------------
const colSegA   = [0.55, 0.24, 0.13];
const colSegB   = [0.08, 0.38, 0.40];
const colSegC   = [0.06, 0.18, 0.20];
const colSegD   = [0.46, 0.32, 0.18];
const colVertex = [0.76, 0.66, 0.50];
const colFace   = [0.40, 0.40, 0.65];
const colFloor1 = [0.34, 0.13, 0.09];
const colFloor2 = [0.06, 0.25, 0.28];
const colLine   = [0.72, 0.55, 0.30];

//the grid line's weight, in folded-chamber units (was 0.0015*HC_FLOOR_LINE)
const lineWidth = 0.0015*2.22972;


export default scene({
    objects: [

        object('honey', {
            //local origin at the world origin, so local coords ARE the
            //half-space coordinates the honeycomb is defined in
            at:    [0.0, 0.0, 0.0],
            shape: lib.hyperbolicHoneycomb({iterations: foldDepth}),

            //regionData + floorData are injected because this body reads them
            material: glsl`
                if(regionData == HC_FLOOR){
                    //floorData = (checker cell, distance to nearest chamber wall);
                    //cell < 0 means the boundary fold never resolved
                    vec3 f = floorData.x < 0.0 ? ${{colLine}}
                           : (floorData.x < 0.5 ? ${{colFloor1}} : ${{colFloor2}});
                    float aa = 0.5*${lineWidth};
                    f = mix(f, ${{colLine}}, 1.0 - smoothstep(${lineWidth} - aa, ${lineWidth} + aa, floorData.y));
                    return makeGloss(f, 0.2, 0.15);
                }

                vec3 c = ${{colSegA}};
                if(regionData == HC_SEG_B)  c = ${{colSegB}};
                if(regionData == HC_SEG_C)  c = ${{colSegC}};
                if(regionData == HC_SEG_D)  c = ${{colSegD}};
                if(regionData == HC_VERTEX) c = ${{colVertex}};
                if(regionData == HC_FACE)   c = ${{colFace}};
                return makeGloss(c, 0.2, 0.15);
            `,
        }),

        //warm key light, where the Shadertoy preset put its spot
        sphereLight({at: [0.04, -2.24, 0.92], radius: 0.45, color: [0.95, 0.88, 0.77], power: 22}),
    ],

    //the legacy scene lost its sky and had been rendering against near-black.
    //A neutral ambient is what these Shadertoys actually lit with (its sibling's
    //AMBIENT_STRENGTH is 0.597, neutral white) — matched here, and free to tune.
    sky: {type: 'gradient', top: [0.62, 0.63, 0.66], bottom: [0.45, 0.47, 0.52]},
});

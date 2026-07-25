//=====================================================================
// BEER — a pint with a foamy head.
//
// The field-driven-material scene. The drink is one subsurface region whose
// MEDIUM VARIES WITH POSITION: near the waterline the scattering goes isotropic
// and the mean free path thickens into an opaque head, fading to clear amber
// below. This is the same idea as the curved-media IOR — a bundle field that is a
// glsl`` expression of the local point, not a constant — so the foam is just a
// `foam(q)` field the drink's mfp/blur (and its surface roughness, for the froth)
// read. No jittered normals, no special material: roughness IS the frothy surface.
//
// Colours are raw absorb, verbatim from the original (amber = blue absorbed most).
//=====================================================================

import {scene, group, lib, glsl, field, withSurface} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass, subsurface} from '../../../js/presets/index.js';


const level = 2.0/1.3;   //waterline in the pint's own frame (pint height / 1.3)
const thick = 0.4;       //foam falloff width around the waterline

//the head: 1 at the surface, fading to 0 below. Drives the medium AND the froth.
const foam = field(glsl`
    float foam(vec3 q){
        return exp(-pow(abs((q.y - ${level})/${thick}), 5.0));
    }
`);


export default scene({
    objects: [

        group('beer', {
            at:   [-1.0, 1.3, -2.0],
            uses: [lib.pint],
            consts: glsl`
                const float P_HEIGHT = 2.0;
                const float P_BASE   = 0.75;
                const float P_FLARE  = 1.5;
                const float P_THICK  = 0.01;
            `,
            sdf: glsl`
                cup   = pintDistance(q, P_HEIGHT, P_BASE, P_FLARE, P_THICK);
                drink = max(pintCavity(q, P_HEIGHT, P_BASE, P_FLARE, P_THICK), q.y - ${level});
            `,
            bound: glsl`pintBound(q, P_HEIGHT, P_BASE, P_FLARE)`,
            regions: {
                cup: {material: glass({absorb: glsl`0.2*vec3(0.3, 0.05, 0.2)`, ior: 1.5})},

                //amber beer whose head is a position-varying medium: blur ramps to
                //isotropic and mfp thickens toward the surface (the foam field), and
                //the top surface roughens into froth
                drink: {
                    material: withSurface(
                        subsurface({
                            absorb: glsl`2.5*vec3(0.03, 0.15, 0.9)`,
                            ior:    1.2,
                            mfp:    glsl`0.1*(1.0 + 3.0*exp(-pow(abs((q.y - ${level})/${thick}), 10.0)))`,
                            blur:   glsl`${foam}(q)`,
                        }),
                        {roughness: glsl`0.6*${foam}(q)`}),
                },
            },
        }),

        sphereLight({at: [-8.0, 3.0, 0.0], radius: 1.0, color: [0.9, 0.9, 0.9], power: 150}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0], knobs: {roomLight: {value: 0.5}}}),
    ],
});

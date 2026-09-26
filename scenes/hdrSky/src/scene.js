//=====================================================================
// HDR SKY — four spheres on a ground plane, lit ONLY by an HDR sky.
//
// The test scene for HDR environment maps (docs/hdr-environment-plan.md):
// no room and no lamps, so the sky both shows behind the objects and does
// all the lighting. The four materials read the sky four ways: chrome
// mirrors it, glass bends it, gold tints it, and the matte ball and the
// ground show its diffuse light — including the sun's hard shadows, which an
// 8-bit .jpg sky (clipped at 1.0) could never cast.
//
// The sky is monkstown_castle_2k.hdr (Poly Haven, CC0): bright but soft —
// its brightest pixel is ~39 — so the whole scene converges evenly. A sky
// with a small, very bright sun does not: Poly Haven's sunflowers_puresky has
// a ~40-pixel sun up to ~70,000 carrying 47% of its light, which diffuse
// surfaces find only by chance, so they speckle for a long time. Sky
// Intensity and Sky Rotation (Render tab) scale and turn the sky.
//=====================================================================

import {scene, object, lib, absorbFor} from '../../../js/scenegen/index.js';
import {matte, glass, chrome, gold} from '../../../js/presets/index.js';


export default scene({
    objects: [

        object('chromeBall', {
            at:       [-3.3, 1.0, 0.0],
            shape:    lib.sphere({radius: 1.0}),
            material: chrome({roughness: 0.02}),
        }),

        object('glassBall', {
            at:       [-1.1, 1.0, 0.0],
            shape:    lib.sphere({radius: 1.0}),
            material: glass({absorb: absorbFor([0.94, 0.97, 0.98], 2.0), ior: 1.5}),
        }),

        object('goldBall', {
            at:       [1.1, 1.0, 0.0],
            shape:    lib.sphere({radius: 1.0}),
            material: gold({roughness: 0.25}),
        }),

        object('matteBall', {
            at:       [3.3, 1.0, 0.0],
            shape:    lib.sphere({radius: 1.0}),
            material: matte({diffuse: [0.8, 0.8, 0.8]}),
        }),

        object('ground', {
            at:       [0.0, 0.0, 0.0],
            shape:    lib.plane({normal: [0.0, 1.0, 0.0]}),
            material: matte({diffuse: [0.45, 0.45, 0.45]}),
        }),
    ],

    sky: {type: 'image', src: '/assets/monkstown_castle_2k.hdr'},
});

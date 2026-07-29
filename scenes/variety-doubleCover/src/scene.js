//=====================================================================
// DOUBLE COVER — one formula, two legitimate pictures.
//
// Both objects come from the SAME catalogue reference — Kummer's quartic,
// authored homogeneous in R⁴ (16 nodes, μ² = 1.5) — and differ only in
// `view:` (docs/variety-builder.md §4: capability is the signature):
//
//   chart   view 'affine' — the generated w = 1 patch: the quartic as it
//           sits in ordinary space, its ends cut off by the clip ball
//           because the real surface runs to infinity.
//   cover   view 'stereo' — the double cover on S³, stereographically
//           projected back down: the WHOLE projective surface, compact,
//           nothing running off — curved into the sphere's geometry.
//
// Both are thickened with the asymmetric shell (inward ≠ outward) so the
// zero set has physical presence, then clipped. Same material on purpose:
// the only difference between the two objects is the view.
//=====================================================================

import {scene, object, lib, knob, variety, varieties, clip, shell} from '../../../js/scenegen/index.js';
import {room, sphereLight, gloss} from '../../../js/presets/index.js';


const kummerScale = knob('kummerScale', {label: 'Kummer Scale', min: 0.3, max: 3.0, step: 0.01, value: 1.0});
const shellIn     = knob('shellIn',  {label: 'Shell Inward',  min: 0.003, max: 0.1, step: 0.001, value: 0.04});
const shellOut    = knob('shellOut', {label: 'Shell Outward', min: 0.003, max: 0.1, step: 0.001, value: 0.015});

const stone = gloss({diffuse: [0.72, 0.62, 0.48], gloss: 0.04, roughness: 0.4});


export default scene({
    objects: [

        object('chart', {
            at:    [-2.2, 1.9, -1.2],
            shape: clip(shell(variety(varieties.kummer, {scale: kummerScale, view: 'affine'}),
                              {inward: shellIn, outward: shellOut}),
                        {to: lib.sphere({radius: 1.9}), blend: 0.06}),
            material: stone,
        }),

        object('cover', {
            at:    [2.2, 1.9, -1.2],
            shape: clip(shell(variety(varieties.kummer, {scale: kummerScale, view: 'stereo'}),
                              {inward: shellIn, outward: shellOut}),
                        {to: lib.sphere({radius: 1.9}), blend: 0.06}),
            material: stone,
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

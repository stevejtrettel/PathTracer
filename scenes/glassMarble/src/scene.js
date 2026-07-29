//=====================================================================
// GLASS MARBLE — a delicate surface sealed inside a glass ball.
//
// The multi-material composite from the variety requirements (docs/
// variety-builder.md §2): a SHEET variety — infinitely thin, a different
// color on each face — floating inside a refracting glass sphere. Two
// nodes sharing one center, declared inner-to-outer:
//
//   veil     the enneper surface as a sheet, clipped to a ball slightly
//            SMALLER than the marble so it never pokes through
//   marble   a plain glass sphere around it — analytic (sphere-traced)
//            while the veil inside it marches
//
// This is the two-node form a preset would later name; the scene's point
// is that it is already short to write.
//=====================================================================

import {scene, object, sheet, lib, knob, glsl, absorbFor,
        variety, varieties, clip} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


const veilScale  = knob('veilScale', {label: 'Veil Scale', min: 0.5, max: 6.0, step: 0.01, value: 2.2});
const frontColor = knob('frontColor', {type: 'color', label: 'Veil Front', value: [0.85, 0.28, 0.22]});
const backColor  = knob('backColor',  {type: 'color', label: 'Veil Back',  value: [0.90, 0.82, 0.30]});
const veilGloss  = knob('veilGloss', {label: 'Veil Sheen', min: 0, max: 1, step: 0.01, value: 0.3});


export default scene({
    objects: [

        sheet('veil', {
            at:    [0.0, 1.5, 0.0],
            shape: clip(variety(varieties.enneper, {scale: veilScale}),
                        {to: lib.sphere({radius: 1.15}), blend: 0.04}),
            front: glsl`makeGloss(${frontColor}, ${veilGloss}, 0.2)`,
            back:  glsl`makeGloss(${backColor}, ${veilGloss}, 0.2)`,
        }),

        object('marble', {
            at:    [0.0, 1.5, 0.0],
            shape: lib.sphere({radius: 1.25}),
            material: glass({absorb: absorbFor([0.78, 0.86, 0.95], 2.5), ior: 1.5}),
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

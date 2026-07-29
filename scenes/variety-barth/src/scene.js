//=====================================================================
// VARIETY — the Barth sextic, confined to a ball in the room.
//
// The pilot of the variety builder (docs/variety-builder.md): an equation
// as a first-class base, riding the modifier chain. The catalogue formula
// is the homogeneous 4-ary (the hand 3-ary patch beside it is the
// redundant rung — the generator derives the w = 1 patch itself, which is
// what `view: 'affine'` draws: the classic 65-node icosahedral surface).
//
// Drawn as a SHEET: the zero set itself, infinitely thin, front/back
// materials on the s>0 / s<0 faces. The sdf stays SIGNED (classifier and
// normals read it); abs() lives only in the emitted marched form. The clip
// ball DONATES its bound — the whole acceleration story: the real sdf is
// dual-number evaluations of a degree-6 polynomial, the bound is one
// length().
//
// (This scene replaced the last hand-written scene.glsl — git history has
// it; it had been broken since the roomFace->roomFaceData migration.)
//=====================================================================

import {scene, sheet, lib, knob, glsl,
        variety, varieties, clip} from '../../../js/scenegen/index.js';
import {room, sphereLight} from '../../../js/presets/index.js';


//the equation's internal zoom: how much of the sextic fits inside the ball
const varScale = knob('varScale', {label: 'Variety Scale', min: 0.3, max: 5, step: 0.01, value: 1.1});

const frontColor = knob('frontColor', {type: 'color', label: 'Front Face', value: [0.85, 0.28, 0.22]});
const backColor  = knob('backColor',  {type: 'color', label: 'Back Face',  value: [0.90, 0.82, 0.30]});
const sheetGloss = knob('sheetGloss', {label: 'Sheen', min: 0, max: 1, step: 0.01, value: 0.3});


export default scene({
    objects: [

        sheet('barth', {
            at:    [0.0, 1.9, -1.2],
            shape: clip(variety(varieties.barthSextic, {scale: varScale, view: 'affine'}),
                        {to: lib.sphere({radius: 1.9}), blend: 0.06}),
            front: glsl`makeGloss(${frontColor}, ${sheetGloss}, 0.2)`,
            back:  glsl`makeGloss(${backColor}, ${sheetGloss}, 0.2)`,
        }),

        sphereLight({
            name: 'light',
            at: [-7.0, 4.0, 2.0], radius: 1.5,
            color: [0.9, 0.9, 0.9], power: 100,
        }),

        room({
            center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0],
            knobs: {roomLight: {max: 2, value: 0.6}},
        }),
    ],
});

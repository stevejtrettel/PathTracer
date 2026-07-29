//=====================================================================
// VARIETY — a zero set drawn two ways: as a surface, and as a solid.
//
// The pilot of the variety builder (docs/variety-builder.md): equations as
// first-class bases, riding the modifier chain. A variety is authored as an
// EQUATION whose signed defining function is the surface; the node kind is
// the mode:
//
//   sheet   the zero set itself — infinitely thin, two-sided, front/back
//           materials on the s>0 / s<0 faces. The sdf stays SIGNED (the
//           classifier and normals read it); abs() lives only in the
//           emitted marched form.
//   solid   the same machinery with an interior: shell() thickens the zero
//           set (inward keeps the hand scene's varietyShell semantics),
//           and the ray refracts and absorbs through it like any glass.
//
// Both are clipped to a ball — the clip DONATES its bound, which is the
// whole acceleration story: the real sdf is dual-number evaluations of a
// trig polynomial, the bound is one length().
//
// (This scene replaced the last hand-written scene.glsl, which had been
// broken since the roomFace->roomFaceData migration — git history has it.)
//=====================================================================

import {scene, object, sheet, lib, knob, glsl, absorbFor,
        variety, varieties, clip, shell} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


//the equation's internal zoom: how many gyroid cells fit inside the clip ball
const varScale = knob('varScale', {label: 'Variety Scale', min: 0.3, max: 5, step: 0.01, value: 1.1});

//depth of the SOLID's shell, grown inward from the zero set (outward stays
//0, the hand varietyShell semantics). The floor is 2*AT_THRESH: thinner and
//the classifier cannot separate the two faces (docs/marching.md).
const shellThickness = knob('shellThickness', {label: 'Shell Thickness', min: 0.006, max: 0.2, step: 0.001, value: 0.035});

const frontColor = knob('frontColor', {type: 'color', label: 'Sheet Front', value: [0.85, 0.28, 0.22]});
const backColor  = knob('backColor',  {type: 'color', label: 'Sheet Back',  value: [0.90, 0.82, 0.30]});
const sheetGloss = knob('sheetGloss', {label: 'Sheet Sheen', min: 0, max: 1, step: 0.01, value: 0.3});


export default scene({
    objects: [

        //the enneper surface as a SHEET: two genuinely different opaque
        //materials on the two sides of one infinitely thin membrane —
        //front is the side the gradient points toward
        sheet('sheet', {
            at:    [-2.4, 1.6, -1.2],
            shape: clip(variety(varieties.enneper, {scale: varScale}),
                        {to: lib.sphere({radius: 1.9}), blend: 0.06}),
            front: glsl`makeGloss(${frontColor}, ${sheetGloss}, 0.2)`,
            back:  glsl`makeGloss(${backColor}, ${sheetGloss}, 0.2)`,
        }),

        //the control: the gyroid thickened into a real region, with glass
        //inside it. Thicken FIRST, clip second — clipping first would cut
        //the shell open and expose the interior at the ball's surface
        object('solid', {
            at:    [2.4, 1.6, -1.2],
            shape: clip(shell(variety(varieties.gyroid, {scale: varScale}),
                              {inward: shellThickness}),
                        {to: lib.sphere({radius: 1.9}), blend: 0.06}),
            material: glass({absorb: absorbFor([0.72, 0.86, 0.80], 0.6), ior: 1.5}),
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

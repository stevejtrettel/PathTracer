//=====================================================================
// MODIFIER — the escape hatch (docs/authored-modifiers.md).
//
// modifier() is the ground-level primitive beneath the named combinators:
// the author writes the distance rewrite as a glsl`` EXPRESSION over the
// documented locals `d` (the running distance) and `q` (the folded local
// point), and DECLARES the one thing the generator cannot derive — the
// bound effect. One object per declaration form:
//
//   drilled  a smooth vertical borehole through a sphere. The surface
//            only ever recedes, so the declaration is 'keep'.
//   halo     the gem plus a detached skin of its own offset surface,
//            solid where |d - gap| < 0.04. The outermost face sits
//            gap + 0.04 OUTSIDE the base, so the declaration is
//            {inflate: 0.64} — the gap knob's max (0.6) plus the skin:
//            the knob's whole range is the promise. A named subtract()
//            STACKS OVER the hatch, halving the assembly vertically —
//            a placed cutter slices the WHOLE thing (shell, air gap,
//            gem), so the cross-section face shows all three layers.
//=====================================================================

import {scene, object, lib, knob, glsl, modifier, subtract} from '../../../js/scenegen/index.js';
import {room, sphereLight, gloss} from '../../../js/presets/index.js';


const bite = knob('bite', {label: 'Bore Softness', min: 0.02, max: 0.3, step: 0.005, value: 0.08});
const gap  = knob('gap',  {label: 'Halo Gap',      min: 0.05, max: 0.6, step: 0.005, value: 0.35});


export default scene({
    objects: [

        object('drilled', {
            at:    [-1.8, 1.0, 0.0],
            shape: modifier(lib.sphere({radius: 1.0}), {
                expr:  glsl`smax(d, 0.45 - length(q.xz), ${bite})`,
                bound: 'keep',
            }),
            material: gloss({diffuse: [0.72, 0.34, 0.22], gloss: 0.06, roughness: 0.3}),
        }),

        object('halo', {
            at:    [1.9, 1.5, 0.4],
            shape: subtract(modifier(lib.gem({size: 1.3}), {
                       expr:  glsl`min(d, abs(d - ${gap}) - 0.04)`,
                       bound: {inflate: 0.64},
                   }),
                   //keeps the side the normal points toward: the -z half,
                   //so the flat cross-section faces the camera
                   {what: lib.plane({normal: [0.0, 0.0, -1.0]})}),
            material: gloss({diffuse: [0.32, 0.42, 0.58], gloss: 0.08, roughness: 0.35}),
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

//=====================================================================
// PENCIL — the equation is yours to play with.
//
// Two custom varieties authored IN THIS FILE, one per transpiler rung
// (docs/variety-builder.md §5, docs/equation-transpiler.md):
//
//   hesse    an {eqn:} string — the Hesse pencil of cubics,
//            x³ + y³ + z³ − 3a·xyz. The knob `a` is a COEFFICIENT OF THE
//            EQUATION: dragging it changes WHICH SURFACE this is, not
//            where it sits. At a = 1 the cubic degenerates — it factors
//            into a plane times a quadric — and the geometry pinches
//            through its singular member live.
//   chmutov  an {fns:} source — standard float GLSL with a counted loop
//            (the Chebyshev recursion), transpiled the same way.
//
// Both are SOLIDS (the {s < 0} region) confined to balls. hesse's clip is
// HARD (blend 0), chmutov's soft — the two clip flavors side by side.
//=====================================================================

import {scene, object, lib, knob, variety, clip} from '../../../js/scenegen/index.js';
import {room, sphereLight, gloss} from '../../../js/presets/index.js';


//the pencil parameter — a number INSIDE the equation. 1.0 is the singular member.
const a = knob('a', {label: 'Pencil Parameter', min: 0.0, max: 2.0, step: 0.005, value: 0.8});

const CHMUTOV = `
    float cheb(float x, int n){
        for(int i = 0; i < n; i++){ x = 2.0*x*x - 1.0; }
        return x;
    }
    float chmutov(float x, float y, float z){
        int n = 2;
        return cheb(x, n) + cheb(y, n) + cheb(z, n) + 1.0;
    }`;


export default scene({
    objects: [

        object('hesse', {
            at:    [-2.2, 1.9, -1.0],
            shape: clip(variety({eqn: 'x^3 + y^3 + z^3 - 3*a*x*y*z', params: {a}}),
                        {to: lib.sphere({radius: 1.8})}),
            material: gloss({diffuse: [0.75, 0.33, 0.24], gloss: 0.06, roughness: 0.3}),
        }),

        object('chmutov', {
            at:    [2.2, 1.9, -1.0],
            shape: clip(variety({fns: CHMUTOV}),
                        {to: lib.sphere({radius: 1.8}), blend: 0.06}),
            material: gloss({diffuse: [0.3, 0.42, 0.58], gloss: 0.06, roughness: 0.3}),
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

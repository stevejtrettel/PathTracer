//=====================================================================
// HYPERBOLIC SOLIDS — the right-angled dodecahedron and the Coxeter cube of H^3,
// both in the BALL (Poincare) model, side by side.
//
// They pair because they are the same construction at different symmetry: the
// unit ball with face spheres carved out, each sphere meeting the boundary
// ORTHOGONALLY (d^2 = r^2 + 1), which is what a hyperbolic plane looks like in
// this model. Twelve faces for the dodecahedron, six for the cube. Both live in
// the unit ball, so they are drawn at the same scale and are directly comparable.
//
// `dihedral` CANNOT REACH 4. The cube's radicand needs 2 sin^2(pi/n) > 1, i.e.
// n < 4; at exactly 4 it is zero and the face spheres run off to infinity. The
// knob stops at 3.9 for that reason — see glsl/shapes/models/hypCoxCube.glsl,
// whose header also flags that the legacy parameter name disagrees with this range.
//
// `coreRadius` hollows both solids out, so you can see the face spheres from inside.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, matte} from '../../../js/presets/index.js';


const dihedral   = knob('dihedral',   {label: 'Cube Dihedral (< 4)', min: 2.0, max: 3.9, step: 0.01, value: 3.0});
const coreRadius = knob('coreRadius', {label: 'Hollow Core',         min: 0.0, max: 0.9, step: 0.01, value: 0.0});

const chalk = matte({diffuse: [0.78, 0.74, 0.68]});


export default scene({
    objects: [

        //the right-angled dodecahedron: twelve face spheres, geometry fixed by
        //orthogonality (there is no size parameter — it is THE solid)
        object('dodec', {
            at:       [-3.0, 4.2, 0.0],
            scale:    [3.2, 3.2, 3.2],
            shape:    lib.hypDod({rCent: coreRadius}),
            material: chalk,
        }),

        //the Coxeter cube: six face spheres, and a real family in `dihedral`
        object('coxcube', {
            at:       [3.0, 4.2, 0.0],
            scale:    [3.2, 3.2, 3.2],
            shape:    lib.hypCoxCube({dihedral: dihedral, rCent: coreRadius}),
            material: chalk,
        }),

        sphereLight({name: 'key', at: [7.0, 15.0, 11.0], radius: 3.0, power: 3800}),
        room({center: [0.0, 11.0, 0.0], half: [15.0, 11.0, 28.0], knobs: {roomLight: {value: 1.7}}}),
    ],
});

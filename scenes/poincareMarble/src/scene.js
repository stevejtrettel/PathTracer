//=====================================================================
// POINCARÉ MARBLE — the right-angled hyperbolic dodecahedron, in glass.
//
// The dodecahedron is drawn in the BALL model of H^3: the unit ball with twelve
// spheres carved out of it, each meeting the boundary ORTHOGONALLY, which is
// what a hyperbolic plane looks like in this model. Its faces are therefore
// spherical caps rather than flat, and the whole figure lives inside the unit
// ball — so a glass sphere of radius 1 is exactly the boundary of the space it
// lives in, not an arbitrary container. That is the picture: a hyperbolic world
// held in the ball that bounds it.
//
// Identifying opposite faces of this solid gives the Seifert-Weber space, which
// is where the legacy scene got its name.
//
// TWO NESTED REGIONS, declared inner-to-outer. The legacy carried this as a
// composite struct with hand-written interface logic: it compared the two
// distances, worked out which side of which surface it was on, and called
// setMaterialInterface with the right pair each way round. All of that is what
// `nestedIn:` now says in one word — the generator emits the containment test,
// and the region system handles the glass/solid interface on its own.
//
// `coreRadius` hollows the dodecahedron out from the middle, so you can see the
// face spheres from inside. The legacy fixed it at 0.4.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';


//MIND THE RANGE. The face spheres cut in to |p| = 0.3836 and the solid only
//reaches |p| = 0.5393, so a core radius near 0.4 carves past the faces and
//leaves nothing but slivers at the vertices — measured, 0.4 destroys 85% of the
//solid, which is why this scene first looked like a plain glass marble. The
//legacy's fixed 0.4 was doing exactly that. 0 is the solid dodecahedron.
const coreRadius = knob('coreRadius', {label: 'Hollow Core', min: 0.0, max: 0.35, step: 0.01, value: 0.0});

const AT    = [0.0, 2.6, 0.0];
const SCALE = [2.5, 2.5, 2.5];   //the model is unit-radius; this makes it a hero object


export default scene({
    objects: [

        //the solid, INSIDE the glass — declared first, as nesting requires
        object('core', {
            at:       AT,
            scale:    SCALE,
            nestedIn: 'marble',
            shape:    lib.hypDod({rCent: coreRadius}),
            material: glass({absorb: [7.5, 20.794, 22.147], ior: 2.5}),
        }),

        //the ball that bounds the hyperbolic space
        object('marble', {
            at:       AT,
            scale:    SCALE,
            shape:    lib.sphere({radius: 1.0}),
            material: glass({absorb: [0.06, 0.01, 0.04], ior: 1.5}),
        }),

        sphereLight({name: 'key', at: [-8.0, 9.0, 6.0], radius: 2.0, power: 220}),

        room({center: [0.0, 5.75, -5.0], half: [20.0, 8.25, 15.0],
              knobs: {roomLight: {value: 0.5}}}),
    ],
});

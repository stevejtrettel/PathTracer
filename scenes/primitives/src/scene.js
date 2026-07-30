//=====================================================================
// PRIMITIVES — the exact closed forms of glsl/shapes/primitives/, in one frame.
//
// A reference page, not art: the point is to compare them side by side, which is
// the one question a lineup answers better than a close-up ("is the dodecahedron
// sized consistently with the icosahedron?"). Every knob here is a real shape
// parameter off the catalogue, so the page is an instrument.
//
// Row 1 is the platonic solids, which all take `size` as an INRADIUS and so
// share one knob. Rows 2 and 3 are the rest, each with its own defining dial.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, matte} from '../../../js/presets/index.js';


//the platonics share one size: that is what makes them comparable
const solidSize  = knob('solidSize',  {label: 'Platonic Inradius', min: 0.4, max: 2.0, step: 0.01, value: 1.1});
//and one dial each for the others
const coneTop    = knob('coneTop',    {label: 'Cone Top Radius',   min: 0.0, max: 1.4, step: 0.01, value: 0.35});
const rimRound   = knob('rimRound',   {label: 'Cylinder Rim',      min: 0.0, max: 0.6, step: 0.01, value: 0.12});
const tubeRadius = knob('tubeRadius', {label: 'Torus Tube',        min: 0.1, max: 0.8, step: 0.01, value: 0.38});
const capRadius  = knob('capRadius',  {label: 'Capsule Radius',    min: 0.1, max: 0.9, step: 0.01, value: 0.42});
const frameEdge  = knob('frameEdge',  {label: 'BoxFrame Strut',    min: 0.02, max: 0.4, step: 0.01, value: 0.11});
const hourFlare  = knob('hourFlare',  {label: 'Hourglass Flare',   min: 0.2, max: 1.3, step: 0.01, value: 0.8});

const clay = matte({diffuse: [0.74, 0.69, 0.61]});
const at   = (name, shape, x, y) => object(name, {at: [x, y, 0.0], shape, material: clay});


export default scene({
    objects: [

        //---- row 1: the platonic solids, one shared inradius ----------------
        at('tetra',  lib.tetrahedron({size: solidSize}),  -4.6, 7.4),
        at('octa',   lib.octahedron({size: solidSize}),   -1.5, 7.4),
        at('dodeca', lib.dodecahedron({size: solidSize}),  1.5, 7.4),
        at('icosa',  lib.icosahedron({size: solidSize}),   4.6, 7.4),

        //---- row 2: the round ones -----------------------------------------
        at('cone',   lib.cone({height: 1.1, radiusLow: 1.0, radiusHigh: coneTop}), -4.6, 4.0),
        at('cyl',    lib.cylinder({radius: 1.0, height: 1.1, rounded: rimRound}),  -1.5, 4.0),
        at('torus',  lib.torus({ringRadius: 1.0, tubeRadius: tubeRadius}),          1.5, 4.0),
        at('caps',   lib.capsule({a: [-0.7, -0.6, 0.0], b: [0.7, 0.6, 0.0], radius: capRadius}), 4.6, 4.0),

        //---- row 3: the rest -----------------------------------------------
        at('egg',    lib.ellipsoid({radii: [1.3, 0.85, 0.95]}),                   -3.1, 1.3),
        at('frame',  lib.boxFrame({halfSize: [1.0, 1.0, 1.0], edge: frameEdge}),   0.0, 1.3),
        at('hour',   lib.doubleCone({height: 1.2, radius: hourFlare}),             3.1, 1.5),

        sphereLight({name: 'key', at: [8.0, 16.0, 12.0], radius: 3.2, power: 4200}),
        room({center: [0.0, 12.0, 0.0], half: [16.0, 12.0, 34.0], knobs: {roomLight: {value: 2.0}}}),
    ],
});

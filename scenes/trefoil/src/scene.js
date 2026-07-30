//=====================================================================
// TREFOIL — the (2,3) torus knot as a square-section tube.
//
// Its own page because it needs room: the tube is THIN relative to the knot, so
// at a small size it renders as a sub-pixel hairline and reads as nothing at all
// (the tube is 0.075*size across, the knot 0.68*size). Big is the only way to see
// the three-fold over-under crossing that makes it a trefoil rather than a circle.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, matte} from '../../../js/presets/index.js';


const knotSize = knob('knotSize', {label: 'Knot Size', min: 2.0, max: 14.0, step: 0.1, value: 6.5});


export default scene({
    objects: [
        object('knot', {
            at:       [0.0, 5.2, 0.0],
            shape:    lib.trefoil({size: knotSize}),
            material: matte({diffuse: [0.8, 0.72, 0.6]}),
        }),

        sphereLight({name: 'key', at: [8.0, 16.0, 12.0], radius: 3.5, power: 4200}),
        room({center: [0.0, 11.0, 0.0], half: [16.0, 11.0, 26.0], knobs: {roomLight: {value: 1.8}}}),
    ],
});

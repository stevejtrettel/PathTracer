//=====================================================================
// MENGER SPONGE — IQ's classic, seven levels deep.
//
// Subtractive and therefore cheap: at each of seven scales, fold space into a
// 3x3x3 cell and MAX out a cross of three square tubes. Each level triples the
// frequency, so the holes get three times finer and seven is past where more
// would show at any sane resolution.
//
// `size` is the dial. This port also fixed the scaling: the legacy divided p by
// size but never scaled the returned distance back, so a sponge under unit size
// overestimated distance and the marcher could step through it.
//=====================================================================

import {scene, object, lib, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, matte} from '../../../js/presets/index.js';


const spongeSize = knob('spongeSize', {label: 'Sponge Size', min: 0.6, max: 5.0, step: 0.05, value: 2.6});


export default scene({
    objects: [
        object('sponge', {
            at:       [0.0, 3.2, 0.0],
            shape:    lib.menger({size: spongeSize}),
            material: matte({diffuse: [0.78, 0.73, 0.65]}),
        }),

        sphereLight({name: 'key', at: [7.0, 13.0, 10.0], radius: 2.8, power: 3200}),
        room({center: [0.0, 10.0, 0.0], half: [14.0, 10.0, 24.0], knobs: {roomLight: {value: 1.8}}}),
    ],
});

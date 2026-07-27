//=====================================================================
// KLEINIANLIMIT — the compact seahorse limit set, cast in scattering glass.
//
// A port of the original hand-written demo (legacy/kleinianLimit). Same
// estimator as the `kleinian` explorer, in Jos Leys' SEAHORSE BOX rather than
// the standard one — a narrower skewed wrap, the inversion sphere off the
// axis, a gentler fold — which is what makes this limit set compact instead of
// a lattice. offset 0 puts that compact piece at the origin; the box constants
// live in js/presets/fractals.js, so (R, I) stay live knobs here too.
//
// COLOUR is the legacy absorb verbatim: 7·(0.4, 0.25, 0.05). That extinguishes
// RED hardest, so the glass reads blue-teal — deliberate, and what the original
// engine did with the same numbers (it applied absorb as Beer extinction too).
//=====================================================================

import {scene, object, glsl, knob, withSurface} from '../../../js/scenegen/index.js';
import {room, sphereLight, subsurface, kleinianSeahorse} from '../../../js/presets/index.js';


//the seahorse group. Defaults ARE the seahorse (R = 1.5+0.39, I = 0.55*2-1);
//sweeping them explores the same family inside this box.
const kleinR = knob('kleinR', {label: 'Klein R',             min: 1.4, max: 2.2, step: 0.001, value: 1.89});
const kleinI = knob('kleinI', {label: 'Klein I',             min: 0.0, max: 2.0, step: 0.001, value: 0.1});
const detail = knob('detail', {label: 'Detail (iterations)', type: 'int', min: 10, max: 80, step: 1, value: 50});

//the scattering interior: mfp = 0.5*density is the legacy dial exactly
const sssDensity = knob('sssDensity', {label: 'Density', min: 0.01, max: 1, step: 0.01, value: 0.557});
const sssScatter = knob('sssScatter', {label: 'Scatter', min: 0,    max: 1, step: 0.01, value: 0.877});


export default scene({
    objects: [

        object('klein', {
            at:    [0.0, 0.0, -3.0],
            shape: kleinianSeahorse({kleinR, kleinI, iterations: detail, offset: [0.0, 0.0, 0.0]}),
            //glass that scatters: light crosses the surface (transmit 1 by
            //construction), diffuses through the interior, and leaves through a
            //nearly smooth exit — the polish is what keeps the highlights sharp
            material: withSurface(
                subsurface({absorb: [2.8, 1.75, 0.35], ior: 1.5,
                            mfp: glsl`0.5*${sssDensity}`, blur: sssScatter}),
                {roughness: 0.04}),
        }),

        sphereLight({at: [-7.0, 8.0, 2.0], radius: 1.0, color: [0.9, 0.9, 0.9], power: 100}),

        //the legacy room: y -1..14, x -20..8.5, z -20..10, slate walls, lit ceiling
        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0]}),
    ],
});

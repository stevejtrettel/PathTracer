//=====================================================================
// BOTTLETORUSCLEARCOAT — the purple decanter under a clear lacquer.
//
// A REINTERPRETATION, not a literal port. The legacy scene faked a clearcoat with
// a SECOND concentric glass shell (a clear ior-1.4 wall around the colored one),
// because the old material model had no coat lobe. The new model does: the
// `Surface.coat` field IS a clearcoat ("1 = full clearcoat", material.glsl), so
// this is just `bottleTorus` with `withCoat` on its material — one shell, one
// region, the coat expressed as what it physically is (a Fresnel lacquer lobe),
// not a geometric hack. See docs/material-system.md.
//=====================================================================

import {scene, object, lib, glsl, knob, withSurface} from '../../../js/scenegen/index.js';
import {room, sphereLight, subsurface, withCoat} from '../../../js/presets/index.js';


const sssScatter = knob('sssScatter', {label: 'Scatter', min: 0, max: 1, step: 0.01, value: 0.368});


export default scene({
    objects: [

        object('donut', {
            at:    [0.0, 1.0, 0.0],
            shape: lib.bottleTorus({
                outer: 2.0, inner: 1.2, height: 2.5,
                base: 0.3, flare: 6.0, smoothing: 2.75, thickness: 0.08,
            }),
            //the dense purple scattering glass (raw absorb, as bottleTorus) UNDER a
            //full clear lacquer — the clearcoat is a coat lobe, no second shell
            material: withCoat(
                withSurface(
                    subsurface({absorb: glsl`0.3*vec3(0.3, 0.05, 0.2)`, ior: 1.6,
                                mfp: glsl`0.02`, blur: sssScatter}),
                    {roughness: 0.0}),
                {coat: 1.0, coatRoughness: 0.0}),
        }),

        sphereLight({at: [-12.0, 8.0, 2.0], radius: 1.5, color: [1.0, 1.0, 1.0], power: 60}),

        room({
            center: [-5.75, 5.75, -5.0], half: [14.25, 8.25, 15.0],
            knobs: {roomLight: {value: 0.1}},
        }),
    ],
});

//=====================================================================
// SUBSURFACE — three balls, testing the medium walk and nested regions.
//
// The scattering scene: makeSubsurface anywhere -> the emitter derives
// SCENE_SUBSURFACE (compiling the medium walk in) and emits inside_/insideOf.
// The core declares `nestedIn: 'shell'`, which is the ONE fact the emitter
// cannot infer — it yields the exclusion term in inside_shell and validates
// that the core is declared first (inner to outer).
//
//   glass   clear, ballistic       the control
//   wax     scattering interior    the walk itself
//   shell   a scattering CORE inside a glass ball — the nested pair: a
//           non-air/non-air interface, and a walk that must stop at the
//           core's own wall
//=====================================================================

import {scene, object, lib, knob, absorbFor} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass, subsurface} from '../../../js/presets/index.js';


//--- the wax ball ----------------------------------------------------
const waxTint    = knob('waxTint',    {type: 'color', label: 'Wax Tint', value: [0.95, 0.55, 0.28]});
const waxDepth   = knob('waxDepth',   {label: 'Wax Tint Depth', min: 0.05, max: 3, step: 0.01, value: 0.6});
const waxDensity = knob('waxDensity', {label: 'Wax mfp',        min: 0.01, max: 1.5, step: 0.01, value: 0.18});
const waxBlur    = knob('waxBlur',    {label: 'Wax Phase',      min: 0, max: 1, step: 0.01, value: 0.8});

//--- the core, inside the glass shell --------------------------------
const coreTint    = knob('coreTint',    {type: 'color', label: 'Core Tint', value: [0.22, 0.68, 0.52]});
const coreDepth   = knob('coreDepth',   {label: 'Core Tint Depth', min: 0.05, max: 3, step: 0.01, value: 0.4});
const coreDensity = knob('coreDensity', {label: 'Core mfp',        min: 0.01, max: 1.5, step: 0.01, value: 0.12});


export default scene({
    objects: [

        //declared first: nested regions come before their containers
        object('core', {
            at:       [2.0, 1.3, -1.2],
            shape:    lib.sphere({radius: 0.8}),
            nestedIn: 'shell',
            material: subsurface({absorb: absorbFor(coreTint, coreDepth), ior: 1.4, mfp: coreDensity, blur: 1.0}),
        }),

        object('shell', {
            at:       [2.0, 1.3, -1.2],
            shape:    lib.sphere({radius: 1.3}),
            material: glass({absorb: absorbFor([0.9, 0.93, 0.96], 3.0), ior: 1.5}),
        }),

        object('wax', {
            at:       [-1.0, 1.3, -1.2],
            shape:    lib.sphere({radius: 1.3}),
            material: subsurface({absorb: absorbFor(waxTint, waxDepth), ior: 1.45, mfp: waxDensity, blur: waxBlur}),
        }),

        object('glass', {
            at:       [-4.0, 1.3, -1.2],
            shape:    lib.sphere({radius: 1.3}),
            material: glass({absorb: absorbFor([0.85, 0.92, 0.9], 2.0), ior: 1.5}),
        }),

        sphereLight({at: [-7.0, 4.0, 2.0], radius: 1.5, color: [0.9, 0.9, 0.9], power: 100}),

        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0]}),
    ],
});

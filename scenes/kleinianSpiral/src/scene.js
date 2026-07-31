//=====================================================================
// KLEINIAN SPIRAL — an EXPERIMENT: can the current estimator reach it?
//
// glsl/objects/fractals/kleinianSpiral.glsl (not ported) is the SAME estimator
// as glsl/shapes/fractals/kleinian.glsl at a particular parameter point — every
// one of its magic constants is one of kleinian's formulas evaluated at
// (a, b) = (1.965295, 0.0182628); see js/presets/fractals.js for the table.
//
// It differs in two ways parameters cannot reach:
//   1. it applies NO sphere inversion, and this estimator always does. There is
//      no identity setting — R^2/|z-C|^2 = 1 cannot hold everywhere — and a
//      large sphere far away approximates a REFLECTION, not the identity.
//   2. it runs a 16-iteration refinement tail with different clamps
//      (min(y, 0.4)/max(df, 3.0) versus min(y, 0.24)/max(DF, 1.0)).
//
// This scene ignores (2) entirely and makes (1) a LIVE DIAL: sweep the inversion
// centre and radius and see whether anything lands near the real spiral. If
// nothing does, the answer is to port kleinianSpiral as its own file.
//
// Start here: radius near 0.8 with the centre on the y axis is the least
// violent setting; push the radius up and the inversion flattens toward a
// reflection, down and it dominates.
//=====================================================================

import {scene, object, clip, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, kleinianSpiralBox, gloss} from '../../../js/presets/index.js';


//the spiral's own group. These two ARE the spiral.
const KLEIN_R = 1.965295;
const KLEIN_I = 0.0182628;

//the dials of the experiment: the inversion the spiral does not have
const invRadius = knob('invRadius', {label: 'Inversion Radius', min: 0.1, max: 3.0, step: 0.01, value: 0.8});
//one 2D pad rather than two sliders — the centre is a POINT, so dragging it as
//one reads better than two numbers. z stays pinned at 0; it is a real degree of
//freedom (the two shipped boxes disagree about it — standard uses z = 0,
//seahorse z = 1), so add a third dial if the sweep ever wants it.
const invCenter = knob('invCenter', {type: 'vec2', label: 'Inversion Centre (x, y)',
                                     min: -2.0, max: 3.0, step: 0.01, value: [0.0, 0.96]});
//iterations is an int in the estimator's signature, so the knob must be one
//too — a float uniform gives 'no matching overloaded function' at compile
const detail    = knob('detail',    {type: 'int', label: 'Iterations', min: 6, max: 60, step: 1, value: 60});
const fudge     = knob('fudge',     {label: 'DE Fudge',         min: 0.05, max: 1.0, step: 0.01, value: 0.24});


export default scene({

    //THE SETTING THAT MAKES THIS FRACTAL VISIBLE AT ALL. The legacy scene set
    //these as mutable globals in buildObjects; they are scene identity now.
    //At the engine default (0.001) the marcher stops on the limit set's thin
    //haze and reads it as a SOLID WALL — 20x finer lets it see through into the
    //detail. maxDist 20 is the ray-length cutoff the original used, which fades
    //the infinite landscape into sky. AT_THRESH follows automatically.
    march: {epsilon: 0.00005, maxDist: 20},

    objects: [

        object('spiral', {
            at:    [0.0, 1.2, 0.0],
            //the spiral is an INFINITE tiling; the legacy scene carved this
            //exact block out of it ("the spiral we're looking at"), and clip
            //also donates the bound the estimator cannot derive
            shape: clip(kleinianSpiralBox({
                kleinR:          KLEIN_R,
                kleinI:          KLEIN_I,
                iterations:      detail,
                offset:          [0.0, 0.0, 0.0],
                inversionCenter: glsl`vec3(${invCenter}, 0.0)`,
                inversionRadius: invRadius,
                fudge:           fudge,
            }), {to: lib.box({halfSize: [0.8, 0.7, 0.8]}), at: [0.6, 0.8, -0.7]}),
            material: gloss({diffuse: [0.62, 0.58, 0.52], gloss: 0.15, roughness: 0.25}),
        }),

        sphereLight({name: 'key', at: [-8.0, 9.0, 6.0], radius: 2.0, power: 400}),

        room({center: [0.0, 6.0, -4.0], half: [16.0, 8.0, 18.0],
              knobs: {roomLight: {value: 0.6}}}),
    ],
});

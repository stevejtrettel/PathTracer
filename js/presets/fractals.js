//-------------------------------------------------
// FRACTAL PRESETS — the named Kleinian boxes
//
// glsl/shapes/kleinian.glsl is ONE estimator: (kleinR, kleinI) are the group
// generators, and box/inversion/size/fold choose which Kleinian box they act
// in. Those are the CLASSIC PRESETS — knowledge, not scene content — so they
// live here, and a scene names a box instead of retyping six constants.
//-------------------------------------------------

import {lib, checkArgs} from '../scenegen/index.js';


//the "standard box" (shadertoy "kleinian escape", Muhammad Ahmad): unit wrap
//box, the inversion sphere on the x axis, full fold
const STANDARD_BOX = {
    box:             [1.0, 1.0],
    inversionCenter: [1.0, 0.96, 0.0],
    inversionRadius: 0.8,
    size:            1.1,
    fold:            1.0,
    fudge:           0.8,
};

//Jos Leys' seahorse box (shadertoy XlVXzh): a narrower, skewed wrap, the
//inversion sphere off the axis, and a gentler fold.
//
//FUDGE: the legacy object marched 0.55 against a DE that floored DF at 2.0;
//this estimator floors at 1.0, so 0.55/2 is a step that is never longer than
//the one that scene took — safe by construction, and raisable by eye.
const SEAHORSE_BOX = {
    box:             [-0.8089, 0.68],     // vec2(-0.40445, 0.34)*2
    inversionCenter: [0.0, 1.0, 1.0],
    inversionRadius: 0.8,
    size:            1.0,
    fold:            0.45,
    fudge:           0.275,
};


//a box preset, as a shape builder: the scene supplies the group and the slice
const kleinianIn = (name, boxPreset) => (spec) => {
    checkArgs(name, spec, ['kleinR', 'kleinI', 'iterations', 'offset']);
    return lib.kleinian({...boxPreset, ...spec});
};

export const kleinianStandardBox = kleinianIn('kleinianStandardBox', STANDARD_BOX);
export const kleinianSeahorse    = kleinianIn('kleinianSeahorse',    SEAHORSE_BOX);

//THE SPIRAL BOX — an EXPERIMENT, not (yet) a settled preset.
//
//glsl/objects/fractals/kleinianSpiral.glsl is the same estimator as this one at
//a particular point in its parameter space: every one of its magic constants is
//one of this file's formulas evaluated at (a, b) = (1.965295, 0.0182628) —
//  shear 0.009292650 = b/a          half-I 0.0091314 = b/2
//  sepBase 0.9826475 = a/2          sepAmp 0.4951475 = (2a - 1.95)/4
//  sepDecay 7.429425 = 7.2 - (1.95 - a)*15
//  wrap period 1.4142 = 2*box, offset -0.7071 = -box, with box = 1/sqrt(2)
//
//It differs in exactly two ways that PARAMETERS CANNOT REACH: it applies no
//sphere inversion (this estimator always does, and there is no identity setting
//— R^2/|z-C|^2 = 1 cannot hold everywhere), and it runs a 16-iteration
//refinement tail with different clamps.
//
//So the inversion is left OPEN here: the scene supplies it, because the point of
//scenes/kleinianSpiral is to sweep it and see whether any setting gets close to
//the real thing. If none does, port kleinianSpiral as its own file.
const SPIRAL_BOX = {
    box:   [0.7071, 0.7071],   // period sqrt(2), the spiral's lattice
    size:  1.0,                // the spiral does no size division
    fold:  1.0,                // makes sepAmp exactly (2a - 1.95)/4
};

export const kleinianSpiralBox = (spec) => {
    checkArgs('kleinianSpiralBox', spec,
              ['kleinR', 'kleinI', 'iterations', 'offset', 'inversionCenter',
               'inversionRadius', 'fudge']);
    return lib.kleinian({...SPIRAL_BOX, ...spec});
};

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

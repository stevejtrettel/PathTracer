//-------------------------------------------------
// THE SIX REGULAR 4-POLYTOPES — named parameter bundles over one shape.
//
// glsl/shapes/models/polytope4D.glsl is ONE estimator: the Coxeter machinery is
// identical for every regular 4-polytope, and only (type, coords) pick which one
// you get. So the six classic figures are presets, not six shape files — the
// same relationship the Kleinian boxes have with the one Kleinian estimator
// (fractals.js).
//
// Each returns a SHAPE, so a scene names the figure and never sees the pair:
//
//     shape: hypercube({vertexRad: 0.15, edgeRad: 0.05})
//
// A preset is CONTENT, not mechanism: plain JS over the public scenegen schema.
//-------------------------------------------------

import {lib} from '../scenegen/index.js';


//the shared defaults. `spin` is an internal rotation of S^3 — the figure's pose
//in 4D, not its placement in 3D — and it is the control worth reaching for: it
//is what turns the projected wireframe inside out as it sweeps.
const DEFAULTS = {
    vertexRad: 0.06,
    edgeRad:   0.03,
    spinAxis:  [0.0, 1.0, 0.1],
    spinAngle: -90,
};

//type is the Coxeter parameter; coords picks the point of the fundamental
//domain whose orbit is the vertex set. The fold runs 3, 8 or 15 times for type
//3, 4 or 5, so the last two figures are markedly dearer than the rest.
const polytope = (type, coords) => (opts = {}) =>
    lib.polytope4D({type, coords, ...DEFAULTS, ...opts});


export const fiveCell        = polytope(3, [0, 1, 0, 0]);   //the simplex
export const hypercube       = polytope(4, [0, 1, 0, 0]);   //the 8-cell
export const sixteenCell     = polytope(4, [0, 0, 0, 1]);   //the hypercube's DUAL
export const twentyFourCell  = polytope(4, [0, 0, 1, 0]);   //self-dual, no 3D analogue
export const oneHundredTwentyCell = polytope(5, [0, 1, 0, 0]);
export const sixHundredCell  = polytope(5, [0, 0, 0, 1]);   //the 120-cell's dual

//=====================================================================
// 4-POLYTOPE — a dual pair: the hypercube and the 16-cell, superimposed.
//
// Both are stereographic projections from S^3, drawn as wireframes: a ball at
// each vertex, a tube along each edge. They are placed at the SAME point on
// purpose — the 16-cell is the hypercube's dual, so its vertices sit where the
// hypercube's cells are, and overlaying them is the clearest way to see that.
//
// `spin` is the control worth turning. It is an internal rotation of S^3, not a
// rotation of the scene: sweeping it moves the figure through the projection, so
// cells swell, pass through infinity and turn inside out. The legacy scene baked
// one fixed pose (-90 degrees about (0,1,0.1)); here it is live.
//
// THE CLIP IS NOT DECORATION. The projected extent depends on the spin — cells
// pass through the projection point and run off toward infinity, so the figure
// is unbounded in general (measured: |p| swings from 1.25 to 3.76 across the
// sweep). The shape therefore carries no bound, and this clip both makes it
// finite and DONATES the bound the marcher needs. Radius 6 clears the measured
// range; raise it if a spin pushes the figure through the cut.
//
// Vertex and edge are told apart by the shape's `partData` output
// (docs/shape-data.md), so one region carries both with a material that switches
// on it — the same channel the room uses for its six walls.
//=====================================================================

import {scene, object, clip, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, hypercube, sixteenCell} from '../../../js/presets/index.js';


const spin      = knob('spin',      {label: 'S³ Spin',       min: -180, max: 180,  step: 1,     value: -90});
const vertexRad = knob('vertexRad', {label: 'Vertex Radius', min: 0.02, max: 0.35, step: 0.005, value: 0.15});
const edgeRad   = knob('edgeRad',   {label: 'Edge Radius',   min: 0.01, max: 0.2,  step: 0.005, value: 0.05});

//the two figures read as one object, so they are told apart by hue rather than
//by shape: the hypercube warm, its dual cool
const HYPER_VERTEX = [0.6, 0.1, 0.1];
const HYPER_EDGE   = [0.4, 0.4, 0.4];
const DUAL_VERTEX  = [0.12, 0.42, 0.5];
const DUAL_EDGE    = [0.22, 0.3, 0.34];

//one material body, reused: partData says which part of the wireframe was hit
const wireframe = (vertexColor, edgeColor) => glsl`
    if(partData == P4_VERTEX){ return makeGloss(${vertexColor}, 0.2, 0.2); }
    return makeGloss(${edgeColor}, 0.2, 0.2);
`;


export default scene({
    objects: [

        //the hypercube (8-cell)
        object('hyper', {
            at:       [0.0, 1.5, 0.0],
            shape:    clip(hypercube({vertexRad, edgeRad, spinAngle: spin}),
                           {to: lib.sphere({radius: 6.0})}),
            material: wireframe(HYPER_VERTEX, HYPER_EDGE),
        }),

        //and its dual, in the same place
        object('dual', {
            at:       [0.0, 1.5, 0.0],
            shape:    clip(sixteenCell({vertexRad, edgeRad, spinAngle: spin}),
                           {to: lib.sphere({radius: 6.0})}),
            material: wireframe(DUAL_VERTEX, DUAL_EDGE),
        }),

        sphereLight({name: 'key', at: [-12.0, 8.0, 2.0], radius: 1.5,
                     color: [1.0, 1.0, 1.0], power: 60}),

        room({center: [0.0, 5.75, -5.0], half: [20.0, 8.25, 15.0],
              knobs: {roomLight: {value: 0.5}}}),
    ],
});

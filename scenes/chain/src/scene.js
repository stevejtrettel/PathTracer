//=====================================================================
// CHAIN — the modifier chains, one stack per object.
//
// Modifiers take one shape and return one shape, so they compose; nesting
// order = application order, innermost first. Each object here is one stack,
// so the mechanism is legible at a glance:
//
//   mesa    clip(carve(sphere))          an eroded boulder with a flat top
//   beads   clip(repLim(sphere))         a lattice trimmed to a disc — and the
//                                        clip DONATES its bound to an
//                                        otherwise unboundable lattice
//   pillar  carve(radial(box))           a 7-fold fluted column, eroded
//   husk    shell(clip(gem))             a clipped gem, hollowed to a skin
//   dice    subtract(box, sphere)        a corner scooped away
//
// Cutters (clip's `to:`, subtract's `what:`) are placed volumes: they act in
// the object's own frame, cutting the WHOLE assembly. Carving acts on the
// folded point, so every lattice/wedge copy erodes identically.
//=====================================================================

import {scene, object, lib, knob, carve, repLim, clip, subtract, shell, radial} from '../../../js/scenegen/index.js';
import {room, sphereLight, gloss, metal, matte, glass} from '../../../js/presets/index.js';


const erosion   = knob('erosion',   {label: 'Erosion',        min: 0.0,  max: 1.0, step: 0.005, value: 0.85});
const bite      = knob('bite',      {label: 'Bite Softness',  min: 0.02, max: 0.4, step: 0.005, value: 0.15});
const segments  = knob('segments',  {label: 'Pillar Folds', type: 'int', min: 2, max: 12, step: 1, value: 7});
const thickness = knob('thickness', {label: 'Husk Thickness', min: 0.02, max: 0.2, step: 0.005, value: 0.06});

const eaten = (seed) => ({octaves: 6, erosion, gain: 0.5, blend: bite, seed});


export default scene({
    objects: [

        //an eroded boulder CLIPPED flat on top: the cut plane rides the
        //placement frame, slicing through every bite at once
        object('mesa', {
            at:    [-4.0, 1.9, -1.5],
            shape: clip(carve(lib.sphere({radius: 1.9}), eaten(0.0)),
                        {to: lib.plane({normal: [0.0, 1.0, 0.0]}), at: [0.0, 0.9, 0.0], blend: 0.05}),
            material: gloss({diffuse: [0.52, 0.47, 0.4], gloss: 0.02, roughness: 0.55}),
        }),

        //a bead lattice trimmed to a disc. The clip REPLACES the derived
        //bound: the unbounded 7x1x7 grid inherits the cutting sphere as its
        //acceleration volume — no authored bound: needed
        object('beads', {
            at:    [3.6, 0.32, -2.6],
            shape: clip(repLim(lib.sphere({radius: 0.32}), {spacing: 1.0, limit: [3.0, 0.0, 3.0]}),
                        {to: lib.sphere({radius: 2.4})}),
            material: gloss({diffuse: [0.78, 0.26, 0.22], gloss: 0.1, roughness: 0.2}),
        }),

        //a box folded into a rotational symmetry, then eroded: the carve sees
        //the FOLDED point, so all `segments` flutes are eaten identically
        object('pillar', {
            at:    [-0.6, 1.2, 0.6],
            shape: carve(radial(lib.box({halfSize: [0.35, 1.2, 0.35]}), {n: segments}), eaten(17.0)),
            material: matte({diffuse: [0.72, 0.68, 0.6]}),
        }),

        //a gem clipped against an offset box, then hollowed to a skin —
        //shell's bound inflates by the thickness (the outer face lies
        //outside the base surface)
        object('husk', {
            at:    [3.2, 1.5, 1.8],
            shape: shell(clip(lib.gem({size: 1.4}), {to: lib.box({halfSize: [2.0, 2.0, 1.0]}), at: [0.0, 0.0, 1.2]}),
                         {thickness}),
            material: metal({specular: [0.92, 0.8, 0.52], roughness: 0.25}),
        }),

        //the plain boolean: a sphere scooped out of a box's corner
        object('dice', {
            at:    [-2.2, 1.0, 3.2],
            shape: subtract(lib.box({halfSize: [1.0, 1.0, 1.0]}),
                            {what: lib.sphere({radius: 1.25}), at: [0.7, 0.7, 0.7], blend: 0.08}),
            material: glass({absorb: [0.03, 0.005, 0.02], ior: 1.5}),
        }),

        sphereLight({
            name: 'lamp',
            at: [-4.0, 8.5, 5.0], radius: 1.4,
            color: [1.0, 0.95, 0.88],
            power: knob('lampPower', {label: 'Lamp Power', min: 0, max: 90, step: 0.5, value: 30}),
        }),

        room({
            center: [0.0, 6.0, 0.0], half: [10.0, 6.0, 10.0],
            knobs: {roomLight: {max: 3, value: 1.0}},
        }),
    ],
});

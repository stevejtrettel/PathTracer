//=====================================================================
// CUBEGRID — a city block of rounded bars on an open plain.
//
// A port of IQ's audio "equalizer city" (shadertoys/cube-grid.glsl) to a STILL:
// the four bouncing audio bands are gone, and the skyline comes instead from the
// shape's height field — a smooth district `swell` mixed with per-cell jitter,
// shaped so a few towers rise over many low blocks (glsl/shapes/cubeGrid.glsl).
//
// DATA-COLOURED: `cellData` is (id, height fraction, height up the bar, swell),
// injected by the emitter with the lattice's own consts baked in
// (docs/shape-data.md). The palette rides the SWELL, so colour travels in
// neighbourhoods the way the heights do, and the per-cell id then picks which
// bars are lamps and which are metal — one sdf evaluation, several looks.
//=====================================================================

import {scene, object, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {sphereLight, gloss} from '../../../js/presets/index.js';


//--- the skyline -------------------------------------------------------
const towerHeight  = knob('towerHeight',  {label: 'Tower Height',   min: 0.5, max: 6.0,  step: 0.01,  value: 3.2});
const districtSize = knob('districtSize', {label: 'District Size',  min: 0.02, max: 0.6, step: 0.005, value: 0.13});
const cellJitter   = knob('cellJitter',   {label: 'Cell Jitter',    min: 0.0, max: 1.0,  step: 0.01,  value: 0.55});
const heightPower  = knob('heightPower',  {label: 'Height Falloff', min: 0.5, max: 5.0,  step: 0.01,  value: 2.2});
const citySeed     = knob('citySeed',     {label: 'Seed',           min: 0.0, max: 20.0, step: 0.5,   value: 3.0});

//--- the look ----------------------------------------------------------
const paletteShift = knob('paletteShift', {label: 'Palette Shift', min: 0.0, max: 1.0, step: 0.001, value: 0.12});
const barRough     = knob('barRough',     {label: 'Bar Roughness', min: 0.0, max: 1.0, step: 0.01,  value: 0.28});
const lampPower    = knob('lampPower',    {label: 'Lamp Power',    min: 0.0, max: 8.0, step: 0.05,  value: 1.0});
const lampChance   = knob('lampChance',   {label: 'Lamps',         min: 0.0, max: 0.4, step: 0.005, value: 0.03});
const metalChance  = knob('metalChance',  {label: 'Metal Bars',    min: 0.0, max: 0.6, step: 0.005, value: 0.18});

//--- the lattice itself: fixed geometry, not knobs ---------------------
const spacing = 1.0;      //cell pitch
const barHalf = 0.4;      //bar half-width — inset 0.1 from the cell wall
const bevel   = 0.1;      //IQ's corner radius
const tiles   = [9, 9];   //a 19x19 block, cut on cell walls

const groundTint = [0.055, 0.052, 0.06];


export default scene({
    objects: [

        object('city', {
            at:    [0.0, 0.0, 0.0],
            shape: lib.cubeGrid({
                spacing, barHalf, bevel, tiles,
                height:    towerHeight,
                clumpFreq: districtSize,
                jitter:    cellJitter,
                contrast:  heightPower,
                seed:      citySeed,
            }),
            //cellData = (id, height fraction, up the bar, district swell)
            material: glsl`
                float id    = cellData.x;
                float f     = cellData.y;
                float up    = cellData.z;
                float swell = cellData.w;

                //the palette rides the district, nudged by the cell's own id
                float t = mix(swell, id, 0.3) + ${paletteShift};
                vec3  c = 0.5 + 0.5*cos(6.2831*(t + vec3(0.0, 0.33, 0.67)));

                //a handful of bars are lamps, standing where the towers are
                if(id > 1.0 - ${lampChance}){
                    return makeLight(mix(c, vec3(1.0), 0.15), ${lampPower}*(0.35 + f));
                }
                //a few more are bare metal
                if(id < ${metalChance}){
                    return makeMetal(mix(c, vec3(0.86, 0.88, 0.92), 0.35), 1.0, ${barRough});
                }
                //the rest: low blocks read darker than towers, and every bar
                //shades down toward its base
                c *= mix(0.5, 1.0, f);
                c  = mix(0.62*c, c, up);
                return makeGloss(c, 0.06, ${barRough});
            `,
        }),

        //the plain the block stands on: analytic, so no ray ever marches at it
        object('ground', {
            at:       [0.0, 0.0, 0.0],
            shape:    lib.plane({normal: [0.0, 1.0, 0.0]}),
            material: gloss({diffuse: groundTint, gloss: 0.04, roughness: 0.35}),
        }),

        //one warm key, high and on the CAMERA's side of the block: from behind, a
        //grid of bars shows nothing but its own shadowed faces. BIG on purpose —
        //a small bright light in a grid of bars is nearly all variance, and this
        //picture is a thousand little shadowed pockets.
        sphereLight({at: [17.0, 15.0, 20.0], radius: 7.0, color: [1.0, 0.88, 0.72], power: 26}),
    ],

    sky: {type: 'gradient', top: [0.42, 0.52, 0.72], bottom: [0.10, 0.09, 0.11]},
});

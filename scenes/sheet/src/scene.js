//=====================================================================
// SHEET — a hollow sheet next to a solid region, against the sky.
//
// The sheet() node: a two-sided surface with NO interior, contributing two
// Surfaces (front/back) and nothing else. The bubble leaves the image sky
// completely undistorted — just tinted, warm on the near face, cool through
// the middle — while the control ball bends and darkens it. If the bubble
// bends the sky, the sheet path is not firing.
//
// No room on purpose: the image sky IS the background, declared here (sky is
// scene identity, not a setting).
//=====================================================================

import {scene, object, sheet, lib, glsl, knob, absorbFor} from '../../../js/scenegen/index.js';
import {glass} from '../../../js/presets/index.js';


const frontTint  = knob('frontTint',  {type: 'color', label: 'Sheet Front', value: [1.0, 0.72, 0.42]});
const backTint   = knob('backTint',   {type: 'color', label: 'Sheet Back',  value: [0.42, 0.72, 1.0]});
const sheetGloss = knob('sheetGloss', {label: 'Sheet Sheen', min: 0, max: 0.5, step: 0.005, value: 0.06});
const ballIOR    = knob('ballIOR',    {label: 'Ball IOR', min: 1, max: 2.4, step: 0.01, value: 1.5});


export default scene({

    //authored helper, emitted verbatim before the objects: one face of a
    //sheet — transmit = 1 through an index-matched surface, so light crosses
    //unbent and just picks up the tint; the gloss floor adds a visible sheen
    glsl: [glsl`
        Material sheetFace(vec3 tint, float gloss){
            Material m;
            initMat(m);
            m.surf.transmit     = 1.0;
            m.surf.transmitTint = tint;
            m.surf.gloss        = gloss;
            m.surf.roughness    = 0.04;
            return m;
        }
    `],

    objects: [

        sheet('bubble', {
            at:    [1.6, 1.3, -1.2],
            shape: lib.sphere({radius: 1.3}),
            //FRONT is the side the sdf's gradient points toward — the outside
            front: glsl`sheetFace(${frontTint}, ${sheetGloss})`,
            back:  glsl`sheetFace(${backTint}, ${sheetGloss})`,
        }),

        //the control: a real region, with an interior that refracts and absorbs
        object('ball', {
            at:    [-1.6, 1.3, -1.2],
            shape: lib.sphere({radius: 1.3}),
            material: glass({absorb: absorbFor([0.8, 0.88, 0.92], 2.0), ior: ballIOR}),
        }),
    ],

    sky: {type: 'image', src: '/assets/office.jpg'},
});

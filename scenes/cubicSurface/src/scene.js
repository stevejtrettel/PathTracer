//=====================================================================
// CUBIC SURFACE WITH ITS 27 LINES
//
// A smooth cubic surface in P^3 carries exactly TWENTY-SEVEN lines, and they
// fall into three classes under the blow-up of P^2 at six points: 15 "pair"
// lines, 6 conic lines, 6 exceptional lines. All three are drawn, coloured by
// class, plus a thin ring marking where the surface leaves the bounding sphere.
//
// THE DATA IS FIXED. scene3d.glsl is machine-written (by the cubic-lines
// project) and imported verbatim: 20 polynomial coefficients and the 27 lines
// as point + unit direction. It is not regenerated here, and its filename
// matches the exporter's so a future regeneration drops straight in.
//
// ONE GROUP, FIVE REGIONS — which is the whole reason a group exists. Every
// piece needs the same polynomial value and gradient at the same point, so the
// body evaluates the cubic ONCE into locals and hands the result to all five.
// The legacy version did this with four file-scope globals (_cachedVal,
// _cachedGrad, _cachedPos, _cachedBBox) because the old object API had no way
// to share; inside a group they are just local variables.
//
// The surface is NOT put through variety(): a general cubic's 20 coefficients
// are machine-generated DATA, not a formula, and the equation builder wants a
// formula. Writing the polynomial and its analytic gradient here also keeps the
// distance identical to the legacy scene and lets the ring share the evaluation.
//=====================================================================

import {scene, group, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass, metal} from '../../../js/presets/index.js';

import cubicData from './scene3d.glsl?raw';


const lineRadius  = knob('lineRadius',  {label: 'Line Thickness',  min: 0.004, max: 0.06, step: 0.001, value: 0.02});
const ringRadius  = knob('ringRadius',  {label: 'Ring Thickness',  min: 0.002, max: 0.05, step: 0.001, value: 0.01});
const shellDepth  = knob('shellDepth',  {label: 'Surface Shell',   min: 0.006, max: 0.08, step: 0.001, value: 0.02});


//the data file declares this as its one assumption; it is scene data, so the
//declaration is scene-authored too
const prelude = glsl`
    struct Line { vec3 point; vec3 dir; };
`;

//the cubic and its ANALYTIC gradient, plus a min over each line class. All of
//it is ordinary authored GLSL over the scene's own data — C[], PAIR_LINES[] and
//friends come from scene3d.glsl above.
const cubic = glsl`
    float cubicF(vec3 p){
        float x = p.x, y = p.y, z = p.z;
        float x2 = x*x, y2 = y*y, z2 = z*z;

        return C[0]*x2*x   + C[1]*x2*y   + C[2]*x2*z   + C[3]*x2
             + C[4]*x*y2   + C[5]*x*y*z  + C[6]*x*y    + C[7]*x*z2
             + C[8]*x*z    + C[9]*x
             + C[10]*y2*y  + C[11]*y2*z  + C[12]*y2    + C[13]*y*z2
             + C[14]*y*z   + C[15]*y
             + C[16]*z2*z  + C[17]*z2    + C[18]*z     + C[19];
    }

    vec3 cubicGrad(vec3 p){
        float x = p.x, y = p.y, z = p.z;
        float x2 = x*x, y2 = y*y, z2 = z*z;

        float dx = 3.0*C[0]*x2   + 2.0*C[1]*x*y   + 2.0*C[2]*x*z + 2.0*C[3]*x
                 +     C[4]*y2   +     C[5]*y*z   +     C[6]*y   +     C[7]*z2
                 +     C[8]*z    +     C[9];

        float dy =     C[1]*x2   + 2.0*C[4]*x*y   +     C[5]*x*z +     C[6]*x
                 + 3.0*C[10]*y2  + 2.0*C[11]*y*z  + 2.0*C[12]*y  +     C[13]*z2
                 +     C[14]*z   +     C[15];

        float dz =     C[2]*x2   +     C[5]*x*y   + 2.0*C[7]*x*z +     C[8]*x
                 +     C[11]*y2  + 2.0*C[13]*y*z  +     C[14]*y
                 + 3.0*C[16]*z2  + 2.0*C[17]*z    +     C[18];

        return vec3(dx, dy, dz);
    }

    //nearest of a line class, already tubed (lineDistance is primitives/line.glsl)
    float cubicPairDist(vec3 p, float r){
        float d = 1.0e6;
        for(int i = 0; i < 15; i++){ d = min(d, lineDistance(p, PAIR_LINES[i].point, PAIR_LINES[i].dir, r)); }
        return d;
    }
    float cubicConicDist(vec3 p, float r){
        float d = 1.0e6;
        for(int i = 0; i < 6; i++){ d = min(d, lineDistance(p, CONIC_LINES[i].point, CONIC_LINES[i].dir, r)); }
        return d;
    }
    float cubicExceptionalDist(vec3 p, float r){
        float d = 1.0e6;
        for(int i = 0; i < 6; i++){ d = min(d, lineDistance(p, EXCEPTIONAL_LINES[i].point, EXCEPTIONAL_LINES[i].dir, r)); }
        return d;
    }
`;


export default scene({

    glsl: [prelude, cubicData, cubic],

    objects: [

        group('cubic', {
            at:   [0.0, 0.0, 0.0],
            uses: [lib.line],

            consts: glsl`
                const float CUBIC_BALL   = 2.0;    //the sphere the whole figure is cut to
                const float CUBIC_ZOOM   = 1.0;    //the surface's internal scale
                const float CUBIC_BLEND  = 0.05;   //how softly the surface meets the cut
            `,

            //ONE evaluation, five regions. Everything below reads `val` and
            //`grad` from the same point, which is what the group is for.
            sdf: glsl`
                float ball = length(q) - CUBIC_BALL;
                vec3  s    = CUBIC_ZOOM*q;
                float val  = cubicF(s);
                vec3  grad = cubicGrad(s)*CUBIC_ZOOM;

                //the surface: a first-order distance estimate to {cubic = 0},
                //thickened into a shell, then cut to the ball
                float de = val/(length(grad) + 0.001);
                surface  = smax(abs(de + ${shellDepth}) - ${shellDepth}, ball, CUBIC_BLEND);

                //the 27 lines, by class, each cut to the same ball
                pairs       = max(cubicPairDist(q, ${lineRadius}), ball);
                conics      = max(cubicConicDist(q, ${lineRadius}), ball);
                exceptional = max(cubicExceptionalDist(q, ${lineRadius}), ball);

                //the ring where the surface leaves the ball: a tube around the
                //curve {cubic = 0} ∩ {ball = 0}. The sphere's gradient is just
                //its radial direction (ops/curve.glsl).
                ring = opCurveTube(val, grad, ball, normalize(q), ${ringRadius});
            `,

            //everything is cut to the radius-2 ball except the ring, which
            //straddles it; 2.5 clears the tube with room to spare and never
            //overestimates the distance to any of it
            bound: glsl`length(q) - 2.5`,

            regions: {
                //declared first, so it owns the walls it shares with the lines
                surface:     {material: glass({absorb: [0.5, 0.3, 0.1], ior: 1.5})},
                pairs:       {material: metal({specular: [0.55, 0.55, 0.55], gloss: 0.8, roughness: 0.1})},
                conics:      {material: metal({specular: [0.2, 0.45, 0.9],   gloss: 0.8, roughness: 0.1})},
                exceptional: {material: metal({specular: [0.9, 0.25, 0.2],   gloss: 0.8, roughness: 0.1})},
                ring:        {material: metal({specular: [0.1, 0.1, 0.1],    gloss: 0.6, roughness: 0.2})},
            },
        }),

        sphereLight({name: 'key', at: [-12.0, 8.0, 2.0], radius: 1.5,
                     color: [1.0, 1.0, 1.0], power: 60}),

        //the legacy room, verbatim except the back wall: the camera sits at
        //z = 11 and the old box stopped at z = 10, which would put the eye in
        //the room's SOLID (the room is the box's complement)
        room({center: [-5.75, 5.75, -3.0], half: [14.25, 8.25, 17.0],
              knobs: {roomLight: {value: 0.5}}}),
    ],
});

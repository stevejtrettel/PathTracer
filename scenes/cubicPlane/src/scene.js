//=====================================================================
// THE BLOW-UP DIAGRAM — the plane picture behind the 27 lines.
//
// A smooth cubic surface is P^2 blown up at SIX points, and that is what this
// draws, flat on a glass plate: the six points as checkers, the 15 lines through
// pairs of them, and the 6 conics through five-of-six. Those 15 + 6 + the 6
// exceptional curves of the blow-up itself are the 27 lines of scenes/cubicSurface,
// seen downstairs.
//
// THE DATA IS FIXED. scene2d.glsl is machine-written (by the cubic-lines project)
// and imported verbatim, filename kept so a regeneration drops straight in.
//
// TWO HELPERS FROM THE OLD SCENE DISSOLVED, which is worth noticing:
//   lineDist2D    was sqrt(|perp|^2 + y^2) — exactly the 3D distance to a line
//                 that happens to lie in the plane y = 0. So it IS lineDistance
//                 (primitives/line.glsl) with the line laid flat.
//   conicTubeDist was sqrt(dConic^2 + |y|^2) - r — a tube around the curve where
//                 the conic cylinder {Q(x,z) = 0} meets the plane {y = 0}. That is
//                 opCurveTube (ops/curve.glsl) with g = y, whose gradient is
//                 (0,1,0). Same zero set; opCurveTube's 0.5 understep makes the
//                 marcher a little more careful, and changes no geometry.
//=====================================================================

import {scene, group, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass, metal} from '../../../js/presets/index.js';

import planeData from './scene2d.glsl?raw';


const curveRadius   = knob('curveRadius',   {label: 'Line / Conic Radius', min: 0.005, max: 0.06, step: 0.001, value: 0.025});
const checkerRadius = knob('checkerRadius', {label: 'Checker Radius',      min: 0.03,  max: 0.2,  step: 0.005, value: 0.08});


//the data file's declared assumptions — scene data, so scene-authored
const prelude = glsl`
    struct Line2D  { vec2 point; vec2 dir; };
    struct Conic2D { float c0, c1, c2, c3, c4, c5; };
`;

const plane = glsl`
    //the conic Q(x,z), and its gradient lifted to 3D. Q does not involve y, so
    //the y component of the gradient is 0 — which is exactly what makes
    //opCurveTube's projection step a no-op here and the maths reduce to the
    //original's sqrt(dConic^2 + y^2).
    float plateConicVal(vec2 xz, Conic2D c){
        float x = xz.x, z = xz.y;
        return c.c0*x*x + c.c1*x*z + c.c2*x + c.c3*z*z + c.c4*z + c.c5;
    }
    vec3 plateConicGrad(vec2 xz, Conic2D c){
        float x = xz.x, z = xz.y;
        return vec3(2.0*c.c0*x + c.c1*z + c.c2,
                    0.0,
                    c.c1*x + 2.0*c.c3*z + c.c4);
    }

    //the square column the diagram is cut to (infinite in y: the tubes are thin
    //around y = 0 anyway, and the plate itself is a box)
    float plateRegion(vec3 p, float halfWidth){
        vec2 d = abs(p.xz) - vec2(halfWidth);
        return max(d.x, d.y);
    }

    //nearest of the 15 lines through pairs of the six points, tubed. Each lies
    //flat in y = 0, so an ordinary 3D line does the job.
    float plateLineDist(vec3 p, float r){
        float d = 1.0e6;
        for(int i = 0; i < 15; i++){
            Line2D l = PLANE_LINES[i];
            d = min(d, lineDistance(p, vec3(l.point.x, 0.0, l.point.y),
                                       vec3(l.dir.x,   0.0, l.dir.y), r));
        }
        return d;
    }

    //nearest of the 6 conics, as a tube around {Q = 0} intersect {y = 0}
    float plateConicDist(vec3 p, float r){
        float d = 1.0e6;
        for(int i = 0; i < 6; i++){
            Conic2D c = PLANE_CONICS[i];
            d = min(d, opCurveTube(plateConicVal(p.xz, c), plateConicGrad(p.xz, c),
                                   p.y, vec3(0.0, 1.0, 0.0), r));
        }
        return d;
    }

    //the six blown-up points, as checkers standing on the plate. cylinderDistance
    //adds its fillet to the HEIGHT (see primitives/cylinder.glsl), so the height
    //argument is the true half-height minus the rounding.
    float plateCheckerDist(vec3 p, float r, float halfH, float rnd, float yOff){
        float d = 1.0e6;
        for(int i = 0; i < 6; i++){
            vec3 c = p - vec3(POINTS[i].x, yOff, POINTS[i].y);
            d = min(d, cylinderDistance(c, r, halfH - rnd, rnd));
        }
        return d;
    }
`;


export default scene({

    glsl: [prelude, planeData, plane],

    objects: [

        group('diagram', {
            at:   [0.0, 0.0, 0.0],
            uses: [lib.line, lib.cylinder],

            consts: glsl`
                const float PLATE_HALF  = 2.0;    //the plate's xz half-width
                const float PLATE_THICK = 0.05;   //and its half-thickness
                const float PLATE_ROUND = 0.02;   //edge fillet (inflates, as the old Box did)
                const float PLATE_TOP   = 0.05;   //curves ride the plate's top face
                const float CHECK_HALF  = 0.03;   //checker half-height
                const float CHECK_ROUND = 0.01;
                const float CHECK_Y     = 0.08;   //checkers sit above the plate
            `,

            sdf: glsl`
                float region = plateRegion(q, PLATE_HALF);

                //the glass plate: a rounded slab. The old Box subtracted its
                //rounding from the distance, so the fillet INFLATES the extents.
                plate = boxDistance(q, vec3(PLATE_HALF, PLATE_THICK, PLATE_HALF)) - PLATE_ROUND;

                //the six points
                checkers = plateCheckerDist(q, ${checkerRadius}, CHECK_HALF, CHECK_ROUND, CHECK_Y);

                //the 15 lines and 6 conics, riding the plate's top face and cut
                //to the plate's outline
                vec3 top = q - vec3(0.0, PLATE_TOP, 0.0);
                lines  = max(plateLineDist(top,  ${curveRadius}), region);
                conics = max(plateConicDist(top, ${curveRadius}), region);
            `,

            //the plate's own corner reach, plus the checkers standing above it
            bound: glsl`length(q - vec3(0.0, 0.05, 0.0)) - 2.95`,

            regions: {
                plate:    {material: glass({absorb: [0.5, 0.3, 0.1], ior: 1.5})},
                checkers: {material: metal({specular: [0.9, 0.25, 0.2], gloss: 0.8, roughness: 0.1})},
                lines:    {material: metal({specular: [0.55, 0.55, 0.55], gloss: 0.8, roughness: 0.1})},
                conics:   {material: metal({specular: [0.2, 0.45, 0.9], gloss: 0.8, roughness: 0.1})},
            },
        }),

        sphereLight({name: 'key', at: [-12.0, 8.0, 2.0], radius: 1.5,
                     color: [1.0, 1.0, 1.0], power: 60}),

        //the legacy room; the eye is at (0, 5, 2) looking down at the plate, so
        //the box comfortably contains it
        room({center: [-5.75, 5.75, -3.0], half: [14.25, 8.25, 17.0],
              knobs: {roomLight: {value: 0.5}}}),
    ],
});

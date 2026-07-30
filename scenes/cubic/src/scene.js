//=====================================================================
// CUBIC — the art piece: the surface and its blow-up diagram, together.
//
// A smooth cubic surface is P^2 blown up at six points, and both halves of that
// sentence are in the frame. On the left, the surface with its 27 lines coloured
// by class. On the right and below, the plane picture they come from: the six
// points, the 15 lines through pairs of them, the 6 conics through five-of-six.
//
// The surface turns on the `rotation` knob; the diagram stays put.
//
// THE DATA IS THE SAME as the two test scenes: scene3d.glsl is a byte copy of
// scenes/cubicSurface's and scene2d.glsl of scenes/cubicPlane's, so this piece
// shows the SAME surface and the SAME six points those two show in isolation —
// which is what makes them useful as tests of it. (The legacy combined scene had
// its own unrelated configuration; that is deliberately not carried over.)
// Both files are machine-written by the cubic-lines project and copied verbatim,
// filenames kept so a regeneration drops straight in — regenerate all three
// together to keep them in step.
//
// TWO GROUPS, because there are two independent shape evaluations: the surface's
// polynomial (shared by its shell, its lines and its ring) and the plate's. Each
// group's bound replaces one tier of the legacy's hand-rolled nested bbox tests.
//
// WHAT THE PORT DELETES. The legacy rotated the surface by hand and then had to
// UN-rotate the resulting normal (`path.dat.normal.dir = unrotXZ(...)`) and
// restore the query point afterwards. None of that is needed: normals are a
// 4-tap of the WORLD sdf, so the chain rule carries any rotation inside it. The
// rotation is now just three lines at the top of the surface group's body.
//=====================================================================

import {scene, group, lib, glsl, knob} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass, metal} from '../../../js/presets/index.js';

import surfaceData from './scene3d.glsl?raw';
import planeData   from './scene2d.glsl?raw';


const rotation = knob('rotation', {label: 'Rotation', min: 0, max: 1, step: 0.01, value: 0.73});


//both data files' declared assumptions
const prelude = glsl`
    struct Line     { vec3 point; vec3 dir; };
    struct Line2D   { vec2 point; vec2 dir; };
    struct Conic2D  { float c0, c1, c2, c3, c4, c5; };
`;

//--- the surface half -------------------------------------------------------
const surfaceMath = glsl`
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

    //the surface group's own spin, about the y axis. Written out rather than
    //using rot2() so the direction matches the original exactly.
    vec3 cubicSpin(vec3 p, float turns){
        float a = turns*6.2832;
        float ca = cos(a), sa = sin(a);
        vec2  r  = mat2(ca, sa, -sa, ca)*p.xz;
        return vec3(r.x, p.y, r.y);
    }

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

//--- the plate half ---------------------------------------------------------
const plateMath = glsl`
    float plateConicVal(vec2 xz, Conic2D c){
        float x = xz.x, z = xz.y;
        return c.c0*x*x + c.c1*x*z + c.c2*x + c.c3*z*z + c.c4*z + c.c5;
    }
    //no y dependence, so the y component of the gradient is 0 — which makes
    //opCurveTube's projection a no-op and reduces it to the original's
    //sqrt(dConic^2 + y^2)
    vec3 plateConicGrad(vec2 xz, Conic2D c){
        float x = xz.x, z = xz.y;
        return vec3(2.0*c.c0*x + c.c1*z + c.c2, 0.0, c.c1*x + 2.0*c.c3*z + c.c4);
    }

    float plateRegion(vec3 p, float halfWidth){
        vec2 d = abs(p.xz) - vec2(halfWidth);
        return max(d.x, d.y);
    }

    //the plate's 15 lines lie flat in y = 0, so an ordinary 3D line does the job
    float plateLineDist(vec3 p, float r){
        float d = 1.0e6;
        for(int i = 0; i < 15; i++){
            Line2D l = PLANE_LINES[i];
            d = min(d, lineDistance(p, vec3(l.point.x, 0.0, l.point.y),
                                       vec3(l.dir.x,   0.0, l.dir.y), r));
        }
        return d;
    }

    //each conic as a tube around {Q = 0} intersect {y = 0}
    float plateConicDist(vec3 p, float r){
        float d = 1.0e6;
        for(int i = 0; i < 6; i++){
            Conic2D c = PLANE_CONICS[i];
            d = min(d, opCurveTube(plateConicVal(p.xz, c), plateConicGrad(p.xz, c),
                                   p.y, vec3(0.0, 1.0, 0.0), r));
        }
        return d;
    }

    //cylinderDistance adds its fillet to the HEIGHT (primitives/cylinder.glsl),
    //so the height argument is the true half-height minus the rounding
    float plateCheckerDist(vec3 p, float r, float halfH, float rnd, float yOff){
        float d = 1.0e6;
        for(int i = 0; i < 6; i++){
            vec3 c = p - vec3(POINTS[i].x, yOff, POINTS[i].y);
            d = min(d, cylinderDistance(c, r, halfH - rnd, rnd));
        }
        return d;
    }
`;


//the two palettes, shared across both halves so the classes read as the same
//thing upstairs and downstairs
const greyMetal = metal({specular: [0.4, 0.4, 0.4], gloss: 0.3, roughness: 0.4});
const blueMetal = metal({specular: [0.1, 0.2, 0.7], gloss: 0.3, roughness: 0.4});
const redMetal  = metal({specular: [0.7, 0.1, 0.1], gloss: 0.3, roughness: 0.4});
const darkMetal = metal({specular: [0.1, 0.1, 0.1], gloss: 0.3, roughness: 0.4});


export default scene({

    glsl: [prelude, surfaceData, planeData, surfaceMath, plateMath],

    objects: [

        //=== the surface, on the left, spinning ==========================
        group('surfaceGroup', {
            at:   [3.5, 0.0, 0.0],
            uses: [lib.line],

            consts: glsl`
                const float CUBIC_BALL  = 2.0;
                const float CUBIC_ZOOM  = 1.0;
                const float CUBIC_SHELL = 0.01;   //inward shell depth
                const float CUBIC_BLEND = 0.05;
                const float CUBIC_LINE  = 0.02;
                const float CUBIC_RING  = 0.05;
            `,

            sdf: glsl`
                //the group's spin. No normal fixup follows: normals are a 4-tap
                //of the world sdf, so the chain rule carries this for free.
                vec3 t = cubicSpin(q, ${rotation});

                float ball = length(t) - CUBIC_BALL;
                vec3  s    = CUBIC_ZOOM*t;
                float val  = cubicF(s);
                vec3  grad = cubicGrad(s)*CUBIC_ZOOM;

                float de = val/(length(grad) + 0.001);
                surface  = smax(abs(de + CUBIC_SHELL) - CUBIC_SHELL, ball, CUBIC_BLEND);

                pairLines       = max(cubicPairDist(t, CUBIC_LINE), ball);
                conicLines      = max(cubicConicDist(t, CUBIC_LINE), ball);
                exceptionalLines = max(cubicExceptionalDist(t, CUBIC_LINE), ball);

                ring = opCurveTube(val, grad, ball, normalize(t), CUBIC_RING);
            `,

            //a sphere about the group's centre, so the spin cannot affect it
            //(the bound sees the UNROTATED placement frame). 2.6 clears the
            //ring, which straddles the radius-2 ball.
            bound: glsl`length(q) - 2.6`,

            regions: {
                surface:          {material: glass({absorb: [0.6, 0.1, 0.4], ior: 1.5})},
                pairLines:        {material: greyMetal},
                conicLines:       {material: blueMetal},
                exceptionalLines: {material: redMetal},
                ring:             {material: darkMetal},
            },
        }),

        //=== the blow-up diagram, on the right, flat =====================
        group('plateGroup', {
            at:   [-1.0, -2.4, 0.0],
            uses: [lib.line, lib.cylinder],

            consts: glsl`
                const float PLATE_HALF  = 1.2;
                const float PLATE_THICK = 0.05;
                const float PLATE_ROUND = 0.02;
                const float PLATE_TOP   = 0.05;
                const float PLATE_CURVE = 0.02;
                const float CHECK_R     = 0.06;
                const float CHECK_HALF  = 0.02;
                const float CHECK_ROUND = 0.008;
                const float CHECK_Y     = 0.07;
            `,

            sdf: glsl`
                float region = plateRegion(q, PLATE_HALF);

                //the old Box subtracted its rounding from the distance, so the
                //fillet INFLATES the extents
                plate = boxDistance(q, vec3(PLATE_HALF, PLATE_THICK, PLATE_HALF)) - PLATE_ROUND;

                checkers = plateCheckerDist(q, CHECK_R, CHECK_HALF, CHECK_ROUND, CHECK_Y);

                vec3 top = q - vec3(0.0, PLATE_TOP, 0.0);
                plateLines  = max(plateLineDist(top,  PLATE_CURVE), region);
                plateConics = max(plateConicDist(top, PLATE_CURVE), region);
            `,

            //the legacy's plate-group box, which contains the slab, the curves
            //on its face and the checkers standing above it
            bound: glsl`boxDistance(q, vec3(1.2, 0.15, 1.2))`,

            regions: {
                plate:       {material: glass({absorb: [0.3, 0.05, 0.2], ior: 1.5})},
                checkers:    {material: redMetal},
                plateLines:  {material: greyMetal},
                plateConics: {material: blueMetal},
            },
        }),

        sphereLight({name: 'key', at: [-12.0, 8.0, 2.0], radius: 1.5,
                     color: [1.0, 1.0, 1.0], power: 60}),

        //the legacy room, verbatim: x +/-20, y -2.5..14, z -20..10
        room({center: [0.0, 5.75, -5.0], half: [20.0, 8.25, 15.0],
              knobs: {roomLight: {value: 0.5}}}),
    ],
});

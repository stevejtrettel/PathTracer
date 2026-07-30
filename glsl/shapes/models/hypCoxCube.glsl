//----------------------------------------------------------------------------
// HYPERBOLIC COXETER CUBE — a cube in H^3 whose dihedral angle is 2*pi/dihedral,
// drawn in the BALL (Poincare) model.
//
// Same construction as models/hypDod.glsl: in the ball model a hyperbolic plane
// is a Euclidean sphere orthogonal to the unit sphere, so the solid is the unit
// ball with six such spheres carved out, one per face, along the coordinate axes.
//
// Unlike the dodecahedron this IS a family, parametrized by `dihedral`. With
// theta2 = pi/dihedral, orthogonality (d^2 = r^2 + 1) plus the dihedral condition
// give the face-sphere geometry:
//     d = 1/sqrt(1 - 1/(2 sin^2(theta2))),    r = sqrt(d*d - 1)
//
// VALID RANGE: dihedral < 4, strictly. The root needs 2 sin^2(theta2) > 1, i.e.
// theta2 > pi/4, i.e. dihedral < 4; at exactly 4 the radicand is 0 and d blows up
// (the flat, Euclidean limit), and above 4 it is negative — no such solid. Useful
// values are around 2 to 3.9; d grows fast near the top (dihedral 3.99 puts the
// face spheres out at d = 16).
//
// A cross-check worth knowing: dihedral = 2.5 reproduces the right-angled
// dodecahedron's face spheres exactly, d = 5^(1/4) = 1.4953488 and r = 1.1117859
// — the same pair models/hypDod.glsl bakes in, since 1 + 2/phi = 2 phi - 1 = sqrt 5.
//
// FLAGGING FOR REVIEW: the legacy file called this parameter "the number of cubes
// fitting around a vertex" and treated theta2 as HALF the dihedral angle, which
// would make the hyperbolic (sub-right-angle) cases dihedral > 4 — exactly the
// range where the formula has no real solution. The formula and that description
// disagree, so the parameter's geometric name is left unclaimed here rather than
// guessed. The math is carried over unchanged.
//
// `rCent` carves a sphere out of the middle, turning the solid into a shell;
// rCent <= 0 leaves it solid.
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


// p is in the solid's own coordinates (origin at the centre of the ball model)
float hypCoxCubeDistance(vec3 p, float dihedral, float rCent){
    float theta2 = PI/dihedral;                          //half the dihedral angle
    float denom  = 2.*sin(theta2)*sin(theta2);
    float d      = 1./sqrt(1. - 1./denom);               //face-sphere centre distance
    float r      = sqrt(d*d - 1.);                       //and its radius (orthogonality)

    float dist = length(p) - 1.0;                        //the unit ball

    //carve the six face spheres, along +/- each coordinate axis
    for(int i = 0; i < 3; i++){
        vec3 v = vec3(i == 0 ? 1.0 : 0.0, i == 1 ? 1.0 : 0.0, i == 2 ? 1.0 : 0.0);
        dist = max(dist, -(length(p - d*v) - r));
        dist = max(dist, -(length(p + d*v) - r));
    }

    //hollow out the middle, if asked (a HARD max here, unlike the dodecahedron's
    //smooth one — preserved from the original)
    if(rCent > 0.0){
        dist = max(dist, rCent - length(p));
    }
    return dist;
}


// the sdf starts at length(p) - 1 and is only ever max()'d LARGER (carving
// spheres out of the unit ball), so the solid is contained in the unit sphere
// and the ball's own first term is provably conservative.
float hypCoxCubeBound(vec3 p, float dihedral, float rCent){
    return length(p) - 1.0;
}

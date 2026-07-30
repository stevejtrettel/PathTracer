//----------------------------------------------------------------------------
// HYPERBOLIC DODECAHEDRON — the right-angled dodecahedron of H^3, drawn in the
// BALL (Poincare) model.
//
// The construction is the whole idea: in the ball model a hyperbolic PLANE is a
// Euclidean sphere meeting the unit sphere orthogonally. So the solid is the unit
// ball with twelve such spheres carved out of it, one per face — and the carving
// is `max(dist, -faceSphere)`, an intersection of the twelve outsides.
//
// Orthogonality fixes the geometry with no freedom left: a face sphere at
// distance d from the origin with radius r must satisfy d^2 = r^2 + 1, and for
// the right-angled dodecahedron c = 2/phi gives r = sqrt(c), d = sqrt(c+1).
// That is why this shape has no size parameter — it is THE right-angled
// dodecahedron, not a family.
//
// The face directions are the icosahedron's vertex directions, (0, ±1, ±phi)
// cycled, since the dodecahedron's faces point at its dual's vertices — the same
// duality primitives/dodecahedron.glsl uses.
//
// `rCent` carves a sphere out of the middle, turning the solid into a shell;
// rCent <= 0 leaves it solid.
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


// the six face directions, up to sign: (0, 1, phi) cycled over the axes.
// phi = 1.6180340, |(0, 1, phi)| = 1.9021130. The legacy normalized a truncated
// 1.618 instead of phi, which tilted every face by ~8e-6 — below anything
// visible, but these are the directions that actually make the solid
// right-angled, so the port uses exact phi.
const vec3 HYPDOD_FACES[6] = vec3[6](
    vec3( 0.0,        0.5257311,  0.8506508),
    vec3( 0.8506508,  0.0,        0.5257311),
    vec3( 0.5257311,  0.8506508,  0.0),
    vec3( 0.0,       -0.5257311,  0.8506508),
    vec3( 0.8506508,  0.0,       -0.5257311),
    vec3(-0.5257311,  0.8506508,  0.0)
);


// p is in the solid's own coordinates (origin at the centre of the ball model)
float hypDodDistance(vec3 p, float rCent){
    //c = 2/phi; the orthogonality condition d^2 = r^2 + 1 then gives both
    const float HYPDOD_R = 1.1117859;                    // sqrt(c),     c = 2/phi
    const float HYPDOD_D = 1.4953488;                    // sqrt(c + 1)

    float dist = length(p) - 1.0;                        //the unit ball

    //carve the twelve face spheres: each direction and its antipode
    for(int i = 0; i < 6; i++){
        vec3 v = HYPDOD_FACES[i];
        dist = max(dist, -(length(p - HYPDOD_D*v) - HYPDOD_R));
        dist = max(dist, -(length(p + HYPDOD_D*v) - HYPDOD_R));
    }

    //hollow out the middle, if asked
    if(rCent > 0.0){
        dist = smax(dist, rCent - length(p), 0.1);
    }
    return dist;
}


// the sdf starts at length(p) - 1 and is only ever max()'d LARGER (carving
// spheres out of the unit ball), so the solid is contained in the unit sphere
// and the ball's own first term is provably conservative.
float hypDodBound(vec3 p, float rCent){
    return length(p) - 1.0;
}

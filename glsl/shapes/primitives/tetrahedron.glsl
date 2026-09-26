//----------------------------------------------------------------------------
// TETRAHEDRON — a regular tetrahedron of CIRCUMRADIUS `size` (centre to
// vertex), standing on a face: apex at y = size, base at y = -size/3 (a regular
// tetrahedron's inradius is a third of its circumradius).
//
// `size` is the CIRCUMRADIUS (centre to vertex), the same for all four platonic
// solids here: at one size they fit the same ball, which is what makes a lineup
// of them comparable. (It was the inradius until Sep 2026 — then a regular
// tetrahedron, whose circumradius is 3 inradii, dwarfed the rest.)
//
// The same construction as primitives/icosahedron.glsl, but with half-spaces
// instead of slabs — a tetrahedron is not centrally symmetric, so each of its
// four faces needs its own normal: dot(p, n) <= r for every face, and the max
// over the normals minus r is the distance estimate. Exact on the faces, a
// conservative underestimate near edges and vertices.
//
// The normals: the base's straight down, and three sides rising at 1/3 (any two
// faces of a regular tetrahedron meet with normals at cos = -1/3), their
// horizontal parts at the same three bearings the old taper had.
//
// REWRITTEN (Sep 2026). The port's version was a cheap tapered max form: 2*size
// tall on a base of side 1.73*size — too tall to be regular — with a `size`
// that was no radius of it, and a taper that overstated distance by 3%.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// the four face normals: sqrt(8)/3 = 0.9428090 horizontal and 1/3 vertical on
// the three sides, at bearings (cos, sin) = (0.8660254, 0.5), (-0.8660254, 0.5),
// (0, -1) in the xz plane
const vec3 TETRA_NORMALS[4] = vec3[4](
    vec3( 0.0,       -1.0,        0.0),
    vec3( 0.8164966,  0.3333333,  0.4714045),
    vec3(-0.8164966,  0.3333333,  0.4714045),
    vec3( 0.0,        0.3333333, -0.9428090)
);


// p is in the tetrahedron's own coordinates (origin at the centre — for a
// regular tetrahedron the incentre, centroid and circumcentre coincide)
float tetrahedronDistance(vec3 p, float size){
    float d = dot(p, TETRA_NORMALS[0]);
    for(int i = 1; i < 4; i++){
        d = max(d, dot(p, TETRA_NORMALS[i]));
    }
    return d - size/3.0;       //the faces sit at the inradius
}


// the circumscribed sphere: the vertices sit exactly on it
float tetrahedronBound(vec3 p, float size){
    return length(p) - size;
}

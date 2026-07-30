//----------------------------------------------------------------------------
// ICOSAHEDRON — a regular icosahedron of INRADIUS `size` (centre to face, the
// only radius that makes this formula's `size` mean one thing).
//
// A polyhedron as the INTERSECTION OF SLABS: for each face normal n, the solid
// satisfies |dot(p, n)| <= r, so max over the normals minus r is a distance
// estimate. Exact on the faces, a conservative underestimate near edges and
// vertices — which is what a sphere tracer wants.
//
// Only TEN normals are needed for twenty faces, because |dot| covers a normal
// and its antipode at once. And the ten are exactly the DODECAHEDRON's vertex
// directions — the two solids are duals, so each one's faces point at the
// other's vertices. (See primitives/dodecahedron.glsl for the mirror image.)
//
// REWRITTEN IN THE PORT, not ported. The legacy pair lived on the `fGDFBegin` /
// `fGDF(GDFVector7)` / `fGDFEnd` macro machinery of objects/basic/gdf.glsl,
// which is hostile to a library of plain functions of a point and some floats —
// and which hid the duality above behind numbered vector defines. The macros
// are gone; the constants are written out normalized. It also gained a `size`
// parameter (the legacy was locked to one size).
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// the dodecahedron's 20 vertex directions, up to sign: the four cube diagonals
// (1,1,1)/sqrt(3), and the (0, 1, phi^2) family cycled over the three axes.
// phi = 1.6180340, phi^2 = phi + 1 = 2.6180340, |(0, 1, phi^2)| = 2.8025171.
const vec3 ICOSA_NORMALS[10] = vec3[10](
    vec3( 0.5773503,  0.5773503,  0.5773503),
    vec3(-0.5773503,  0.5773503,  0.5773503),
    vec3( 0.5773503, -0.5773503,  0.5773503),
    vec3( 0.5773503,  0.5773503, -0.5773503),
    vec3( 0.0,        0.3568221,  0.9341724),
    vec3( 0.0,       -0.3568221,  0.9341724),
    vec3( 0.9341724,  0.0,        0.3568221),
    vec3(-0.9341724,  0.0,        0.3568221),
    vec3( 0.3568221,  0.9341724,  0.0),
    vec3(-0.3568221,  0.9341724,  0.0)
);


// p is in the icosahedron's own coordinates (origin at the centre)
float icosahedronDistance(vec3 p, float size){
    vec3  q = p/size;
    float d = 0.0;
    for(int i = 0; i < 10; i++){
        d = max(d, abs(dot(q, ICOSA_NORMALS[i])));
    }
    return (d - 1.0)*size;
}


// the circumscribed sphere. For a regular icosahedron the circumradius is
// 1.2584086 times the inradius.
float icosahedronBound(vec3 p, float size){
    return length(p) - 1.2584086*size;
}

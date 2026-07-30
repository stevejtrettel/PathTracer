//----------------------------------------------------------------------------
// DODECAHEDRON — a regular dodecahedron of INRADIUS `size` (centre to face).
//
// The dual of primitives/icosahedron.glsl, and the same construction: the
// intersection of slabs |dot(p, n)| <= r over the face normals, exact on the
// faces and a conservative underestimate near edges and vertices.
//
// SIX normals for twelve faces (|dot| covers each normal and its antipode), and
// the six are the ICOSAHEDRON's vertex directions — the (0, phi, 1) family
// cycled over the axes. Duality again: each solid's faces point at the other's
// vertices.
//
// REWRITTEN IN THE PORT off the objects/basic/gdf.glsl macros, and gained a
// `size` parameter — see primitives/icosahedron.glsl for the full note.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// the icosahedron's 12 vertex directions, up to sign: the (0, phi, 1) family
// cycled over the three axes. phi = 1.6180340, |(0, phi, 1)| = 1.9021130.
const vec3 DODECA_NORMALS[6] = vec3[6](
    vec3( 0.0,        0.8506508,  0.5257311),
    vec3( 0.0,       -0.8506508,  0.5257311),
    vec3( 0.5257311,  0.0,        0.8506508),
    vec3(-0.5257311,  0.0,        0.8506508),
    vec3( 0.8506508,  0.5257311,  0.0),
    vec3(-0.8506508,  0.5257311,  0.0)
);


// p is in the dodecahedron's own coordinates (origin at the centre)
float dodecahedronDistance(vec3 p, float size){
    vec3  q = p/size;
    float d = 0.0;
    for(int i = 0; i < 6; i++){
        d = max(d, abs(dot(q, DODECA_NORMALS[i])));
    }
    return (d - 1.0)*size;
}


// the circumscribed sphere. For a regular dodecahedron the circumradius is
// 1.2584086 times the inradius — the SAME ratio as the icosahedron's, which is
// a property dual Platonic solids share (verified to 7 places, not assumed).
float dodecahedronBound(vec3 p, float size){
    return length(p) - 1.2584086*size;
}

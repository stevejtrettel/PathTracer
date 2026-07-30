//----------------------------------------------------------------------------
// OCTAHEDRON — a regular octahedron with vertices `size` from the centre.
//
// IQ's exact octahedron, valid everywhere.
//
// TWO CHANGES IN THE PORT. It gained a `size` parameter (the legacy
// objects/basic/octahedron.glsl was locked to one size), and its hand-rolled
// far-field cull — an `if(length(p) > 1.) return length(p) - 0.9;` sitting
// inside the sdf — became a proper `octahedronBound`. That cull was never a
// domain guard (the sdf is exact at any range); it was a bounding volume
// written in the wrong place, and the emitter does that job now. The bound is
// also exact rather than the loose 0.9: an octahedron with vertices at `size`
// is inscribed in the sphere of radius `size`.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the octahedron's own coordinates (origin at the centre).
// 0.57735027 = 1/sqrt(3), the face-normal projection.
float octahedronDistance(vec3 p, float size){
    vec3  a = abs(p);
    float m = a.x + a.y + a.z - size;

    vec3 q;
    if     (3.0*a.x < m){ q = a.xyz; }
    else if(3.0*a.y < m){ q = a.yzx; }
    else if(3.0*a.z < m){ q = a.zxy; }
    else                { return m*0.57735027; }

    float k = clamp(0.5*(q.z - q.y + size), 0.0, size);
    return length(vec3(q.x, q.y - size + k, q.z - k));
}


// the circumscribed sphere: the vertices sit exactly on it
float octahedronBound(vec3 p, float size){
    return length(p) - size;
}

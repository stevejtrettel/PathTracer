//----------------------------------------------------------------------------
// TRIANGLE — an equilateral triangular prism, `side` across, `thickness` deep
// along z (a classic dispersing prism).
//
// glsl/shapes/ is the math-only library: plain functions of a point and some
// floats. No structs, no Frame, no Material. Placement, materials and the
// region interface are emitted by the scene.
//----------------------------------------------------------------------------


// p is in the prism's own coordinates (origin at the centroid). Equilateral
// cross-section in the xy-plane, extruded along z; 0.86602 = cos(30°).
float triangleDistance(vec3 p, float side, float thickness){
    vec3 q = abs(p);
    return max(q.z - thickness, max(q.x*0.86602 + p.y*0.5, -p.y) - side*0.5);
}

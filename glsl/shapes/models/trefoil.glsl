//----------------------------------------------------------------------------
// TREFOIL — a trefoil knot as a square-section tube, `size` across.
//
// The construction is the classic one for a (2,3) torus knot: go to cylindrical
// coordinates about y, shift to the tube's centre circle of radius `ring`, then
// TWIST the cross-section by 1.5 times the azimuth. That 3/2 is the knot — the
// section returns to itself only after two full turns, which is what makes the
// curve close up as a trefoil rather than a circle. A second fold by PI/2 steps
// gives the square section its four-fold symmetry, and the 2D box distance
// thickens it into a tube.
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


//the far-field clamp the original carried: beyond this the returned distance
//saturates rather than growing (harmless — the marcher is long gone by then)
const float TREFOIL_FAR = 100.0;


//2D box distance, for the square cross-section (file-private)
float trefoil_box2d(vec2 p, vec2 b){
    vec2 d = abs(p) - b;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}


//2D rotation by a (file-private)
vec2 trefoil_rot2d(vec2 q, float a){
    return q*cos(a) + q.yx*sin(a)*vec2(-1.0, 1.0);
}


//the knot itself, at unit scale, about a centre circle of radius `ring`
float trefoil_tube(vec3 p, float ring){
    float dMin = TREFOIL_FAR;

    vec3  q = p;
    float a = atan(q.z, q.x);                     //azimuth about y
    q.xz = vec2(length(q.xz) - ring, q.y);        //to tube-local coordinates
    q.xz = trefoil_rot2d(q.xz, 1.5*a);            //the 3/2 twist: this IS the knot
    q.xz = trefoil_rot2d(q.xz, -PI*(floor(atan(q.z, q.x)/PI + 0.5)));
    q.x -= 1.0;

    float d = length(trefoil_box2d(q.xz, vec2(0.2))) - 0.05;
    if(d < dMin){ dMin = d; }
    return 0.4*dMin;
}


// p is in the knot's own coordinates (origin at the centre, axis = y).
// The swizzle stands the knot up. It replaces a full axis-angle rotation matrix
// in the original — `p *= rotMat(vec3(1,0,0), PI/2)` is exactly this permutation,
// verified, so the duplicated 10-line rotation helper is gone.
float trefoilDistance(vec3 p, float size){
    vec3 q = vec3(p.x, -p.z, p.y);
    q /= 0.18*size;
    return trefoil_tube(q, 2.5)*0.18*size;
}


// bounding sphere, TIGHTENED IN THE PORT. The legacy claimed radius 1.9*size,
// which is 2.8x looser than the knot: measured over 4M samples the solid reaches
// |q| = 3.7604 in the knot's own scaled frame, and q = p/(0.18*size), so the true
// world extent is 0.677*size. 0.80 keeps an 18% margin over that measurement.
// A loose bound costs only speed, but 2.8x is a lot of wasted marching.
float trefoilBound(vec3 p, float size){
    return length(p) - 0.80*size;
}

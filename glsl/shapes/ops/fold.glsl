//----------------------------------------------------------------------------
// OPS · FOLD — operators that act on the POINT, before the sdf sees it.
//
// Vocabulary: always compiled (glsl/shapes/_vocabulary.glsl), callable from any
// shape file and from authored scene GLSL with no declaration. See
// docs/shape-library.md §1.
//
// Call these on p, then evaluate the shape at the folded point. A fold is an
// isometry (or a projection onto a fundamental domain), so the result is still
// a distance — with ONE standing caveat: the base shape must stay INSIDE its
// cell/wedge, or the fold OVERESTIMATES distance across the seam, which the
// marcher punishes as tunneling.
//
// The 2D->3D lifts (revolution, twist) live here too: they also act on p.
//----------------------------------------------------------------------------


//--- MIRROR: fold across the coordinate planes ------------------------------

vec3 opSymX(vec3 p){ p.x = abs(p.x); return p; }
vec3 opSymY(vec3 p){ p.y = abs(p.y); return p; }
vec3 opSymZ(vec3 p){ p.z = abs(p.z); return p; }
vec3 opSymXY(vec3 p){ p.xy = abs(p.xy); return p; }
vec3 opSymXZ(vec3 p){ p.xz = abs(p.xz); return p; }
vec3 opSymYZ(vec3 p){ p.yz = abs(p.yz); return p; }
vec3 opSymXYZ(vec3 p){ return abs(p); }


//--- REPEAT -----------------------------------------------------------------

//INFINITE repetition on a grid of spacing s (one copy of the shape per cell)
vec3 opRep(vec3 p, vec3 s){ return p - s*round(p/s); }

//LIMITED repetition: a (2*lim+1) grid of spacing s, centered at the origin
vec3 opRepLim(vec3 p, float s, vec3 lim){ return p - s*clamp(round(p/s), -lim, lim); }


//--- STRETCH ----------------------------------------------------------------

//ELONGATE: pull a shape apart by h along each axis (cheap; exact for convex shapes)
vec3 opElongate(vec3 p, vec3 h){ return p - clamp(p, -h, h); }


//--- RADIAL: n-fold rotational symmetry about an axis ------------------------
//
//A rotation is an isometry, so this is exact; but like opRepLim, the base must
//stay inside its wedge (see the header caveat).

vec3 opRadialY(vec3 p, float n){
    float r = length(p.xz);
    if(r < 1.0e-6){ return p; }              //on the axis atan is undefined
    float seg = 6.2831853/n;
    float a   = mod(atan(p.z, p.x) + 0.5*seg, seg) - 0.5*seg;
    return vec3(r*cos(a), p.y, r*sin(a));
}
vec3 opRadialX(vec3 p, float n){
    float r = length(p.yz);
    if(r < 1.0e-6){ return p; }
    float seg = 6.2831853/n;
    float a   = mod(atan(p.z, p.y) + 0.5*seg, seg) - 0.5*seg;
    return vec3(p.x, r*cos(a), r*sin(a));
}
vec3 opRadialZ(vec3 p, float n){
    float r = length(p.xy);
    if(r < 1.0e-6){ return p; }
    float seg = 6.2831853/n;
    float a   = mod(atan(p.y, p.x) + 0.5*seg, seg) - 0.5*seg;
    return vec3(r*cos(a), r*sin(a), p.z);
}


//--- 2D -> 3D ---------------------------------------------------------------

//REVOLUTION: the (radius, height) input for a 2D sdf spun about the y axis,
//offset w from the axis. Pair with opExtrusion's sibling in ops/smooth.glsl.
vec2 opRevolution(vec3 p, float w){
    return vec2(length(p.xz) - w, p.y);
}

//TWIST about the y axis, k radians per unit of height
vec3 opTwist(vec3 p, float k){
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    vec2  r = mat2(c, -s, s, c)*p.xz;
    return vec3(r.x, p.y, r.y);
}

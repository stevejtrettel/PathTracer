//----------------------------------------------------------------------------
// KLEIN BOTTLE — the figure-8 immersion, as a hollow surface of wall thickness
// `thickness`, overall scale `size`. After shadertoy 4ltSW8.
//
// Assembled from four pieces, unioned: a SIDE HANDLE (a stretched cylinder about
// xz), a LOWER BASE (half a torus, forming the open mouth), a MID BASE (a
// stretched torus), and an UPPER HANDLE (half a torus about xy, cut off at a
// fixed height). Each is hollowed by the same `abs(...) - thickness` shell trick,
// so the result is a surface with a wall rather than a solid.
//
// The pieces are shaped by `y`, a squared sine of height, which is what tapers
// the handle and the mid base together so they meet without a seam.
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


//the bottle at unit scale (file-private). `thickness` is the wall half-width.
float kleinBottle_sd(vec3 p, float thickness){
    float d = maxDist;

    p.y += 0.5;
    p.xy *= rot2(PI/2.);

    vec3  q = p + vec3(1. - cos((1. - p.y)/3.*PI), 0, 0);
    float y = pow(sin((1. - p.y)/3.*PI/2.), 2.);

    // SIDE HANDLE (stretched xz cylinder), hollowed
    float sideHandle = max(max(abs(length(q.xz) - 0.5 + 0.25*y) - thickness, q.y - 1.0), -q.y - 2.0);
    d = min(d, sideHandle);

    // LOWER BASE: the opening (half an xz torus)
    q = p - vec3(0, 1, 0);
    float lowerBase = max(abs(length(vec2(length(q.xz) - 1.0, q.y)) - 0.5) - thickness, -q.y);
    d = min(d, lowerBase);

    // MID BASE (stretched xz torus)
    q = p;
    float midBase = max(max(abs(length(q.xz) - 1.5 + 1.25*y), q.y - 1.0), -q.y - 2.0) - thickness;
    d = min(d, midBase);

    // UPPER HANDLE (half an xy torus), cut off at a fixed height
    q = p + vec3(1, 2, 0);
    float upperHandle = abs(length(vec2(length(q.xy) - 1.0, q.z)) - 0.25) - thickness;
    upperHandle = max(upperHandle, q.y);
    d = min(d, upperHandle);

    return 0.8*d;
}


// p is in the bottle's own coordinates. The axis permutation is baked into the
// shape (it is how the immersion is oriented), not a placement choice.
// `thickness` is RELATIVE — a fraction of the unit bottle — so it scales with
// size rather than fighting it. 0.05 is a good wall.
//
// FIXED IN THE PORT: the legacy divided p by size but never scaled the returned
// distance back, so for size < 1 it overestimated distance and the marcher could
// tunnel. Its only scene used size = 1.0, where every scaling is the identity,
// so the bug was never exercised — this is byte-identical there and correct
// elsewhere.
float kleinBottleDistance(vec3 p, float size, float thickness){
    vec3 q = vec3(-p.y, p.z, p.x)/size;
    return size*kleinBottle_sd(q, thickness);
}


// bounding sphere: the bottle lies within radius 5.9 at unit scale, and the axis
// permutation preserves length
float kleinBottleBound(vec3 p, float size){
    return length(p) - 5.9*size;
}

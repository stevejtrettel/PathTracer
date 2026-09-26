//----------------------------------------------------------------------------
// APOLLONIAN GASKET — the FRACT-fold gasket, morphed by `foldOffset`.
//
// The same fold family as fractals/apollonian.glsl, framed differently. That
// one folds with `p -= 2*round(0.5*p)` and morphs through the inversion radius;
// this one folds with `p = -1 + 2*fract(0.5*p + foldOffset)` at a fixed scale of
// 1.5 and morphs by SHIFTING the fold each iteration. At foldOffset 0.5 the two
// folds agree; what stays different is the framing below (and the +0.2 floor),
// which makes this one a ball-shaped packing — hence two files.
//
// Two things make it renderable at all. An outer sphere INVERSION maps the
// space-filling gasket into a compact blob, and its conformal factor has to be
// undone: distances measured in the inverted coordinates are stretched by
// 3/|p|^2, so the estimate is scaled back by m/3. And the result is CLIPPED to
// the unit ball, because the folded fractal is otherwise infinite.
//
// KEEP foldOffset NEAR 0.5 (about 0.4..0.6). Away from 0.5 the structure fills
// in and the estimate is tiny almost everywhere in the ball. Fraction of
// interior points under the default epsilon (1e-3), 6k samples:
//
//     foldOffset     0.4   0.45   0.5   0.55   0.6   0.877
//     "solid"        23%   11%    8%    11%    23%   ~98%
//
// 0.877 was the legacy's saved value, and it is why the port rendered as a
// smooth SPHERE: 98% of the ball read as a wall. Two earlier diagnoses blamed
// the epsilon (a 1e-7 march override) and then the estimator itself; neither
// was it. At 0.5 the original maths renders at the default marcher settings.
//----------------------------------------------------------------------------


// p is in the gasket's own coordinates. `radius` is the inversion radius,
// `foldOffset` shifts the fold each iteration and morphs the gasket.
float apollonianGasketDistance(vec3 p, float radius, float foldOffset){
    //the clip that makes an infinite space-filler into an object
    float ballDist = length(p) - 1.0;

    vec3 q = radius*p;

    //conformal factor of the inversion below, undone at the end
    float m = dot(q, q);

    q /= dot(q, q);
    q += vec3(1.0);
    q *= 3.0;

    float scale = 1.0;
    const float s = 1.5;

    for(int i = 0; i < 10; i++){
        q = -1.0 + 2.0*fract(0.5*q + foldOffset);

        float r2 = dot(q, q);
        float k  = s/r2;
        q     *= k;
        scale *= k;
    }

    float res  = min(abs(q.z) + abs(q.x), min(abs(q.x) + abs(q.y), abs(q.y) + abs(q.z))) + 0.2;
    float dist = 0.25*res/scale * m/3.0;

    return max(dist, ballDist);
}


// ADDED IN THE PORT. The sdf ends in max(dist, length(p) - 1), so the solid is
// contained in the unit ball and this is provably conservative — the same
// argument models/hypDod.glsl uses. The legacy had no bound, which meant every
// far-away ray paid for a 10-iteration fold loop; this skips it.
float apollonianGasketBound(vec3 p, float radius, float foldOffset){
    return length(p) - 1.0;
}

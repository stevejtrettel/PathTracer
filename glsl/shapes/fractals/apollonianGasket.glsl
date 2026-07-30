//----------------------------------------------------------------------------
// APOLLONIAN GASKET — the FRACT-fold gasket, morphed by `foldOffset`.
//
// A DIFFERENT ESTIMATOR from fractals/apollonian.glsl, not a preset of it. That
// one folds with `p -= 2*round(0.5*p)` and morphs through the inversion radius;
// this one folds with `p = -1 + 2*fract(0.5*p + foldOffset)` at a fixed scale of
// 1.5 and morphs by SHIFTING the fold each iteration. Different fold, different
// fractal — hence two files.
//
// Two things make it renderable at all. An outer sphere INVERSION maps the
// space-filling gasket into a compact blob, and its conformal factor has to be
// undone: distances measured in the inverted coordinates are stretched by
// 3/|p|^2, so the estimate is scaled back by m/3. And the result is CLIPPED to
// the unit ball, because the folded fractal is otherwise infinite.
//
// ⚠ UNRESOLVED — THIS ESTIMATOR IS DEGENERATE AT DEFAULT MARCHER SETTINGS, and
// the port is faithful, so the problem is in the math it carries. Measured over
// 30k points inside the unit ball, at foldOffset 0, 0.5 and 0.877 alike:
//   - the fractal term is NEVER negative (min 7e-11), so the solid has NO
//     interior at all — which is arguably right for a gasket, a set of measure
//     zero, but means nothing is ever "inside";
//   - its MEDIAN value inside the ball is ~3e-5, far below marcher epsilon,
//     because `scale` accumulates k = 1.5/r2 with r2 typically below 1.5 and so
//     diverges over ten iterations, crushing the estimate toward zero.
// The consequence is that a ray reads the whole unit ball as a wall and the
// object renders as a smooth SPHERE. This is the "thin haze read as a solid
// wall" failure the ROADMAP describes for fractal DEs; the fix is a scene-level
// EPSILON override, and the legacy scene never set one (it is likely one of the
// unverified fractal ports). Left faithful and flagged rather than silently
// "fixed" — retuning a fractal DE is by-eye work, not a mechanical port.
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
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

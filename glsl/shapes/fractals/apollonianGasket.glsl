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
// THIS ESTIMATOR NEEDS A FINE EPSILON — see scenes/apollonianGasket, which sets
// `march: {epsilon: 1e-7, maxSteps: 4000}`.
//
// It is unusually pessimistic. `res` carries a +0.2 floor so it never reaches
// zero, and `scale` diverges over the ten iterations, so the returned value is
// tiny almost EVERYWHERE inside the unit ball rather than only near the gasket.
// Measured over 200k interior points at foldOffset 0.877:
//
//     percentile     value            epsilon    fraction of the ball it "hits"
//     0.01%          9.3e-10          1e-3       97.1%   <- the engine default
//     1%             7.1e-08          1e-5       30.7%
//     25%            6.7e-06          1e-6        7.7%
//     50%            3.1e-05          1e-7        1.3%   <- what the scene uses
//     90%            3.7e-04          1e-8        0.15%
//
// At the engine default the marcher counts 97% of the ball as a hit and the
// object renders as a smooth SPHERE. That is not a bug in this file — the maths
// is the original's — it is what a distance estimator this conservative costs,
// and the per-scene `march:` key is how it is paid.
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

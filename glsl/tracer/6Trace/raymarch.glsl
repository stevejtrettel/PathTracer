//-------------------------------------------------
// RAYMARCH
// march the scene sdf and return the distance to the nearest surface (or
// stopDist if none is reached first). Does NOT update the path.
//
// Over-relaxed sphere tracing with adaptive cone epsilon (Keinert, Innmann,
// Süßmuth, Stamminger, "Enhanced Sphere Tracing", 2014). Full derivation and
// the A/B history that led here — it replaced a fixed 0.9-under-relaxed march —
// are in docs/marching.md.
//
// cost(ray) ~= (# steps) * (cost of one sdf_Scene eval). The bound() cull in
// objectAPI.glsl attacks the per-eval cost; this marcher attacks the step COUNT
// with two independent tricks:
//
//   ADAPTIVE CONE EPSILON: the hit tolerance grows with marched distance,
//     eps = EPSILON*(1 + MARCH_CONE*t). A surface far from the camera projects
//     to less than a pixel, so resolving it to the absolute EPSILON just burns
//     convergence steps. Growing the tolerance with t stops that geometric crawl
//     on distant geometry; invisible to the eye and geometry-neutral (it only
//     reads the returned scalar distance, so it is safe under any flow()).
//
//   OVER-RELAXED STEPPING: step by MARCH_RELAX*radius instead of radius. For
//     MARCH_RELAX in (1,2) this over-shoots and can skip a thin surface, so it
//     is guarded by the enhanced-sphere-tracing fallback: an over-step from a
//     sphere of radius r_prev is valid only if the new unbounding sphere reaches
//     back to overlap it (step <= r_prev + radius). If not (sorFail), retreat to
//     the guaranteed-safe point r_prev past the previous sample and resume — so
//     no surface is ever skipped. The signedRadius sign-lock lets one loop march
//     from inside a solid too (glass interiors), like a plain abs() march.
//
// CAVEAT (non-Euclidean): the overlap fallback assumes Euclidean ball geometry
// along a straight ray — exact for the current straight-line flow(). A future
// curved-geodesic space should re-derive the invariant, or drop MARCH_RELAX to
// <= 1 (pure under-relaxation, which needs no overlap assumption). Adaptive cone
// epsilon carries no such assumption.
//-------------------------------------------------


// over-relaxation ω (>1 over-steps with the overlap fallback; =1 is the plain
// conservative full step; <1 under-relaxes, the safe direction for DE fields that
// overestimate distance — varieties, fractals) and the cone-epsilon growth per
// unit marched distance. Tuned by eye across the whole scene library; these were
// live marchRelax/marchCone knobs during the A/B (see git history + docs/marching.md).
const float MARCH_RELAX = 1.2;
const float MARCH_CONE  = 0.005;


float raymarch(Vector tv, float stopDist){

    float t          = 0.;   //arclength marched so far
    float prevRadius = 0.;   //unbounding radius at the previous sample
    float stepLength = 0.;   //the step that carried us to the current sample
    float sgn = (sdf_Scene(tv) < 0.) ? -1. : 1.;   //start inside or outside the surface

    for (int i = 0; i < maxMarchSteps; i++){

        float raw    = sdf_Scene( tv );
        float radius = abs(raw);
        float signedRadius = sgn * raw;   //>0 while on the starting side

        //over-relaxation fallback: did the last over-step overshoot past the
        //overlap of consecutive unbounding spheres? If so it may have skipped a
        //surface — retreat to the safe point instead of accepting this sample.
        bool sorFail = (MARCH_RELAX > 1.) && (prevRadius + radius < stepLength);
        stepLength = sorFail ? (prevRadius - stepLength)      //negative: back up to the safe point
                             : (signedRadius * MARCH_RELAX);  //normal (over-)relaxed step
        prevRadius = radius;

        //adaptive cone epsilon (skip the convergence test on a fallback retreat,
        //where this sample is the overshot, invalid point)
        float eps = EPSILON * (1. + MARCH_CONE * t);
        if(!sorFail && radius < eps){
            //Land a hair on the STARTING SIDE, not exactly on the surface. The
            //surface-exact landing (t + signedRadius) leaves sdf ~= 0 at the hit,
            //so inside() = (sdf < 0) becomes a float-noise coin flip -> the normal
            //randomly negates (setImpactData) -> ring-structured normal speckle
            //centred on head-on incidence. Subtracting EPSILON along the ray backs
            //the hit off to the starting side (sdf ~= +/-EPSILON, sign = sgn) in
            //all four approach/overshoot x outside/inside cases, so inside() is
            //stable. (signedRadius already retreats an over-relaxed overshoot; this
            //adds the safety margin on top.)
            return t + signedRadius - EPSILON;
        }

        //analytic stop: exit ONLY when the SAFE (unrelaxed) sphere clears it —
        //radius is a true lower bound, so no marched surface can precede the stop.
        //Exiting on the RELAXED step instead is wrong: it is a speculative over-step
        //whose skip-guard (sorFail) runs on the NEXT sample, and an early exit never
        //takes that sample — so a marched surface sitting just in front of the
        //analytic one (glassware on the floor) gets silently skipped at grazing
        //angles. (Verified: cup-on-floor lost its whole bottom band this way.)
        if(!sorFail && t + radius > stopDist){
            return stopDist;
        }
        //a relaxed step about to cross the stop can't be validated by the overlap
        //test (there is no next sample past an exit) — take the safe full step.
        if(t + stepLength > stopDist){
            stepLength = signedRadius;
        }

        t += stepLength;
        if(t > stopDist){
            return stopDist;   //unreachable but for float noise; keep as the net
        }

        flow(tv, stepLength);   //stepLength may be negative on a fallback retreat
    }

    //if you hit nothing
    return stopDist;
}

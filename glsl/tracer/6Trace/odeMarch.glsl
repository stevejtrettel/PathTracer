//-------------------------------------------------
// ODE MARCH — curved-light transport (the curved sibling of raymarch)
//
// When the ray is inside a MEDIUM REGION with a variable effective index n(x),
// the segment to the next surface is a GEODESIC, not a line. stepForward()
// branches here when isMedium(path.region) instead of the straight
// raytrace+raymarch. Everything downstream is unchanged: this reports the hit +
// the ARC LENGTH in path.distance, so updateFromVolume colours the curved segment
// and scatter refracts at the boundary exactly as for a straight segment.
//
// Integrator: SYMPLECTIC leapfrog (Störmer-Verlet). The optical ray ODE is
// Hamiltonian, H = ½(|T|² − n²(r)), state (r, T = n·tangent), dr/dt = T,
// dT/dt = n·∇n (Sharma-Kumar-Ghatak). Separable ⇒ kick-drift-kick conserves the
// invariant |T| = n over long paths (black-hole orbits) at ONE gradient eval/step.
//
// THE FIELD IS PER-REGION. A medium is an object whose interior index varies with
// position; the scene supplies, keyed by region id,
//     bool  isMedium(int id);              is this region a curved medium?
//     float indexFieldOf(int id, vec3 p);  its index n(p), 1.0 = vacuum
// odeMarch reads the region the ray is currently traversing off path.region — the
// state already carried for the subsurface walk ("am I still inside THIS region?")
// — and integrates that region's field. No global field, no #define gate: WHICH
// region confines the curving is the region's own sdf, and the field is chosen
// ONCE per traversal (path.region only changes at a surface crossing, which is
// exactly where odeMarch exits), so ∇n stays smooth across the wall for free.
// Static metric null geodesics are n = √(g_space/g_time), so this bends light for
// graded-index optics AND black holes (Majumdar-Papapetrou = U²).
//
// THE FIELD MUST BE SMOOTH past the region's own boundary — real a little OUTSIDE
// the wall; do NOT clamp it to 1 there. odeForce central-differences ∇n, and a
// value-cliff at the wall reads garbage and bands. The region's sdf, not a jump in
// n, is what stops the ray curving outside it. The confining surface refracts with
// n_wall = indexFieldOf(id, hit) (the SAME field), so Snell at the wall matches the
// interior eikonal: Luneburg (n→1 at the rim, seamless) and the black-hole cube
// (n≠1 at the wall) are ONE case.
//
// Scenes with no medium define neither symbol; the #ifndef defaults below make
// isMedium()==false everywhere ⇒ this file is never entered ⇒ byte-identical to
// the straight tracer.
//-------------------------------------------------

#ifndef ODE_STEP
#define ODE_STEP 0.03           // leapfrog parameter step (arc length per step ≈ n·ODE_STEP)
#endif
#ifndef ODE_GRAD_EPS
#define ODE_GRAD_EPS 0.002     // central-difference epsilon for ∇n
#endif
#ifndef ODE_CAPTURE
#define ODE_CAPTURE 50.        // n above this = captured (black-hole horizon)
#endif
#ifndef ODE_DS_MAX
#define ODE_DS_MAX 0.05        // max COORDINATE step h·|mom|; caps the |mom|=n blow-up near a BH point
#endif
#ifndef ODE_DTOL
#define ODE_DTOL 0.05          // max fractional change of n per step (strong-field accuracy)
#endif


// scene hooks: the engine defaults (no medium anywhere). This file compiles after
// the scene chunk, so a scene WITH media `#define SCENE_HAS_MEDIA` and supplies its
// own isMedium/indexFieldOf (keyed by region id), standing these defaults down.
#ifndef SCENE_HAS_MEDIA
bool  isMedium(int id){ return false; }
float indexFieldOf(int id, vec3 p){ return 1.; }
#endif

float odeIndex(int reg, vec3 p){ return max(indexFieldOf(reg, p), 1e-3); }   // physical n ≥ 0; fp floor

// force F(r) = n·∇n = ½∇(n²), central differences of region `reg`'s index field
vec3 odeForce(int reg, vec3 p){
    vec2 e = vec2(ODE_GRAD_EPS, 0.);
    vec3 g = vec3(
        odeIndex(reg, p+e.xyy) - odeIndex(reg, p-e.xyy),
        odeIndex(reg, p+e.yxy) - odeIndex(reg, p-e.yxy),
        odeIndex(reg, p+e.yyx) - odeIndex(reg, p-e.yyx)
    ) / (2.*ODE_GRAD_EPS);
    return odeIndex(reg, p) * g;
}

// advance path.tv along the geodesic to the next surface. Reports the outcome the
// same way the straight branch of stepForward does — sets path.distance to the ARC
// LENGTH (so updateFromVolume's Beer's law is correct over the curve) and path.dat.isSky,
// or keepGoing=false on capture. stepForward owns the shared tail (totalDistance,
// setData_Scene); this does NOT touch them.
void odeMarch(inout Path path){

    // mom is the canonical momentum conjugate to position r in the optical
    // Hamiltonian H = ½(|mom|² − n²(r)): mom = n·(unit tangent) (Sharma's ray
    // vector T), so |mom| = n — the invariant the symplectic step conserves.
    // (Named `mom`, not `T`: `T` is #defined to vec2 for dual numbers; `p` is position.)
    int  reg = path.region;                       // the medium we are traversing (isMedium(reg) is true)
    vec3 r   = path.tv.pos;
    vec3 mom = odeIndex(reg, r) * path.tv.dir;
    float arc = 0.;
    float startSgn = sign(sdf_Scene(path.tv));   // side we start on (inside the medium: < 0)
    vec3 force = odeForce(reg, r);                // reused across leapfrog steps

    for(int i = 0; i < maxMarchSteps; i++){

        float n = odeIndex(reg, r);

        // capture: the index blows up at the singular POINT (the event horizon is
        // a point in these coords). Any ray this deep is heading in — stop it; it
        // keeps whatever light it had (none more is added) => renders black.
        if(n > ODE_CAPTURE){
            path.keepGoing = false;
            return;
        }

        // --- ADAPTIVE affine step h ---------------------------------------------
        // The drift is r += h·mom with |mom| = n, so a FIXED h overshoots wildly
        // where n is large (approaching a black-hole point) — that overshoot is
        // the exploding, concentric-ring garbage. Bound two things per step:
        //   (1) the COORDINATE step   h·n      ≤ ODE_DS_MAX
        //   (2) the fractional change  h·|∇n|  ≤ ODE_DTOL   (|∇n| = |force|/n)
        // Far from any mass (n≈1, ∇n≈0) neither binds and h = ODE_STEP, so smooth
        // media (e.g. the Luneburg lens) integrate exactly as before.
        float gradN = length(force) / max(n, 1e-6);
        float h = min(ODE_STEP, ODE_DS_MAX / n);
        h = min(h, ODE_DTOL / max(gradN, 1e-6));

        // --- variable-step kick-drift-kick (force reused across steps) ----------
        vec3 rBefore = r;            // step start (on the startSgn side)
        mom += 0.5*h*force;          // half kick   (force at r)
        r  += h*mom;                 // drift
        force = odeForce(reg, r);    // force at the new r (this step's 2nd kick + next step's 1st)
        mom += 0.5*h*force;          // half kick
        arc += length(mom)*h;        // ds ≈ n·h

        vec3 dir = normalize(mom);    // world ray: unit tangent = mom/|mom|

        // reached the next surface? (sdf_Scene changed sign along the curve)
        if(startSgn * sdf_Scene(Vector(r, dir)) < 0.){
            // The step crossed the surface. Bisect the (near-linear) step so we land
            // WITHIN AT_THRESH of it — otherwise the overshoot (up to n·ODE_STEP) is
            // bigger than AT_THRESH, setData's at() test misses, and the boundary
            // interaction is skipped (that overshoot, banded by exit angle, was the
            // concentric-ring artifact).
            vec3 a = rBefore, b = r;                   // a = inside side, b = crossed side
            for(int k = 0; k < 8; k++){
                vec3 m = 0.5*(a + b);
                if(startSgn * sdf_Scene(Vector(m, dir)) < 0.) b = m; else a = m;
            }
            path.tv = Vector(a, dir);                  // just on the startSgn side of the surface
            path.distance  = arc;                      // arc length (stepForward owns totalDistance + setData)
            path.dat.isSky = false;
            return;
        }

        path.tv = Vector(r, dir);

        if(length(r) > maxDist){ break; }  // escaped to infinity (unbounded / global media)
    }

    // ran out of steps or escaped: treat as sky (stepForward owns totalDistance)
    path.distance  = arc;
    path.dat.isSky = true;
}

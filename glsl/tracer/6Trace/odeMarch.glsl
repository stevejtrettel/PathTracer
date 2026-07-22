//-------------------------------------------------
// ODE MARCH — curved-light transport (the curved sibling of raymarch)
//
// When the ray is inside a medium with a variable effective index n(x), the
// segment to the next surface is a GEODESIC, not a line. stepForward() branches
// here (see inMedium below) instead of the straight raytrace+raymarch. Everything
// downstream is unchanged: this reports the hit + the ARC LENGTH in path.distance,
// so updateFromVolume colours the curved segment and scatter refracts at the
// boundary exactly as for a straight segment.
//
// Integrator: SYMPLECTIC leapfrog (Störmer-Verlet). The optical ray ODE is
// Hamiltonian, H = ½(|T|² − n²(r)), state (r, T = n·tangent), dr/dt = T,
// dT/dt = n·∇n (Sharma-Kumar-Ghatak). Separable ⇒ kick-drift-kick conserves the
// invariant |T| = n over long paths (black-hole orbits) at ONE gradient eval/step.
//
// A medium scene supplies the field `float indexField(vec3 p)` (1.0 = vacuum),
// announced with `#define SCENE_INDEX_FIELD` above the definition (a scene hook —
// see docs/material-fields.md; the default below stands down). Static metric null
// geodesics are n = √(g_space/g_time), so this bends light for graded-index optics
// AND black holes (Majumdar-Papapetrou = U²). Scenes with no medium say nothing:
// the default indexField()==1 ⇒ inMedium() is always false ⇒ this file is never
// entered ⇒ byte-identical to the straight tracer.
//
// BOUNDED-MEDIUM CONTRACT (one unified pattern — see IN_MEDIUM_REGION below):
// A medium confined to a shape (a lens, a block of graded glass) provides
//   (1) a SMOOTH indexField(p): the IOR function, real-valued a little PAST the
//       boundary — do NOT clamp it to 1 outside. Clamping makes a value-cliff (or,
//       if the field already hits 1 at the wall, a slope-kink); either way the
//       central-difference ∇n in odeForce reads garbage right at the wall and bands.
//   (2) `#define IN_MEDIUM_REGION(p) <inside my shape>`: the geometric gate that
//       actually confines the curving. indexField extends past the shape; the gate,
//       not a discontinuity, is what stops the ray curving outside it.
//   (3) a surface object whose setData refracts with n_wall = indexField(hit) (the
//       dynamic-IOR wall), so Snell at the surface matches the interior field.
// Luneburg (self-tapering, n→1 at the rim) and the black-hole cube (n≠1 at the wall)
// are the SAME case under this contract; the only prior difference was clamp severity.
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


// scene hook: the engine default (no medium anywhere). This file compiles after
// the scene chunk, so a scene's `#define SCENE_INDEX_FIELD` + its own indexField
// replace it — same pattern as IN_MEDIUM_REGION below.
#ifndef SCENE_INDEX_FIELD
float indexField(vec3 p){ return 1.; }
#endif

float odeIndex(vec3 p){ return max(indexField(p), 1e-3); }   // physical n ≥ 0; fp floor

// Geometric confinement gate. A BOUNDED medium (a real dielectric with a surface)
// has a DISCONTINUOUS index at its wall — and central-differencing ∇n across that
// cliff gives odeForce a spurious huge kick (concentric banding). The cure is to
// let indexField stay SMOOTH (the medium field continued past the wall) and decide
// straight-vs-curved GEOMETRICALLY instead. A scene with a bounded medium #defines
// IN_MEDIUM_REGION(p) as "inside my medium object"; unbounded/tapered media (global
// black hole, Luneburg) leave it at the default and are unchanged.
#ifndef IN_MEDIUM_REGION
#define IN_MEDIUM_REGION(p) true
#endif

// cheap gate for stepForward: is p inside a medium region AND is n actually != 1?
bool inMedium(vec3 p){ return IN_MEDIUM_REGION(p) && (abs(indexField(p) - 1.) > 0.001); }

// force F(r) = n·∇n = ½∇(n²), central differences of the index field
vec3 odeForce(vec3 p){
    vec2 e = vec2(ODE_GRAD_EPS, 0.);
    vec3 g = vec3(
        odeIndex(p+e.xyy) - odeIndex(p-e.xyy),
        odeIndex(p+e.yxy) - odeIndex(p-e.yxy),
        odeIndex(p+e.yyx) - odeIndex(p-e.yyx)
    ) / (2.*ODE_GRAD_EPS);
    return odeIndex(p) * g;
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
    vec3 r   = path.tv.pos;
    vec3 mom = odeIndex(r) * path.tv.dir;
    float arc = 0.;
    float startSgn = sign(sdf_Scene(path.tv));   // side we start on (inside the medium: < 0)
    vec3 force = odeForce(r);                     // reused across leapfrog steps

    for(int i = 0; i < maxMarchSteps; i++){

        float n = odeIndex(r);

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
        force = odeForce(r);         // force at the new r (this step's 2nd kick + next step's 1st)
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

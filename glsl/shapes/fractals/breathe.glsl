//----------------------------------------------------------------------------
// BREATHE — an abs-fold-rotate IFS (Connor Bell / macbooktall), carved to an
// ellipsoid so the form is compact.
//
// What makes it "breathe": the per-iteration rotation angles depend on `time`
// AND on the point's distance from the origin, so `time` does not spin the shape
// — it sweeps a SPACE-VARYING deformation through it. time is in [0,1]; 0.5 is
// the shadertoy's still pose, and it is a fine live knob.
//
// Exposes an orbit-trap DATA output (docs/shape-data.md): a material that reads
// `orbitTrapData` gets it injected, with this object's own consts baked in.
//
// NOT CENTRED ON ITS LOCAL ORIGIN: breathe_de shifts by y += 0.12 and rotates
// before it starts, so the form sits off to one side of the object's `at:` point.
// Place it by eye. (This is also why an origin-centred bounding sphere is the
// wrong shape for it — see breatheBound's absence at the bottom of the file.)
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


// --- shape constants (the shadertoy's gui preset) ---
const vec3  BR_ROT_PHASE   = vec3(0.591, 0.366, 0.5005);
const vec3  BR_ANIM_PHASE  = vec3(-0.42, 0.33, 0.0);
const vec3  BR_OFFSET      = vec3(0.66, 0.37, 0.18);
const vec3  BR_ANIM_AMP    = vec3(-0.02, 0.02, -0.06) * 3.0;
const float BR_SPACE_FREQ  = 0.06;
const float BR_START_SCALE = 1.5;
const float BR_PLACE_SCALE = 0.3;
const int   BR_ITERATIONS  = 20;

// IFS DEs overestimate; a fudge keeps the marcher on the surface (the shadertoy
// marched with understep 0.5). tune by eye, not by theory.
const float BR_FUDGE = 0.6;


//the core estimator, also filling the orbit trap (min over the iterates).
//
//br_pR, br_smin and br_smax are GONE from the port: they were bit-for-bit the
//engine's rot2, smin and smax (verified numerically), so this calls those. An
//unused br_vmax went with them.
float breathe_de(vec3 p, float time, out float trap){
    p.y += 0.12;
    p.yz = rot2(0.75)*p.yz;
    p /= BR_PLACE_SCALE;
    vec3 pp = p;

    float scale = BR_START_SCALE;
    float len   = length(p)*BR_SPACE_FREQ*2.0;
    float phase = time*PI*2.0 + len*-5.0;

    //the rotation per iteration: space-varying (len) plus breathing (time)
    vec3 anim = len + BR_ROT_PHASE*PI*2.0 + sin(phase + BR_ANIM_PHASE*PI*2.0)*BR_ANIM_AMP;

    trap = 1e20;
    for(int i = 0; i < BR_ITERATIONS; i++){
        p.xz = abs(p.zx);
        p    = p*scale - BR_OFFSET;
        p.xz = rot2(anim.x)*p.xz;
        p.yz = rot2(anim.y)*p.yz;
        p.xy = rot2(anim.z)*p.xy;
        trap = min(trap, length(p) - scale);
    }

    float d = length(p)*pow(scale, -float(BR_ITERATIONS));

    //SUBTRACT an ellipsoidal void from the middle. Note the sign: the second
    //argument is POSITIVE inside the ellipsoid, so the smax pushes d positive
    //there — the form is hollow, and what remains lives OUTSIDE the ellipsoid.
    //The original's comment called this "carve to an ellipsoid so the form is
    //compact", which reads as a clip and is backwards; the outer extent comes
    //from the IFS, not from here.
    d = smax(d, -(length(pp*vec3(1.0, 1.0, 0.75)) - 0.4), 0.1);
    return d*BR_PLACE_SCALE;
}


// p is in the form's own coordinates. `time` in [0,1] sweeps the breathing cycle.
float breatheDistance(vec3 p, float time){
    float trap;
    return BR_FUDGE*breathe_de(p, time, trap);
}


// the orbit trap (shape data): the min of |iterate| - scale over the orbit
float breatheOrbitTrapData(vec3 p, float time){
    float trap;
    breathe_de(p, time, trap);
    return trap;
}


// NO BOUND, deliberately. A first attempt at one read the ellipsoid as a CLIP
// containing the form and derived |p| <= 0.29 from it — which is exactly wrong,
// since the ellipsoid is a void SUBTRACTED from the middle (see breathe_de). That
// bound excluded almost the whole shape and rendered it invisible. The real outer
// extent is set by the IFS escape, not by any closed form here, so it would have
// to be MEASURED before it could be asserted. Left off until then: a wrong bound
// silently deletes geometry, while a missing one only costs speed.

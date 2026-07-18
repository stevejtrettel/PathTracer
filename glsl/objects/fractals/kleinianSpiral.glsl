
//-------------------------------------------------
// KLEINIAN SPIRAL LIMIT SET
//
// a sheared-and-folded Kleinian group limit set (the "spiral" variant). the
// outlier of our Kleinians (cf. kleinianSeahorse / kleinianEscape): this one has
// a shear term, an exponential separation line, wrap period sqrt(2), and NO
// sphere inversion. distance estimator + orbit trap ported from a Shadertoy in
// the Jos Leys / Knighty Kleinian lineage; the surrounding renderer (AO, fog,
// clouds, bloom, DOF) is discarded — our path tracer supplies all of that.
//
// COLORING lives in the scene: the object exposes the orbit trap via orbitTrap()
// (closest-approach values accumulated during iteration); the scene recolors in
// a setData followup. see [[shadertoy-integration]].
//-------------------------------------------------


// --- shape constants (the Shadertoy preset) ---
const float KS_R           = 1.965295;      // KleinR
const float KS_I           = 0.0182628;     // KleinI
const float KS_SHEAR       = 0.009292650721647385;
const float KS_HALF_I      = 0.0091314;
const vec2  KS_WRAP_PERIOD = vec2(1.4142);
const vec2  KS_WRAP_OFFSET = vec2(-0.7071);
const float KS_SEP_BASE    = 0.9826475;
const float KS_SEP_AMP     = 0.4951475;
const float KS_SEP_DECAY   = 7.429425;
const float KS_CLAMP_Y     = 0.4;
const float KS_CLAMP_DF    = 3.0;
const int   KS_FINAL_ITER  = 16;

// Kleinian DEs overestimate the true distance; scale the returned value so the
// raymarcher never overshoots the surface. tune by eye (the Shadertoy used 0.24).
const float KS_FUDGE       = 0.24;

//COLORING lives in the scene: the object exposes the raw orbit trap via
//orbitTrap() below, and the scene recolors in a setData followup. see
//[[shadertoy-integration]].


//the data of the spiral: frame, material, a detail knob, and an optional clip
//volume. this variant is an INFINITE tiling (period sqrt(2) in x/z, a slab in
//y); clip carves it down to a finite block so it reads as a hero object.
//  boxIterations : box-fold count (~24 preview ... ~60 to match the original).
//  clip          : carve to clipCenter +/- clipSize? false -> full landscape.
//  clipCenter/clipSize : the clipping box, in the object's local coordinates.
//all set in buildObjects (initObject does not touch them).
struct KleinianSpiral{
    Frame frame;
    Material mat;
    int   boxIterations;
    bool  clip;
    vec3  clipCenter;
    vec3  clipSize;
};


//file-local orbit trap, filled by the DE when captureTrap is true
vec4 ksTrap = vec4(1e4);


vec2 ks_wrap(vec2 p, vec2 period, vec2 offset){
    p -= offset;
    return p - period*floor(p/period) + offset;
}

//the Mobius-like generator (inversion + reflection); radius-squared passed in
void ks_transA(inout vec3 z, inout float df, float r2, float a, float b){
    float ir = 1.0/r2;
    z *= -ir;
    z.x = -b - z.x;
    z.y =  a + z.y;
    df *= ir;
}

//core distance estimator in the object's local coordinates.
//captureTrap: also accumulate the orbit trap (only needed once, at a hit).
float ks_de(vec3 z, int boxIter, bool captureTrap){
    float a = KS_R;
    float b = KS_I;
    vec3  prev  = z + vec3(1.0);
    vec3  prev2 = z - vec3(1.0);
    float df = 1.0;

    if(captureTrap) ksTrap = vec4(1e4);

    for(int i=0;i<boxIter;i++){
        //shear, wrap the (x,z) lattice, unshear
        z.x += KS_SHEAR*z.y;
        z.xz = ks_wrap(z.xz, KS_WRAP_PERIOD, KS_WRAP_OFFSET);
        z.x -= KS_SHEAR*z.y;

        //fold across the exponential separation line
        float cx  = z.x + KS_HALF_I;
        float sep = KS_SEP_BASE
                  + KS_SEP_AMP*sign(cx)*(1.0 - exp(-KS_SEP_DECAY*abs(cx)));
        if(z.y >= sep) z = vec3(-b, a, 0.0) - z;

        float r2 = dot(z,z);
        if(captureTrap) ksTrap = min(ksTrap, abs(vec4(z, r2)));
        ks_transA(z, df, r2, a, b);

        //bail out once the orbit settles into a 2-cycle
        if(dot(z-prev2, z-prev2) < 1e-12) break;
        prev2 = prev; prev = z;
    }

    float dist = 1e10;
    for(int i=0;i<KS_FINAL_ITER;i++){
        float y = min(z.y, a - z.y);                 // ShowBalls
        dist = min(dist, min(y, KS_CLAMP_Y)/max(df, KS_CLAMP_DF));
        ks_transA(z, df, dot(z,z), a, b);
    }
    float y = min(z.y, a - z.y);
    dist = min(dist, min(y, KS_CLAMP_Y)/max(df, KS_CLAMP_DF));
    return dist;
}


//exact box SDF, used to carve the infinite tiling to a finite block
float ks_sdBox(vec3 p, vec3 b){
    vec3 d = abs(p) - b;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

//the local-frame sdf (trap-free: used for marching, at/inside, and normals).
//the DE is a pure surface (never negative), so max() with the box cleanly
//truncates the fractal to the clip region rather than adding solid faces.
float sdf( vec3 p, KleinianSpiral obj ){
    float d = KS_FUDGE * ks_de(p, obj.boxIterations, false);
    if(obj.clip) d = max(d, ks_sdBox(p - obj.clipCenter, obj.clipSize));
    return d;
}


//initObject, and the world-facing sdf/at/inside
OBJECT_INIT(KleinianSpiral)
OBJECT_LOCATORS(KleinianSpiral)


//overload of normalVec: hand-written with a smaller epsilon (0.00001) than the
//standard macro (0.0001) to resolve the fractal's fine surface detail.
Vector normalVec( Vector tv, KleinianSpiral obj ){
    vec3 q = toLocal(obj.frame, tv.pos);
    const float ep = 0.00001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    vec3 dir = e.xyy*sdf( q + e.xyy*ep, obj )
             + e.yyx*sdf( q + e.yyx*ep, obj )
             + e.yxy*sdf( q + e.yxy*ep, obj )
             + e.xxx*sdf( q + e.xxx*ep, obj );
    return Vector( tv.pos, dirToWorld(obj.frame, normalize(dir)) );
}


//SHADING PROBE: the orbit trap (closest-approach values) at a local point.
//the scene calls this in its recolor followup to tint the surface however it
//likes. evaluated once per hit, so the cost is fine.
vec4 orbitTrap( vec3 p, KleinianSpiral obj ){
    ks_de(p, obj.boxIterations, true);   // fills ksTrap
    return ksTrap;
}


//standard flat-material setData (uses obj.mat); the scene overrides the color
OBJECT_SETDATA(KleinianSpiral)

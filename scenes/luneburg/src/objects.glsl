//-------------------------------------------------
// OBJECTS — a LUNEBURG LENS
// A sphere whose interior refractive index is n(r) = sqrt(2 - (r/R)^2): it
// focuses parallel rays to the point on the OPPOSITE surface. The boundary is
// transparent (n = 1 there, so no refraction at the edge) — all the bending is
// the curved geodesic through the graded interior, integrated by the ODE marcher
// (glsl/tracer/6Trace/odeMarch.glsl).
//
// The lens boundary is registered BOTH analytically (trace, for the exact entry
// hit) AND as an SDF (so odeMarch can detect the boundary from inside via the
// sdf_Scene sign change). The analytic entry avoids a marcher artifact at head-on
// incidence.
//-------------------------------------------------

Sphere lens;

const vec3  LENS_C = vec3(0., 3., 0.);   // lens center — MUST match indexField() below
const float LENS_R = 3.;                 // lens radius


void buildObjects(){
    lens.frame  = makeFrame(LENS_C);
    lens.radius = LENS_R;
    // transparent boundary: IOR 1 (no bend at the edge) + always transmit (no Fresnel).
    lens.mat = makeGlass(vec3(0.), 1.0, 1.0);
}


// the graded index n(r) INSIDE the lens (Luneburg), 1 outside. This is the field
// the ODE marcher integrates; inMedium() (n != 1) is true only inside the lens.
// The Luneburg index n(r) = sqrt(2 - (r/R)^2). SMOOTH and continued past the rim
// (it stays real out to r = R*sqrt(2)); confinement is geometric via IN_MEDIUM_REGION
// below, NOT a clamp to 1. A clamp would leave a slope KINK at the rim that odeForce's
// central difference smears — see the bounded-medium contract in odeMarch.glsl.
#define SCENE_INDEX_FIELD   //scene hook: replaces the engine's n==1 default (docs/material-fields.md)
float indexField(vec3 p){
    float rn = length(p - LENS_C) / LENS_R;   // normalized radius, 0 at center, 1 at rim
    return sqrt(max(2. - rn*rn, 0.));
}

// the ray curves only while inside the lens sphere. The rim is n = 1, so exiting is
// seamless (IOR-1 boundary, no refraction) — the graded interior does all the work.
bool inLens(vec3 p){ return inside(Vector(p, vec3(0.,0.,1.)), lens); }
#define IN_MEDIUM_REGION(p) inLens(p)


//-------------------------------------------------
// Finding the Objects
//-------------------------------------------------

// analytic entry hit (exact front surface, no marcher artifact)
float trace_Objects( Vector tv ){
    return maxDist;
}

// SDF too, so odeMarch sees the boundary as an sdf_Scene sign change from inside
float sdf_Objects( Vector tv ){
    float dist=maxDist;
    dist = min(dist, sdf(tv, lens));
    return dist;
}

bool inside_Object( Vector tv ){
    return inside(tv, lens);
}

void setData_Objects(inout Path path){
    setData(path, lens);
}

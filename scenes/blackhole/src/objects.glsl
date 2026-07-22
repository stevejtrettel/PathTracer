//-------------------------------------------------
// OBJECTS — a GLOBAL BLACK HOLE (Majumdar-Papapetrou analog)
//
// The whole scene is a curved-light medium: the effective refractive index
//     n(r) = U^2,   U = 1 + M/r
// fills ALL of space (M = the `mass` knob, r = distance to the hole). This is the
// optical index of a null geodesic in the extremal MP metric (Fermat on the null
// condition gives dt = U^2 dl, so n = U^2). It is asymptotically flat: n -> 1 as
// r -> infinity, exactly what odeMarch requires.
//
// There is NO geometry. Every ray is inside the medium at the camera (n > 1
// everywhere finite), so stepForward hands straight to odeMarch (glsl/tracer/
// 6Trace/odeMarch.glsl) and the ray curves the whole way. Two fates:
//   - it falls in: n -> infinity past the capture radius (odeIndex > ODE_CAPTURE
//     => r < M/6), odeMarch kills the ray -> it renders BLACK. That disk is the
//     shadow (pure physics, not a drawn sphere).
//   - it escapes: sampled against the image sky in its BENT exit direction -> the
//     background warps into an Einstein ring.
//
// mass = 0 turns the field off (n == 1 everywhere) -> plain straight sky, a clean
// A/B baseline.
//-------------------------------------------------

const vec3 BH_C = vec3(0.);   // hole center


void buildObjects(){}


//-------------------------------------------------
// Finding the Objects — none (the shadow is the medium's capture, not geometry)
//-------------------------------------------------

float trace_Objects( Vector tv ){ return maxDist; }

float sdf_Objects( Vector tv ){ return maxDist; }

bool inside_Object( Vector tv ){ return false; }

void setData_Objects(inout Path path){}


//-------------------------------------------------
// The curved-light medium: n(r) = (1 + M/r)^2, everywhere.
//-------------------------------------------------

float indexField(vec3 p){
    float r = max(length(p - BH_C), 1e-4);   // floor r: r=0 is the singularity (NaN guard, not physics)
    float U = 1. + mass / r;
    return U*U;
}

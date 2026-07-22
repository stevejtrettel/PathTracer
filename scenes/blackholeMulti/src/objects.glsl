//-------------------------------------------------
// OBJECTS — MULTIPLE BLACK HOLES (Majumdar-Papapetrou)
//
// Extremal charged black holes (charge = mass) sit in STATIC EQUILIBRIUM — their
// electrostatic repulsion exactly cancels their gravity — so any number of them can
// coexist at rest. That is what makes a multi-hole scene physical. The optical index
// is still n = U^2, now with U summed over every hole:
//     U(r) = 1 + sum_i  M_i / |r - r_i|
//
// Default config: an equilateral triangle of three equal holes in the z = 0 plane.
// Change N_HOLES / HOLE_POS for a binary (2) or any arrangement — the physics and the
// rest of the pipeline are identical.
//
// Same machinery as scenes/blackhole: a GLOBAL medium (every ray curves), pure capture
// near any hole -> black shadow, escape -> the lensed image sky. mass = 0 turns them
// all off (flat, undistorted sky) — a clean A/B baseline.
//-------------------------------------------------

const int  N_HOLES = 3;
const vec3 HOLE_POS[3] = vec3[3](
    vec3( 0.00,  2.50, 0.0),
    vec3(-2.17, -1.25, 0.0),
    vec3( 2.17, -1.25, 0.0)
);


void buildObjects(){}


//-------------------------------------------------
// Finding the Objects — none (the shadows are the medium's capture, not geometry)
//-------------------------------------------------

float trace_Objects( Vector tv ){ return maxDist; }

float sdf_Objects( Vector tv ){ return maxDist; }

bool inside_Object( Vector tv ){ return false; }

void setData_Objects(inout Path path){}


//-------------------------------------------------
// The curved-light medium: MP potential U = 1 + sum M_i/r_i, optical index n = U^2.
//-------------------------------------------------

float indexField(vec3 p){
    float U = 1.;
    for(int i = 0; i < N_HOLES; i++){
        float r = max(length(p - HOLE_POS[i]), 1e-4);   // floor r at each singularity (NaN guard)
        U += mass / r;
    }
    return U*U;
}

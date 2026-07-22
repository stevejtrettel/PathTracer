//-------------------------------------------------
// OBJECTS — a BLACK HOLE INSIDE A GLASS CUBE (transformation-optics analog)
//
// A real dielectric block sitting in ordinary flat Euclidean space, whose
// refractive index follows the black-hole profile
//     n(r) = (1 + M/r)^2   INSIDE the cube,   n = 1 outside.
// Light through it lenses exactly like light near a black hole — but this is a
// genuine physical object with a surface, not a curved spacetime.
//
// The key to making it rigorous (a real piece of glass, not a magic box): the
// cube wall refracts by the medium's OWN index just inside it,
//     n_wall = bhIndex(hitPos),
// set per-hit in setData below. So Snell's law at the surface and the eikonal
// (odeMarch) in the interior are two faces of ONE field n(p). The wall's `n_wall`
// varies across the faces (corners are farther from the hole -> smaller n_wall).
//
// A ray's life: straight outside -> refract IN at the glass (Snell, ratio 1/n_wall)
// -> odeMarch curves it through the interior -> falls in (capture -> black, seen
// through the glass) OR reaches the wall -> refract OUT (or TIR, trapping it). At
// mass = 0 the index is 1 everywhere -> the cube is invisible and the background
// is undistorted: a clean off-state.
//-------------------------------------------------

const vec3 BH_C = vec3(0.);   // hole center = cube center

Box cube;


void buildObjects(){
    cube.frame   = makeFrame(BH_C);
    cube.sides   = vec3(1.8);
    cube.rounded = 0.;
    // IOR here is a placeholder: setData_Objects overrides it per-hit with n_wall.
    // refractivity 1.0 = always transmit (TIR still handled inside vRefract).
    cube.mat = makeGlass(vec3(0.), 1.5, 1.0);
}


// the black-hole optical index n(r) = (1 + M/r)^2  (M = the `mass` knob)
float bhIndex(vec3 p){
    float r = max(length(p - BH_C), 1e-4);   // floor r: r=0 is the singularity (NaN guard)
    float U = 1. + mass / r;
    return U*U;
}


// The curved-light medium. NOTE: this is SMOOTH everywhere (= bhIndex, not clamped
// to the cube). Confinement is geometric, via IN_MEDIUM_REGION below — NOT via a
// jump in the index. A discontinuous index would make odeMarch's central-difference
// ∇n explode at the wall (banding); keeping it smooth avoids that, and the ray only
// ever curves while IN_MEDIUM_REGION says it is inside the glass.
#define SCENE_INDEX_FIELD   //scene hook: replaces the engine's n==1 default (docs/material-fields.md)
float indexField(vec3 p){
    return bhIndex(p);
}

// geometric confinement: the ray curves only while inside the cube (the glass
// surface handles the actual index jump, via refraction with n_wall in setData).
bool inCube(vec3 p){ return inside(Vector(p, vec3(0.,0.,1.)), cube); }
#define IN_MEDIUM_REGION(p) inCube(p)


//-------------------------------------------------
// Finding the Objects
//   - straight camera rays hit the cube via the raymarch (sdf_Objects);
//   - odeMarch (inside the medium) also reads sdf_Scene to detect the wall as a
//     sign change, so the cube MUST be in sdf_Objects (not an analytic-only trace).
//-------------------------------------------------

float trace_Objects( Vector tv ){ return maxDist; }

float sdf_Objects( Vector tv ){ return sdf(tv, cube); }

bool inside_Object( Vector tv ){ return inside(tv, cube); }


//-------------------------------------------------
// Setting the Objects Data — the DYNAMIC-IOR WALL
//-------------------------------------------------
void setData_Objects(inout Path path){
    if( at(path.tv, cube) ){
        Vector normal = normalVec(path.tv, cube);
        bool side = inside(path.tv, cube);

        // the wall refracts by the medium's own index just inside it, so the same
        // field n(p) governs the surface (Snell) and the interior (eikonal).
        Material m = cube.mat;
        m.interior.ior = bhIndex(path.tv.pos);   // n_wall; setObjectInAir -> 1/n_wall in, n_wall out
        setObjectInAir(path.dat, side, normal, m);
    }
}

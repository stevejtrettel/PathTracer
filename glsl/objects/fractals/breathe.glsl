
//-------------------------------------------------
// BREATHE
//
// an abs-fold-rotate IFS (Connor Bell / macbooktall), carved by an ellipsoid,
// whose per-iteration rotations depend on a `time` parameter AND on the point's
// distance from the origin -- so `time` sweeps a space-varying "breathing"
// deformation (the shadertoy holds it at time = 0.5). here `time` is a struct
// field, driven live from a scratch knob in the scene. see [[shadertoy-integration]].
//
// COLORING lives in the scene: the object exposes orbitTrap() below; by default
// the scene just gives it an opaque material. write the sdf, set materials yourself.
//-------------------------------------------------


// --- shape constants (the shadertoy's gui preset) ---
const vec3  BR_ROT_PHASE  = vec3(0.591, 0.366, 0.5005);
const vec3  BR_ANIM_PHASE = vec3(-0.42, 0.33, 0.0);
const vec3  BR_OFFSET     = vec3(0.66, 0.37, 0.18);
const vec3  BR_ANIM_AMP   = vec3(-0.02, 0.02, -0.06) * 3.0;
const float BR_SPACE_FREQ = 0.06;
const float BR_START_SCALE = 1.5;
const float BR_PLACE_SCALE = 0.3;    // p /= s
const int   BR_ITERATIONS = 20;

// IFS DEs overestimate; a fudge keeps the marcher on the surface (the shadertoy
// marched with understep 0.5). tune by eye.
const float BR_FUDGE = 0.6;


//the data of the breathing form: frame, material, and the deform phase.
//time in [0,1] sweeps the breathing cycle (0.5 = the shadertoy's still pose).
struct Breathe{
    Frame frame;
    Material mat;
    float time;
};


void br_pR(inout vec2 p, float a){
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float br_vmax(vec3 v){ return max(max(v.x, v.y), v.z); }

float br_smin(float a, float b, float k){
    float f = clamp(0.5 + 0.5*((a-b)/k), 0.0, 1.0);
    return (1.0-f)*a + f*b - f*(1.0-f)*k;
}
float br_smax(float a, float b, float k){ return -br_smin(-a, -b, k); }


//core distance estimator; also returns the orbit trap (min over iterates)
float br_de(vec3 p, float time, out float trap){
    p.y += 0.12;
    br_pR(p.yz, 0.75);
    p /= BR_PLACE_SCALE;
    vec3 pp = p;

    float scale = BR_START_SCALE;
    float len = length(p) * BR_SPACE_FREQ * 2.0;
    float phase = time * PI * 2.0 + len * -5.0;

    //per-iteration rotation: space-varying (len) + breathing (time)
    vec3 anim = len + BR_ROT_PHASE*PI*2.0 + sin(phase + BR_ANIM_PHASE*PI*2.0) * BR_ANIM_AMP;

    trap = 1e20;
    for(int i=0;i<BR_ITERATIONS;i++){
        p.xz = abs(p.zx);
        p = p*scale - BR_OFFSET;
        br_pR(p.xz, anim.x);
        br_pR(p.yz, anim.y);
        br_pR(p.xy, anim.z);
        trap = min(trap, length(p) - scale);
    }

    float d = length(p) * pow(scale, -float(BR_ITERATIONS));

    //carve to an ellipsoid so the form is compact
    p = pp;
    d = br_smax(d, -(length(p*vec3(1.0,1.0,0.75)) - 0.4), 0.1);
    d *= BR_PLACE_SCALE;
    return d;
}


//the local-frame sdf (used for marching, at/inside, and normals)
float sdf( vec3 p, Breathe obj ){
    float trap;
    return BR_FUDGE * br_de(p, obj.time, trap);
}

OBJECT_INIT(Breathe)
OBJECT_LOCATORS(Breathe)
OBJECT_NORMAL_FD(Breathe)


//SHADING PROBE: the orbit trap at a local point (scene may map it to color)
float orbitTrap( vec3 p, Breathe obj ){
    float trap;
    br_de(p, obj.time, trap);
    return trap;
}


//standard flat-material setData (uses obj.mat)
OBJECT_SETDATA(Breathe)

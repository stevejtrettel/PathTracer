
//-------------------------------------------------
// KLEINIAN SEAHORSE
//
// the "seahorse" Kleinian limit set (Jos Leys & Knighty, shadertoy XlVXzh):
// 80-iteration-capable, sphere-inversion distance correction ENABLED, and an
// orbit trap tracked for coloring. serves TWO scenes via its offset/iterations
// fields: `kleinianLimit` (offset 0, glass, the compact limit set) and
// `kleinianSeahorse` (offset placement, dielectric + spectrum orbit-trap color).
//
// COLORING lives in the scene: the object exposes orbitTrap() below; the scene
// recolors in a setData followup (here, the shadertoy's spectrum palette). see
// [[shadertoy-integration]].
//-------------------------------------------------


// --- shape constants (the seahorse preset) ---
const float KSH_R      = 1.89;                    // KleinR = 1.5 + 0.39
const float KSH_I      = 0.1;                     // KleinI = 0.55*2 - 1
const vec2  KSH_BOX    = vec2(-0.40445, 0.34) * 2.0;
const vec3  KSH_INV_C  = vec3(0.0, 1.0, 1.0);     // sphere-inversion center
const float KSH_RAD    = 0.8;                     // inversion radius

// the shadertoy marches with understep 0.5; a fudge keeps our marcher off the
// thin surface. tune by eye.
const float KSH_FUDGE  = 0.55;


//the data of the seahorse: frame, material, an iteration knob (~30 preview ...
//~80 to match the original), and a local-space offset that selects which slice
//of the fractal sits at the origin (the shadertoy's map() used (-.86,1.16,1.76);
//0 gives the compact limit set used by kleinianLimit). set in buildObjects.
struct KleinianSeahorse{
    Frame frame;
    Material mat;
    int  iterations;
    vec3 offset;
};


vec2 ksh_wrap(vec2 x, vec2 a, vec2 s){
    x -= s;
    return (x - a*floor(x/a)) + s;
}

//the Mobius-like generator (inversion + reflection)
void ksh_transA(inout vec3 z, inout float df, float a, float b){
    float ir = 1.0/dot(z,z);
    z *= -ir;
    z.x = -b - z.x;
    z.y =  a + z.y;
    df *= ir;
}

//the seahorse distance estimator; also returns the orbit trap (min over iterates)
float ksh_de(vec3 z, out vec3 trap, int iter){
    float a = KSH_R;
    float b = KSH_I;
    vec3 lz = z + vec3(1.0), llz = z + vec3(-1.0);

    //sphere inversion
    z = z - KSH_INV_C;
    float d  = length(z);
    float d2 = d*d;
    z = (KSH_RAD*KSH_RAD/d2)*z + KSH_INV_C;

    trap = vec3(1e20);
    float DE = 1e12;
    float DF = 1.0;
    float f = sign(b) * 0.45;

    for(int i=0;i<iter;i++){
        z.x += b/a*z.y;
        z.xz = ksh_wrap(z.xz, KSH_BOX*2.0, -KSH_BOX);
        z.x -= b/a*z.y;

        //fold across the exponential separation line
        if(z.y >= a*0.5 + f*(2.0*a-1.95)/4.0 * sign(z.x + b*0.5)
                        * (1.0 - exp(-(7.2-(1.95-a)*15.0)*abs(z.x + b*0.5)))){
            z = vec3(-b, a, 0.0) - z;
        }

        ksh_transA(z, DF, a, b);

        if(dot(z-llz, z-llz) < 1e-5) break;   //bail on a 2-cycle
        llz = lz; lz = z;
        trap = min(trap, z);
    }

    float y = min(z.y, a - z.y);
    DE = min(DE, min(y, 0.3)/max(DF, 2.0));
    DE = DE * d2 / (KSH_RAD + d*DE);          //sphere-inversion correction
    return DE;
}


//the local-frame sdf (used for marching, at/inside, and normals)
float sdf( vec3 p, KleinianSeahorse obj ){
    vec3 trap;
    return KSH_FUDGE * ksh_de(p + obj.offset, trap, obj.iterations);
}

OBJECT_INIT(KleinianSeahorse)
OBJECT_LOCATORS(KleinianSeahorse)


//small-epsilon normalVec for the fractal's fine surface detail
Vector normalVec( Vector tv, KleinianSeahorse obj ){
    vec3 q = toLocal(obj.frame, tv.pos);
    const float ep = 0.00001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    vec3 dir = e.xyy*sdf( q + e.xyy*ep, obj )
             + e.yyx*sdf( q + e.yyx*ep, obj )
             + e.yxy*sdf( q + e.yxy*ep, obj )
             + e.xxx*sdf( q + e.xxx*ep, obj );
    return Vector( tv.pos, dirToWorld(obj.frame, normalize(dir)) );
}


//SHADING PROBE: the orbit trap at a local point (scene maps it to color)
vec3 orbitTrap( vec3 p, KleinianSeahorse obj ){
    vec3 trap;
    ksh_de(p + obj.offset, trap, obj.iterations);
    return trap;
}


//standard flat-material setData (uses obj.mat); the scene overrides the color
OBJECT_SETDATA(KleinianSeahorse)

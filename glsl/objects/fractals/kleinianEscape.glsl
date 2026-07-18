
//-------------------------------------------------
// KLEINIAN ESCAPE  (parameter explorer)
//
// a Jos Leys / Knighty Kleinian DE in the "standard box" variant (box_size 1,
// f = sign(b), sphere-inversion correction; cf. kleinianSeahorse, the seahorse
// box) -- but with KleinR and KleinI exposed as LIVE PARAMETERS. that's the
// whole point: sweep (R, I) and watch the limit set morph through the parameter
// space of Kleinian groups. from shadertoy "kleinian escape" (Muhammad Ahmad).
//
// R and I are struct fields, driven from named GUI params in the scene. COLORING
// lives in the scene: the object exposes a scalar log-radius orbit trap via
// orbitTrap(). see [[shadertoy-integration]].
//-------------------------------------------------


// --- placement + inversion (the shadertoy preset) ---
const vec2  KE_BOX    = vec2(1.0, 1.0);              // wrap box_size_x/z
const vec4  KE_INV    = vec4(1.0, 0.96, 0.0, 0.8);  // inversion sphere: center.xyz, radius.w
const float KE_SIZE   = 1.1;                         // fractal_size
const vec3  KE_OFFSET = vec3(0.9, 0.8, 0.0);         // placement offset

// the shadertoy marches with understep 0.8; a fudge keeps our marcher on the
// thin surface. tune by eye.
const float KE_FUDGE  = 0.8;


//the data of the explorer: frame, material, the two Kleinian parameters
//(R ~ 1.5-2.2, I ~ 0-1.5), and an iteration count. set in buildObjects.
struct KleinianEscape{
    Frame frame;
    Material mat;
    float kleinR;
    float kleinI;
    int   iterations;
};


vec2 ke_wrap(vec2 x, vec2 a, vec2 s){
    x -= s;
    return (x - a*floor(x/a)) + s;
}

//the Kleinian distance estimator; R,I are parameters. also returns the orbit
//trap (min of log|z| over the iterates).
float ke_de(vec3 z, float R, float I, int iter, out float trap){
    z /= KE_SIZE;
    z += KE_OFFSET;

    vec3 lz = z + vec3(1.0), llz = z + vec3(-1.0);

    //sphere inversion
    z -= KE_INV.xyz;
    float d  = length(z);
    float d2 = d*d;
    z = (KE_INV.w*KE_INV.w/d2) * z;
    z += KE_INV.xyz;

    float DF = 1.0;
    float DE = 1e6;
    float a = R, b = I;
    float f = sign(b);
    trap = 1e4;

    for(int i=0;i<iter;i++){
        z.x += b/a*z.y;
        z.xz = ke_wrap(z.xz, 2.0*KE_BOX, -KE_BOX);
        z.x -= b/a*z.y;

        //fold across the exponential separation line
        if(z.y >= a*0.5 + f*(2.0*a-1.95)/4.0 * sign(z.x + b*0.5)
                        * (1.0 - exp(-(7.2-(1.95-a)*15.0)*abs(z.x + b*0.5)))){
            z = vec3(-b, a, 0.0) - z;
        }

        //Mobius generator
        float ir = 1.0/dot(z,z);
        z *= -ir;
        z.x = -b - z.x;
        z.y =  a + z.y;
        DF *= ir;

        trap = min(trap, log(length(z)));

        if(dot(z-llz, z-llz) < 1e-5) break;   //bail on a 2-cycle
        llz = lz; lz = z;
    }

    float y = min(z.y, a - z.y);
    DE = min(DE, min(y, 0.24)/max(DF, 1.0));
    DE = DE * d2 / (KE_INV.w + d*DE);          //sphere-inversion correction
    return KE_SIZE * DE;
}


//the local-frame sdf (used for marching, at/inside, and normals)
float sdf( vec3 p, KleinianEscape obj ){
    float trap;
    return KE_FUDGE * ke_de(p, obj.kleinR, obj.kleinI, obj.iterations, trap);
}

OBJECT_INIT(KleinianEscape)
OBJECT_LOCATORS(KleinianEscape)


//small-epsilon normalVec for the fractal's fine surface detail
Vector normalVec( Vector tv, KleinianEscape obj ){
    vec3 q = toLocal(obj.frame, tv.pos);
    const float ep = 0.00001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    vec3 dir = e.xyy*sdf( q + e.xyy*ep, obj )
             + e.yyx*sdf( q + e.yyx*ep, obj )
             + e.yxy*sdf( q + e.yxy*ep, obj )
             + e.xxx*sdf( q + e.xxx*ep, obj );
    return Vector( tv.pos, dirToWorld(obj.frame, normalize(dir)) );
}


//SHADING PROBE: the scalar log-radius orbit trap (scene maps it to color)
float orbitTrap( vec3 p, KleinianEscape obj ){
    float trap;
    ke_de(p, obj.kleinR, obj.kleinI, obj.iterations, trap);
    return trap;
}


//standard flat-material setData (uses obj.mat); the scene overrides the color
OBJECT_SETDATA(KleinianEscape)

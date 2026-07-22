//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/kleinianSeahorse.glsl

//set the names of objects contained in the scene
KleinianSeahorse klein;

void buildObjects(){

    klein.frame = makeFrame(vec3(0,0,0));

    //iteration knob (named GUI param): ~30 snappy preview ... ~80 matches the original
    klein.iterations = detail;

    //places the fractal to match the shadertoy's framing
    klein.offset = vec3(-0.86, 1.16, 1.76);

    //standard opaque dielectric; color comes from the orbit-trap followup below
    klein.mat = makeDielectric(vec3(0.6), 0.15, 0.1);

}


//-------------------------------------------------
// COLOR (scene-owned): the shadertoy's spectrum orbit-trap coloring
//-------------------------------------------------

//IQ cosine palette
vec3 ksh_pal(float t, vec3 a, vec3 b, vec3 c, vec3 d){ return a + b*cos(6.28318*(c*t+d)); }
//warm varied palette — as colorful as the original orbit-trap, but the hues are red,
//orange, yellow and sage instead of the full rainbow. c=1 gives a full cycle (the
//variability); the small blue amplitude/base keeps blue LOW so the cycle stays in the
//warm->green range (red -> orange -> yellow -> sage) and never goes blue/cyan. The
//red/green phase offset (d.g = 0.17) is what carries it through those hues.
vec3 ksh_spectrum(float n){
    //a_b=0.30 lifts the blue floor and b_g=0.36 tames the green amplitude, so the
    //green reads as a muted SAGE (desaturated) rather than a saturated lime.
    return ksh_pal(n, vec3(0.5,0.48,0.30), vec3(0.45,0.36,0.10), vec3(1.0), vec3(0.0,0.17,0.0));
}


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    return dist;
}

float sdf_Objects( Vector tv ){
    float dist=maxDist;
    dist=min( dist, sdf(tv, klein) );
    return dist;
}


//used in subsurface scattering: keep scattering while inside this object
bool inside_Object( Vector tv ){
    return inside(tv,klein);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, klein);                            // geometry + flat base material
    if( at(path.tv, klein) ){                        // orbit-trap recolor followup
        vec3 p = toLocal(klein.frame, path.tv.pos);
        vec3 trap = orbitTrap(p, klein);
        vec3 base = ksh_spectrum(clamp(trap.y*2.0, 0.0, 1.0));
        path.dat.surfDiffuse = base;                 // warm muted albedo, no self-glow — lit by the scene light
    }
}

//no curved-light medium in this scene (n === 1 everywhere: straight transport).
//A medium scene overrides this with its effective refractive index field.
float indexField(vec3 p){ return 1.; }

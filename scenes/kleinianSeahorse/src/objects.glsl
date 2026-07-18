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
vec3 ksh_spectrum(float n){
    return ksh_pal(n, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0,0.33,0.67));
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
        float boost = mix(1.0, 3.0, smoothstep(0.0, 0.4, trap.y));
        path.dat.surfDiffuse = base;                 // colored albedo (safe, in [0,1])
        path.dat.surfEmit    = base * (boost - 1.0); // the >1 glow as emission
    }
}

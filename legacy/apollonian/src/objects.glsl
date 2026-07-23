//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/apollonian.glsl

//set the names of objects contained in the scene
Apollonian gasket;

void buildObjects(){

    gasket.frame = makeFrame(vec3(0,0,0));

    //the MORPH knob (named GUI param): inversion radius squared r2.
    //~1.2 is the shadertoy's still preset; sweep for the breathing/morph.
    gasket.r2 = morph;

    //standard opaque material; color comes from the orbit-trap followup below
    gasket.mat = makeGloss(vec3(0.7), 0.15, 0.1);

}


//-------------------------------------------------
// COLOR (scene-owned): the shadertoy's orbit-trap coloring
//-------------------------------------------------

vec3 apolloColor( vec3 p ){
    vec4 orb = orbitTrap(p, gasket);
    float c0 = pow(clamp(orb.w, 0.0, 1.0), 2.0);
    vec3 col1 = mix(vec3(1.0), vec3(0.4, 0.0, 0.0), clamp(3.5*orb.y, 0.0, 1.0));
    vec3 col0 = c0 * vec3(0.0, 1.0, 1.0);
    return clamp(col1 - col0, 0.0, 1.0);   //white/red base with cyan accents removed
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
    dist=min( dist, sdf(tv, gasket) );
    return dist;
}


//used in subsurface scattering: keep scattering while inside this object
bool inside_Object( Vector tv ){
    return inside(tv,gasket);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, gasket);                          // geometry + flat base material
    if( at(path.tv, gasket) ){                      // orbit-trap recolor followup
        vec3 p = toLocal(gasket.frame, path.tv.pos);
        path.dat.surfDiffuse = apolloColor(p);
    }
}

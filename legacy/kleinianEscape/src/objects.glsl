//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/kleinianEscape.glsl

//set the names of objects contained in the scene
KleinianEscape klein;

void buildObjects(){

    klein.frame = makeFrame(vec3(0,0,0));

    //THE PARAMETER EXPLORER: sweep these (named GUI knobs) to morph the set.
    klein.kleinR     = kleinR;      // named params, declared in settings.js
    klein.kleinI     = kleinI;
    klein.iterations = detail;

    //standard opaque material; color comes from the orbit-trap followup below
    klein.mat = makeGloss(vec3(0.75), 0.15, 0.1);

}


//-------------------------------------------------
// COLOR (scene-owned): the shadertoy's 2-color orbit-trap palette
//-------------------------------------------------

const vec3 KE_COL_1 = vec3(1.0);                        // low trap -> white
const vec3 KE_COL_2 = vec3(0.8) * vec3(1.1, 0.7, 0.3);  // high trap -> warm orange

vec3 escapeColor( vec3 p ){
    float trap = orbitTrap(p, klein);
    return clamp(mix(KE_COL_1, KE_COL_2, trap), 0.0, 1.0);
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
        path.dat.surfDiffuse = escapeColor(p);
    }
}

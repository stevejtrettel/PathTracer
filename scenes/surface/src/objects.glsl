//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list!
#include ../../../glsl/objects/varieties/formulas/misc.glsl

T surface_Eqn(T x, T y, T z){
    return gyroid(x,y,z);
}

float surface_bBox(vec3 pos){
    return length(pos)-2.;
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/surface.glsl

//set the names of objects contained in the scene
Surface surf;

void buildObjects(){

    vec3 tealScatter = vec3(0.25,0.65,0.7);

    surf.frame = makeFrame(vec3(-2,1.5,-2));
    surf.scale=10.;
    surf.mat=makeDielectric(tealScatter,0.5,0.2);

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
    dist=min( dist, sdf(tv, surf) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, surf);
}

//no curved-light medium in this scene (n === 1 everywhere: straight transport).
//A medium scene overrides this with its effective refractive index field.
float indexField(vec3 p){ return 1.; }

//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/hyperbolicHoneycomb2.glsl

//set the names of objects contained in the scene
HyperbolicHoneycomb2 honey;

void buildObjects(){

    //local origin at the world origin: local coords == render (half-space) coords
    honey.frame = makeFrame(vec3(0,0,0));

    //fold-depth knob, driven live by scratch1 (~30 preview ... ~180 full depth)
    honey.foldIterations = int(mix(30., 180., scratch1));

    //material supplies roughness/specular; per-cell diffuse comes from the palette
    honey.mat = makeDielectric(vec3(0.5), 0.2, 0.12);

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
    dist=min( dist, sdf(tv, honey) );
    return dist;
}



//used in subsurface scattering: keep scattering while inside this object
bool inside_Object( Vector tv ){
    return inside(tv,honey);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, honey);
}

//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/hyperbolicHoneycomb.glsl

//set the names of objects contained in the scene
HyperbolicHoneycomb honey;

void buildObjects(){

    //the honeycomb lives in the z>0 half-space; place its local origin at the
    //world origin so local coords == render (upper-half-space) coords
    honey.frame = makeFrame(vec3(0,0,0));

    //fold-depth knob, driven live by scratch1: how deep toward the ideal
    //boundary the honeycomb resolves (~20 snappy preview ... ~200 for depth)
    honey.foldIterations = int(mix(20., 200., scratch1));

    //material supplies roughness/specular; the per-cell diffuse color comes
    //from the palette in hyperbolicHoneycomb.glsl (set via the custom setData)
    honey.mat = makeDielectric(vec3(0.5), 0.2, 0.15);

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

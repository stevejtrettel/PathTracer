//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/kleinianSpiral.glsl

//set the names of objects contained in the scene
KleinianSpiral klein;

void buildObjects(){

    klein.frame = makeFrame(vec3(0,0,-3));

    //detail knob: box-fold iterations, driven live by scratch1
    //(~16 snappy preview ... ~60 matches the original resolution)
    klein.boxIterations = int(mix(16., 60., scratch1));

    //PRESENTATION: carve the infinite tiling down to a finite block.
    //set clip=false for the full spiral-landscape view instead (then reframe
    //the camera low and looking across the slab).
    klein.clip       = true;
    klein.clipCenter = vec3(0.0, 0.98, 0.0);   //slab is y in [0, ~1.96]
    klein.clipSize   = vec3(1.4, 0.9, 1.4);    //half-extents (local units)

    //simple opaque dielectric; diffuseColor is the BASE tint the orbit trap
    //modulates (see ks_trapColor in kleinianSpiral.glsl)
    vec3 base = vec3(0.55, 0.5, 0.6);
    klein.mat = makeDielectric(base, 0.2, 0.05);

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
    setData(path, klein);
}

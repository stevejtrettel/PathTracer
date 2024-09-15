//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/apolonianGasket.glsl
//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Gasket gasket;

void buildObjects(){


    vec3 color;
    float specularity, roughness;

    //----------- GASKET -------------------------
    gasket.center=vec3(0,1.8,0);
    gasket.radius=1.;

    color= vec3(0.4,0.3,0.2);
    specularity=0.5;
    roughness=0.01;
    // gasket.mat= makeMetal(color,specularity,roughness);
    // makeDielectric(color,specularity,roughness);
    //  gasket.mat.surfaceEmit=0.1*vec3(0.02,0.02,0.04);
    gasket.mat=makeGlass(vec3(1)-0.9*vec3(0,0.65,0.35),1.2,0.8);


}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------
bool render_Objects=true;


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

//copy as many lines of dist=min(dist, trace(tv, NEW_OBJ)), one for each object to be traced
float trace_Objects( Vector tv ){
    float dist=maxDist;
    return dist;
}

//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, gasket) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, gasket);
}





//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/bottleTorus.glsl
#include ../../../glsl/objects/multiMaterial/bottleTorusClearcoat.glsl

//set the names of objects contained in the scene
BottleTorus donut;
BottleTorusClearcoat layerDonut;

void buildObjects(){


    //----------- TORUS BOTTLE -------------------------
    donut.frame=makeFrame(vec3(0,1.,0));
    donut.inner=1.2;
    donut.outer=2.;
    donut.height=2.5;
    donut.base=0.3;
    donut.flare=6.;
    donut.smoothing = 2.75;
    donut.thickness = 0.08;


    donut.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.6,0.99);
    //alternate material experiments:
    //donut.mat.diffuseColor=0.6*(vec3(1.)-4.*vec3(0.2,0.03,0.0));
    //donut.mat.absorbColor= 4.*0.01*vec3(0.2,0.04,0.0);
    //donut.mat.emitColor= scratch1*vec3(0.5,0.1,0.0);
    //donut.mat.surfaceEmit=0.5*scratch2*vec3(0.3,0.3,0.0);
    //donut.mat.specularChance=0.05;
    //donut.mat.specularColor=vec3(1.)-donut.mat.absorbColor/3.;
    donut.mat.refractionChance=0.0;
    donut.mat.subSurface=true;
    donut.mat.meanFreePath=0.02;
    donut.mat.isotropicScatter=sssScatter;
    donut.mat.roughness=0.0;






    layerDonut.inner=donut;
    layerDonut.outer=donut;

    layerDonut.outer.thickness=0.3;
    layerDonut.outer.mat=makeGlass(vec3(0.),1.4);
    layerDonut.outer.mat.specularChance=0.05;

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
    dist=min( dist, sdf(tv, layerDonut) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,layerDonut);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, layerDonut);
}

//no curved-light medium in this scene (n === 1 everywhere: straight transport).
//A medium scene overrides this with its effective refractive index field.
float indexField(vec3 p){ return 1.; }

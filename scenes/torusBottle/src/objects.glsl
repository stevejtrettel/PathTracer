//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../src/glsl/objects/compound/torusBottle.glsl
#include ../../../src/glsl/objects/multiMaterial/coatedTorusBottle.glsl

//set the names of objects contained in the scene
TorusBottle donut;
CoatedTorusBottle layerDonut;

void buildObjects(){


    //----------- TORUS BOTTLE -------------------------
    donut.center=vec3(0,1.,0);
    donut.inner=1.2;
    donut.outer=2.;
    donut.height=2.5;
    donut.base=0.3;
    donut.flare=6.;
    donut.smoothing = 2.75;
    donut.thickness = 0.08;


    donut.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.6,0.99);
    //donut.mat.diffuseColor=0.6*(vec3(1.)-4.*vec3(0.2,0.03,0.0));
    //donut.mat.absorbColor= 4.*0.01*vec3(0.2,0.04,0.0);
    //donut.mat.emitColor= extra*vec3(0.5,0.1,0.0);
    //donut.mat.surfaceEmit=0.5*extra2*vec3(0.3,0.3,0.0);
    //donut.mat.specularChance=0.05;
    //donut.mat.specularColor=vec3(1.)-donut.mat.absorbColor/3.;
    donut.mat.refractionChance=0.0;
    donut.mat.subSurface=true;
    donut.mat.meanFreePath=0.02;
    donut.mat.isotropicScatter=extra3;
    donut.mat.roughness=0.0;






    layerDonut.inner=donut;
    layerDonut.outer=donut;

    layerDonut.outer.thickness=0.3;
    layerDonut.outer.mat=makeGlass(vec3(0.),1.4);
    layerDonut.outer.mat.specularChance=0.05;

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


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, layerDonut);
}




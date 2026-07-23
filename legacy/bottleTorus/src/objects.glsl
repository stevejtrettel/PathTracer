//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/bottleTorus.glsl

//set the names of objects contained in the scene
BottleTorus donut;

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


    donut.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.6,1.);
    //alternate material experiments:
    //donut.mat.surf.diffuse=0.6*(vec3(1.)-4.*vec3(0.2,0.03,0.0));
    //donut.mat.interior.absorb= 4.*0.01*vec3(0.2,0.04,0.0);
    //donut.mat.interior.emit= scratch1*vec3(0.5,0.1,0.0);
    //donut.mat.surf.emit=0.5*scratch2*vec3(0.3,0.3,0.0);
    //donut.mat.surf.gloss=0.05;
    //donut.mat.surf.specular=vec3(1.)-donut.mat.interior.absorb/3.;
    donut.mat.surf.transmit=1.;
    donut.mat.interior.mfp=0.02;
    donut.mat.interior.blur=sssScatter;
    donut.mat.surf.roughness=0.0;

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
    dist=min( dist, sdf(tv, donut) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,donut);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, donut);
}

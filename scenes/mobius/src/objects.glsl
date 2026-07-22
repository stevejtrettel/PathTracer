//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/multiMaterial/mobius.glsl


//set the names of objects contained in the scene
Mobius mobius, mobius2;

void buildObjects(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);



    mobius.frame=makeFrame(vec3(-5,1.5,-2));
    mobius.twists=1.;
    mobius.radius=1.;
    mobius.width =0.4;
    mobius.thickness=0.04;
    mobius.offset=false;
    //alternate material:
    //mobius.borderMat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,sssDensity);

    mobius.bandMat=makeGlass(30.*(0.75*brownAbsorb+0.5*redAbsorb),1.5,0.99);
    mobius.bandMat.refractionChance=0.;
    mobius.bandMat.subSurface=true;
    mobius.bandMat.meanFreePath=0.2*sssDensity;
    mobius.bandMat.isotropicScatter=sssScatter;
    mobius.bandMat.roughness=0.7;

    //alternate material:
    //mobius.borderMat=makeMetal(vec3(0.02),specularity,0.4);
    mobius.borderMat=makeGlass(10.*(brownAbsorb+0.25*redAbsorb),1.5,0.99);
    mobius.borderMat.refractionChance=0.;
    mobius.borderMat.subSurface=true;
    mobius.borderMat.meanFreePath=0.05;
    mobius.borderMat.isotropicScatter=0.4;
    mobius.borderMat.roughness=0.3;


    mobius2.frame=makeFrame(vec3(-5,1.5,-2));
    mobius2.twists=1.;
    mobius2.radius=1.;
    mobius2.width =0.4;
    mobius2.thickness=0.04;
    mobius2.offset=true;

    //alternate material:
    //mobius2.bandMat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.1,sssDensity);
    mobius2.bandMat=makeGlass(20.*vec3(1,0.6,0.3),1.5,0.99);
    mobius2.bandMat.refractionChance=0.;
    mobius2.bandMat.subSurface=true;
    mobius2.bandMat.meanFreePath=0.2*sssDensity;
    mobius2.bandMat.isotropicScatter=sssScatter;
    mobius2.bandMat.roughness=0.7;

    mobius2.borderMat=makeGlass(0.5*vec3(1,0.6,0.3),1.5,0.99);
    mobius2.borderMat.refractionChance=0.;
    mobius2.borderMat.subSurface=true;
    mobius2.borderMat.meanFreePath=0.1;
    mobius2.borderMat.isotropicScatter=0.6;
    mobius2.borderMat.roughness=0.3;
    //alternate material:
    //makeMetal(vec3(0.2),specularity,0.4);


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
    dist=min( dist, sdf(tv, mobius) );
    dist=min( dist, sdf(tv, mobius2) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,mobius)||inside(tv,mobius2);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, mobius);
    setData(path, mobius2);
}

//no curved-light medium in this scene (n === 1 everywhere: straight transport).
//A medium scene overrides this with its effective refractive index field.
float indexField(vec3 p){ return 1.; }

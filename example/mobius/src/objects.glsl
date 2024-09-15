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
    vec3 whiskey=vec3(0.18,0.43,0.62);



    mobius.center=vec3(-5,1.5,-2);
    mobius.twists=1.;
    mobius.radius=1.;
    mobius.width =0.4;
    mobius.thickness=0.04;
    mobius.offset=false;
    //mobius.borderMat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,extra2);

    mobius.bandMat=makeGlass(30.*(0.75*brownAbsorb+0.5*redAbsorb),1.5,0.99);
    mobius.bandMat.refractionChance=0.;
    mobius.bandMat.subSurface=true;
    mobius.bandMat.meanFreePath=0.2*extra2;
    mobius.bandMat.isotropicScatter=extra;
    mobius.bandMat.roughness=0.7;

    //mobius.borderMat=makeMetal(vec3(0.02),specularity,0.4);
    mobius.borderMat=makeGlass(10.*(brownAbsorb+0.25*redAbsorb),1.5,0.99);
    mobius.borderMat.refractionChance=0.;
    mobius.borderMat.subSurface=true;
    mobius.borderMat.meanFreePath=0.05;
    mobius.borderMat.isotropicScatter=0.4;
    mobius.borderMat.roughness=0.3;


    mobius2.center=vec3(-5,1.5,-2);
    mobius2.twists=1.;
    mobius2.radius=1.;
    mobius2.width =0.4;
    mobius2.thickness=0.04;
    mobius2.offset=true;

    //mobius2.bandMat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.1,extra2);
    mobius2.bandMat=makeGlass(20.*vec3(1,0.6,0.3),1.5,0.99);
    mobius2.bandMat.refractionChance=0.;
    mobius2.bandMat.subSurface=true;
    mobius2.bandMat.meanFreePath=0.2*extra2;
    mobius2.bandMat.isotropicScatter=extra;
    mobius2.bandMat.roughness=0.7;

    mobius2.borderMat=makeGlass(0.5*vec3(1,0.6,0.3),1.5,0.99);
    mobius2.borderMat.refractionChance=0.;
    mobius2.borderMat.subSurface=true;
    mobius2.borderMat.meanFreePath=0.1;
    mobius2.borderMat.isotropicScatter=0.6;
    mobius2.borderMat.roughness=0.3;
    //makeMetal(vec3(0.2),specularity,0.4);


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


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, mobius);
    setData(path, mobius2);
}




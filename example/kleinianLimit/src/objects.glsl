//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/kleinian.glsl

//set the names of objects contained in the scene
Kleinian klein;

void buildObjects(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);

    klein.center=vec3(0,0,-3);
    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    //klein.mat=makeDielectric(color,specularity,roughness);

    klein.mat=makeGlass(7.*vec3(0.4,0.25,0.05),1.5,0.95);
    //klein.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    //makeGlass(7.*vec3(0.5,0.1,0.05),1.5,0.95);
    //makeGlass(3.*vec3(0.3,0.05,0.2),1.5,0.95);

    //klein.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

    // klein.mat.diffuseColor=vec3(1);
    //klein.mat.absorbColor=vec3(0.1);
    //vec3(1)-0.9*vec3(0,0.65,0.35);
    //klein.mat.emitColor =  0.4*extra2*vec3(1.,0.15,0.);
    //klein.mat.surfaceEmit =  0.1*extra3*vec3(0.75,0.25,0.);
    //vec3(0.01);
    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    klein.mat.refractionChance=0.;
    klein.mat.subSurface=true;
    klein.mat.meanFreePath=0.5*extra2;
    klein.mat.isotropicScatter=extra;
    klein.mat.roughness=0.04;


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
    dist=min( dist, sdf(tv, klein) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,klein);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, klein);
}




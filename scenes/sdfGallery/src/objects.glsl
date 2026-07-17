#include ../../../glsl/objects/sdf_gallery/object.glsl;

//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Object obj;

void buildObjects(){

    vec3 blueGlass = vec3(0.1,0.9,0.8);
    vec3 tealScatter = vec3(0.25,0.65,0.7);
    vec3 magentaGlass = vec3(0.3,0.05,0.2);

    obj.frame=makeFrame(vec3(0,-0.4,0));
    //alternate materials:
    //obj.mat=makeDielectric(vec3(0.6,0.55,0.5),0.2,0.5);


    //vec3 ice=vec3(1,0.8,0.5);
    vec3 ivory = vec3(0.75,0.85,1);
    obj.mat=makeGlass(1.*ivory,1.5,0.95);
//alternate materials:
//    obj.mat=makeGlass(tealScatter,1.5,0.95);

    obj.mat.refractionChance=0.;
    obj.mat.subSurface=true;
    obj.mat.meanFreePath=0.5*scratch2;
    obj.mat.isotropicScatter=scratch1;
    obj.mat.roughness=scratch3;

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
    dist=min( dist, sdf(tv, obj) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    //return false;
    return inside(tv,obj);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, obj);
}




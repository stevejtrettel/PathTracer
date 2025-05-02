#include ../../../glsl/objects/sdf_gallery/object.glsl;

//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Object obj;

void buildObjects(){

    vec3 blueGlass = vec3(0.1,0.9,0.8);
    vec3 pinkScatter = vec3(0.25,0.65,0.7);
    vec3 greenGlass = vec3(0.3,0.05,0.2);

    obj.center=vec3(0,1.25,0);
    //obj.mat=makeDielectric(vec3(0.6,0.55,0.5),0.2,0.5);


    //vec3 ice=vec3(1,0.8,0.5);
    vec3 ivory = vec3(0.75,0.85,1);
    obj.mat=makeGlass(1.*ivory,1.5,0.95);




//    obj.mat=makeGlass(pinkScatter,1.5,0.95);


    obj.mat.refractionChance=0.;
    obj.mat.subSurface=true;
    obj.mat.meanFreePath=0.5*extra2;
    obj.mat.isotropicScatter=extra;
    obj.mat.roughness=extra3;

//    //make the bunny glow
//    sphere.mat.diffuseColor=vec3(1);
//    sphere.mat.absorbColor=vec3(0.1);
//    sphere.mat.emitColor =  0.4*extra2*vec3(1.,0.15,0.);
//    sphere.mat.surfaceEmit =  0.1*extra3*vec3(0.75,0.25,0.);

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


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, obj);
}




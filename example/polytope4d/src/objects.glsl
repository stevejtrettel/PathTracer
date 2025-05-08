#include ../../../glsl/objects/polytopes/Polytope4D.glsl


//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Polytope4D poly;

void buildObjects(){

    set120Cell(poly);
    poly.center = vec3(0,1,0);
//    poly.vertexRad = 0.1;
//
//
//    vec3 pinkScatter = vec3(0.25,0.65,0.7);
//    vec3 greenGlass = vec3(0.3,0.05,0.2);
//
//    sphere.center=vec3(0,1.2,0);
//    sphere.radius=2.;
//
//    sphere.mat=makeGlass(greenGlass,1.5,0.95);

//    sphere.mat.refractionChance=0.;
//    sphere.mat.subSurface=true;
//    sphere.mat.meanFreePath=0.5*extra2;
//    sphere.mat.isotropicScatter=extra;
//    sphere.mat.roughness=0.0;

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
    dist=min( dist, sdf(tv, poly) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //return inside(tv,sphere);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, poly);
}




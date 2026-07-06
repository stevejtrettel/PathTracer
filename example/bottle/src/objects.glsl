//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/bottle.glsl;


//set the names of objects contained in the scene
Bottle bottle;

void buildObjects(){

    bottle.frame=makeFrame(vec3(1,0.48,2));
    bottle.baseHeight=1.5;
    bottle.baseRadius=1.25;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.1;
    bottle.rounded=0.1;
    bottle.smoothJoin=0.3;
    bottle.bump=1.;

    vec3 purpleScatter = vec3(0.25,0.65,0.4);
    vec3 greenGlass = vec3(0.3,0.05,0.2);

    bottle.mat=makeGlass(1.5*purpleScatter,1.5,0.95);
    bottle.mat.refractionChance=0.;
    bottle.mat.subSurface=true;
    bottle.mat.meanFreePath=0.5*extra2;
    bottle.mat.isotropicScatter=extra;
    bottle.mat.roughness=0.0;

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
    dist=min( dist, sdf(tv, bottle) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,bottle);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, bottle);
}




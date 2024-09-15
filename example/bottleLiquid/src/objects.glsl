//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/bottle.glsl;
#include ../../../glsl/objects/multiMaterial/bottleLiquid.glsl;

//set the names of objects contained in the scene
Bottle bottle;
BottleLiquid gin;

void buildObjects(){

    bottle.center=vec3(1,0.48,2);
    bottle.baseHeight=1.5;
    bottle.baseRadius=1.25;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.1;
    bottle.rounded=0.1;
    bottle.smoothJoin=0.3;
    bottle.bump=1.;
    bottle.mat=makeGlass(0.5*vec3(0.3,0.05,0.08),1.5,0.92);
    //makeGlass(0.1*vec3(0.3,0.05,0.08),1.5,0.99);

    //set up the bounding sphere
    bottle.boundingBox.center=bottle.center;
    bottle.boundingBox.radius=bottle.baseHeight+bottle.neckHeight+0.5;


    //-------- GIN BOTTLE ----------------
    gin.glass=bottle;
    gin.cup = bottle.mat;
    gin.drink=makeGlass(vec3(0.1,0.05,0.),1.3,0.99);
    gin.fill=0.6;

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
    dist=min( dist, sdf(tv, gin) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //return inside(tv,bottle);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, gin);
}




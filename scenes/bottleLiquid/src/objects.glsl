//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/bottle.glsl
#include ../../../glsl/objects/multiMaterial/bottleLiquid.glsl

//set the names of objects contained in the scene
Bottle bottle;
BottleLiquid gin;

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
    bottle.mat=makeGlass(0.5*vec3(0.3,0.05,0.08),1.5,0.92);
    //alternate: makeGlass(0.1*vec3(0.3,0.05,0.08),1.5,0.99);


    //-------- GIN BOTTLE ----------------
    gin.glass=bottle;
    gin.cup = bottle.mat;
    gin.drink=makeGlass(vec3(0.1,0.05,0.),1.3,0.99);
    gin.fill=0.6;

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
    dist=min( dist, sdf(tv, gin) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //alternate: sssScatter inside the bottle
    //return inside(tv,bottle);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, gin);
}

//no curved-light medium in this scene (n === 1 everywhere: straight transport).
//A medium scene overrides this with its effective refractive index field.
float indexField(vec3 p){ return 1.; }

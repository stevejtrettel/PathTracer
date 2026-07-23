//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/bottle.glsl


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

    vec3 greenScatter = vec3(0.25,0.65,0.4);

    bottle.mat=makeGlass(1.5*greenScatter,1.5,1.);
    bottle.mat.surf.transmit=1.;
    bottle.mat.interior.mfp=0.5*sssDensity;
    bottle.mat.interior.blur=sssScatter;
    bottle.mat.surf.roughness=0.0;

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


void setData_Objects(inout Path path){
    setData(path, bottle);
}

//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list!
#include ../../../glsl/objects/varieties/formulas/cubics.glsl

T surfBox_Eqn(T x, T y, T z){
    return myCubic(x,y,z);
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/surfBox.glsl


//set the names of objects contained in the scene
SurfBox surf;

void buildObjects(){

    vec3 red = vec3(1,0,0);

    surf.frame = makeFrame(vec3(-2,1.5,-2));
    surf.box = vec3(1,1,1);
    surf.scale=10.;
    surf.mat=makeDielectric(red,0.5,0.2);


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
    dist=min( dist, sdf(tv, surf) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, surf);
}

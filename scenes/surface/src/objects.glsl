//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list!
T surface_Eqn(T x, T y, T z){
    return gyroid(x,y,z);
}

float surface_bBox(vec3 pos){
    return length(pos)-2.;
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/surface.glsl

//set the names of objects contained in the scene
Surface surf;

void buildObjects(){

    vec3 pinkScatter = vec3(0.25,0.65,0.7);

    surf.center=vec3(-2,1.5,-2);
    surf.scale=10.;
    surf.mat=makeDielectric(pinkScatter,0.5,0.2);

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
    dist=min( dist, sdf(tv, surf) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //return inside(tv,var);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, surf);
}




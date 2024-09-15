//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list!
T varSphere_Eqn(T x, T y, T z){
    return gyroid(x,y,z);
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/varSphere.glsl


//set the names of objects contained in the scene
VarSphere var;

void buildObjects(){

    vec3 pinkScatter = vec3(0.25,0.65,0.7);

    var.center=vec3(-2,1.5,-2);
    var.radius = 2.;
    var.smoothing =0.065;
    var.scale=10.;
    var.thickness = vec2(0.0075,0.0);

    var.mat=makeGlass(30.*pinkScatter,1.5,0.99);
    var.mat.refractionChance=0.;
    var.mat.subSurface=true;
    var.mat.meanFreePath=0.2*extra2;
    var.mat.isotropicScatter=extra;
    var.mat.roughness=0.7;

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
    dist=min( dist, sdf(tv, var) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,var);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, var);
}




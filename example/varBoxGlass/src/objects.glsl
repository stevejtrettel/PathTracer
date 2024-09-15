//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list!
T varBox_Eqn(T x, T y, T z){
    return gyroid(x,y,z);
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/varBox.glsl
#include ../../../glsl/objects/multiMaterial/varBoxGlass.glsl

//set the names of objects contained in the scene
VarBox var;
VarBoxGlass marble;

void buildObjects(){

    vec3 pinkScatter = vec3(0.25,0.65,0.7);
    vec3 greenGlass = vec3(0.3,0.05,0.2);

    var.center=vec3(-2,1.5,-2);
    var.box = vec3(1,1,1);
    var.smoothing =0.065;
    var.scale=5.;
    var.thickness = vec2(0.0075,0.0);

    var.mat=makeGlass(30.*pinkScatter,1.5,0.99);
    var.mat.refractionChance=0.;
    var.mat.subSurface=true;
    var.mat.meanFreePath=0.5*extra2;
    var.mat.isotropicScatter=extra;
    var.mat.roughness=0.0;

    //make a glass material:
    Material glassMat = makeGlass(0.2*greenGlass,1.25,0.98);

    //now that we've created the variety, make the marble
    marble = createVarBoxGlass(var, glassMat);

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
    dist=min( dist, sdf(tv, marble) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,marble);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, marble);
}




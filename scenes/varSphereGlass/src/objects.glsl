//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list!
#include ../../../glsl/objects/varieties/formulas/barthSextic.glsl

T varSphere_Eqn(T x, T y, T z){
    return barthSextic(x,y,z);
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/varSphere.glsl
#include ../../../glsl/objects/multiMaterial/varSphereGlass.glsl

//set the names of objects contained in the scene
VarSphere var;
VarSphereGlass marble;

void buildObjects(){

    vec3 tealScatter = vec3(0.25,0.65,0.7);
    vec3 magentaGlass = vec3(0.3,0.05,0.2);

    var.frame = makeFrame(vec3(-2,1.5,-2));
    var.radius = 2.;
    var.smoothing =0.065;
    var.scale = 0.9;
    var.thickness = vec2(0.0075,0.0);

    var.mat=makeGlass(30.*tealScatter,1.5,0.99);
    var.mat.refractionChance=0.;
    var.mat.subSurface=true;
    var.mat.meanFreePath=0.2*sssDensity;
    var.mat.isotropicScatter=sssScatter;
    var.mat.roughness=0.7;

    //make a glass material:
    Material glassMat = makeGlass(0.2*magentaGlass,1.25,0.98);

    //now that we've created the variety, make the marble
    marble = createVarSphereGlass(var, glassMat);

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


void setData_Objects(inout Path path){
    setData(path, marble);
}




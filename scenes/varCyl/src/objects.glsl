//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list!
#include ../../../glsl/objects/varieties/formulas/misc.glsl

T varCyl_Eqn(T x, T y, T z){
    return gyroid(x,y,z);
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/varCyl.glsl
//set the names of objects contained in the scene
VarCyl var;


void buildObjects(){

    vec3 tealScatter = vec3(0.25,0.65,0.7);

    var.frame = makeFrame(vec3(-2,1.5,-2));
    var.cyl = vec2(1,1);
    var.smoothing =0.065;
    var.scale=10.;
    var.thickness = vec2(0.0075,0.0);

    var.mat=makeGlass(30.*tealScatter,1.5,1.);
    var.mat.surf.transmit=1.;
    var.mat.interior.mfp=0.2*sssDensity;
    var.mat.interior.blur=sssScatter;
    var.mat.surf.roughness=0.7;

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


void setData_Objects(inout Path path){
    setData(path, var);
}

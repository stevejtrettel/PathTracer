//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


//need to choose a variety equation from our list! #include its formula file
//(see glsl/objects/varieties/formulas/) and return it below.
#include ../../../glsl/objects/varieties/formulas/cubics.glsl

T var_Eqn(T x, T y, T z){
    //alternate varieties (add the matching #include to use):
   // return goldman(x,y,z);          // formulas/misc.glsl
    //return romanSurfaceVar(x,y,z);  // formulas/gallery.glsl
    return myCubic(x,y,z);
}

float var_bBox(vec3 pos){
    //pos is already centered at origin
    return length(pos)-2.;
}

//now that we have chosen an equation, can build the variety struct with it
#include ../../../glsl/objects/varieties/variety.glsl


//set the names of objects contained in the scene
Variety var;

void buildObjects(){

    vec3 tealScatter = vec3(0.25,0.65,0.7);

    var.frame = makeFrame(vec3(-2,1.5,-2));
    var.smoothing =0.065;
    var.scale=5.;
    var.thickness = vec2(0.0075,0.0);

    var.mat=makeGlass(30.*tealScatter,1.5,0.99);
    var.mat.refractionChance=0.;
    var.mat.subSurface=true;
    var.mat.meanFreePath=0.1;
    //alternate: drive from the scratch sliders
    //0.2*scratch2;
    var.mat.isotropicScatter=0.7;
    //alternate: drive from the scratch sliders
    //scratch1;
    var.mat.roughness=0.7;

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

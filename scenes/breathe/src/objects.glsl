//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/breathe.glsl

//set the names of objects contained in the scene
Breathe form;

void buildObjects(){

    form.frame = makeFrame(vec3(0,0,0));

    //the deform knob (named GUI param): breathing phase
    //(0.5 = the shadertoy's still pose; sweep 0->1 for the full cycle)
    form.time = breath;

    //opaque material (set to taste). the sdf's orbit trap is available via
    //orbitTrap() if you want to color it in a recolor followup.
    form.mat = makeDielectric(vec3(0.85, 0.62, 0.52), 0.15, 0.3);

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
    dist=min( dist, sdf(tv, form) );
    return dist;
}


//used in subsurface scattering: keep scattering while inside this object
bool inside_Object( Vector tv ){
    return inside(tv,form);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, form);
}

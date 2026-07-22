//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/bunny.glsl

//set the names of objects contained in the scene
Bunny bunny;


void buildObjects(){

    vec3 magentaGlass = vec3(0.3,0.05,0.2);

    bunny.frame=makeFrame(vec3(0,0,0));
    bunny.scale=2.;

    bunny.mat=makeGlass(magentaGlass,1.5,1.);

    bunny.mat.surf.transmit=1.;
    bunny.mat.interior.mfp=0.5*sssDensity;
    bunny.mat.interior.blur=sssScatter;
    bunny.mat.surf.roughness=0.0;

//    //alternate: emissive bunny — make the bunny glow
//    bunny.mat.surf.diffuse=vec3(1);
//    bunny.mat.interior.absorb=vec3(0.1);
//    bunny.mat.interior.emit =  0.4*sssDensity*vec3(1.,0.15,0.);
//    bunny.mat.surf.emit =  0.1*scratch3*vec3(0.75,0.25,0.);

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
    dist=min( dist, sdf(tv, bunny) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,bunny);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, bunny);
}

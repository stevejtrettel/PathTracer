//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Sphere sphere;


void buildObjects(){

    vec3 magentaGlass = vec3(0.3,0.05,0.2);

    sphere.frame=makeFrame(vec3(0,1.2,0));
    sphere.radius=2.;

    sphere.mat=makeGlass(magentaGlass,ior,1.);

//alternate materials:
//    sphere.mat.surf.transmit=1.;
//    sphere.mat.interior.mfp=0.5*scratch2;
//    sphere.mat.interior.blur=scratch1;
//    sphere.mat.surf.roughness=0.0;

}



//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,sphere));
    return dist;
}

float sdf_Objects( Vector tv ){

    float dist=maxDist;
   //alternate: raymarch instead of the analytic trace
   // dist=min( dist, sdf(tv, sphere) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    //return false;
    return inside(tv,sphere);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, sphere);
}

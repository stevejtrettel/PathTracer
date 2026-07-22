//-------------------------------------------------
// THE SCENE
// this takes in the following functions, defined for each individual scene;
// buildEnvironment() sdf_Environment() trace_Environment() setData_Environment()
// buildObjects() sdf_Objects() trace_Objects() setData_Objects()
// inside_Object() — objects only, called directly by the medium walk
//   (6Trace/mediumWalk.glsl); not aggregated here since there is no
//   environment analogue (subsurface happens inside objects, not walls).
//-------------------------------------------------


//-------------------------------------------------
//Building the Scene
//-------------------------------------------------

void buildScene(){
    buildEnvironment();
    buildObjects();
}


//-------------------------------------------------
//Building the SDF
//-------------------------------------------------

float sdf_Scene( Vector tv ){
    float dist=maxDist;

    dist=min(dist, sdf_Environment( tv ));
    dist=min(dist, sdf_Objects( tv ));

    return dist;

}



//-------------------------------------------------
//Setting Up the RayTrace
//-------------------------------------------------

float trace_Scene( Vector tv ){
    float dist=maxDist;

    dist = min(dist, trace_Environment(tv));
    dist = min( dist, trace_Objects(tv) );

    return dist;
}



//-------------------------------------------------
//Setting Data Upon Reaching an Object
//-------------------------------------------------

void setData_Scene(inout Path path){

    //need to set this data first!
    setData_Objects(path);
    setData_Environment(path);

}

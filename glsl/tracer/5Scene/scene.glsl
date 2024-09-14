//-------------------------------------------------
// THE SCENE
// this assumes we've already included environment and objects
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

    if(render_Environment){
        dist=min(dist, sdf_Environment( tv ));
    }

    if(render_Objects){
        dist=min(dist, sdf_Objects( tv ));
    }
    //if we had to march walls or lights; would add them here
    // but right now all those are simple objects: we trace them

    return dist;

}



//-------------------------------------------------
//Setting Up the RayTrace
//-------------------------------------------------

float trace_Scene( Vector tv ){

    float dist=maxDist;

    if(render_Environment){
        dist = min(dist, trace_Environment(tv));
    }

    if(render_Objects){
        dist = min( dist, trace_Objects(tv) );
    }

    return dist;
}



//-------------------------------------------------
//Setting Data Upon Reaching an Object
//-------------------------------------------------

void setData_Scene(inout Path path){

    //need to set this data first!
    if(render_Objects){
        setData_Objects(path);
    }

    if(render_Environment){
        setData_Environment(path);
    }


}

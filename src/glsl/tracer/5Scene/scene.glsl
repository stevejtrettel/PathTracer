//-------------------------------------------------
// THE SCENE
// collects all the pieces of the scene from other files to combine
// this contains buildScene, sceneSDF, sceneTrace, and setDataScene
//-------------------------------------------------


//include the scene we are currently drawing:
#include ../../../scenes/sceneShader.glsl

//-------------------------------------------------
//Building the Scene
//-------------------------------------------------

void buildScene(){
    buildWalls();
    buildLights();
    buildObjects();
}


//-------------------------------------------------
//Building the SDF
//-------------------------------------------------

float sdf_Scene( Vector tv ){
    float dist=maxDist;

    if(render_Objects){
        dist=min(dist, sdf_Objects( tv ));
    }

    if(render_Lights){
        dist=min(dist, sdf_Lights( tv ));
    }

    if(render_Walls){
        dist=min(dist, sdf_Walls( tv ));
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

    if(render_Lights){
        setData_Lights(path);
    }

    if(render_Walls){
        setData_Walls(path);
    }

}

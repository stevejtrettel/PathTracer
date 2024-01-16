//-------------------------------------------------
// RAYMARCH
// this function raymarches a scene
// this does NOT update the path, and just gives the distance to an object
//-------------------------------------------------

float raymarch(Vector tv, float stopDist){

    float totalDist=0.;
    float distToScene=0.;
    float marchFactor=0.9;

    for (int i = 0; i < maxMarchSteps; i++){

        distToScene = abs(sdf_Scene( tv ));

        if (distToScene< EPSILON){
            return totalDist+distToScene;
        }

        //slow down the march as it is not exact
        distToScene *= marchFactor;
        totalDist += distToScene;

        if(totalDist>stopDist){
            //break out of loop
            return stopDist;
        }

        //otherwise keep going
        flow(tv, distToScene);
    }

    //if you hit nothing
    return stopDist;
}







//-------------------------------------------------
// RAYMARCH
// this function raymarches a scene
// and updates if a material is intersected within a specified threshhold
//-------------------------------------------------

float raymarch(Path path, float stopDist){

    float totalDist=0.;
    float distToScene=0.;
    float marchFactor=0.9;

    for (int i = 0; i < maxMarchSteps; i++){

        distToScene = abs(sceneSDF(path));

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
        flow(path.tv, distToScene);
    }

    //if you hit nothing
    path.keepGoing=false;
    return stopDist;
}







//-------------------------------------------------
// RAYMARCH
// this function raymarches a scene
// and updates if a material is intersected within a specified threshhold
//-------------------------------------------------

float raymarch(inout Path path, float stopDist){

    float totalDist=0.;
    float distToScene=0.;

    for (int i = 0; i < maxMarchSteps; i++){

        distToScene =abs(sceneSDF(path));

        if (distToScene< EPSILON){
            path.pixel+=vec3(0,0,1);
            return totalDist;
        }

        totalDist += distToScene;

        if(totalDist>stopDist){
            //break out of loop
            path.pixel+=vec3(1,0,0);
            return maxDist;
        }

        //otherwise keep going
        flow(path.tv, distToScene);
    }

    //if you hit nothing
    path.dat.isSky=true;
    path.keepGoing=false;
    return maxDist;
}




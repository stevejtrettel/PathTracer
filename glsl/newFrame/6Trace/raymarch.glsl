//-------------------------------------------------
// RAYMARCH
// this function raymarches a scene
// and updates if a material is intersected within a specified threshhold
//-------------------------------------------------



float raymarch(Vector tv, inout localData dat){

    float distToScene=0.;
    float totalDist=0.;

    float factor=0.8;
    float marchDist;


    for (int i = 0; i < maxMarchSteps; i++){

        distToScene =abs(sceneSDF(tv,dat));
        marchDist=factor*distToScene;

        if (distToScene< EPSILON){
            return totalDist;
        }

        totalDist += marchDist;

        if(totalDist>maxDist){
            break;
        }

        //otherwise keep going
        flow(tv, marchDist);
    }

    //if you hit nothing
    dat.isSky=true;
    return maxDist;
}




//-------------------------------------------------
// The RAYMARCHING LOOP: FOR SDFS
//-------------------------------------------------


float raymarch(inout Vector tv, inout localData dat){

    float distToScene=0.;
    float totalDist=0.;

    float factor=0.8;
    float marchDist;

    Vector temp=tv;

    for (int i = 0; i < maxMarchSteps; i++){

        distToScene =abs(sceneSDF(temp,dat));
        marchDist=factor*distToScene;

        if (distToScene< EPSILON){
            flow(tv,totalDist);
            return totalDist;
        }

        totalDist += marchDist;

        if(totalDist>maxDist){
            break;
        }

        //otherwise keep going
        flow(temp, marchDist);
    }

    //if you hit nothing
    dat.isSky=true;
    flow(tv,maxDist);
    return maxDist;
}


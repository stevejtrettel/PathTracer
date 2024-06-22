//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------

//void stepForward(inout Path path){
//
//    float distance;
//    //do the raymarching, move to the next point of intersection
//    raymarch( path.tv, distance);
//
//    //update the distance traveled
//    path.distance=distance;
//    path.totalDistance+=distance;
//
//    //check if we hit the sky: if not, set the data from our intersection point.
//    path.dat.isSky=(path.distance>maxDist-0.1);
//    if(!path.dat.isSky){
//        setData_Scene(path);
//    }
//
//}



void binarySearch( inout Vector tv, inout float dt){
    float dist=0.;
    //you are outside, but flowing by dt is inside
    //dt is small enough the path is treated as linear: so we use flowLinear
    float testDist=dt;
    Vector temp;

    //get the sign (+ or -) of the scene distance where you start.
    float origSgn = sdf_Scene( tv );

    for(int i=0;i<10;i++){

        //divide the step size in half
        testDist=testDist/2.;

        //test flow by that amount:
        temp=tv;
        flow(temp, dist+testDist);

        //if you are still on the same side, add the dist
        //multiplying the two signs gives + if both are (-) or both are (+); so same side
        if(origSgn*sdf_Scene(temp)>0.){
            dist+=testDist;
        }
        //if not, then don't add: divide in half and try again
    }

    //set dt to the correct amount, and flow by this
    dt = dist-EPSILON/2.;
    flow(tv,dt);
}




void stepAlong(inout Vector tv, out float distance){

    distance = 0.;

    //get the sign (+ or -) of the scene distance where you start.
    float origSgn = sdf_Scene( tv );
    float dt;
    float defaultDT = 0.1;
    Vector temp = tv;
    trashBool=false;
    for (int i = 0; i < maxMarchSteps; i++){

        //start marching along using euler and our dt step size:
        dt = setDT(temp, defaultDT);
        odeStep(temp, dt);

        //if we hit the event horizon, stop:
        if(stopODE(temp)){
            return;
        }

        //see if we went inside an object: if so, do a binary search
        //this moves tv to the correct location and resets dt accordingly
        if(origSgn*sdf_Scene(temp)<0.){
            binarySearch(tv, dt);
            distance += dt;
            return;
        }

        //if we did not, then its safe to keep moving: so set tv to new location, update distance
        distance += dt;
        tv = temp;
    }

    //if you hit nothing
    distance = maxDist;
}



void stepForward(inout Path path){

    float distance;
    //do the raymarching, move to the next point of intersection
    stepAlong( path.tv, distance);

//    float testDist = sdf_Scene(path.tv);
//    if(testDist<0.){
//        path.pixel = vec3(0,0,100.*testDist);
//    }
//    else{
//        path.pixel= vec3(100.*testDist,0,0);
//    }
//    path.keepGoing=false;

    //update the distance traveled
    path.distance=distance;
    path.totalDistance+=distance;

    //check if we hit the sky: if not, set the data from our intersection point.
    path.dat.isSky=(path.distance>maxDist-0.1);
    if(!path.dat.isSky){
        setData_Scene(path);
    }

}

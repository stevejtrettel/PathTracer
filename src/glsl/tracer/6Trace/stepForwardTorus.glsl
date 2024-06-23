//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


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





void stepForward(inout Path path){

    //get the sign (+ or -) of the scene distance where you start.
    float origSgn = sdf_Scene(path.tv);
    path.distance=0.;

    float dt;
    float defaultDT = 0.1;
    Vector temp = path.tv;

    for (int i = 0; i < maxMarchSteps; i++){

        //start marching along:
        dt = 1.;
        //dt = setDT(temp, defaultDT);
        dt = min(dt, sdf_Scene(temp));
        //odeStep(temp, dt);
        flow(temp,dt);

        float torusSize = 10.;
        if(temp.pos.x>torusSize){temp.pos.x -= 2.*torusSize;}
        if(temp.pos.y>torusSize){temp.pos.y -= 2.*torusSize;}
        if(temp.pos.z>torusSize){temp.pos.z -= 2.*torusSize;}
        if(temp.pos.x<-torusSize){temp.pos.x += 2.*torusSize;}
        if(temp.pos.y<-torusSize){temp.pos.y += 2.*torusSize;}
        if(temp.pos.z<-torusSize){temp.pos.z += 2.*torusSize;}

        //if we hit the event horizon, stop:
//        if (stopODE(temp)){
//            path.keepGoing=false;
//            path.pixel=vec3(0);
//            break;
//        }

        //see if we went inside an object: if so, do a binary search
        //this moves tv to the correct location and resets dt accordingly
        if (origSgn*sdf_Scene(temp)<0.){
            binarySearch(path.tv, dt);
            path.distance += dt;
            break;
        }

        //if we did not, then its safe to keep moving: so set tv to new location, update distance
        path.distance += dt;
        path.tv = temp;

    }

    //add to the toal distance traveled
    path.totalDistance+=path.distance;


    //FOG ATTENUATION
    vec3 beersLaw = vec3(0.025)*path.distance;
    if(length(beersLaw)>0.0001){
        path.light *= exp( -beersLaw );
    }

    //check if we hit the sky: if not, set the data from our intersection point.
    path.dat.isSky=(path.distance>maxDist-0.1);
    if (!path.dat.isSky){
        setData_Scene(path);
    }
}

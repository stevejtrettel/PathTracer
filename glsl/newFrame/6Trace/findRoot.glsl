//-------------------------------------------------
// BISECT
// this traces a scene numerically along a ray
// finds the nearest intersection, and updates if this is before a given threshhold.
// this may use RAYTRACE or RAYMARCH to get to the bounding box.
//-------------------------------------------------


bool changeSign(Vector u, Vector v){
    float x=variety(u);
    float y=variety(v);

    bool change = (x*y>0.) ? true : false;
    return change;
//
//    if(x*y<0.){
//        return true;
//    }
//    return false;
}


void binarySearch(inout Vector tv, inout float dt){
    //given that you just passed changed sign, find the root
    float dist=0.;
    //flowing dist from tv doesnt hit the plane, dist+dt does:
    float testDist=dt;
    Vector temp;
    for(int i=0;i<3;i++){

        //divide the step size in half
        testDist=testDist/2.;

        //test flow by that amount:
        temp=tv;
        flow(temp, dist+testDist);
        //if you are still above the plane, add to distance.
        if(!changeSign(temp,tv)){
            dist+=testDist;
        }
        //if not, then don't add: divide in half and try again

    }

    //step tv ahead by the right ammount;
    flow(tv,dist);

}




float findRoot(Vector tv, float stopDist){
    float depth=0.;
    float dt;

    Vector temp=tv;

    vec3 dir;
    Vector normal;
    float side;

    for (int i = 0; i <500; i++){

        //determine how far to test flow from current location
        dt=0.05;
        //setStepSize(tv);

        //temporarily step forward that distance along the ray
        temp=tv;
        flow(temp,dt);

        //check if we crossed the surface:f
        if(changeSign(temp,tv)){
            //set side based on orig position:
            //side=variety(tv);
            return depth;

            //use a binary search to give exact intersection
            //binarySearch(tv,dt);

            //return the actual distance to the variety
            //return depth+dt;
        }

        //if we didn't cross the surface, move tv ahead by this step
        tv=temp;
        //increase the total distance marched
        depth+=dt;

        //check if we escaped the bounding box
        if(depth>stopDist){
            break;
        }
    }

    //if there are no roots inside the sphere
    return maxDist;
}





float findNearestRoot(Path path, float stopDist){

    return findRoot(path.tv,stopDist);

//    float dist=stopDist;
//    float distToBBox;
//
//    //trace bounding box, see if outside
//    distToBBox=traceBBox(path,stopDist);
//    bool outside=sphereDistance(path.tv,sextic.boundingBox)>0.?true:false;
//
//    //if it is, return this distance
//    if(outside){
//        return min(dist,stopDist);
//    }
//
//    //otherwise, we know from traceBoundingBox how far
//    //we have to look on the interior for a root:
//    dist+=findRoot(path.tv,distToBBox);
//
//    return min(dist,stopDist);

}
//-------------------------------------------------
// BISECT
// this traces a scene numerically along a ray
// finds the nearest intersection, and updates if this is before a given threshhold.
// this may use RAYTRACE or RAYMARCH to get to the bounding box.
//-------------------------------------------------


float setStepSize( Vector tv ){

    float val=variety(tv);
    if(val>5.){
        return 0.2;
    }
    else if(val>1.){
        return 0.05;
    }
    return 0.01;

}

bool changeSign(Vector u, Vector v){
    float x=variety(u);
    float y=variety(v);

    bool change = (x*y<0.) ? true : false;
    return change;
}


float binarySearch(Vector tv, float dt){
    //given that you just passed changed sign, find the root
    float dist=0.;
    //flowing dist from tv doesnt hit the plane, dist+dt does:
    float testDist=dt;
    Vector temp;

    for(int i=0;i<10;i++){

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


    return dist;
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
        dt=setStepSize(tv);

        //temporarily step forward that distance along the ray
        temp=tv;
        flow(temp,dt);

        //check if we crossed the surface:f
        if(changeSign(temp, tv)){
            //use a binary search to give exact intersection
            return depth+binarySearch(tv, dt)-EPSILON/5.;
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
    return stopDist;
}



float bBox(Vector tv){
    vec3 center=vec3(0,0,0.);
    vec3 pos=tv.pos.coords.xyz-center;
    return length(pos)-1.5;
}


float marchBBox(inout Vector tv){

    float distToScene=0.;
    float totalDist=0.;

    float marchDist;

    Vector temp=tv;
    if(bBox(tv)>0.){
        for (int i = 0; i < maxMarchSteps; i++){

            distToScene =bBox(temp);
            marchDist=distToScene;

            if (distToScene< EPSILON){
                flow(tv, totalDist);
                return totalDist;
            }

            totalDist += marchDist;

            if (totalDist>maxDist){
                break;
            }

            //otherwise keep going
            flow(temp, marchDist);
        }

        //if you hit nothing
        flow(tv, maxDist);
        return maxDist;
    }
    else{
        return 0.;
    }
}


float setStepSize(Vector tv){

    float dist=abs(variety(tv));

    if(dist>10.){
        return 0.05;
    }
    else if(dist>1.){
        return 0.01;
    }
    else{
        return 0.0005;
    }
}


bool changeSign(Vector u, Vector v){
    float x=variety(u);
    float y=variety(v);
    if(x*y<0.){
        return true;
    }
    return false;
}


void binarySearch(inout Vector tv,inout float dt){
    //given that you just passed changed sign, find the root
    float dist=0.;
    //flowing dist from tv doesnt hit the plane, dist+dt does:
    float testDist=dt;
    Vector temp;
    for(int i=0;i<20;i++){

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




float findRoot(inout Vector tv, inout localData dat){

    float marchStep = 0.;
    float depth=0.;
    float dt;

    Vector temp=tv;
    vec3 dir;
    Vector normal;
    float side;
    float boundingBox=20.;

    //before beginning the root find, first march tv forward until we hit the bounding box:
    depth=marchBBox(tv);
    //flow(tv,1.5*EPSILON);

    //now look for a zero inside the bounding box
    for (int i = 0; i <2000; i++){

        //determine how far to test flow from current location
        dt=0.01;
        //setStepSize(tv);

        //temporarily step forward that distance along the ray
        temp=tv;
        flow(temp,dt);

        //check if we crossed the surface:f
        if(changeSign(temp,tv)){
            //set side based on orig position:
            side=variety(tv);

            //use a binary search to give exact intersection
            binarySearch(tv,dt);

            //set all the data:
            dir=gradient(tv);
            normal=Vector(tv.pos,dir);
            // setObjectInAir(dat,side,normal,ball3.mat);
            setSurfaceInAir(dat,side,normal,varMat);
            return depth+dt;
        }

        //if we didn't cross the surface, move tv ahead by this step
        tv=temp;
        //increase the total distance marched
        depth+=dt;


        //check if we escaped the bounding box
        if(bBox(tv)>EPSILON){
            //if so, raymarch the scene to see where we get:
            return maxDist;
        }
    }

    //hit nothing
    flow(tv,depth);
    return depth;
}








//
//float findRoot(inout Vector tv, inout localData dat){
//    return 500.;
//}
//


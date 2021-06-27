//-------------------------------------------------
// SUB SURFACE SCATTERING
// this function maybe conceptually belongs in the '3Renderer' folder
// as it updates a path before the next bounce.  But it needs the sdfs
//-------------------------------------------------


float bisect(Vector tv, float dt){
    float dist=0.;
    //you are inside, but flowing by dt is outside
    float testDist=dt;
    Vector temp;

    for(int i=0;i<10;i++){

        //divide the step size in half
        testDist=testDist/2.;

        //test flow by that amount:
        temp=tv;
        flow(temp, dist+testDist);
        //if you are still inside, add the dist
        if(inside_Object(temp)){
            dist+=testDist;
        }
        //if not, then don't add: divide in half and try again

    }
    return dist;
}



void subSurfScatter(inout Path path){

    int scatterSteps=100;
    float depth=0.;

    //length of a mean free path in the material:
    float mfp=0.05;
    float flowDist;

    //set the vector we will carry along for the ride
    Vector tv=path.tv;
    Vector temp=path.tv;
    Vector newDir;

    //do the subsurface scattering for the surface we are at
    for (int i = 0; i < scatterSteps; i++){

        //choose the direction of scatter
        newDir=randomVector(temp.pos);

        temp=newDir;
        //mix(temp,newDir,0.5);

        //update tv's direction
        tv=temp;

        //choose the distance to flow
        flowDist=mfp;
        //to a trial flow of this distance
        flow(temp,flowDist);

        //if we have left the object
        if(!inside_Object(temp)){
            //tv is behind it, temp is in front: with distance flowDist
            //find the distance
            flowDist=bisect(tv,flowDist);
            //flow slightly farther so you get out
            //SHOULD MOVE THIS TO A NEW FUNCTION WHREE WE PICK THE NEW RAY?
            flow(tv,flowDist-EPSILON/2.);
            path.tv=tv;
            path.distance=depth+flowDist;
            path.subSurface=false;
            return;
        }

        //if we are inside still:
        //move ahead to this point:
        tv=temp;
        depth+=flowDist;

    }

    //we got stuck inside the material
    path.keepGoing=false;
}
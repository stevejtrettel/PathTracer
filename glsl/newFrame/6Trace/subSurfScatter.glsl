//-------------------------------------------------
// SUB SURFACE SCATTERING
// this function maybe conceptually belongs in the '3Renderer' folder
// as it updates a path before the next bounce.  But it needs the sdfs....
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

    int scatterSteps=500;
    float depth=0.;
    float flowDist;

    //set the vector we will carry along for the ride
    Vector tv=path.tv;
    Vector temp=path.tv;
    Vector newDir;
    float rough=path.dat.isotropicScatter*path.dat.isotropicScatter;


    flow(path.tv,path.dat.meanFreePath);
    //setObjID(path.tv);

    //do the subsurface scattering for the surface we are at
    for (int i = 0; i < scatterSteps; i++){

        //choose the direction of scatter
        newDir=randomVector(temp.pos);

        temp=mix(temp,newDir,rough);

        //update tv's direction
        tv=temp;

        //choose the distance to flow
        flowDist=path.dat.meanFreePath;
        //to a trial flow of this distance
        flow(temp,flowDist);

        //if we have left the object
        if(!inside_Object(temp)){
            //tv is behind it, temp is in front: with distance flowDist
            //find the distance
            flowDist=bisect(tv,flowDist);
            //flow slightly farther so you get out
            flow(tv,flowDist-EPSILON/2.);
            //set your new data, right back on the surface
            path.tv=tv;
            path.distance=depth+flowDist;
            path.numScatters=float(i);
            path.subSurface=false;
            return;
        }

        //if we are inside still:
        //move ahead to this point:
        tv=temp;
        depth+=flowDist;

        //kill off rays
        roulette(path);
        if(!path.keepGoing){
            break;
        }

    }

    //we got stuck inside the material
    path.numScatters=float(scatterSteps);
    path.distance=depth;
    path.keepGoing=false;
}